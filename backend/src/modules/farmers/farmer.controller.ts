import { Request, Response } from "express";
import {
  createFarmer,
  listFarmers,
  getFarmerById,
  updateFarmer,
  addCropToFarmer,
  getFarmerCrops,
} from "./farmer.service";

/**
 * POST /api/farmers
 * Creates a new farmer profile.
 */
export async function createFarmerHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  try {
    const {
      userId,
      region,
      zone,
      woreda,
      kebele,
      latitude,
      longitude,
      alertEnabled,
    } = req.body;

    if (!userId || typeof userId !== "string") {
      return res.status(400).json({
        message:
          "Missing or invalid required field: 'userId' must be a valid string.",
      });
    }

    const farmer = await createFarmer({
      userId,
      region,
      zone,
      woreda,
      kebele,
      latitude: typeof latitude === "number" ? latitude : undefined,
      longitude: typeof longitude === "number" ? longitude : undefined,
      alertEnabled:
        typeof alertEnabled === "boolean" ? alertEnabled : undefined,
    });

    return res.status(201).json(farmer);
  } catch (error) {
    return res.status(500).json({
      message: "An error occurred while creating the farmer profile.",
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
    return res.status(500).json({
      message: "An error occurred while retrieving farmers.",
    });
  }
}

/**
 * GET /api/farmers/:id
 * Retrieves a specific farmer by their ID.
 */
export async function getFarmerByIdHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  try {
    const id = req.params.id as string;

    if (!id) {
      return res.status(400).json({
        message: "Farmer ID parameter is required.",
      });
    }

    const farmer = await getFarmerById(id);

    if (!farmer) {
      return res.status(404).json({
        message: "Farmer not found.",
      });
    }

    return res.status(200).json(farmer);
  } catch (error) {
    return res.status(500).json({
      message: "An error occurred while retrieving the farmer.",
    });
  }
}

/**
 * PUT /api/farmers/:id
 * Updates an existing farmer's details.
 */
export async function updateFarmerHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  try {
    const id = req.params.id as string;

    if (!id) {
      return res.status(400).json({
        message: "Farmer ID parameter is required.",
      });
    }

    const existingFarmer = await getFarmerById(id);

    if (!existingFarmer) {
      return res.status(404).json({
        message: "Farmer not found.",
      });
    }

    const {
      region,
      zone,
      woreda,
      kebele,
      latitude,
      longitude,
      alertEnabled,
    } = req.body;

    const updatedFarmer = await updateFarmer(id, {
      region,
      zone,
      woreda,
      kebele,
      latitude: typeof latitude === "number" ? latitude : undefined,
      longitude: typeof longitude === "number" ? longitude : undefined,
      alertEnabled:
        typeof alertEnabled === "boolean" ? alertEnabled : undefined,
    });

    return res.status(200).json(updatedFarmer);
  } catch (error) {
    return res.status(500).json({
      message: "An error occurred while updating the farmer profile.",
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
  try {
    const id = req.params.id as string;
    const { cropId } = req.body;

    if (!id) {
      return res.status(400).json({
        message: "Farmer ID parameter is required.",
      });
    }

    if (!cropId || typeof cropId !== "string") {
      return res.status(400).json({
        message:
          "Missing or invalid required field: 'cropId' must be a valid string.",
      });
    }

    const existingFarmer = await getFarmerById(id);

    if (!existingFarmer) {
      return res.status(404).json({
        message: "Farmer not found.",
      });
    }

    const farmerCrop = await addCropToFarmer(id, cropId);

    return res.status(201).json(farmerCrop);
  } catch (error) {
    return res.status(500).json({
      message:
        "An error occurred while associating the crop with the farmer.",
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
  try {
    const id = req.params.id as string;

    if (!id) {
      return res.status(400).json({
        message: "Farmer ID parameter is required.",
      });
    }

    const existingFarmer = await getFarmerById(id);

    if (!existingFarmer) {
      return res.status(404).json({
        message: "Farmer not found.",
      });
    }

    const cropsList = await getFarmerCrops(id);

    return res.status(200).json(cropsList);
  } catch (error) {
    return res.status(500).json({
      message: "An error occurred while retrieving crops for the farmer.",
    });
  }
}