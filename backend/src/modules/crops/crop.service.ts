import { db } from "../../config/database";
import { crops } from "../../../../database/schema";

export async function getAllCrops() {
  return await db.select().from(crops);
}
