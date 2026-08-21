"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createFarmerHandler = createFarmerHandler;
exports.listFarmersHandler = listFarmersHandler;
exports.getFarmerByIdHandler = getFarmerByIdHandler;
exports.updateFarmerHandler = updateFarmerHandler;
exports.addCropToFarmerHandler = addCropToFarmerHandler;
exports.getFarmerCropsHandler = getFarmerCropsHandler;
const farmer_service_1 = require("./farmer.service");
const farmer_schema_1 = require("./farmer.schema");
/**
 * POST /api/farmers
 * Creates a new farmer profile.
 */
async function createFarmerHandler(req, res) {
    const parsed = farmer_schema_1.createFarmerSchema.safeParse(req.body);
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
        const farmer = await (0, farmer_service_1.createFarmer)(parsed.data);
        return res.status(201).json(farmer);
    }
    catch (error) {
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
async function listFarmersHandler(_req, res) {
    try {
        const farmersList = await (0, farmer_service_1.listFarmers)();
        return res.status(200).json(farmersList);
    }
    catch (error) {
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
async function getFarmerByIdHandler(req, res) {
    const parsed = farmer_schema_1.farmerIdSchema.safeParse(req.params);
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
        const farmer = await (0, farmer_service_1.getFarmerById)(parsed.data.id);
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
    }
    catch (error) {
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
async function updateFarmerHandler(req, res) {
    const idParsed = farmer_schema_1.farmerIdSchema.safeParse(req.params);
    if (!idParsed.success) {
        return res.status(400).json({
            error: {
                code: "VALIDATION_ERROR",
                message: "Invalid farmer ID",
                details: idParsed.error.issues,
            },
        });
    }
    const bodyParsed = farmer_schema_1.updateFarmerSchema.safeParse(req.body);
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
        const existingFarmer = await (0, farmer_service_1.getFarmerById)(idParsed.data.id);
        if (!existingFarmer) {
            return res.status(404).json({
                error: {
                    code: "NOT_FOUND",
                    message: "Farmer not found",
                    details: [],
                },
            });
        }
        const updatedFarmer = await (0, farmer_service_1.updateFarmer)(idParsed.data.id, bodyParsed.data);
        return res.status(200).json(updatedFarmer);
    }
    catch (error) {
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
async function addCropToFarmerHandler(req, res) {
    const idParsed = farmer_schema_1.farmerIdSchema.safeParse(req.params);
    if (!idParsed.success) {
        return res.status(400).json({
            error: {
                code: "VALIDATION_ERROR",
                message: "Invalid farmer ID",
                details: idParsed.error.issues,
            },
        });
    }
    const cropParsed = farmer_schema_1.addFarmerCropSchema.safeParse(req.body);
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
        const existingFarmer = await (0, farmer_service_1.getFarmerById)(idParsed.data.id);
        if (!existingFarmer) {
            return res.status(404).json({
                error: {
                    code: "NOT_FOUND",
                    message: "Farmer not found",
                    details: [],
                },
            });
        }
        const farmerCrop = await (0, farmer_service_1.addCropToFarmer)(idParsed.data.id, cropParsed.data.cropId);
        return res.status(201).json(farmerCrop);
    }
    catch (error) {
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
async function getFarmerCropsHandler(req, res) {
    const parsed = farmer_schema_1.farmerIdSchema.safeParse(req.params);
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
        const existingFarmer = await (0, farmer_service_1.getFarmerById)(parsed.data.id);
        if (!existingFarmer) {
            return res.status(404).json({
                error: {
                    code: "NOT_FOUND",
                    message: "Farmer not found",
                    details: [],
                },
            });
        }
        const cropsList = await (0, farmer_service_1.getFarmerCrops)(parsed.data.id);
        return res.status(200).json(cropsList);
    }
    catch (error) {
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
