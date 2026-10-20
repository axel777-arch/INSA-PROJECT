import { eq, desc } from "drizzle-orm";
import { db } from "../../db/index";
import { cases, caseResponses } from "../../../../database/schema/cases";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { crops } from "../../../../database/schema/crops";
import { addAuditEntry } from "../admin/admin.service";

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
  status: string;
  images: string | null;
  responseCount: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CaseDetail extends CaseListItem {
  responses: Array<{
    id: string;
    caseId: string;
    expertId: string | null;
    expertName: string;
    diagnosis: string;
    recommendation: string;
    internalNotes: string | null;
    images: string | null;
    createdAt: Date;
  }>;
}

export async function listCases(filters?: { status?: string; farmerId?: string }): Promise<CaseListItem[]> {
  console.log("[CASES] Listing cases with filters:", filters);

  const rows = await db
    .select({
      id: cases.id,
      farmerId: cases.farmerId,
      cropId: cases.cropId,
      title: cases.title,
      description: cases.description,
      location: cases.location,
      status: cases.status,
      images: cases.images,
      createdAt: cases.createdAt,
      updatedAt: cases.updatedAt,
      farmerUserId: farmers.userId,
      farmerName: users.fullName,
      farmerPhone: users.phone,
      cropName: crops.name,
    })
    .from(cases)
    .leftJoin(farmers, eq(cases.farmerId, farmers.id))
    .leftJoin(users, eq(farmers.userId, users.id))
    .leftJoin(crops, eq(cases.cropId, crops.id))
    .orderBy(desc(cases.createdAt));

  // Count responses per case
  const allResponses = await db
    .select({ id: caseResponses.id, caseId: caseResponses.caseId })
    .from(caseResponses);

  const responseCountMap = new Map<string, number>();
  for (const resp of allResponses) {
    const curr = responseCountMap.get(resp.caseId) ?? 0;
    responseCountMap.set(resp.caseId, curr + 1);
  }

  let results = rows.map((r) => ({
    id: r.id,
    farmerId: r.farmerId,
    farmerName: r.farmerName ?? "Unknown Farmer",
    farmerPhone: r.farmerPhone,
    cropId: r.cropId,
    cropName: r.cropName,
    title: r.title,
    description: r.description,
    location: r.location,
    status: r.status,
    images: r.images,
    responseCount: responseCountMap.get(r.id) ?? 0,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  }));

  if (filters?.status) {
    const statuses = filters.status.split(",").map((s) => s.trim().toUpperCase());
    results = results.filter((c) => statuses.includes(c.status));
  }

  if (filters?.farmerId) {
    results = results.filter((c) => c.farmerId === filters.farmerId);
  }

  return results;
}

export async function getCaseById(id: string): Promise<CaseDetail | null> {
  console.log(`[CASES] Fetching case id=${id}`);
  const rows = await db
    .select({
      id: cases.id,
      farmerId: cases.farmerId,
      cropId: cases.cropId,
      title: cases.title,
      description: cases.description,
      location: cases.location,
      status: cases.status,
      images: cases.images,
      createdAt: cases.createdAt,
      updatedAt: cases.updatedAt,
      farmerUserId: farmers.userId,
      farmerName: users.fullName,
      farmerPhone: users.phone,
      cropName: crops.name,
    })
    .from(cases)
    .leftJoin(farmers, eq(cases.farmerId, farmers.id))
    .leftJoin(users, eq(farmers.userId, users.id))
    .leftJoin(crops, eq(cases.cropId, crops.id))
    .where(eq(cases.id, id))
    .limit(1);

  if (rows.length === 0) return null;
  const r = rows[0];

  const responsesRows = await db
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

  return {
    id: r.id,
    farmerId: r.farmerId,
    farmerName: r.farmerName ?? "Unknown Farmer",
    farmerPhone: r.farmerPhone,
    cropId: r.cropId,
    cropName: r.cropName,
    title: r.title,
    description: r.description,
    location: r.location,
    status: r.status,
    images: r.images,
    responseCount: responsesRows.length,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    responses: responsesRows.map((resp) => ({
      id: resp.id,
      caseId: resp.caseId,
      expertId: resp.expertId,
      expertName: resp.expertName ?? "Agricultural Expert",
      diagnosis: resp.diagnosis,
      recommendation: resp.recommendation,
      internalNotes: resp.internalNotes,
      images: resp.images,
      createdAt: resp.createdAt,
    })),
  };
}

export async function createCase(data: {
  farmerId?: string;
  cropId?: string;
  title: string;
  description: string;
  location?: string;
  images?: string;
}): Promise<CaseListItem> {
  const [created] = await db
    .insert(cases)
    .values({
      farmerId: data.farmerId ?? null,
      cropId: data.cropId ?? null,
      title: data.title,
      description: data.description,
      location: data.location ?? null,
      images: data.images ?? null,
      status: "OPEN",
    })
    .returning();

  return (await getCaseById(created.id))!;
}

export async function submitCaseResponse(
  caseId: string,
  expertUserId: string,
  data: {
    diagnosis: string;
    recommendation: string;
    internalNotes?: string;
    images?: string;
  }
) {
  console.log(`[CASES] Submitting expert response for case id=${caseId}`);

  // 1. Insert case response record
  const [response] = await db
    .insert(caseResponses)
    .values({
      caseId,
      expertId: expertUserId,
      diagnosis: data.diagnosis,
      recommendation: data.recommendation,
      internalNotes: data.internalNotes ?? null,
      images: data.images ?? null,
    })
    .returning();

  // 2. Auto-close / resolve case status in database
  const [updatedCase] = await db
    .update(cases)
    .set({
      status: "RESOLVED",
      updatedAt: new Date(),
    })
    .where(eq(cases.id, caseId))
    .returning();

  // 3. Record audit log
  await addAuditEntry({
    actor: expertUserId,
    actorName: "Expert",
    actorRole: "EXPERT",
    action: "CASE_RESOLVED",
    target: `Case resolved: ${updatedCase?.title ?? caseId}`,
    targetId: caseId,
  });

  return {
    response,
    case: updatedCase,
  };
}
