import crypto from "node:crypto";
import { eq, sql } from "drizzle-orm";
import { db } from "../../config/database";
import { farmers } from "../../../../database/schema/farmers";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";
import { users } from "../../../../database/schema/users";

const hashPassword = (password: string) => crypto.createHash("sha256").update(password).digest("hex");

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

export async function createManagedFarmer(data: {
  fullName: string;
  phone: string;
  password: string;
  gender: "Male" | "Female";
  region: string;
  zone: string;
  woreda: string;
  kebele: string;
  alertEnabled: boolean;
  cropIds: string[];
}) {
  return db.transaction(async (tx) => {
    const [existingUser] = await tx.select({ id: users.id }).from(users).where(eq(users.phone, data.phone)).limit(1);
    if (existingUser) {
      const duplicateError = new Error("A farmer with this phone already exists.");
      (duplicateError as Error & { code?: string }).code = "23505";
      throw duplicateError;
    }
    const [user] = await tx.insert(users).values({
      fullName: data.fullName,
      phone: data.phone,
      passwordHash: hashPassword(data.password),
      role: "FARMER",
      status: "APPROVED",
      active: true,
      preferredLanguage: "en",
    }).returning({ id: users.id });
    const [farmer] = await tx.insert(farmers).values({
      userId: user.id,
      region: data.region,
      zone: data.zone,
      woreda: data.woreda,
      kebele: data.kebele,
      alertEnabled: data.alertEnabled,
      gender: data.gender,
    }).returning();
    for (const cropId of data.cropIds.filter((value) => /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value))) {
      await tx.insert(farmerCrops).values({ farmerId: farmer.id, cropId });
    }
    return { ...farmer, fullName: data.fullName, phone: data.phone, gender: data.gender };
  });
}

export async function listFarmers() {
  return db.select({
    id: farmers.id,
    user_id: farmers.userId,
    full_name: users.fullName,
    phone: users.phone,
    gender: farmers.gender,
    region: farmers.region,
    zone: farmers.zone,
    woreda: farmers.woreda,
    kebele: farmers.kebele,
    alert_enabled: farmers.alertEnabled,
    active: users.active,
    crop_ids: sql<string[]>`coalesce((select array_agg(${farmerCrops.cropId}::text) from ${farmerCrops} where ${farmerCrops.farmerId} = ${farmers.id}), '{}')`,
    crop_names: sql<string[]>`coalesce((select array_agg(${crops.name} order by ${crops.name}) from ${farmerCrops} inner join ${crops} on ${farmerCrops.cropId} = ${crops.id} where ${farmerCrops.farmerId} = ${farmers.id}), '{}')`,
  }).from(farmers).innerJoin(users, eq(farmers.userId, users.id));
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

export async function updateManagedFarmer(id: string, data: {
  fullName: string;
  phone: string;
  gender: "Male" | "Female";
  region: string;
  zone: string;
  woreda: string;
  kebele: string;
  alertEnabled: boolean;
}) {
  return db.transaction(async (tx) => {
    const [current] = await tx.select({ userId: farmers.userId }).from(farmers).where(eq(farmers.id, id));
    if (!current) return null;
    await tx.update(users).set({ fullName: data.fullName, phone: data.phone, updatedAt: new Date() }).where(eq(users.id, current.userId));
    const [updated] = await tx.update(farmers).set({
      gender: data.gender,
      region: data.region,
      zone: data.zone,
      woreda: data.woreda,
      kebele: data.kebele,
      alertEnabled: data.alertEnabled,
      updatedAt: new Date(),
    }).where(eq(farmers.id, id)).returning();
    return { ...updated, full_name: data.fullName, phone: data.phone, active: true, crop_ids: [] };
  });
}

export async function deleteManagedFarmer(id: string) {
  return db.transaction(async (tx) => {
    const [farmer] = await tx.select({ userId: farmers.userId }).from(farmers).where(eq(farmers.id, id));
    if (!farmer) return false;
    await tx.delete(users).where(eq(users.id, farmer.userId));
    return true;
  });
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
