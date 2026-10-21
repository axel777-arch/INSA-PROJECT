import { eq } from "drizzle-orm";
import { db } from "../../db/index";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";

// ── Shared helper: build the enriched farmer view ─────────────────────────────
// Flutter's FarmerModel expects: id, user_id, full_name, phone, gender(?),
// region, zone, woreda, kebele, alert_enabled, active (derived), crop_ids
// We JOIN users to bring full_name and phone into every farmer response.

export interface FarmerWithUser {
  id: string;
  user_id: string;
  full_name: string;
  phone: string;
  region: string | null;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  latitude: number | null;
  longitude: number | null;
  alert_enabled: boolean;
  active: boolean;
  crop_ids: string[];
  created_at: Date;
  updated_at: Date;
}

async function attachCropIds(farmerIds: string[]): Promise<Map<string, string[]>> {
  if (farmerIds.length === 0) return new Map();
  const rows = await db.select({ farmerId: farmerCrops.farmerId, cropId: farmerCrops.cropId })
    .from(farmerCrops)
    .where(
      farmerIds.length === 1
        ? eq(farmerCrops.farmerId, farmerIds[0])
        : undefined,
    );
  // For multi-farmer queries, fetch all and filter in memory
  const allRows = farmerIds.length === 1
    ? rows
    : await db.select({ farmerId: farmerCrops.farmerId, cropId: farmerCrops.cropId }).from(farmerCrops);

  const map = new Map<string, string[]>();
  for (const row of allRows) {
    if (!farmerIds.includes(row.farmerId)) continue;
    const existing = map.get(row.farmerId) ?? [];
    existing.push(row.cropId);
    map.set(row.farmerId, existing);
  }
  return map;
}

function buildFarmerView(
  farmer: typeof farmers.$inferSelect,
  user: { fullName: string; phone: string | null } | undefined,
  cropIdList: string[],
): FarmerWithUser {
  return {
    id: farmer.id,
    user_id: farmer.userId,
    full_name: user?.fullName ?? '',
    phone: user?.phone ?? '',
    region: farmer.region ?? null,
    zone: farmer.zone ?? null,
    woreda: farmer.woreda ?? null,
    kebele: farmer.kebele ?? null,
    latitude: farmer.latitude ?? null,
    longitude: farmer.longitude ?? null,
    alert_enabled: farmer.alertEnabled,
    active: true,
    crop_ids: cropIdList,
    created_at: farmer.createdAt,
    updated_at: farmer.updatedAt,
  };
}

// ── Service functions ─────────────────────────────────────────────────────────

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
  console.log(`[SERVICE] Creating farmer for userId=${data.userId}`);
  const [farmer] = await db.insert(farmers).values(data).returning();
  const [user] = await db.select({ fullName: users.fullName, phone: users.phone })
    .from(users).where(eq(users.id, farmer.userId)).limit(1);
  console.log(`[DATABASE] Farmer created: id=${farmer.id}`);
  return buildFarmerView(farmer, user, []);
}

export async function listFarmers(): Promise<FarmerWithUser[]> {
  console.log('[SERVICE] Listing all farmers (with user join)');
  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      fullName: users.fullName,
      phone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id));

  const farmerIds = rows.map((r) => r.id);
  const cropMap = await attachCropIds(farmerIds);

  console.log(`[DATABASE] Farmers retrieved: ${rows.length}`);
  return rows.map((r) =>
    buildFarmerView(
      {
        id: r.id,
        userId: r.userId,
        region: r.region,
        zone: r.zone,
        woreda: r.woreda,
        kebele: r.kebele,
        latitude: r.latitude,
        longitude: r.longitude,
        alertEnabled: r.alertEnabled,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      } as typeof farmers.$inferSelect,
      { fullName: r.fullName ?? '', phone: r.phone },
      cropMap.get(r.id) ?? [],
    ),
  );
}

export async function getFarmerById(id: string): Promise<FarmerWithUser | null> {
  console.log(`[SERVICE] Getting farmer by id=${id}`);
  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      fullName: users.fullName,
      phone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id))
    .where(eq(farmers.id, id))
    .limit(1);

  if (rows.length === 0) return null;
  const r = rows[0];
  const cropMap = await attachCropIds([r.id]);
  return buildFarmerView(
    {
      id: r.id, userId: r.userId, region: r.region, zone: r.zone,
      woreda: r.woreda, kebele: r.kebele, latitude: r.latitude,
      longitude: r.longitude, alertEnabled: r.alertEnabled,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    } as typeof farmers.$inferSelect,
    { fullName: r.fullName ?? '', phone: r.phone },
    cropMap.get(r.id) ?? [],
  );
}

export async function getFarmerByUserId(userId: string): Promise<FarmerWithUser | null> {
  console.log(`[SERVICE] Getting farmer by userId=${userId}`);
  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      fullName: users.fullName,
      phone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id))
    .where(eq(farmers.userId, userId))
    .limit(1);

  if (rows.length === 0) return null;
  const r = rows[0];
  const cropMap = await attachCropIds([r.id]);
  return buildFarmerView(
    {
      id: r.id, userId: r.userId, region: r.region, zone: r.zone,
      woreda: r.woreda, kebele: r.kebele, latitude: r.latitude,
      longitude: r.longitude, alertEnabled: r.alertEnabled,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    } as typeof farmers.$inferSelect,
    { fullName: r.fullName ?? '', phone: r.phone },
    cropMap.get(r.id) ?? [],
  );
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
): Promise<FarmerWithUser | null> {
  console.log(`[SERVICE] Updating farmer id=${id}`);
  const [updated] = await db
    .update(farmers)
    .set({ ...data, updatedAt: new Date() })
    .where(eq(farmers.id, id))
    .returning();
  if (!updated) return null;
  console.log(`[DATABASE] Farmer updated: id=${updated.id}`);
  return getFarmerById(updated.id);
}

export async function addCropToFarmer(farmerId: string, cropId: string) {
  console.log(`[SERVICE] Assigning crop ${cropId} to farmer ${farmerId}`);
  const [relation] = await db
    .insert(farmerCrops)
    .values({ farmerId, cropId })
    .returning();
  console.log(`[DATABASE] Crop assigned: farmerId=${farmerId}, cropId=${cropId}`);
  return relation;
}

export async function getFarmerCrops(farmerId: string) {
  console.log(`[SERVICE] Getting crops for farmer ${farmerId}`);
  const result = await db
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
  console.log(`[DATABASE] Crops retrieved for farmer ${farmerId}: ${result.length}`);
  return result;
}
