import { eq, and } from "drizzle-orm";
import { db } from "../../db/index";
import { followUpRecords } from "../../../../database/schema/followUpRecords";
import { users } from "../../../../database/schema/users";
import { farmers } from "../../../../database/schema/farmers";

export interface FollowUpView {
  id: string;
  farmer_id: string;
  worker_id: string;
  observation_id: string | null;
  scheduled_date: Date;
  completed_date: Date | null;
  status: string;
  notes: string | null;
  outcome: string | null;
  farmer_name: string;
  worker_name: string;
  created_at: Date;
  updated_at: Date;
}

export async function createFollowUp(data: {
  farmerId: string;
  workerId: string;
  observationId?: string;
  scheduledDate: string;
  notes?: string;
}): Promise<FollowUpView> {
  console.log(`[SERVICE] Creating follow-up for farmer=${data.farmerId} by worker=${data.workerId}`);

  const [record] = await db
    .insert(followUpRecords)
    .values({
      farmerId: data.farmerId,
      workerId: data.workerId,
      observationId: data.observationId ?? null,
      scheduledDate: new Date(data.scheduledDate),
      notes: data.notes ?? null,
    })
    .returning();

  console.log(`[DATABASE] Follow-up created: id=${record.id}`);
  return getFollowUpById(record.id) as Promise<FollowUpView>;
}

export async function listFollowUps(options: {
  requestingUserId: string;
  requestingUserRole: string;
  farmerId?: string;
  status?: string;
}): Promise<FollowUpView[]> {
  const rows = await db
    .select({
      id: followUpRecords.id,
      farmerId: followUpRecords.farmerId,
      workerId: followUpRecords.workerId,
      observationId: followUpRecords.observationId,
      scheduledDate: followUpRecords.scheduledDate,
      completedDate: followUpRecords.completedDate,
      status: followUpRecords.status,
      notes: followUpRecords.notes,
      outcome: followUpRecords.outcome,
      createdAt: followUpRecords.createdAt,
      updatedAt: followUpRecords.updatedAt,
      farmerFullName: farmers.fullName,
      workerFullName: users.fullName,
    })
    .from(followUpRecords)
    .leftJoin(farmers, eq(followUpRecords.farmerId, farmers.id))
    .leftJoin(users, eq(followUpRecords.workerId, users.id))
    .where(
      options.farmerId
        ? eq(followUpRecords.farmerId, options.farmerId)
        : options.requestingUserRole === "EXTENSION_WORKER"
        ? eq(followUpRecords.workerId, options.requestingUserId)
        : undefined,
    );

  return rows.map((r) => ({
    id: r.id,
    farmer_id: r.farmerId,
    worker_id: r.workerId,
    observation_id: r.observationId ?? null,
    scheduled_date: r.scheduledDate,
    completed_date: r.completedDate ?? null,
    status: r.status,
    notes: r.notes ?? null,
    outcome: r.outcome ?? null,
    farmer_name: r.farmerFullName ?? "",
    worker_name: r.workerFullName ?? "",
    created_at: r.createdAt,
    updated_at: r.updatedAt,
  }));
}

export async function getFollowUpById(id: string): Promise<FollowUpView | null> {
  const rows = await db
    .select({
      id: followUpRecords.id,
      farmerId: followUpRecords.farmerId,
      workerId: followUpRecords.workerId,
      observationId: followUpRecords.observationId,
      scheduledDate: followUpRecords.scheduledDate,
      completedDate: followUpRecords.completedDate,
      status: followUpRecords.status,
      notes: followUpRecords.notes,
      outcome: followUpRecords.outcome,
      createdAt: followUpRecords.createdAt,
      updatedAt: followUpRecords.updatedAt,
      farmerFullName: farmers.fullName,
      workerFullName: users.fullName,
    })
    .from(followUpRecords)
    .leftJoin(farmers, eq(followUpRecords.farmerId, farmers.id))
    .leftJoin(users, eq(followUpRecords.workerId, users.id))
    .where(eq(followUpRecords.id, id))
    .limit(1);

  if (rows.length === 0) return null;
  const r = rows[0];
  return {
    id: r.id,
    farmer_id: r.farmerId,
    worker_id: r.workerId,
    observation_id: r.observationId ?? null,
    scheduled_date: r.scheduledDate,
    completed_date: r.completedDate ?? null,
    status: r.status,
    notes: r.notes ?? null,
    outcome: r.outcome ?? null,
    farmer_name: r.farmerFullName ?? "",
    worker_name: r.workerFullName ?? "",
    created_at: r.createdAt,
    updated_at: r.updatedAt,
  };
}

export async function updateFollowUp(
  id: string,
  data: {
    status?: string;
    completedDate?: string;
    notes?: string;
    outcome?: string;
  },
): Promise<FollowUpView | null> {
  const [updated] = await db
    .update(followUpRecords)
    .set({
      ...(data.status ? { status: data.status as any } : {}),
      ...(data.completedDate ? { completedDate: new Date(data.completedDate) } : {}),
      ...(data.notes !== undefined ? { notes: data.notes } : {}),
      ...(data.outcome !== undefined ? { outcome: data.outcome } : {}),
      updatedAt: new Date(),
    })
    .where(eq(followUpRecords.id, id))
    .returning();

  if (!updated) return null;
  return getFollowUpById(updated.id);
}
