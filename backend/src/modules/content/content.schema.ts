import { z } from "zod";
import { contentStatusEnum } from "../../../../database/schema/content";

const uuidSchema = z.string().uuid();

export const createContentBodySchema = z.object({
  title: z.string().min(1).max(255),
  body: z.string().min(1),
  cropId: uuidSchema.nullable().optional(),
  language: z.string().min(1).max(50),
  location: z.string().min(1).max(255).nullable().optional(),
});

export const updateContentBodySchema = z
  .object({
    title: z.string().min(1).max(255).optional(),
    body: z.string().min(1).optional(),
    cropId: uuidSchema.nullable().optional(),
    language: z.string().min(1).max(50).optional(),
    location: z.string().min(1).max(255).nullable().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field must be provided to update content.",
  });

export const idParamSchema = z.object({
  id: uuidSchema,
});

export const listContentQuerySchema = z.object({
  status: z.enum(contentStatusEnum.enumValues).optional(),
  cropId: uuidSchema.optional(),
  language: z.string().min(1).optional(),
  location: z.string().min(1).optional(),
});

export const rejectContentBodySchema = z.object({
  comment: z.string().trim().min(1).max(2000),
});

export const archiveContentBodySchema = z.object({});