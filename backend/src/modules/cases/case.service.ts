import { and, desc, eq, inArray, isNull, ne, or, type SQL } from "drizzle-orm";
import { db } from "../../db/index";
import { cases, caseEvents, caseMessages, caseResponses } from "../../../../database/schema/cases";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { crops } from "../../../../database/schema/crops";
import { ForbiddenError, NotFoundError, ValidationError } from "../../utils/errors";
import { createNotification, notifyRoles } from "../notifications/notification.service";

export type CaseStatus =
  | "OPEN"
  | "ASSIGNED"
  | "IN_PROGRESS"
  | "WAITING_FOR_INFORMATION"
  | "ESCALATED"
  | "RESOLVED"
  | "CLOSED";

export interface CaseActor {
  id: string;
  role: string;
}

export interface CaseListItem {
  id: string;
  farmerId: string | null;
  farmerName: string;
  farmerPhone: string | null;
  cropId: string | null;
  cropName: string | null;
  title: string;
  description: string;
  location: string | null;
  category: string;
  priority: string;
  source: string;
  assignedTo: string | null;
  observationDate: string | null;
  preferredResponseLanguage: string | null;
  resolutionSummary: string | null;
  status: string;
  attachments: string | null;
  images: string | null;
  responseCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const caseStatuses: CaseStatus[] = [
  "OPEN",
  "ASSIGNED",
  "IN_PROGRESS",
  "WAITING_FOR_INFORMATION",
  "ESCALATED",
  "RESOLVED",
  "CLOSED",
];

const transitions: Record<CaseStatus, CaseStatus[]> = {
  OPEN: ["ASSIGNED", "IN_PROGRESS", "WAITING_FOR_INFORMATION", "ESCALATED", "RESOLVED"],
  ASSIGNED: ["OPEN", "IN_PROGRESS", "WAITING_FOR_INFORMATION", "ESCALATED", "RESOLVED"],
  IN_PROGRESS: ["WAITING_FOR_INFORMATION", "ESCALATED", "RESOLVED"],
  WAITING_FOR_INFORMATION: ["IN_PROGRESS", "ESCALATED", "RESOLVED"],
  ESCALATED: ["ASSIGNED", "IN_PROGRESS", "WAITING_FOR_INFORMATION", "RESOLVED"],
  RESOLVED: ["IN_PROGRESS", "CLOSED"],
  CLOSED: [],
};

function serializeDetails(details: Record<string, unknown>): string {
  return JSON.stringify(details);
}

async function recordEvent(caseId: string, actorId: string, eventType: string, details: Record<string, unknown>) {
  await db.insert(caseEvents).values({ caseId, actorId, eventType, details: serializeDetails(details) });
}

async function getCaseOrThrow(id: string) {
  const [found] = await db.select().from(cases).where(eq(cases.id, id)).limit(1);
  if (!found) throw new NotFoundError("Case");
  return found;
}

async function farmerProfileId(userId: string): Promise<string | null> {
  const [profile] = await db.select({ id: farmers.id }).from(farmers).where(eq(farmers.userId, userId)).limit(1);
  return profile?.id ?? null;
}

async function assertCaseAccess(caseId: string, actor: CaseActor) {
  const found = await getCaseOrThrow(caseId);
  if (actor.role === "FARMER") {
    const farmerId = await farmerProfileId(actor.id);
    if (!farmerId || found.farmerId !== farmerId) throw new ForbiddenError("You cannot access this case");
  } else if (actor.role !== "ADMIN"
      && found.assignedTo !== null
      && found.assignedTo !== actor.id
      && found.creatorId !== actor.id) {
    throw new ForbiddenError("This case is assigned to another worker");
  }
  return found;
}

async function caseViewRows(filters: Array<ReturnType<typeof eq>>) {
  const query = db
    .select({
      id: cases.id,
      farmerId: cases.farmerId,
      cropId: cases.cropId,
      title: cases.title,
      description: cases.description,
      location: cases.location,
      category: cases.category,
      priority: cases.priority,
      source: cases.source,
      assignedTo: cases.assignedTo,
      observationDate: cases.observationDate,
      preferredResponseLanguage: cases.preferredResponseLanguage,
      resolutionSummary: cases.resolutionSummary,
      status: cases.status,
      attachments: cases.attachments,
      images: cases.images,
      createdAt: cases.createdAt,
      updatedAt: cases.updatedAt,
      farmerName: users.fullName,
      farmerPhone: users.phone,
      cropName: crops.name,
    })
    .from(cases)
    .leftJoin(farmers, eq(cases.farmerId, farmers.id))
    .leftJoin(users, eq(farmers.userId, users.id))
    .leftJoin(crops, eq(cases.cropId, crops.id))
    .orderBy(desc(cases.createdAt));

  return filters.length ? query.where(and(...filters)) : query;
}

export async function listCases(actor: CaseActor, filters?: { status?: string }): Promise<CaseListItem[]> {
  const conditions: SQL[] = [];
  if (actor.role === "FARMER") {
    const farmerId = await farmerProfileId(actor.id);
    if (!farmerId) return [];
    conditions.push(eq(cases.farmerId, farmerId));
  } else if (actor.role !== "ADMIN") {
    const workerScope = or(isNull(cases.assignedTo), eq(cases.assignedTo, actor.id), eq(cases.creatorId, actor.id));
    if (workerScope) conditions.push(workerScope);
  }
  if (filters?.status) {
    const statuses = filters.status.split(",").map((status) => status.trim().toUpperCase());
    if (statuses.some((status) => !caseStatuses.includes(status as CaseStatus))) {
      throw new ValidationError("Unsupported case status");
    }
    conditions.push(inArray(cases.status, statuses));
  }

  const rows = await caseViewRows(conditions);
  const responseRows = await db.select({ caseId: caseResponses.caseId }).from(caseResponses);
  const responseCounts = new Map<string, number>();
  for (const response of responseRows) {
    responseCounts.set(response.caseId, (responseCounts.get(response.caseId) ?? 0) + 1);
  }

  return rows.map((row) => ({
    ...row,
    farmerName: row.farmerName ?? "Unknown Farmer",
    responseCount: responseCounts.get(row.id) ?? 0,
  }));
}

export async function getCaseById(id: string, actor: CaseActor) {
  await assertCaseAccess(id, actor);
  const [row] = await caseViewRows([eq(cases.id, id)]);
  if (!row) return null;

  const responses = await db
    .select({
      id: caseResponses.id,
      caseId: caseResponses.caseId,
      expertId: caseResponses.expertId,
      diagnosis: caseResponses.diagnosis,
      recommendation: caseResponses.recommendation,
      internalNotes: caseResponses.internalNotes,
      images: caseResponses.images,
      createdAt: caseResponses.createdAt,
      expertName: users.fullName,
    })
    .from(caseResponses)
    .leftJoin(users, eq(caseResponses.expertId, users.id))
    .where(eq(caseResponses.caseId, id))
    .orderBy(desc(caseResponses.createdAt));

  const messages = await db
    .select()
    .from(caseMessages)
    .where(
      actor.role === "FARMER"
        ? and(eq(caseMessages.caseId, id), ne(caseMessages.visibility, "INTERNAL"))
        : eq(caseMessages.caseId, id),
    )
    .orderBy(desc(caseMessages.createdAt));
  const unreadMessageIds = messages
    .filter((message) => message.recipientId === actor.id && message.readAt === null)
    .map((message) => message.id);
  if (unreadMessageIds.length) {
    await db
      .update(caseMessages)
      .set({ readAt: new Date() })
      .where(inArray(caseMessages.id, unreadMessageIds));
  }
  const events = await db
    .select()
    .from(caseEvents)
    .where(eq(caseEvents.caseId, id))
    .orderBy(desc(caseEvents.createdAt));

  return {
    ...row,
    farmerName: row.farmerName ?? "Unknown Farmer",
    farmerPhone: row.farmerPhone,
    responseCount: responses.length,
    responses: responses.map((response) => ({
      ...response,
      expertName: response.expertName ?? "Agricultural Expert",
      internalNotes: actor.role === "FARMER" ? null : response.internalNotes,
    })),
    messages: messages.map((message) => ({
      ...message,
      readAt: unreadMessageIds.includes(message.id) ? new Date() : message.readAt,
    })),
    events: events.map((event) => ({
      ...event,
      details: actor.role === "FARMER" ? null : event.details,
    })),
  };
}

export async function createCase(
  actor: CaseActor,
  data: {
    farmerId?: string;
    cropId?: string;
    title: string;
    description: string;
    location?: string;
    category?: string;
    priority?: string;
    source?: string;
    observationDate?: string;
    preferredResponseLanguage?: string;
    attachments?: string;
  },
) {
  let relatedFarmerId = data.farmerId ?? null;
  if (actor.role === "FARMER") {
    relatedFarmerId = await farmerProfileId(actor.id);
    if (!relatedFarmerId) throw new ValidationError("Your account does not have a farmer profile");
  } else if (relatedFarmerId) {
    const [farmer] = await db.select({ id: farmers.id }).from(farmers).where(eq(farmers.id, relatedFarmerId)).limit(1);
    if (!farmer) throw new ValidationError("Farmer does not exist");
  }
  if (data.cropId) {
    const [crop] = await db.select({ id: crops.id }).from(crops).where(eq(crops.id, data.cropId)).limit(1);
    if (!crop) throw new ValidationError("Crop does not exist");
  }

  const [created] = await db
    .insert(cases)
    .values({
      farmerId: relatedFarmerId,
      creatorId: actor.id,
      cropId: data.cropId ?? null,
      title: data.title,
      description: data.description,
      location: data.location ?? null,
      category: data.category?.trim() || "GENERAL",
      priority: data.priority ?? "NORMAL",
      source: data.source ?? (actor.role === "FARMER" ? "FARMER_QUESTION" : "FIELD_OBSERVATION"),
      observationDate: data.observationDate ?? null,
      preferredResponseLanguage: data.preferredResponseLanguage ?? null,
      attachments: data.attachments ?? null,
    })
    .returning();

  await recordEvent(created.id, actor.id, "CASE_CREATED", { source: created.source });
  await notifyRoles(["EXTENSION_WORKER", "EXPERT"], {
    eventType: "NEW_CASE",
    resourceType: "CASE",
    resourceId: created.id,
    title: "New farmer question",
    body: created.title,
    route: "/expert/case/detail",
  });
  return getCaseById(created.id, actor);
}

export async function assignCase(caseId: string, actor: CaseActor, assignedTo: string) {
  if (actor.role !== "ADMIN" && actor.role !== "EXTENSION_WORKER" && actor.role !== "EXPERT") {
    throw new ForbiddenError("Only case workers can assign cases");
  }
  const current = await assertCaseAccess(caseId, actor);
  const [assignee] = await db
    .select({ id: users.id, role: users.role, active: users.active })
    .from(users)
    .where(eq(users.id, assignedTo))
    .limit(1);
  if (!assignee || !assignee.active || !["EXTENSION_WORKER", "EXPERT"].includes(assignee.role)) {
    throw new ValidationError("Assignee must be an active extension worker or expert");
  }
  if (current.status === "RESOLVED" || current.status === "CLOSED") {
    throw new ValidationError(`Case cannot be assigned while in ${current.status}`);
  }
  const nextStatus = current.status === "OPEN" || current.status === "ESCALATED" ? "ASSIGNED" : current.status;
  await db.update(cases).set({ assignedTo, status: nextStatus, updatedAt: new Date() }).where(eq(cases.id, caseId));
  await recordEvent(caseId, actor.id, "CASE_ASSIGNED", { previousAssignee: current.assignedTo, assignedTo });
  await createNotification({
    recipientId: assignee.id,
    eventType: "CASE_ASSIGNED",
    resourceType: "CASE",
    resourceId: caseId,
    title: "Case assigned",
    body: current.title,
    route: "/expert/case/detail",
  });
  return getCaseById(caseId, actor);
}

export async function changeCaseStatus(
  caseId: string,
  actor: CaseActor,
  status: CaseStatus,
  details?: string,
) {
  if (actor.role !== "ADMIN" && actor.role !== "EXTENSION_WORKER" && actor.role !== "EXPERT") {
    throw new ForbiddenError("Only case workers can change case status");
  }
  const current = await assertCaseAccess(caseId, actor);
  if (!transitions[current.status as CaseStatus]?.includes(status)) {
    throw new ValidationError(`Invalid case status transition: ${current.status} -> ${status}`);
  }
  const resolutionSummary = status === "RESOLVED" ? details?.trim() || null : current.resolutionSummary;
  await db
    .update(cases)
    .set({ status, ...(status === "RESOLVED" ? { resolutionSummary } : {}), updatedAt: new Date() })
    .where(eq(cases.id, caseId));
  await recordEvent(caseId, actor.id, `STATUS_${status}`, { from: current.status, summary: details ?? null });

  if (status === "ESCALATED") {
    await notifyRoles(["EXPERT", "ADMIN"], {
      eventType: "CASE_ESCALATED",
      resourceType: "CASE",
      resourceId: caseId,
      title: "Case escalated",
      body: current.title,
      route: "/expert/case/detail",
    });
  }
  if (status === "WAITING_FOR_INFORMATION" && current.farmerId) {
    const [profile] = await db
      .select({ userId: farmers.userId })
      .from(farmers)
      .where(eq(farmers.id, current.farmerId))
      .limit(1);
    if (profile) {
      await createNotification({
        recipientId: profile.userId ?? '',
        eventType: "INFORMATION_REQUESTED",
        resourceType: "CASE",
        resourceId: caseId,
        title: "More information requested",
        body: current.title,
        route: "/farmer/cases",
      });
    }
  }
  return getCaseById(caseId, actor);
}

export async function addCaseMessage(
  caseId: string,
  actor: CaseActor,
  body: string,
  visibility: "FARMER" | "INTERNAL",
  attachments?: string,
  notifyRecipient = true,
) {
  const current = await assertCaseAccess(caseId, actor);
  if (actor.role === "FARMER" && visibility !== "FARMER") {
    throw new ForbiddenError("Farmers cannot create internal messages");
  }
  if (actor.role === "FARMER" && !current.farmerId) {
    throw new ForbiddenError("This case is not linked to your farmer profile");
  }
  const [message] = await db
    .insert(caseMessages)
    .values({
      caseId,
      senderId: actor.id,
      recipientId: actor.role === "FARMER"
        ? current.assignedTo
        : current.assignedTo && current.assignedTo !== actor.id
          ? current.assignedTo
          : current.creatorId && current.creatorId !== actor.id
            ? current.creatorId
            : null,
      body,
      visibility,
      attachments: attachments ?? null,
    })
    .returning();

  await recordEvent(caseId, actor.id, "MESSAGE_ADDED", { messageId: message.id, visibility });
  if (actor.role === "FARMER" && current.status === "WAITING_FOR_INFORMATION") {
    await db.update(cases)
      .set({ status: "IN_PROGRESS", updatedAt: new Date() })
      .where(eq(cases.id, caseId));
    await recordEvent(caseId, actor.id, "STATUS_IN_PROGRESS", {
      from: "WAITING_FOR_INFORMATION",
      reason: "Farmer supplied follow-up information",
    });
  }
  if (!notifyRecipient) return message;
  if (message.recipientId && message.recipientId !== actor.id) {
    await createNotification({
      recipientId: message.recipientId,
      eventType: "CASE_MESSAGE",
      resourceType: "CASE",
      resourceId: message.id,
      title: "New case message",
      body: current.title,
      route: actor.role === "FARMER" ? "/expert/case/detail" : "/farmer/cases",
    });
  } else if (visibility === "FARMER" && current.farmerId) {
    const [profile] = await db
      .select({ userId: farmers.userId })
      .from(farmers)
      .where(eq(farmers.id, current.farmerId))
      .limit(1);
    if (profile && profile.userId !== actor.id) {
      await createNotification({
        recipientId: profile.userId ?? '',
        eventType: "CASE_MESSAGE",
        resourceType: "CASE",
        resourceId: message.id,
        title: "New case reply",
        body: current.title,
        route: "/farmer/cases",
      });
    }
  } else if (visibility === "INTERNAL" && current.assignedTo && current.assignedTo !== actor.id) {
    await createNotification({
      recipientId: current.assignedTo,
      eventType: "CASE_MESSAGE",
      resourceType: "CASE",
      resourceId: message.id,
      title: "New internal case message",
      body: current.title,
      route: "/expert/case/detail",
    });
  }
  return message;
}

export async function submitCaseResponse(
  caseId: string,
  actor: CaseActor,
  data: {
    diagnosis: string;
    recommendation: string;
    internalNotes?: string;
    images?: string;
  },
) {
  if (actor.role !== "EXPERT" && actor.role !== "EXTENSION_WORKER" && actor.role !== "ADMIN") {
    throw new ForbiddenError("Only case workers can submit a case response");
  }
  const current = await assertCaseAccess(caseId, actor);
  const [response] = await db
    .insert(caseResponses)
    .values({
      caseId,
      expertId: actor.id,
      diagnosis: data.diagnosis,
      recommendation: data.recommendation,
      internalNotes: data.internalNotes ?? null,
      images: data.images ?? null,
    })
    .returning();

  const resolutionSummary = `${data.diagnosis}\n${data.recommendation}`;
  await db
    .update(cases)
    .set({ status: "RESOLVED", resolutionSummary, updatedAt: new Date() })
    .where(eq(cases.id, caseId));
  await recordEvent(caseId, actor.id, "CASE_RESOLVED", { responseId: response.id });
  if (current.farmerId) {
    const [profile] = await db
      .select({ userId: farmers.userId })
      .from(farmers)
      .where(eq(farmers.id, current.farmerId))
      .limit(1);
    if (profile) {
      await createNotification({
        recipientId: profile.userId ?? '',
        eventType: "CASE_RESOLVED",
        resourceType: "CASE",
        resourceId: caseId,
        title: "Case response available",
        body: current.title,
        route: "/farmer/cases",
      });
    }
  }
  return { response, case: await getCaseById(caseId, actor) };
}
