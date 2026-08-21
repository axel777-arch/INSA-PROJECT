"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.archiveContentBodySchema = exports.rejectContentBodySchema = exports.listContentQuerySchema = exports.idParamSchema = exports.updateContentBodySchema = exports.createContentBodySchema = void 0;
const zod_1 = require("zod");
const content_1 = require("../../../../database/schema/content");
const uuidSchema = zod_1.z.string().uuid();
exports.createContentBodySchema = zod_1.z.object({
    title: zod_1.z.string().min(1).max(255),
    body: zod_1.z.string().min(1),
    cropId: uuidSchema.nullable().optional(),
    language: zod_1.z.string().min(1).max(50),
    location: zod_1.z.string().min(1).max(255).nullable().optional(),
});
exports.updateContentBodySchema = zod_1.z
    .object({
    title: zod_1.z.string().min(1).max(255).optional(),
    body: zod_1.z.string().min(1).optional(),
    cropId: uuidSchema.nullable().optional(),
    language: zod_1.z.string().min(1).max(50).optional(),
    location: zod_1.z.string().min(1).max(255).nullable().optional(),
})
    .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field must be provided to update content.",
});
exports.idParamSchema = zod_1.z.object({
    id: uuidSchema,
});
exports.listContentQuerySchema = zod_1.z.object({
    status: zod_1.z.enum(content_1.contentStatusEnum.enumValues).optional(),
    cropId: uuidSchema.optional(),
    language: zod_1.z.string().min(1).optional(),
    location: zod_1.z.string().min(1).optional(),
});
exports.rejectContentBodySchema = zod_1.z.object({
    comment: zod_1.z.string().trim().min(1).max(2000),
});
exports.archiveContentBodySchema = zod_1.z.object({});
