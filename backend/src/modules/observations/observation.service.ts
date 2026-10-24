import { eq, and } from "drizzle-orm";
import { db } from "../../db/index";
import { fieldObservations, observationAttachments } from "../../../../database/schema/fieldObservations";
import { users } from "../../../../database/schema/users";
import { farmers } from "../../../../database/schema/farmers";
import { cases } from "../../../../database/schema/cases";
import { notifications } from "../../../../database/schema/notifications";

export interface ObservationView {
  id: string;
  farmer_id: string;
  worker_id: string;
  crop_id: string | null;
  observation_type: string;
  severity: string;
  title: string;
  description: string;
  action_taken: string | null;
  is_escalated: boolean;
  escalated_to_id: string | null;
  farmer_name: string;
  worker_name: string;
  attachments: AttachmentView[];
  created_at: Date;
  updated_at: Date;
}

export interface AttachmentView {
  id: string;
  observation_id: string;
  file_url: string;
  file_type: string;
  file_name: string | null;
  uploaded_at: Date;
}

export async function createObservation(data: {
  farmerId: string;
  workerId: string;
  cropId?: string;
  observationType?: string;
  severity?: string;
  title: string;
  description: string;
  actionTaken?: string;
}): Promise<ObservationView> {
  console.log(`[SERVICE] Creating observation for farmer=${data.farmerId} by worker=${data.workerId}`);

  const [obs] = await db
    .insert(fieldObservations)
    .values({
      farmerId: data.farmerId,
      workerId: data.workerId,
      cropId: data.cropId ?? null,
      observationType: (data.observationType ?? "GENERAL_CHECKUP") as any,
      severity: (data.severity ?? "LOW") as any,
      title: data.title,
      description: data.description,
      actionTaken: data.actionTaken ?? null,
    })
    .returning();

  console.log(`[DATABASE] Observation created: id=${obs.id}`);
  return getObservationById(obs.id) as Promise<ObservationView>;
}

export async function listObservations(filters: {
  requestingUserId: string;
  requestingUserRole: string;
  farmerId?: string;
  isEscalated?: boolean;
}): Promise<ObservationView[]> {
  const rows = await db
    .select({
      id: fieldObservations.id,
      farmerId: fieldObservations.farmerId,
      workerId: fieldObservations.workerId,
      cropId: fieldObservations.cropId,
      observationType: fieldObservations.observationType,
      severity: fieldObservations.severity,
      title: fieldObservations.title,
      description: fieldObservations.description,
      actionTaken: fieldObservations.actionTaken,
      isEscalated: fieldObservations.isEscalated,
      escalatedToId: fieldObservations.escalatedToId,
      createdAt: fieldObservations.createdAt,
      updatedAt: fieldObservations.updatedAt,
      farmerFullName: farmers.fullName,
      workerFullName: users.fullName,
    })
    .from(fieldObservations)
    .leftJoin(farmers, eq(fieldObservations.farmerId, farmers.id))
    .leftJoin(users, eq(fieldObservations.workerId, users.id))
    .where(
      filters.farmerId
        ? eq(fieldObservations.farmerId, filters.farmerId)
        : filters.requestingUserRole === "EXTENSION_WORKER"
        ? eq(fieldObservations.workerId, filters.requestingUserId)
        : undefined,
    );

  return rows.map((r) => ({
    id: r.id,
    farmer_id: r.farmerId,
    worker_id: r.workerId,
    crop_id: r.cropId ?? null,
    observation_type: r.observationType,
    severity: r.severity,
    title: r.title,
    description: r.description,
    action_taken: r.actionTaken ?? null,
    is_escalated: r.isEscalated,
    escalated_to_id: r.escalatedToId ?? null,
    farmer_name: r.farmerFullName ?? "",
    worker_name: r.workerFullName ?? "",
    attachments: [],
    created_at: r.createdAt,
    updated_at: r.updatedAt,
  }));
}

export async function getObservationById(id: string): Promise<ObservationView | null> {
  const rows = await db
    .select({
      id: fieldObservations.id,
      farmerId: fieldObservations.farmerId,
      workerId: fieldObservations.workerId,
      cropId: fieldObservations.cropId,
      observationType: fieldObservations.observationType,
      severity: fieldObservations.severity,
      title: fieldObservations.title,
      description: fieldObservations.description,
      actionTaken: fieldObservations.actionTaken,
      isEscalated: fieldObservations.isEscalated,
      escalatedToId: fieldObservations.escalatedToId,
      createdAt: fieldObservations.createdAt,
      updatedAt: fieldObservations.updatedAt,
      farmerFullName: farmers.fullName,
      workerFullName: users.fullName,
    })
    .from(fieldObservations)
    .leftJoin(farmers, eq(fieldObservations.farmerId, farmers.id))
    .leftJoin(users, eq(fieldObservations.workerId, users.id))
    .where(eq(fieldObservations.id, id))
    .limit(1);

  if (rows.length === 0) return null;
  const r = rows[0];

  const attachmentRows = await db
    .select()
    .from(observationAttachments)
    .where(eq(observationAttachments.observationId, id));

  return {
    id: r.id,
    farmer_id: r.farmerId,
    worker_id: r.workerId,
    crop_id: r.cropId ?? null,
    observation_type: r.observationType,
    severity: r.severity,
    title: r.title,
    description: r.description,
    action_taken: r.actionTaken ?? null,
    is_escalated: r.isEscalated,
    escalated_to_id: r.escalatedToId ?? null,
    farmer_name: r.farmerFullName ?? "",
    worker_name: r.workerFullName ?? "",
    attachments: attachmentRows.map((a) => ({
      id: a.id,
      observation_id: a.observationId,
      file_url: a.fileUrl,
      file_type: a.fileType,
      file_name: a.fileName ?? null,
      uploaded_at: a.uploadedAt,
    })),
    created_at: r.createdAt,
    updated_at: r.updatedAt,
  };
}

export async function updateObservation(
  id: string,
  data: {
    observationType?: string;
    severity?: string;
    title?: string;
    description?: string;
    actionTaken?: string;
  },
): Promise<ObservationView | null> {
  const [updated] = await db
    .update(fieldObservations)
    .set({
      ...(data.observationType ? { observationType: data.observationType as any } : {}),
      ...(data.severity ? { severity: data.severity as any } : {}),
      ...(data.title ? { title: data.title } : {}),
      ...(data.description ? { description: data.description } : {}),
      ...(data.actionTaken !== undefined ? { actionTaken: data.actionTaken } : {}),
      updatedAt: new Date(),
    })
    .where(eq(fieldObservations.id, id))
    .returning();

  if (!updated) return null;
  return getObservationById(updated.id);
}

export async function escalateObservation(
  id: string,
  escalatedToId: string,
): Promise<ObservationView | null> {
  console.log(`[SERVICE] Escalating observation ${id} to expert ${escalatedToId}`);
  const [updated] = await db
    .update(fieldObservations)
    .set({ isEscalated: true, escalatedToId, updatedAt: new Date() })
    .where(and(eq(fieldObservations.id, id), eq(fieldObservations.isEscalated, false)))
    .returning();

  if (!updated) return null;

  try {
    // 1. Create a linked case in cases table so it surfaces on FieldCaseResponseScreen for experts
    const [farmer] = await db
      .select()
      .from(farmers)
      .where(eq(farmers.id, updated.farmerId))
      .limit(1);

    const locationStr = farmer
      ? [farmer.region, farmer.zone, farmer.woreda, farmer.kebele].filter(Boolean).join(", ")
      : null;
    const priority =
      updated.severity === "CRITICAL" ? "URGENT" : updated.severity === "HIGH" ? "HIGH" : "NORMAL";

    const [createdCase] = await db
      .insert(cases)
      .values({
        farmerId: updated.farmerId,
        creatorId: updated.workerId,
        assignedTo: escalatedToId,
        cropId: updated.cropId,
        title: `[Field Observation] ${updated.title}`,
        description: updated.description,
        location: locationStr,
        category: updated.observationType,
        priority,
        source: "FIELD_OBSERVATION",
        status: "OPEN",
      })
      .returning();

    // 2. Trigger notification for experts
    const expertRecipients = await db
      .select({ id: users.id })
      .from(users)
      .where(and(eq(users.role, "EXPERT"), eq(users.active, true)));

    for (const expert of expertRecipients) {
      await db
        .insert(notifications)
        .values({
          recipientId: expert.id,
          eventType: "OBSERVATION_ESCALATED",
          resourceType: "CASE",
          resourceId: createdCase?.id ?? updated.id,
          title: "Field Observation Escalated",
          body: `Observation "${updated.title}" was escalated with ${updated.severity} severity.`,
          route: "/expert/cases",
        })
        .onConflictDoNothing();
    }
  } catch (error) {
    console.error("[SERVICE] Error linking escalated observation to cases/notifications:", error);
  }

  return getObservationById(updated.id);
}

export async function addObservationAttachment(data: {
  observationId: string;
  fileUrl: string;
  fileType: string;
  fileName?: string;
}): Promise<AttachmentView> {
  const [attachment] = await db
    .insert(observationAttachments)
    .values({
      observationId: data.observationId,
      fileUrl: data.fileUrl,
      fileType: data.fileType,
      fileName: data.fileName ?? null,
    })
    .returning();
  return {
    id: attachment.id,
    observation_id: attachment.observationId,
    file_url: attachment.fileUrl,
    file_type: attachment.fileType,
    file_name: attachment.fileName ?? null,
    uploaded_at: attachment.uploadedAt,
  };
}
