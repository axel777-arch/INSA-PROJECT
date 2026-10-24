import { z } from "zod";

const uuidSchema = z.string().uuid();

const latitudeSchema = z
  .number()
  .min(-90, "Latitude must be between -90 and 90")
  .max(90, "Latitude must be between -90 and 90");

const longitudeSchema = z
  .number()
  .min(-180, "Longitude must be between -180 and 180")
  .max(180, "Longitude must be between -180 and 180");

export const createFarmerSchema = z.object({
  fullName: z.string().trim().min(2, "Full name must be at least 2 characters"),
  phone: z.string().trim().min(9, "Phone number must be at least 9 characters"),
  preferredLanguage: z.string().trim().default("amharic"),
  createAppAccount: z.boolean().default(false),
  userId: uuidSchema.optional(),
  farmSize: z.number().positive().optional(),
  experienceYears: z.number().nonnegative().optional(),
  region: z.string().trim().min(1).optional(),
  zone: z.string().trim().min(1).optional(),
  woreda: z.string().trim().min(1).optional(),
  kebele: z.string().trim().min(1).optional(),
  latitude: latitudeSchema.optional(),
  longitude: longitudeSchema.optional(),
  alertEnabled: z.boolean().optional(),
  cropIds: z.array(uuidSchema).optional(),
});

export const updateFarmerSchema = z.object({
  fullName: z.string().trim().min(2).optional(),
  phone: z.string().trim().min(9).optional(),
  preferredLanguage: z.string().trim().optional(),
  farmSize: z.number().positive().optional(),
  experienceYears: z.number().nonnegative().optional(),
  region: z.string().trim().min(1).optional(),
  zone: z.string().trim().min(1).optional(),
  woreda: z.string().trim().min(1).optional(),
  kebele: z.string().trim().min(1).optional(),
  latitude: latitudeSchema.optional(),
  longitude: longitudeSchema.optional(),
  alertEnabled: z.boolean().optional(),
});

export const farmerIdSchema = z.object({
  id: uuidSchema,
});

export const addFarmerCropSchema = z.object({
  cropId: uuidSchema,
});

export const assignFarmerSchema = z.object({
  workerId: uuidSchema,
  assignmentType: z.enum(["PRIMARY", "TEMPORARY_COVERAGE", "COLLABORATOR"]).default("PRIMARY"),
  reason: z.string().trim().optional(),
  note: z.string().trim().optional(),
  endDate: z.string().datetime().optional(),
});
