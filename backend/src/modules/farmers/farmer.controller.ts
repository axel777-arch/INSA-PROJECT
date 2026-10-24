// farmer.controller.ts - merged implementation combining both branches
import { Request, Response } from "express";

import {
  createFarmer,
  listFarmers,
  getFarmerById,
  getFarmerByUserId,
  updateFarmer,
  addCropToFarmer,
  getFarmerCrops,
  assignFarmer,
  getFarmerAssignments,
  listFarmerLocations,
} from "./farmer.service";

import {
  createFarmerSchema,
  updateFarmerSchema,
  farmerIdSchema,
  addFarmerCropSchema,
  assignFarmerSchema,
} from "./farmer.schema";

/**
 * POST /api/farmers
 * Creates a new farmer profile.
 */
export async function createFarmerHandler(req: Request, res: Response): Promise<Response> {
  const parsed = createFarmerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: { code: "VALIDATION_ERROR", message: "Invalid farmer data", details: parsed.error.issues },
    });
  }

  try {
    const workerId = req.user?.id;
    if (!workerId) {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "User not authenticated", details: [] } });
    }
    const farmer = await createFarmer({
      ...parsed.data,
      primaryWorkerId: workerId,
    });
    return res.status(201).json(farmer);
  } catch (error: any) {
    console.error("CREATE FARMER ERROR:", error);
    const pgCode = error?.cause?.code ?? error?.code;
    if (pgCode === "23503") {
      return res.status(404).json({ error: { code: "USER_NOT_FOUND", message: "The specified user does not exist.", details: [] } });
    }
    if (pgCode === "23505") {
      return res.status(409).json({ error: { code: "FARMER_ALREADY_EXISTS", message: "A farmer profile already exists for this user.", details: [] } });
    }
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to create farmer profile", details: [] } });
  }
}

/**
 * GET /api/farmers
 * Retrieves all farmers. Supports optional filtering based on requesting user.
 */
export async function listFarmersHandler(req: Request, res: Response): Promise<Response> {
  try {
    // Preserve original behaviour of passing requesting user info if available.
    const farmersList = await listFarmers({
      requestingUserId: req.user?.id,
      requestingUserRole: req.user?.role,
    });
    return res.status(200).json(farmersList);
  } catch (error) {
    console.error("LIST FARMERS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve farmers", details: [] } });
  }
}

/**
 * GET /api/farmers/:id
 */
export async function getFarmerByIdHandler(req: Request, res: Response): Promise<Response> {
  const parsed = farmerIdSchema.safeParse(req.params);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: parsed.error.issues } });
  }
  try {
    const farmer = await getFarmerById(parsed.data.id);
    if (!farmer) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Farmer not found", details: [] } });
    }
    return res.status(200).json(farmer);
  } catch (error) {
    console.error("GET FARMER ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve farmer", details: [] } });
  }
}

/**
 * GET /api/farmers/user/:userId
 */
export async function getFarmerByUserIdHandler(req: Request, res: Response): Promise<Response> {
  const { userId } = req.params;
  if (!userId || typeof userId !== "string") {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "userId is required", details: [] } });
  }
  try {
    const farmer = await getFarmerByUserId(userId);
    if (!farmer) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Farmer not found", details: [] } });
    }
    return res.status(200).json(farmer);
  } catch (error) {
    console.error("GET FARMER BY USERID ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve farmer", details: [] } });
  }
}

/**
 * PATCH /api/farmers/:id
 */
export async function updateFarmerHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = farmerIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: idParsed.error.issues } });
  }
  const bodyParsed = updateFarmerSchema.safeParse(req.body);
  if (!bodyParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer update data", details: bodyParsed.error.issues } });
  }
  try {
    const existing = await getFarmerById(idParsed.data.id);
    if (!existing) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Farmer not found", details: [] } });
    }
    const updated = await updateFarmer(idParsed.data.id, bodyParsed.data);
    return res.status(200).json(updated);
  } catch (error) {
    console.error("UPDATE FARMER ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to update farmer profile", details: [] } });
  }
}

/**
 * POST /api/farmers/:id/assign
 */
export async function assignFarmerHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = farmerIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: idParsed.error.issues } });
  }
  const bodyParsed = assignFarmerSchema.safeParse(req.body);
  if (!bodyParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid assignment data", details: bodyParsed.error.issues } });
  }
  try {
    const farmer = await getFarmerById(idParsed.data.id);
    if (!farmer) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Farmer not found", details: [] } });
    }
    const assignment = await assignFarmer(idParsed.data.id, req.user!.id, bodyParsed.data);
    return res.status(201).json({ success: true, data: assignment });
  } catch (error) {
    console.error("ASSIGN FARMER ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to assign farmer", details: [] } });
  }
}

/**
 * GET /api/farmers/:id/assignments
 */
export async function getFarmerAssignmentsHandler(req: Request, res: Response): Promise<Response> {
  const parsed = farmerIdSchema.safeParse(req.params);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: parsed.error.issues } });
  }
  try {
    const assignments = await getFarmerAssignments(parsed.data.id);
    return res.status(200).json(assignments);
  } catch (error) {
    console.error("GET ASSIGNMENTS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve assignments", details: [] } });
  }
}

/**
 * POST /api/farmers/:id/crops
 */
export async function addCropToFarmerHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = farmerIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: idParsed.error.issues } });
  }
  const cropParsed = addFarmerCropSchema.safeParse(req.body);
  if (!cropParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid crop data", details: cropParsed.error.issues } });
  }
  try {
    const farmer = await getFarmerById(idParsed.data.id);
    if (!farmer) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Farmer not found", details: [] } });
    }
    const relation = await addCropToFarmer(idParsed.data.id, cropParsed.data.cropId);
    if (!relation) {
      return res.status(409).json({ error: { code: "ALREADY_ASSIGNED", message: "Crop already assigned to this farmer", details: [] } });
    }
    return res.status(201).json({ success: true, data: relation });
  } catch (error: any) {
    console.error("ADD CROP TO FARMER ERROR:", error);
    const postgresCode = error?.cause?.code ?? error?.code;
    if (postgresCode === "23505") {
      return res.status(409).json({ error: { code: "ALREADY_ASSIGNED", message: "Crop already assigned to this farmer", details: [] } });
    }
    if (postgresCode === "23503") {
      return res.status(404).json({ error: { code: "CROP_NOT_FOUND", message: "The specified crop does not exist.", details: [] } });
    }
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to associate crop with farmer", details: [] } });
  }
}

/**
 * GET /api/farmers/:id/crops
 */
export async function getFarmerCropsHandler(req: Request, res: Response): Promise<Response> {
  const parsed = farmerIdSchema.safeParse(req.params);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid farmer ID", details: parsed.error.issues } });
  }
  try {
    const farmerCropList = await getFarmerCrops(parsed.data.id);
    return res.status(200).json(farmerCropList);
  } catch (error) {
    console.error("GET FARMER CROPS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve farmer crops", details: [] } });
  }
}

/**
 * GET /api/farmers/locations
 * Returns active farmer coordinates and primary crops for live mapping.
 */
export async function getFarmerLocationsHandler(_req: Request, res: Response): Promise<Response> {
  try {
    const locations = await listFarmerLocations();
    return res.status(200).json(locations);
  } catch (error) {
    console.error("GET FARMER LOCATIONS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve farmer locations" } });
  }
}
