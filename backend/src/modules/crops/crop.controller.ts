import { Request, Response } from "express";

import { createCrop, getAllCrops } from "./crop.service";
import { createCropSchema } from "./crop.schema";

export async function getCrops(_req: Request, res: Response) {
  try {
    const crops = await getAllCrops();

    return res.status(200).json({
      success: true,
      data: crops,
    });
  } catch (error) {
    console.error("GET CROPS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch crops",
    });
  }
}

export async function createCropHandler(req: Request, res: Response) {
  const parsed = createCropSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid crop data",
        details: parsed.error.issues,
      },
    });
  }

  try {
    const crop = await createCrop(parsed.data);

    return res.status(201).json({
      success: true,
      data: crop,
    });
  } catch (error) {
    if (
      error instanceof Error &&
      (error as Error & { code?: string }).code === "CONFLICT"
    ) {
      return res.status(409).json({
        error: {
          code: "CONFLICT",
          message: error.message,
          details: [],
        },
      });
    }

    console.error("CREATE CROP ERROR:", error);

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to create crop",
        details: [],
      },
    });
  }
}