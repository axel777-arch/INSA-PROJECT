import { z } from "zod";

const uuidSchema = z.uuid();

const latitudeSchema = z
  .number()
  .min(-90, "Latitude must be between -90 and 90")
  .max(90, "Latitude must be between -90 and 90");

const longitudeSchema = z
  .number()
  .min(-180, "Longitude must be between -180 and 180")
  .max(180, "Longitude must be between -180 and 180");

export const createFarmerSchema = z.object({
  userId: uuidSchema,
  region: z.string().trim().min(1).optional(),
  zone: z.string().trim().min(1).optional(),
  woreda: z.string().trim().min(1).optional(),
  kebele: z.string().trim().min(1).optional(),
  latitude: latitudeSchema.optional(),
  longitude: longitudeSchema.optional(),
  alertEnabled: z.boolean().optional(),
});

export const updateFarmerSchema = createFarmerSchema
  .omit({ userId: true })
  .partial();

export const managedFarmerUpdateSchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  phone: z.string().trim().min(1),
  gender: z.enum(["Male", "Female"]),
  region: z.string().trim().min(1),
  zone: z.string().trim().min(1),
  woreda: z.string().trim().min(1),
  kebele: z.string().trim().min(1),
  alertEnabled: z.boolean(),
});

export const farmerIdSchema = z.object({
  id: uuidSchema,
});

export const addFarmerCropSchema = z.object({
  cropId: uuidSchema,
});

export const managedFarmerSchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  phone: z.string().trim().min(1),
  password: z.string().min(8).max(128),
  gender: z.enum(["Male", "Female"]),
  region: z.string().trim().min(1),
  zone: z.string().trim().min(1),
  woreda: z.string().trim().min(1),
  kebele: z.string().trim().min(1),
  alertEnabled: z.boolean().default(true),
  cropIds: z.array(z.string().trim().min(1)).default([]),
});