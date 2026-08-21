"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.addFarmerCropSchema = exports.farmerIdSchema = exports.updateFarmerSchema = exports.createFarmerSchema = void 0;
const zod_1 = require("zod");
const uuidSchema = zod_1.z.uuid();
const latitudeSchema = zod_1.z
    .number()
    .min(-90, "Latitude must be between -90 and 90")
    .max(90, "Latitude must be between -90 and 90");
const longitudeSchema = zod_1.z
    .number()
    .min(-180, "Longitude must be between -180 and 180")
    .max(180, "Longitude must be between -180 and 180");
exports.createFarmerSchema = zod_1.z.object({
    userId: uuidSchema,
    region: zod_1.z.string().trim().min(1).optional(),
    zone: zod_1.z.string().trim().min(1).optional(),
    woreda: zod_1.z.string().trim().min(1).optional(),
    kebele: zod_1.z.string().trim().min(1).optional(),
    latitude: latitudeSchema.optional(),
    longitude: longitudeSchema.optional(),
    alertEnabled: zod_1.z.boolean().optional(),
});
exports.updateFarmerSchema = exports.createFarmerSchema
    .omit({ userId: true })
    .partial();
exports.farmerIdSchema = zod_1.z.object({
    id: uuidSchema,
});
exports.addFarmerCropSchema = zod_1.z.object({
    cropId: uuidSchema,
});
