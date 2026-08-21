import { eq } from "drizzle-orm";

import { db } from "../../config/database";
import { crops } from "../../../../database/schema";

export async function getAllCrops() {
  return db.select().from(crops);
}

export async function createCrop(data: {
  name: string;
  description?: string;
  active?: boolean;
}) {
  const existing = await db
    .select()
    .from(crops)
    .where(eq(crops.name, data.name))
    .limit(1);

  if (existing.length > 0) {
    const error = new Error("Crop with this name already exists");
    (error as Error & { code?: string }).code = "CONFLICT";
    throw error;
  }

  const [crop] = await db
    .insert(crops)
    .values(data)
    .returning();

  return crop;
}