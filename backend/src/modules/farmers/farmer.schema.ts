
import { z } from "zod";

const uuidSchema = z.uuid();

const latitudeSchema = z
  .number()
  .min(-90, "Latitude must be at least -90")
  .max(90, "Latitude must be at most 90");

const longitudeSchema = z
  .number()
  .min(-180, "Longitude must be at least -180")
  .max(180, "Longitude must be at most 180");

export const createFarmerSchema = z.object({
  // Optional: farmers can have profiles without app accounts.
  userId: uuidSchema.optional(),

  // Contact information stored directly on the farmer profile.
  fullName: z.string().trim().min(1).optional(),
  phone: z.string().trim().min(1).optional(),

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

export const farmerIdSchema = z.object({
  id: uuidSchema,
});

export const addFarmerCropSchema = z.object({
  cropId: uuidSchema,
});