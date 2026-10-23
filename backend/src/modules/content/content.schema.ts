import { z } from "zod";
import { contentStatusEnum } from "../../../../database/schema/content";

const uuidSchema = z.string().uuid();

export const createContentBodySchema = z.object({
  title: z.string().trim().min(1, "Title is required").max(255),
  summary: z.string().trim().max(1000).nullable().optional(),
  body: z.string().trim().min(1, "Content body is required"),
  cropId: uuidSchema.nullable().optional(),
  category: z.string().trim().max(100).nullable().optional(),
  language: z.string().trim().min(2).max(10).default("en").optional(),
  region: z.string().trim().max(100).nullable().optional(),
  zone: z.string().trim().max(100).nullable().optional(),
  woreda: z.string().trim().max(100).nullable().optional(),
  kebele: z.string().trim().max(100).nullable().optional(),
  season: z.string().trim().max(100).nullable().optional(),
  cropStage: z.string().trim().max(100).nullable().optional(),
  priority: z.enum(["LOW", "NORMAL", "HIGH", "URGENT"]).default("NORMAL").optional(),
  validFrom: z.coerce.date().nullable().optional(),
  validUntil: z.coerce.date().nullable().optional(),
  sourceInfo: z.string().trim().max(1000).nullable().optional(),
  attachments: z.string().nullable().optional(),
});

export const updateContentBodySchema = z
  .object({
    title: z.string().trim().min(1).max(255).optional(),
    summary: z.string().trim().max(1000).nullable().optional(),
    body: z.string().trim().min(1).optional(),
    cropId: uuidSchema.nullable().optional(),
    category: z.string().trim().max(100).nullable().optional(),
    language: z.string().trim().min(2).max(10).optional(),
    region: z.string().trim().max(100).nullable().optional(),
    zone: z.string().trim().max(100).nullable().optional(),
    woreda: z.string().trim().max(100).nullable().optional(),
    kebele: z.string().trim().max(100).nullable().optional(),
    season: z.string().trim().max(100).nullable().optional(),
    cropStage: z.string().trim().max(100).nullable().optional(),
    priority: z.enum(["LOW", "NORMAL", "HIGH", "URGENT"]).optional(),
    validFrom: z.coerce.date().nullable().optional(),
    validUntil: z.coerce.date().nullable().optional(),
    sourceInfo: z.string().trim().max(1000).nullable().optional(),
    attachments: z.string().nullable().optional(),
    changeSummary: z.string().trim().max(500).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field must be provided to update content.",
  });

export const idParamSchema = z.object({
  id: z.string().trim().min(1, "Content ID is required"),
});

export const versionIdParamSchema = z.object({
  id: z.string().trim().min(1, "Content ID is required"),
  versionId: z.string().trim().min(1, "Version ID is required"),
});

export const contentStatusQuerySchema = z
  .string()
  .transform((val) => {
    const normalized = val.trim().toUpperCase().replace(/-/g, "_");
    if (normalized === "IN_REVIEW") {
      return "PENDING_REVIEW";
    }
    if (normalized === "REVISION_REQUESTED" || normalized === "REVISION_NEEDED") {
      return "NEEDS_REVISION";
    }
    return normalized;
  })
  .pipe(z.enum(contentStatusEnum.enumValues));

export const listContentQuerySchema = z.object({
  status: contentStatusQuerySchema.optional(),
  cropId: uuidSchema.optional(),
  category: z.string().optional(),
  authorId: uuidSchema.optional(),
  reviewerId: uuidSchema.optional(),
  language: z.string().optional(),
  region: z.string().optional(),
  zone: z.string().optional(),
  woreda: z.string().optional(),
  search: z.string().optional(),
  dateFrom: z.string().optional(),
  dateTo: z.string().optional(),
  includeArchived: z
    .string()
    .optional()
    .transform((val) => val === "true" || val === "1"),
});

export const rejectContentBodySchema = z.object({
  comment: z.string().trim().min(1, "Rejection reason is required").max(2000),
});

export const requestRevisionBodySchema = z.object({
  comment: z.string().trim().min(1, "Revision comment or requested information is required").max(2000),
});

export const approveContentBodySchema = z.object({
  comment: z.string().trim().max(2000).optional(),
});

export const archiveContentBodySchema = z.object({
  reason: z.string().trim().max(1000).optional(),
});