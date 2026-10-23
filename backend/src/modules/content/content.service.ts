import { assertTransition, canTransition } from "./content.workflow";
import { and, desc, asc, eq, ilike, or, gte, lte, ne, inArray } from "drizzle-orm";
import { db } from "../../db/index";
import { content } from "../../../../database/schema/content";
import { contentReviews } from "../../../../database/schema/contentReviews";
import { contentVersions } from "../../../../database/schema/contentVersions";
import { auditLogs } from "../../../../database/schema/auditLogs";
import { users } from "../../../../database/schema/users";
import { targetingService } from "../../services/targeting/targeting.service";
import { messageService } from "../messaging/message.service";
import {
  NotFoundError,
  ForbiddenError,
  ConflictError,
  ValidationError,
} from "../../utils/errors";
import type {
  Content,
  ContentVersion,
  ContentReview,
  ContentFilter,
  CreateContentInput,
  UpdateContentInput,
  SubmitForReviewInput,
  ApproveContentInput,
  RejectContentInput,
  RequestRevisionInput,
  PublishContentInput,
  ArchiveContentInput,
  ContentPublishedEvent,
} from "./content.types";

export const ContentStatus = {
  DRAFT: "DRAFT" as const,
  PENDING_REVIEW: "PENDING_REVIEW" as const,
  IN_REVIEW: "PENDING_REVIEW" as const, // backwards compatibility alias
  NEEDS_REVISION: "NEEDS_REVISION" as const,
  APPROVED: "APPROVED" as const,
  REJECTED: "REJECTED" as const,
  PUBLISHED: "PUBLISHED" as const,
  ARCHIVED: "ARCHIVED" as const,
};

export class ContentNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Content with id "${id}" was not found.`);
    this.name = "ContentNotFoundError";
  }
}

export class InvalidContentTransitionError extends ConflictError {
  constructor(message: string) {
    super(message);
    this.name = "InvalidContentTransitionError";
  }
}

export class ContentService {
  canTransition(from: string, to: string): boolean {
    return canTransition(from, to);
  }

  createDraft(input: {
    title: string;
    body: string;
    summary?: string | null;
    cropId?: string | null;
    category?: string | null;
    language?: string;
    region?: string | null;
    zone?: string | null;
    woreda?: string | null;
    kebele?: string | null;
    season?: string | null;
    cropStage?: string | null;
    priority?: string;
    validFrom?: Date | string | null;
    validUntil?: Date | string | null;
    sourceInfo?: string | null;
    attachments?: string | null;
    authorId?: string;
    createdBy?: string;
  }): Content {
    return {
      id: `content-${Date.now()}`,
      title: input.title,
      summary: input.summary ?? null,
      body: input.body,
      status: "DRAFT",
      cropId: input.cropId ?? null,
      category: input.category ?? null,
      language: input.language ?? "en",
      region: input.region ?? null,
      zone: input.zone ?? null,
      woreda: input.woreda ?? null,
      kebele: input.kebele ?? null,
      season: input.season ?? null,
      cropStage: input.cropStage ?? null,
      priority: input.priority ?? "NORMAL",
      validFrom: input.validFrom ? new Date(input.validFrom) : null,
      validUntil: input.validUntil ? new Date(input.validUntil) : null,
      sourceInfo: input.sourceInfo ?? null,
      attachments: input.attachments ?? null,
      version: 1,
      authorId: input.authorId ?? input.createdBy ?? null,
      approvedBy: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  submitForReview(item: Content): Content {
    if (!this.canTransition(item.status, ContentStatus.PENDING_REVIEW)) {
      throw new Error(`cannot move from ${item.status} to IN_REVIEW`);
    }
    return {
      ...item,
      status: "PENDING_REVIEW",
      updatedAt: new Date(),
    };
  }
}

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function findContentOrThrow(id: string): Promise<Content> {
  if (!UUID_REGEX.test(id)) {
    throw new ContentNotFoundError(id);
  }

  const [row] = await db.select().from(content).where(eq(content.id, id)).limit(1);

  if (!row) {
    throw new ContentNotFoundError(id);
  }

  return row;
}

/**
 * Creates an advisory draft in the database.
 * Automatically saves version 1 snapshot for auditing.
 */
export async function createContent(input: CreateContentInput): Promise<Content> {
  const author = input.authorId ?? input.createdBy;
  console.log(`[SERVICE] Creating content: "${input.title}" by userId=${author}`);

  const [created] = await db
    .insert(content)
    .values({
      title: input.title,
      summary: input.summary ?? null,
      body: input.body,
      cropId: input.cropId ?? null,
      category: input.category ?? null,
      language: input.language ?? "en",
      region: input.region ?? null,
      zone: input.zone ?? null,
      woreda: input.woreda ?? null,
      kebele: input.kebele ?? null,
      season: input.season ?? null,
      cropStage: input.cropStage ?? null,
      priority: input.priority ?? "NORMAL",
      validFrom: input.validFrom ? new Date(input.validFrom) : null,
      validUntil: input.validUntil ? new Date(input.validUntil) : null,
      sourceInfo: input.sourceInfo ?? null,
      attachments: input.attachments ?? null,
      version: 1,
      status: "DRAFT",
      authorId: author ?? null,
    })
    .returning();

  // Snapshot initial draft version
  try {
    await db.insert(contentVersions).values({
      contentId: created.id,
      versionNumber: 1,
      title: created.title,
      summary: created.summary,
      body: created.body,
      cropId: created.cropId,
      category: created.category,
      language: created.language,
      region: created.region,
      zone: created.zone,
      woreda: created.woreda,
      kebele: created.kebele,
      season: created.season,
      cropStage: created.cropStage,
      priority: created.priority,
      validFrom: created.validFrom,
      validUntil: created.validUntil,
      sourceInfo: created.sourceInfo,
      attachments: created.attachments,
      statusAtVersion: "DRAFT",
      authorId: author ?? null,
      changeSummary: "Initial draft creation",
    });
  } catch (err) {
    console.warn("[VERSION ERROR] Failed to record initial version snapshot:", err);
  }

  console.log(`[DATABASE] Content created: id=${created.id}, status=${created.status}`);
  return created;
}

/**
 * Lists content with comprehensive multi-criteria filtering and security scoping.
 * By default excludes archived content unless explicitly requested.
 */
export async function listContent(filter: ContentFilter): Promise<Content[]> {
  console.log("[SERVICE] Listing content with filter:", filter);
  const conditions = [];

  if (filter.status) {
    conditions.push(eq(content.status, filter.status));
  } else if (!filter.includeArchived) {
    // Exclude ARCHIVED items from active farmer feeds and standard listing
    conditions.push(ne(content.status, "ARCHIVED"));
  }

  if (filter.cropId) conditions.push(eq(content.cropId, filter.cropId));
  if (filter.category) conditions.push(eq(content.category, filter.category));
  if (filter.authorId) conditions.push(eq(content.authorId, filter.authorId));
  if (filter.language) conditions.push(eq(content.language, filter.language));
  if (filter.region) conditions.push(eq(content.region, filter.region));
  if (filter.zone) conditions.push(eq(content.zone, filter.zone));
  if (filter.woreda) conditions.push(eq(content.woreda, filter.woreda));

  if (filter.search && filter.search.trim().length > 0) {
    const term = `%${filter.search.trim()}%`;
    conditions.push(
      or(
        ilike(content.title, term),
        ilike(content.body, term),
        ilike(content.summary, term)
      )
    );
  }

  if (filter.dateFrom) {
    conditions.push(gte(content.createdAt, new Date(filter.dateFrom)));
  }
  if (filter.dateTo) {
    conditions.push(lte(content.createdAt, new Date(filter.dateTo)));
  }

  // If filtered by reviewerId, find contentIds evaluated by this reviewer
  if (filter.reviewerId) {
    const reviewedRows = await db
      .select({ contentId: contentReviews.contentId })
      .from(contentReviews)
      .where(eq(contentReviews.reviewerId, filter.reviewerId));

    const contentIds = reviewedRows.map((r) => r.contentId);
    if (contentIds.length === 0) {
      return [];
    }
    conditions.push(inArray(content.id, contentIds));
  }

  const query = db.select().from(content).orderBy(desc(content.createdAt));

  if (conditions.length > 0) {
    return query.where(and(...conditions));
  }
  const results = await query;
  console.log(`[DATABASE] Content retrieved: ${results.length} items`);
  return results;
}

export async function getContentById(id: string): Promise<Content> {
  return findContentOrThrow(id);
}

/**
 * Updates an existing draft or revision-requested content.
 * Enforces ownership: only author (or ADMIN) can update.
 */
export async function updateContent(
  id: string,
  input: UpdateContentInput,
  userId?: string,
  userRole?: string
): Promise<Content> {
  const current = await findContentOrThrow(id);

  // Status check: edits only allowed on DRAFT, NEEDS_REVISION, or REJECTED
  if (
    current.status !== "DRAFT" &&
    current.status !== "NEEDS_REVISION" &&
    current.status !== "REJECTED"
  ) {
    throw new InvalidContentTransitionError(
      `Cannot edit content in status "${current.status}". ` +
        `Content can only be edited while in DRAFT, NEEDS_REVISION, or REJECTED status.`
    );
  }

  // Ownership check: backend security rule
  if (userId && userRole !== "ADMIN" && current.authorId && current.authorId !== userId) {
    throw new ForbiddenError("You cannot edit content authored by another user.");
  }

  // If revising after review, bump version counter
  const newVersion =
    current.status === "NEEDS_REVISION" || current.status === "REJECTED"
      ? current.version + 1
      : current.version;

  const [updated] = await db
    .update(content)
    .set({
      ...(input.title !== undefined ? { title: input.title } : {}),
      ...(input.summary !== undefined ? { summary: input.summary } : {}),
      ...(input.body !== undefined ? { body: input.body } : {}),
      ...(input.cropId !== undefined ? { cropId: input.cropId } : {}),
      ...(input.category !== undefined ? { category: input.category } : {}),
      ...(input.language !== undefined ? { language: input.language } : {}),
      ...(input.region !== undefined ? { region: input.region } : {}),
      ...(input.zone !== undefined ? { zone: input.zone } : {}),
      ...(input.woreda !== undefined ? { woreda: input.woreda } : {}),
      ...(input.kebele !== undefined ? { kebele: input.kebele } : {}),
      ...(input.season !== undefined ? { season: input.season } : {}),
      ...(input.cropStage !== undefined ? { cropStage: input.cropStage } : {}),
      ...(input.priority !== undefined ? { priority: input.priority } : {}),
      ...(input.validFrom !== undefined
        ? { validFrom: input.validFrom ? new Date(input.validFrom) : null }
        : {}),
      ...(input.validUntil !== undefined
        ? { validUntil: input.validUntil ? new Date(input.validUntil) : null }
        : {}),
      ...(input.sourceInfo !== undefined ? { sourceInfo: input.sourceInfo } : {}),
      ...(input.attachments !== undefined ? { attachments: input.attachments } : {}),
      version: newVersion,
      ...(current.status === "REJECTED"
        ? {
            status: "DRAFT",
            approvedBy: null,
          }
        : {}),
      updatedAt: new Date(),
    })
    .where(eq(content.id, id))
    .returning();

  return updated;
}

/**
 * Submits content for expert review.
 * Preserves a recoverable version snapshot in content_versions table.
 */
export async function submitForReview(
  input: SubmitForReviewInput,
  userRole?: string
): Promise<Content> {
  const current = await findContentOrThrow(input.contentId);

  // Ownership check
  if (
    input.submittedBy &&
    userRole !== "ADMIN" &&
    current.authorId &&
    current.authorId !== input.submittedBy
  ) {
    throw new ForbiddenError("You can only submit your own drafts for review.");
  }

  const targetStatus = "PENDING_REVIEW" as const;
  assertTransition(current.status, targetStatus);

  return db.transaction(async (tx) => {
    // 1. Snapshot version before submitting
    const changeSummary =
      current.status === "NEEDS_REVISION"
        ? "Resubmitted for review after addressing reviewer comments"
        : "Submitted for expert review";

    await tx.insert(contentVersions).values({
      contentId: current.id,
      versionNumber: current.version,
      title: current.title,
      summary: current.summary,
      body: current.body,
      cropId: current.cropId,
      category: current.category,
      language: current.language,
      region: current.region,
      zone: current.zone,
      woreda: current.woreda,
      kebele: current.kebele,
      season: current.season,
      cropStage: current.cropStage,
      priority: current.priority,
      validFrom: current.validFrom,
      validUntil: current.validUntil,
      sourceInfo: current.sourceInfo,
      attachments: current.attachments,
      statusAtVersion: "PENDING_REVIEW",
      authorId: current.authorId,
      changeSummary,
    });

    // 2. Advance content status to PENDING_REVIEW
    const [updated] = await tx
      .update(content)
      .set({ status: "PENDING_REVIEW", updatedAt: new Date() })
      .where(eq(content.id, input.contentId))
      .returning();

    return updated;
  });
}

/**
 * Requests changes / additional information from the author.
 * Returns the draft to the author queue while preserving all reviewer comments and history.
 */
export async function requestRevision(
  input: RequestRevisionInput
): Promise<Content> {
  console.log(`[SERVICE] Requesting revision on content id=${input.contentId} by reviewerId=${input.reviewerId}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "NEEDS_REVISION" as const;
  assertTransition(current.status, targetStatus);

  const now = new Date();

  return db.transaction(async (tx) => {
    const [updated] = await tx
      .update(content)
      .set({
        status: "NEEDS_REVISION",
        updatedAt: now,
      })
      .where(eq(content.id, input.contentId))
      .returning();

    await tx.insert(contentReviews).values({
      contentId: input.contentId,
      reviewerId: input.reviewerId,
      status: "NEEDS_REVISION",
      comments: input.comment,
      reviewedAt: now,
    });

    try {
      await tx.insert(auditLogs).values({
        userId: input.reviewerId,
        action: "CONTENT_REVISION_REQUESTED",
        entityType: "CONTENT",
        entityId: input.contentId,
        details: JSON.stringify({
          title: updated.title,
          comment: input.comment,
          version: updated.version,
        }),
      });
    } catch (e) {
      console.error("[AUDIT ERROR] Failed to record revision request audit log:", e);
    }

    console.log(`[DATABASE] Content moved to revision queue: id=${input.contentId}`);
    return updated;
  });
}

export async function approveContent(
  input: ApproveContentInput
): Promise<Content> {
  console.log(`[SERVICE] Approving content id=${input.contentId} by userId=${input.approvedBy}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "APPROVED" as const;
  assertTransition(current.status, targetStatus);

  const now = new Date();

  return db.transaction(async (tx) => {
    const [updated] = await tx
      .update(content)
      .set({
        status: "APPROVED",
        approvedBy: input.approvedBy,
        updatedAt: now,
      })
      .where(eq(content.id, input.contentId))
      .returning();

    await tx.insert(contentReviews).values({
      contentId: input.contentId,
      reviewerId: input.approvedBy,
      status: "APPROVED",
      comments: input.comment ?? null,
      reviewedAt: now,
    });

    if (input.approvedBy) {
      try {
        await tx.insert(auditLogs).values({
          userId: input.approvedBy,
          action: "CONTENT_APPROVED",
          entityType: "CONTENT",
          entityId: input.contentId,
          details: JSON.stringify({ title: updated.title }),
        });
      } catch (e) {
        console.error("[AUDIT ERROR] Failed to record approve audit log:", e);
      }
    }
    console.log(`[DATABASE] Content approved: id=${input.contentId}`);
    return updated;
  });
}

export async function rejectContent(
  input: RejectContentInput
): Promise<Content> {
  console.log(`[SERVICE] Rejecting content id=${input.contentId} by userId=${input.rejectedBy}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "REJECTED" as const;
  assertTransition(current.status, targetStatus);

  const now = new Date();

  return db.transaction(async (tx) => {
    const [updated] = await tx
      .update(content)
      .set({ status: "REJECTED", updatedAt: now })
      .where(eq(content.id, input.contentId))
      .returning();

    await tx.insert(contentReviews).values({
      contentId: input.contentId,
      reviewerId: input.rejectedBy,
      status: "REJECTED",
      comments: input.comment,
      reviewedAt: now,
    });

    try {
      await tx.insert(auditLogs).values({
        userId: input.rejectedBy,
        action: "CONTENT_REJECTED",
        entityType: "CONTENT",
        entityId: input.contentId,
        details: JSON.stringify({ title: updated.title, comment: input.comment }),
      });
    } catch (e) {
      console.error("[AUDIT ERROR] Failed to record reject audit log:", e);
    }

    console.log(`[DATABASE] Content rejected: id=${input.contentId}`);
    return updated;
  });
}

/**
 * Publishes an approved advisory.
 * Executes targeting query, triggers SMS broadcasts, records audit log,
 * and produces documented ContentPublishedEvent for Member 4 integration.
 */
export async function publishContent(
  input: PublishContentInput
): Promise<{ content: Content; event: ContentPublishedEvent }> {
  console.log(`[SERVICE] Publishing content id=${input.contentId}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "PUBLISHED" as const;
  assertTransition(current.status, targetStatus);

  const now = new Date();

  const [updated] = await db
    .update(content)
    .set({ status: "PUBLISHED", updatedAt: now })
    .where(eq(content.id, input.contentId))
    .returning();

  console.log(`[DATABASE] Content published: id=${updated.id}, title="${updated.title}"`);

  if (input.publishedBy || updated.approvedBy || updated.authorId) {
    try {
      await db.insert(auditLogs).values({
        userId: input.publishedBy ?? updated.approvedBy ?? updated.authorId,
        action: "CONTENT_PUBLISHED",
        entityType: "CONTENT",
        entityId: input.contentId,
        details: JSON.stringify({ title: updated.title }),
      });
    } catch (e) {
      console.error("[AUDIT ERROR] Failed to record publish audit log:", e);
    }
  }

  // Multi-attribute Targeting (Crop, Location, Language)
  let matchedRecipientCount = 0;
  let broadcastMessageId: string | undefined;

  try {
    const matchedFarmers = await targetingService.findTargetFarmersForContent({
      cropId: updated.cropId,
      region: updated.region,
      language: updated.language,
    });

    const farmerIds = matchedFarmers.map((f) => f.id);
    matchedRecipientCount = farmerIds.length;
    console.log(
      `[TARGETING] Found ${farmerIds.length} matching farmers for published content id=${updated.id} ` +
        `(cropId=${updated.cropId}, region=${updated.region}, language=${updated.language})`
    );

    // Forward the target recipient list and published content payload to the Messaging Service
    const broadcastResult = await messageService.dispatchBroadcast({
      title: updated.title,
      body: updated.summary ? `${updated.title}: ${updated.summary}` : updated.body,
      channel: "SMS",
      createdBy: input.publishedBy ?? updated.approvedBy ?? updated.authorId ?? undefined,
      farmerIds,
    });

    broadcastMessageId = broadcastResult.message.id;
    console.log(
      `[MESSAGING] Broadcast dispatched: messageId=${broadcastResult.message.id}, recipientsCount=${broadcastResult.recipients.length}`
    );
  } catch (err) {
    console.error(`[MESSAGING/TARGETING ERROR] Failed to broadcast published content ${updated.id}:`, err);
  }

  // Documented event contract for Member 4 consumption
  const event: ContentPublishedEvent = {
    eventId: `evt-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
    eventType: "CONTENT_PUBLISHED",
    timestamp: now.toISOString(),
    content: updated,
    targetCriteria: {
      cropId: updated.cropId,
      region: updated.region,
      language: updated.language,
    },
    matchedRecipientCount,
    broadcastMessageId,
  };

  return { content: updated, event };
}

/**
 * Moves an approved or published advisory to ARCHIVED status.
 * Archived content remains viewable to authorized staff for audit/research,
 * but is excluded from active farmer feeds and broadcast triggers.
 */
export async function archiveContent(
  input: ArchiveContentInput
): Promise<Content> {
  console.log(`[SERVICE] Archiving content id=${input.contentId} by userId=${input.archivedBy}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "ARCHIVED" as const;
  assertTransition(current.status, targetStatus);

  const now = new Date();

  const [updated] = await db
    .update(content)
    .set({ status: "ARCHIVED", updatedAt: now })
    .where(eq(content.id, input.contentId))
    .returning();

  try {
    await db.insert(auditLogs).values({
      userId: input.archivedBy,
      action: "CONTENT_ARCHIVED",
      entityType: "CONTENT",
      entityId: input.contentId,
      details: JSON.stringify({
        title: updated.title,
        reason: input.reason ?? "Archived from active circulation",
      }),
    });
  } catch (e) {
    console.error("[AUDIT ERROR] Failed to record archive audit log:", e);
  }

  console.log(`[DATABASE] Content archived: id=${input.contentId}`);
  return updated;
}

/**
 * Returns full version history for an advisory.
 */
export async function getContentVersions(
  contentId: string
): Promise<ContentVersion[]> {
  await findContentOrThrow(contentId);
  return db
    .select()
    .from(contentVersions)
    .where(eq(contentVersions.contentId, contentId))
    .orderBy(desc(contentVersions.versionNumber));
}

/**
 * Retrieves a specific historical version snapshot.
 */
export async function getContentVersionById(
  contentId: string,
  versionId: string
): Promise<ContentVersion> {
  if (!UUID_REGEX.test(versionId)) {
    throw new NotFoundError("Version");
  }
  await findContentOrThrow(contentId);

  const [row] = await db
    .select()
    .from(contentVersions)
    .where(
      and(
        eq(contentVersions.contentId, contentId),
        eq(contentVersions.id, versionId)
      )
    )
    .limit(1);

  if (!row) {
    throw new NotFoundError("Version");
  }

  return row;
}

/**
 * Returns editorial review history with reviewer identity.
 */
export async function getContentReviews(
  contentId: string
): Promise<
  Array<ContentReview & { reviewerName?: string | null; reviewerRole?: string | null }>
> {
  await findContentOrThrow(contentId);

  const rows = await db
    .select({
      id: contentReviews.id,
      contentId: contentReviews.contentId,
      reviewerId: contentReviews.reviewerId,
      status: contentReviews.status,
      comments: contentReviews.comments,
      reviewedAt: contentReviews.reviewedAt,
      reviewerName: users.fullName,
      reviewerRole: users.role,
    })
    .from(contentReviews)
    .leftJoin(users, eq(users.id, contentReviews.reviewerId))
    .where(eq(contentReviews.contentId, contentId))
    .orderBy(desc(contentReviews.reviewedAt));

  return rows;
}
