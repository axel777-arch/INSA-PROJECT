import { eq } from "drizzle-orm";
import { db } from "../../config/database";
import { farmers } from "../../../../database/schema/farmers";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";

export async function createFarmer(data: {
  userId: string;
  region?: string;
  zone?: string;
  woreda?: string;
  kebele?: string;
  latitude?: number;
  longitude?: number;
  alertEnabled?: boolean;
}) {
  const [farmer] = await db.insert(farmers).values(data).returning();
  return farmer;
}

export async function listFarmers() {
  return db.select().from(farmers);
}

export async function getFarmerById(id: string) {
  const [farmer] = await db
    .select()
    .from(farmers)
    .where(eq(farmers.id, id));

  return farmer;
}

export async function getFarmerByUserId(userId: string) {
  const [farmer] = await db.select().from(farmers).where(eq(farmers.userId, userId));
  return farmer;
}

export async function updateFarmer(
  id: string,
  data: {
    region?: string;
    zone?: string;
    woreda?: string;
    kebele?: string;
    latitude?: number;
    longitude?: number;
    alertEnabled?: boolean;
  },
) {
  const [farmer] = await db
    .update(farmers)
    .set({
      ...data,
      updatedAt: new Date(),
    })
    .where(eq(farmers.id, id))
    .returning();

  return farmer;
}

export async function addCropToFarmer(farmerId: string, cropId: string) {
  const [relation] = await db
    .insert(farmerCrops)
    .values({ farmerId, cropId })
    .returning();

  return relation;
}

export async function getFarmerCrops(farmerId: string) {
  return db
    .select({
      farmerId: farmerCrops.farmerId,
      cropId: farmerCrops.cropId,
      cropName: crops.name,
      cropDescription: crops.description,
      cropActive: crops.active,
    })
    .from(farmerCrops)
    .innerJoin(crops, eq(farmerCrops.cropId, crops.id))
    .where(eq(farmerCrops.farmerId, farmerId));
}
