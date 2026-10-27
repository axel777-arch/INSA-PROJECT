
import type { Request, Response } from "express";

import {
  createFarmer,
  listFarmers,
  getFarmerById,
  getFarmerByUserId,
  updateFarmer,
  addCropToFarmer,
  getFarmerCrops,
  listFarmerLocations,
} from "./farmer.service";

import { canAccessFarmer } from "./farmer-assignment.service";

import {
  createFarmerSchema,
  updateFarmerSchema,
  farmerIdSchema,
  addFarmerCropSchema,
} from "./farmer.schema";

/**
 * Checks authentication and authorization for a farmer.
 */
async function checkFarmerAccess(
  req: Request,
  farmerId: string,
): Promise<boolean> {
  if (!req.user?.id) {
    return false;
  }

  return canAccessFarmer(
    farmerId,
    req.user.id,
    req.user.role,
  );
}

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

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Authentication is required.",
        details: [],
      },
    });
  }

  try {
    const farmer = await createFarmer({
      ...parsed.data,
      registeredBy: req.user.id,
    });

    return res.status(201).json(farmer);
  } catch (error: any) {
    console.error("CREATE FARMER ERROR:", error);

    const postgresCode = error?.cause?.code ?? error?.code;

    if (postgresCode === "23503") {
      return res.status(404).json({
        error: {
          code: "USER_NOT_FOUND",
          message: "The specified user does not exist.",
          details: [],
        },
      });
    }

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
 * Retrieves farmers the authenticated user is allowed to access.
 */
export async function listFarmersHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Authentication is required.",
        details: [],
      },
    });
  }

  try {
    const farmersList = await listFarmers();

    const accessibleFarmers = await Promise.all(
      farmersList.map(async (farmer) => ({
        farmer,
        allowed: await checkFarmerAccess(req, farmer.id),
      })),
    );

    return res.status(200).json(
      accessibleFarmers
        .filter((item) => item.allowed)
        .map((item) => item.farmer),
    );
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

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHENTICATED",
        message: "Authentication required",
        details: [],
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

    const allowed = await checkFarmerAccess(req, parsed.data.id);

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to access this farmer",
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

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHENTICATED",
        message: "Authentication required",
        details: [],
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

    const allowed = await checkFarmerAccess(req, idParsed.data.id);

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to update this farmer",
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
 * Maps a crop to a farmer the authenticated user can access.
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

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHENTICATED",
        message: "Authentication required",
        details: [],
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

    const allowed = await checkFarmerAccess(req, idParsed.data.id);

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to add crops to this farmer",
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
 * Retrieves crops belonging to an accessible farmer.
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

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHENTICATED",
        message: "Authentication required",
        details: [],
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

    const allowed = await checkFarmerAccess(req, parsed.data.id);

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to view this farmer's crops",
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

/**
 * GET /api/farmers/user/:userId
 * Retrieves a farmer by linked user ID.
 */
export async function getFarmerByUserIdHandler(
  req: Request,
  res: Response,
): Promise<Response> {
  const userId = Array.isArray(req.params.userId)
    ? req.params.userId[0]
    : req.params.userId;

  if (!req.user?.id) {
    return res.status(401).json({
      error: {
        code: "UNAUTHENTICATED",
        message: "Authentication required",
        details: [],
      },
    });
  }

  try {
    // Farmers may retrieve only their own linked profile.
    if (req.user.role === "FARMER" && req.user.id !== userId) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to access this farmer profile",
          details: [],
        },
      });
    }

    const farmer = await getFarmerByUserId(userId);

    if (!farmer) {
      return res.status(404).json({
        error: {
          code: "NOT_FOUND",
          message: "Farmer not found",
          details: [],
        },
      });
    }

    const allowed = await checkFarmerAccess(req, farmer.id);

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to access this farmer profile",
          details: [],
        },
      });
    }

    return res.status(200).json(farmer);
  } catch (error) {
    console.error("GET FARMER BY USER ID ERROR:", error);

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
 * GET /api/farmers/locations
 * Returns geographic positions and crop info for all farmers (for map/dashboard display).
 */
export async function getFarmerLocationsHandler(
  _req: Request,
  res: Response,
): Promise<Response> {
  try {
    const locations = await listFarmerLocations();
    return res.status(200).json(locations);
  } catch (error) {
    console.error('[FARMERS CONTROLLER] Error fetching locations:', error);
    return res.status(500).json({
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'Failed to fetch farmer locations',
        details: [],
      },
    });
  }
}
