import { Request, Response } from "express";

import {
  createFarmer,
  listFarmers,
  getFarmerById,
  updateFarmer,
  addCropToFarmer,
  getFarmerCrops,
} from "./farmer.service";

import {
  createFarmerSchema,
  updateFarmerSchema,
  farmerIdSchema,
  addFarmerCropSchema,
} from "./farmer.schema";

/**
 * POST /api/farmers
 * Creates a new farmer profile.
 */
export async function createFarmerHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const parsed = createFarmerSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer data",
        details: parsed.error.issues,
      },
    });
  }

  try {
    const farmer = await createFarmer(parsed.data);

    return res.status(201).json(farmer);
  } catch (error: any) {
    console.error("CREATE FARMER ERROR:", error);

    const postgresCode = error?.cause?.code ?? error?.code;

    // User does not exist
    if (postgresCode === "23503") {
      return res.status(404).json({
        error: {
          code: "USER_NOT_FOUND",
          message: "The specified user does not exist.",
          details: [],
        },
      });
    }

    // Farmer already exists for this user
    if (postgresCode === "23505") {
      return res.status(409).json({
        error: {
          code: "FARMER_ALREADY_EXISTS",
          message: "A farmer profile already exists for this user.",
          details: [],
        },
      });
    }

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to create farmer profile",
        details: [],
      },
    });
  }
}

/**
 * GET /api/farmers
 * Retrieves all registered farmers.
 */
export async function listFarmersHandler(
  _req: Request,
  res: Response,
): Promise<Response> {
  try {
    const farmersList = await listFarmers();

    return res.status(200).json(farmersList);
  } catch (error) {
    console.error("LIST FARMERS ERROR:", error);

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to retrieve farmers",
        details: [],
      },
    });
  }
}

/**
 * GET /api/farmers/:id
 * Retrieves a specific farmer by ID.
 */
export async function getFarmerByIdHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const parsed = farmerIdSchema.safeParse(req.params);

  if (!parsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer ID",
        details: parsed.error.issues,
      },
    });
  }

  try {
    const farmer = await getFarmerById(parsed.data.id);

    if (!farmer) {
      return res.status(404).json({
        error: {
          code: "NOT_FOUND",
          message: "Farmer not found",
          details: [],
        },
      });
    }

    return res.status(200).json(farmer);
  } catch (error) {
    console.error("GET FARMER ERROR:", error);

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to retrieve farmer",
        details: [],
      },
    });
  }
}

/**
 * PATCH /api/farmers/:id
 * Updates an existing farmer's details.
 */
export async function updateFarmerHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const idParsed = farmerIdSchema.safeParse(req.params);

  if (!idParsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer ID",
        details: idParsed.error.issues,
      },
    });
  }

  const bodyParsed = updateFarmerSchema.safeParse(req.body);

  if (!bodyParsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer update data",
        details: bodyParsed.error.issues,
      },
    });
  }

  try {
    const existingFarmer = await getFarmerById(idParsed.data.id);

    if (!existingFarmer) {
      return res.status(404).json({
        error: {
          code: "NOT_FOUND",
          message: "Farmer not found",
          details: [],
        },
      });
    }

    const updatedFarmer = await updateFarmer(
      idParsed.data.id,
      bodyParsed.data,
    );

    return res.status(200).json(updatedFarmer);
  } catch (error) {
    console.error("UPDATE FARMER ERROR:", error);

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to update farmer profile",
        details: [],
      },
    });
  }
}

/**
 * POST /api/farmers/:id/crops
 * Maps a crop to a specific farmer.
 */
export async function addCropToFarmerHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const idParsed = farmerIdSchema.safeParse(req.params);

  if (!idParsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer ID",
        details: idParsed.error.issues,
      },
    });
  }

  const cropParsed = addFarmerCropSchema.safeParse(req.body);

  if (!cropParsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid crop data",
        details: cropParsed.error.issues,
      },
    });
  }

  try {
    const existingFarmer = await getFarmerById(idParsed.data.id);

    if (!existingFarmer) {
      return res.status(404).json({
        error: {
          code: "NOT_FOUND",
          message: "Farmer not found",
          details: [],
        },
      });
    }

    const farmerCrop = await addCropToFarmer(
      idParsed.data.id,
      cropParsed.data.cropId,
    );

    return res.status(201).json(farmerCrop);
  } catch (error: any) {
    console.error("ADD CROP TO FARMER ERROR:", error);

    const postgresCode = error?.cause?.code ?? error?.code;

    if (postgresCode === "23505") {
      return res.status(409).json({
        error: {
          code: "CROP_ALREADY_ASSIGNED",
          message: "This crop is already assigned to this farmer.",
          details: [],
        },
      });
    }

    if (postgresCode === "23503") {
      return res.status(404).json({
        error: {
          code: "CROP_NOT_FOUND",
          message: "The specified crop does not exist.",
          details: [],
        },
      });
    }

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to associate crop with farmer",
        details: [],
      },
    });
  }
}

/**
 * GET /api/farmers/:id/crops
 * Retrieves all crops assigned to a specific farmer.
 */
export async function getFarmerCropsHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const parsed = farmerIdSchema.safeParse(req.params);

  if (!parsed.success) {
    return res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid farmer ID",
        details: parsed.error.issues,
      },
    });
  }

  try {
    const existingFarmer = await getFarmerById(parsed.data.id);

    if (!existingFarmer) {
      return res.status(404).json({
        error: {
          code: "NOT_FOUND",
          message: "Farmer not found",
          details: [],
        },
      });
    }

    const cropsList = await getFarmerCrops(parsed.data.id);

    return res.status(200).json(cropsList);
  } catch (error) {
    console.error("GET FARMER CROPS ERROR:", error);

    return res.status(500).json({
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to retrieve crops for farmer",
        details: [],
      },
    });
  }
}