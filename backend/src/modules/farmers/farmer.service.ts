
import { eq } from "drizzle-orm";
import { db } from "../../db/index";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";

// ── Farmer response model ─────────────────────────────────────────────────────

export interface FarmerWithUser {
  id: string;
  user_id: string | null;
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

// ── Attach crop IDs to farmer profiles ────────────────────────────────────────

async function attachCropIds(
  farmerIds: string[],
): Promise<Map<string, string[]>> {
  if (farmerIds.length === 0) return new Map();

  const allRows = await db
    .select({
      farmerId: farmerCrops.farmerId,
      cropId: farmerCrops.cropId,
    })
    .from(farmerCrops);

  const map = new Map<string, string[]>();

  for (const row of allRows) {
    if (!farmerIds.includes(row.farmerId)) continue;

    const existing = map.get(row.farmerId) ?? [];
    existing.push(row.cropId);
    map.set(row.farmerId, existing);
  }

  return map;
}

// ── Build a farmer response ───────────────────────────────────────────────────

function buildFarmerView(
  farmer: typeof farmers.$inferSelect,
  user: { fullName: string; phone: string | null } | undefined,
  cropIdList: string[],
): FarmerWithUser {
  return {
    id: farmer.id,
    user_id: farmer.userId,
    full_name: farmer.fullName ?? user?.fullName ?? "",
    phone: farmer.phone ?? user?.phone ?? "",
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

// ── Create a farmer ───────────────────────────────────────────────────────────

export async function createFarmer(data: {
  userId?: string;
  fullName?: string;
  phone?: string;
  registeredBy?: string;
  region?: string;
  zone?: string;
  woreda?: string;
  kebele?: string;
  latitude?: number;
  longitude?: number;
  alertEnabled?: boolean;
  preferredLanguage?: string;
  hasAppAccess?: boolean;
  farmSize?: number;
  experienceYears?: number;
  primaryWorkerId?: string;
  createAppAccount?: boolean;
}) {
  console.log("[SERVICE] Creating farmer");

  const {
    createAppAccount: _createAppAccount,
    ...farmerData
  } = data;

  const [farmer] = await db
    .insert(farmers)
    .values(farmerData)
    .returning();

  const [user] = farmer.userId
    ? await db
        .select({
          fullName: users.fullName,
          phone: users.phone,
        })
        .from(users)
        .where(eq(users.id, farmer.userId))
        .limit(1)
    : [];

  console.log(`[DATABASE] Farmer created: id=${farmer.id}`);

  return buildFarmerView(farmer, user, []);
}

// ── List farmers ──────────────────────────────────────────────────────────────

export async function listFarmers(): Promise<FarmerWithUser[]> {
  console.log("[SERVICE] Listing all farmers");

  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      farmerFullName: farmers.fullName,
      farmerPhone: farmers.phone,
      registeredBy: farmers.registeredBy,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      preferredLanguage: farmers.preferredLanguage,
      hasAppAccess: farmers.hasAppAccess,
      farmSize: farmers.farmSize,
      experienceYears: farmers.experienceYears,
      primaryWorkerId: farmers.primaryWorkerId,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      userFullName: users.fullName,
      userPhone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id));

  const farmerIds = rows.map((row) => row.id);
  const cropMap = await attachCropIds(farmerIds);

  console.log(`[DATABASE] Farmers retrieved: ${rows.length}`);

  return rows.map((row) =>
    buildFarmerView(
      {
        id: row.id,
        userId: row.userId,
        fullName: row.farmerFullName,
        phone: row.farmerPhone,
        registeredBy: row.registeredBy,
        region: row.region,
        zone: row.zone,
        woreda: row.woreda,
        kebele: row.kebele,
        latitude: row.latitude,
        longitude: row.longitude,
        alertEnabled: row.alertEnabled,
        preferredLanguage: row.preferredLanguage,
        hasAppAccess: row.hasAppAccess,
        farmSize: row.farmSize,
        experienceYears: row.experienceYears,
        primaryWorkerId: row.primaryWorkerId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      },
      {
        fullName: row.userFullName ?? "",
        phone: row.userPhone,
      },
      cropMap.get(row.id) ?? [],
    ),
  );
}

// ── Get farmer by profile ID ──────────────────────────────────────────────────

export async function getFarmerById(
  id: string,
): Promise<FarmerWithUser | null> {
  console.log(`[SERVICE] Getting farmer by id=${id}`);

  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      farmerFullName: farmers.fullName,
      farmerPhone: farmers.phone,
      registeredBy: farmers.registeredBy,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      preferredLanguage: farmers.preferredLanguage,
      hasAppAccess: farmers.hasAppAccess,
      farmSize: farmers.farmSize,
      experienceYears: farmers.experienceYears,
      primaryWorkerId: farmers.primaryWorkerId,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      userFullName: users.fullName,
      userPhone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id))
    .where(eq(farmers.id, id))
    .limit(1);

  if (rows.length === 0) return null;

  const row = rows[0];
  const cropMap = await attachCropIds([row.id]);

  return buildFarmerView(
    {
      id: row.id,
      userId: row.userId,
      fullName: row.farmerFullName,
      phone: row.farmerPhone,
      registeredBy: row.registeredBy,
      region: row.region,
      zone: row.zone,
      woreda: row.woreda,
      kebele: row.kebele,
      latitude: row.latitude,
      longitude: row.longitude,
      alertEnabled: row.alertEnabled,
      preferredLanguage: row.preferredLanguage,
      hasAppAccess: row.hasAppAccess,
      farmSize: row.farmSize,
      experienceYears: row.experienceYears,
      primaryWorkerId: row.primaryWorkerId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    },
    {
      fullName: row.userFullName ?? "",
      phone: row.userPhone,
    },
    cropMap.get(row.id) ?? [],
  );
}

// ── Get farmer by linked user ID ──────────────────────────────────────────────

export async function getFarmerByUserId(
  userId: string,
): Promise<FarmerWithUser | null> {
  console.log(`[SERVICE] Getting farmer by userId=${userId}`);

  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      farmerFullName: farmers.fullName,
      farmerPhone: farmers.phone,
      registeredBy: farmers.registeredBy,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      preferredLanguage: farmers.preferredLanguage,
      hasAppAccess: farmers.hasAppAccess,
      farmSize: farmers.farmSize,
      experienceYears: farmers.experienceYears,
      primaryWorkerId: farmers.primaryWorkerId,
      createdAt: farmers.createdAt,
      updatedAt: farmers.updatedAt,
      userFullName: users.fullName,
      userPhone: users.phone,
    })
    .from(farmers)
    .leftJoin(users, eq(farmers.userId, users.id))
    .where(eq(farmers.userId, userId))
    .limit(1);

  if (rows.length === 0) return null;

  const row = rows[0];
  const cropMap = await attachCropIds([row.id]);

  return buildFarmerView(
    {
      id: row.id,
      userId: row.userId,
      fullName: row.farmerFullName,
      phone: row.farmerPhone,
      registeredBy: row.registeredBy,
      region: row.region,
      zone: row.zone,
      woreda: row.woreda,
      kebele: row.kebele,
      latitude: row.latitude,
      longitude: row.longitude,
      alertEnabled: row.alertEnabled,
      preferredLanguage: row.preferredLanguage,
      hasAppAccess: row.hasAppAccess,
      farmSize: row.farmSize,
      experienceYears: row.experienceYears,
      primaryWorkerId: row.primaryWorkerId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    },
    {
      fullName: row.userFullName ?? "",
      phone: row.userPhone,
    },
    cropMap.get(row.id) ?? [],
  );
}

// ── Update a farmer ───────────────────────────────────────────────────────────

export async function updateFarmer(
  id: string,
  data: {
    fullName?: string;
    phone?: string;
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

// ── Assign a crop to a farmer ─────────────────────────────────────────────────

export async function addCropToFarmer(
  farmerId: string,
  cropId: string,
) {
  console.log(
    `[SERVICE] Assigning crop ${cropId} to farmer ${farmerId}`,
  );

  const [relation] = await db
    .insert(farmerCrops)
    .values({ farmerId, cropId })
    .returning();

  console.log(
    `[DATABASE] Crop assigned: farmerId=${farmerId}, cropId=${cropId}`,
  );

  return relation;
}

// ── Get a farmer's crops

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

  console.log(
    `[DATABASE] Crops retrieved for farmer ${farmerId}: ${result.length}`,
  );

  return result;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function generateTemporaryPassword(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#";
  let password = "";
  for (let i = 0; i < 12; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}
export interface FarmerLocationItem {
  id: string;
  userId: string;
  fullName: string;
  phone: string | null;
  region: string | null;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  latitude: number;
  longitude: number;
  primaryCrop: string;
  alertEnabled: boolean;
  updatedAt: Date;
}

export async function listFarmerLocations(): Promise<FarmerLocationItem[]> {
  console.log("[SERVICE] Listing farmer locations for dynamic map");
  const rows = await db
    .select({
      id: farmers.id,
      userId: farmers.userId,
      fullName: users.fullName,
      phone: users.phone,
      region: farmers.region,
      zone: farmers.zone,
      woreda: farmers.woreda,
      kebele: farmers.kebele,
      latitude: farmers.latitude,
      longitude: farmers.longitude,
      alertEnabled: farmers.alertEnabled,
      updatedAt: farmers.updatedAt,
    })
    .from(farmers)
    .innerJoin(users, eq(farmers.userId, users.id));

  // Fetch primary crops
  const cropRows = await db
    .select({
      farmerId: farmerCrops.farmerId,
      cropName: crops.name,
    })
    .from(farmerCrops)
    .innerJoin(crops, eq(farmerCrops.cropId, crops.id));

  const cropMap = new Map<string, string>();
  for (const c of cropRows) {
    if (!cropMap.has(c.farmerId)) {
      cropMap.set(c.farmerId, c.cropName);
    }
  }

  // Baseline coordinates centered around Ethiopia if not explicitly set
  const defaultCoords = [
    { lat: 8.54, lng: 39.27 }, // Adama / Oromia
    { lat: 11.59, lng: 37.39 }, // Bahir Dar / Amhara
    { lat: 7.05, lng: 38.47 }, // Hawassa / Sidama
    { lat: 13.50, lng: 39.47 }, // Mekelle / Tigray
    { lat: 6.88, lng: 37.76 }, // Wolaita / SNNPR
  ];

  return rows.map((r, idx) => {
    const fallback = defaultCoords[idx % defaultCoords.length];
    return {
      id: r.id,
      userId: r.userId ?? "",
      fullName: r.fullName ?? "Farmer",
      phone: r.phone,
      region: r.region,
      zone: r.zone,
      woreda: r.woreda,
      kebele: r.kebele,
      latitude: r.latitude ?? fallback.lat,
      longitude: r.longitude ?? fallback.lng,
      primaryCrop: cropMap.get(r.id) ?? "Teff",
      alertEnabled: r.alertEnabled,
      updatedAt: r.updatedAt,
    };
  });
}


/**
 * Record-level permission check (re-exported from farmer-assignment.service)
 */
export { canAccessFarmer } from "./farmer-assignment.service";
