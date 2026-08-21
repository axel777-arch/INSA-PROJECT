import { z } from "zod";

export const createCropSchema = z.object({
  name: z.string().trim().min(1, "Crop name is required"),
  description: z.string().trim().optional(),
  active: z.boolean().optional(),
});

export const cropIdSchema = z.object({
  id: z.uuid(),
});