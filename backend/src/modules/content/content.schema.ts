import { z } from "zod";
import { contentStatusEnum } from "../../../../database/schema/content";

const uuidSchema = z.string().uuid();

export const createContentBodySchema = z.object({
  title: z.string().min(1).max(255),
  body: z.string().min(1),
  cropId: uuidSchema.nullable().optional(),
  category: z.string().optional(),
});

export const updateContentBodySchema = z
  .object({
    title: z.string().min(1).max(255).optional(),
    body: z.string().min(1).optional(),
    cropId: uuidSchema.nullable().optional(),
    category: z.string().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field must be provided to update content.",
  });

export const idParamSchema = z.object({
  id: z.string().trim().min(1, "Content ID is required"),
});

export const contentStatusQuerySchema = z
  .string()
  .transform((val) => {
    const normalized = val.trim().toUpperCase().replace(/-/g, "_");
    if (normalized === "IN_REVIEW") {
      return "PENDING_REVIEW";
    }
    return normalized;
  })
  .pipe(z.enum(contentStatusEnum.enumValues));

export const listContentQuerySchema = z.object({
  status: contentStatusQuerySchema.optional(),
  cropId: uuidSchema.optional(),
  category: z.string().optional(),
  authorId: uuidSchema.optional(),
});

export const rejectContentBodySchema = z.object({
  comment: z.string().trim().min(1).max(2000),
});