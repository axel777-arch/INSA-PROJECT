import { z } from "zod";

const uuidSchema = z.string().uuid();

export const createObservationSchema = z.object({
  farmerId: uuidSchema,
  cropId: uuidSchema.optional(),
  observationType: z.enum([
    "PEST_INFESTATION",
    "DISEASE",
    "WEATHER_DAMAGE",
    "SOIL_ISSUE",
    "GENERAL_CHECKUP",
  ]).default("GENERAL_CHECKUP"),
  severity: z.enum(["LOW", "MEDIUM", "HIGH", "CRITICAL"]).default("LOW"),
  title: z.string().trim().min(3, "Title must be at least 3 characters"),
  description: z.string().trim().min(10, "Description must be at least 10 characters"),
  actionTaken: z.string().trim().optional(),
});

export const updateObservationSchema = z.object({
  observationType: z.enum([
    "PEST_INFESTATION",
    "DISEASE",
    "WEATHER_DAMAGE",
    "SOIL_ISSUE",
    "GENERAL_CHECKUP",
  ]).optional(),
  severity: z.enum(["LOW", "MEDIUM", "HIGH", "CRITICAL"]).optional(),
  title: z.string().trim().min(3).optional(),
  description: z.string().trim().min(10).optional(),
  actionTaken: z.string().trim().optional(),
});

export const escalateObservationSchema = z.object({
  escalatedToId: uuidSchema,
});

export const observationIdSchema = z.object({
  id: uuidSchema,
});
