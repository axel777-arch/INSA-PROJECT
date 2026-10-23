import { eq, and, or, inArray } from "drizzle-orm";
import { db } from "../../db/index";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";
import { farmerWorkerAssignments } from "../../../../database/schema/farmerWorkerAssignments";
import { hashPassword } from "../auth/auth.service";

// ── Shared response type ──────────────────────────────────────────────────────

export interface FarmerView {
  id: string;
  user_id: string | null;
  full_name: string;
  phone: string;
  preferred_language: string;
  has_app_access: boolean;
  farm_size: number | null;
  experience_years: number | null;
  region: string | null;
  zone: string | null;
  woreda: string | null;
  kebele: string | null;
  latitude: number | null;
  longitude: number | null;
  primary_worker_id: string | null;
  alert_enabled: boolean;
  active: boolean;
  crop_ids: string[];
  created_at: Date;
  updated_at: Date;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

async function attachCropIds(farmerIds: string[]): Promise<Map<string, string[]>> {
  if (farmerIds.length === 0) return new Map();
  const rows = await db
    .select({ farmerId: farmerCrops.farmerId, cropId: farmerCrops.cropId })
    .from(farmerCrops)
    .where(
      farmerIds.length === 1
        ? eq(farmerCrops.farmerId, farmerIds[0])
        : inArray(farmerCrops.farmerId, farmerIds),
    );
  const map = new Map<string, string[]>();
  for (const row of rows) {
    const existing = map.get(row.farmerId) ?? [];
    existing.push(row.cropId);
    map.set(row.farmerId, existing);
  }
  return map;
}

function buildView(
  farmer: typeof farmers.$inferSelect,
  userRow: { fullName: string | null; phone: string | null; active: boolean | null } | undefined,
  cropIdList: string[],
): FarmerView {
  // If the farmer has no user account, use the farmer's own name/phone fields.
  const fullName = farmer.fullName ?? userRow?.fullName ?? "";
  const phone = farmer.phoneNumber ?? userRow?.phone ?? "";
  return {
    id: farmer.id,
    user_id: farmer.userId ?? null,
    full_name: fullName,
    phone,
    preferred_language: farmer.preferredLanguage ?? "amharic",
    has_app_access: farmer.hasAppAccess,
    farm_size: farmer.farmSize ?? null,
    experience_years: farmer.experienceYears ?? null,
    region: farmer.region ?? null,
    zone: farmer.zone ?? null,
    woreda: farmer.woreda ?? null,
    kebele: farmer.kebele ?? null,
    latitude: farmer.latitude ?? null,
    longitude: farmer.longitude ?? null,
    primary_worker_id: farmer.primaryWorkerId ?? null,
    alert_enabled: farmer.alertEnabled,
    active: userRow?.active ?? true,
    crop_ids: cropIdList,
    created_at: farmer.createdAt,
    updated_at: farmer.updatedAt,
  };
}

// ── Service functions ─────────────────────────────────────────────────────────

export async function createFarmer(data: {
  fullName: string;
  phone: string;
  preferredLanguage?: string;
  createAppAccount?: boolean;
  userId?: string;
  farmSize?: number;
  experienceYears?: number;
  region?: string;
  zone?: string;
  woreda?: string;
  kebele?: string;
  latitude?: number;
  longitude?: number;
  alertEnabled?: boolean;
  cropIds?: string[];
  primaryWorkerId?: string;
}): Promise<FarmerView & { temporaryPassword?: string }> {
  console.log(`[SERVICE] Creating farmer: name=${data.fullName}`);

  let resolvedUserId: string | null = data.userId ?? null;
  let temporaryPassword: string | undefined;

  if (data.createAppAccount && !resolvedUserId) {
    // Generate a secure random temporary password (never the phone number)
    temporaryPassword = generateTemporaryPassword();
    const passwordHash = await hashPassword(temporaryPassword);

    const [newUser] = await db
      .insert(users)
      .values({
        fullName: data.fullName,
        phone: data.phone,
        passwordHash,
        role: "FARMER",
        preferredLanguage: data.preferredLanguage ?? "amharic",
        active: true,
      })
      .returning({ id: users.id });

    resolvedUserId = newUser.id;
    console.log(`[SERVICE] App account created for farmer: userId=${resolvedUserId}`);
  }

  const [farmer] = await db
    .insert(farmers)
    .values({
      userId: resolvedUserId,
      fullName: data.fullName,
      phoneNumber: data.phone,
      preferredLanguage: data.preferredLanguage ?? "amharic",
      hasAppAccess: !!data.createAppAccount,
      farmSize: data.farmSize,
      experienceYears: data.experienceYears,
      region: data.region,
      zone: data.zone,
      woreda: data.woreda,
      kebele: data.kebele,
      latitude: data.latitude,
      longitude: data.longitude,
      alertEnabled: data.alertEnabled ?? true,
      primaryWorkerId: data.primaryWorkerId ?? null,
    })
    .returning();

  console.log(`[DATABASE] Farmer created: id=${farmer.id}`);

  // Assign initial crops if provided
  if (data.cropIds && data.cropIds.length > 0) {
    await db
      .insert(farmerCrops)
      .values(data.cropIds.map((cropId) => ({ farmerId: farmer.id, cropId })))
      .onConflictDoNothing();
  }

  const userRow = resolvedUserId
    ? await db
        .select({ fullName: users.fullName, phone: users.phone, active: users.active })
        .from(users)
        .where(eq(users.id, resolvedUserId))
        .limit(1)
        .then((r) => r[0])
    : undefined;

  const view = buildView(farmer, userRow, data.cropIds ?? []);

  if (temporaryPassword) {
    return { ...view, temporaryPassword };
  }
  return view;
}

/**
 * List farmers — scoped for extension workers (only their assigned farmers),
 * unrestricted for admins.
 */
export async function listFarmers(options: {
  requestingUserId: string;
  requestingUserRole: string;
}): Promise<FarmerView[]> {
  console.log(`[SERVICE] Listing farmers for user=${options.requestingUserId} role=${options.requestingUserRole}`);

  let farmerRows: (typeof farmers.$inferSelect)[];

  if (options.requestingUserRole === "EXTENSION_WORKER") {
    // Get farmers either primary-assigned to this worker, or via assignment table
    const assignmentRows = await db
      .select({ farmerId: farmerWorkerAssignments.farmerId })
      .from(farmerWorkerAssignments)
      .where(
        and(
          eq(farmerWorkerAssignments.workerId, options.requestingUserId),
          eq(farmerWorkerAssignments.status, "ACTIVE"),
        ),
      );

    const assignedFarmerIds = assignmentRows.map((r) => r.farmerId);

    // Also include farmers where primaryWorkerId matches
    const allConditions = assignedFarmerIds.length > 0
      ? or(
          eq(farmers.primaryWorkerId, options.requestingUserId),
          inArray(farmers.id, assignedFarmerIds),
        )
      : eq(farmers.primaryWorkerId, options.requestingUserId);

    farmerRows = await db.select().from(farmers).where(allConditions);
  } else {
    // Admin, Expert: return all
    farmerRows = await db.select().from(farmers);
  }

  if (farmerRows.length === 0) return [];

  // Join user data in one query
  const userIds = farmerRows
    .map((f) => f.userId)
    .filter((id): id is string => id !== null);

  const userRows = userIds.length > 0
    ? await db
        .select({ id: users.id, fullName: users.fullName, phone: users.phone, active: users.active })
        .from(users)
        .where(inArray(users.id, userIds))
    : [];
  const userMap = new Map(userRows.map((u) => [u.id, u]));

  const cropMap = await attachCropIds(farmerRows.map((f) => f.id));

  console.log(`[DATABASE] Farmers retrieved: ${farmerRows.length}`);
  return farmerRows.map((f) =>
    buildView(f, f.userId ? userMap.get(f.userId) : undefined, cropMap.get(f.id) ?? []),
  );
}

export async function getFarmerById(id: string): Promise<FarmerView | null> {
  console.log(`[SERVICE] Getting farmer by id=${id}`);
  const rows = await db.select().from(farmers).where(eq(farmers.id, id)).limit(1);
  if (rows.length === 0) return null;
  const farmer = rows[0];
  const userRow = farmer.userId
    ? await db
        .select({ fullName: users.fullName, phone: users.phone, active: users.active })
        .from(users)
        .where(eq(users.id, farmer.userId))
        .limit(1)
        .then((r) => r[0])
    : undefined;
  const cropMap = await attachCropIds([farmer.id]);
  return buildView(farmer, userRow, cropMap.get(farmer.id) ?? []);
}

export async function getFarmerByUserId(userId: string): Promise<FarmerView | null> {
  console.log(`[SERVICE] Getting farmer by userId=${userId}`);
  const rows = await db.select().from(farmers).where(eq(farmers.userId, userId)).limit(1);
  if (rows.length === 0) return null;
  const farmer = rows[0];
  const userRow = await db
    .select({ fullName: users.fullName, phone: users.phone, active: users.active })
    .from(users)
    .where(eq(users.id, userId))
    .limit(1)
    .then((r) => r[0]);
  const cropMap = await attachCropIds([farmer.id]);
  return buildView(farmer, userRow, cropMap.get(farmer.id) ?? []);
}

export async function updateFarmer(
  id: string,
  data: {
    fullName?: string;
    phone?: string;
    preferredLanguage?: string;
    farmSize?: number;
    experienceYears?: number;
    region?: string;
    zone?: string;
    woreda?: string;
    kebele?: string;
    latitude?: number;
    longitude?: number;
    alertEnabled?: boolean;
  },
): Promise<FarmerView | null> {
  console.log(`[SERVICE] Updating farmer id=${id}`);
  const [updated] = await db
    .update(farmers)
    .set({
      fullName: data.fullName,
      phoneNumber: data.phone,
      preferredLanguage: data.preferredLanguage,
      farmSize: data.farmSize,
      experienceYears: data.experienceYears,
      region: data.region,
      zone: data.zone,
      woreda: data.woreda,
      kebele: data.kebele,
      latitude: data.latitude,
      longitude: data.longitude,
      alertEnabled: data.alertEnabled,
      updatedAt: new Date(),
    })
    .where(eq(farmers.id, id))
    .returning();

  if (!updated) return null;
  console.log(`[DATABASE] Farmer updated: id=${updated.id}`);
  return getFarmerById(updated.id);
}

export async function assignFarmer(
  farmerId: string,
  assignedByUserId: string,
  data: {
    workerId: string;
    assignmentType?: "PRIMARY" | "TEMPORARY_COVERAGE" | "COLLABORATOR";
    reason?: string;
    endDate?: string;
  },
) {
  console.log(`[SERVICE] Assigning farmer ${farmerId} to worker ${data.workerId}`);

  const assignmentType = data.assignmentType ?? "PRIMARY";

  if (assignmentType === "PRIMARY") {
    // End previous primary assignments
    await db
      .update(farmerWorkerAssignments)
      .set({ status: "ENDED", endDate: new Date(), updatedAt: new Date() })
      .where(
        and(
          eq(farmerWorkerAssignments.farmerId, farmerId),
          eq(farmerWorkerAssignments.assignmentType, "PRIMARY"),
          eq(farmerWorkerAssignments.status, "ACTIVE"),
        ),
      );
    // Update primaryWorkerId on the farmer record
    await db
      .update(farmers)
      .set({ primaryWorkerId: data.workerId, updatedAt: new Date() })
      .where(eq(farmers.id, farmerId));
  }

  const [assignment] = await db
    .insert(farmerWorkerAssignments)
    .values({
      farmerId,
      workerId: data.workerId,
      assignedBy: assignedByUserId,
      assignmentType,
      status: "ACTIVE",
      startDate: new Date(),
      endDate: data.endDate ? new Date(data.endDate) : undefined,
      reason: data.reason,
    })
    .returning();

  console.log(`[DATABASE] Assignment created: id=${assignment.id}`);
  return assignment;
}

export async function getFarmerAssignments(farmerId: string) {
  return db
    .select({
      id: farmerWorkerAssignments.id,
      farmerId: farmerWorkerAssignments.farmerId,
      workerId: farmerWorkerAssignments.workerId,
      assignedBy: farmerWorkerAssignments.assignedBy,
      assignmentType: farmerWorkerAssignments.assignmentType,
      status: farmerWorkerAssignments.status,
      startDate: farmerWorkerAssignments.startDate,
      endDate: farmerWorkerAssignments.endDate,
      reason: farmerWorkerAssignments.reason,
      workerName: users.fullName,
    })
    .from(farmerWorkerAssignments)
    .leftJoin(users, eq(farmerWorkerAssignments.workerId, users.id))
    .where(eq(farmerWorkerAssignments.farmerId, farmerId));
}

export async function addCropToFarmer(farmerId: string, cropId: string) {
  console.log(`[SERVICE] Assigning crop ${cropId} to farmer ${farmerId}`);
  const [relation] = await db
    .insert(farmerCrops)
    .values({ farmerId, cropId })
    .onConflictDoNothing()
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

// ── Helpers ───────────────────────────────────────────────────────────────────

function generateTemporaryPassword(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#";
  let password = "";
  for (let i = 0; i < 12; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}
