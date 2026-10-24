import { z } from "zod";

const uuidSchema = z.string().uuid();

export const createFollowUpSchema = z.object({
  farmerId: uuidSchema,
  observationId: uuidSchema.optional(),
  scheduledDate: z.string().datetime({ message: "scheduledDate must be an ISO 8601 datetime string" }),
  notes: z.string().trim().optional(),
});

export const updateFollowUpSchema = z.object({
  status: z.enum(["PENDING", "IN_PROGRESS", "COMPLETED", "CANCELLED"]).optional(),
  completedDate: z.string().datetime().optional(),
  notes: z.string().trim().optional(),
  outcome: z.string().trim().optional(),
});

export const followUpIdSchema = z.object({
  id: uuidSchema,
});
