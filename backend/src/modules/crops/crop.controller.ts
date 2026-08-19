import { Request, Response } from "express";
import { getAllCrops } from "./crop.service";

export async function getCrops(_req: Request, res: Response) {
  try {
    const crops = await getAllCrops();

    res.json({
      success: true,
      data: crops,
    });
  } catch (error) {
    console.error("GET CROPS ERROR:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch crops",
    });
  }
}
