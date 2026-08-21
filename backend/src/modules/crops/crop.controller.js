"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCrops = getCrops;
exports.createCropHandler = createCropHandler;
const crop_service_1 = require("./crop.service");
const crop_schema_1 = require("./crop.schema");
async function getCrops(_req, res) {
    try {
        const crops = await (0, crop_service_1.getAllCrops)();
        return res.status(200).json({
            success: true,
            data: crops,
        });
    }
    catch (error) {
        console.error("GET CROPS ERROR:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to fetch crops",
        });
    }
}
async function createCropHandler(req, res) {
    const parsed = crop_schema_1.createCropSchema.safeParse(req.body);
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
        const crop = await (0, crop_service_1.createCrop)(parsed.data);
        return res.status(201).json({
            success: true,
            data: crop,
        });
    }
    catch (error) {
        if (error instanceof Error &&
            error.code === "CONFLICT") {
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
