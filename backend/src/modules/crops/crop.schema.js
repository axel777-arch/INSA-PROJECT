"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cropIdSchema = exports.createCropSchema = void 0;
const zod_1 = require("zod");
exports.createCropSchema = zod_1.z.object({
    name: zod_1.z.string().trim().min(1, "Crop name is required"),
    description: zod_1.z.string().trim().optional(),
    active: zod_1.z.boolean().optional(),
});
exports.cropIdSchema = zod_1.z.object({
    id: zod_1.z.uuid(),
});
