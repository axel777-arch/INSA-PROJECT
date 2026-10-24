import { assertTransition, canTransition } from "./content.workflow";
import { and, desc, eq } from "drizzle-orm";
import { db } from "../../db/index";
import { content } from "../../../../database/schema/content";
import { contentReviews } from "../../../../database/schema/contentReviews";
import { auditLogs } from "../../../../database/schema/auditLogs";
import { targetingService } from "../../services/targeting/targeting.service";
import { messageService } from "../messaging/message.service";
import type {
  Content,
  ContentFilter,
  CreateContentInput,
  UpdateContentInput,
  SubmitForReviewInput,
  ApproveContentInput,
  RejectContentInput,
  PublishContentInput,
} from "./content.types";

export const ContentStatus = {
  DRAFT: "DRAFT" as const,
  PENDING_REVIEW: "PENDING_REVIEW" as const,
  IN_REVIEW: "PENDING_REVIEW" as const, // backwards compatibility alias
  APPROVED: "APPROVED" as const,
  REJECTED: "REJECTED" as const,
  PUBLISHED: "PUBLISHED" as const,
};

export class ContentNotFoundError extends Error {
  constructor(id: string) {
    super(`Content with id "${id}" was not found.`);
    this.name = "ContentNotFoundError";
  }
}

export class InvalidContentTransitionError extends Error {
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
    category?: string;
    authorId?: string;
    createdBy?: string;
  }): Content {
    return {
      id: `content-${Date.now()}`,
      title: input.title,
      body: input.body,
      status: "DRAFT",
      cropId: null,
      category: input.category ?? null,
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

export async function createContent(input: CreateContentInput): Promise<Content> {
  const author = input.authorId ?? input.createdBy;
  console.log(`[SERVICE] Creating content: "${input.title}" by userId=${author}`);
  const [created] = await db
    .insert(content)
    .values({
      title: input.title,
      body: input.body,
      cropId: input.cropId ?? null,
      category: input.category ?? null,
      authorId: author ?? null,
    })
    .returning();
  console.log(`[DATABASE] Content created: id=${created.id}, status=${created.status}`);
  return created;
}

export async function listContent(filter: ContentFilter): Promise<Content[]> {
  console.log("[SERVICE] Listing content with filter:", filter);
  const conditions = [];

  if (filter.status) conditions.push(eq(content.status, filter.status));
  if (filter.cropId) conditions.push(eq(content.cropId, filter.cropId));
  if (filter.category) conditions.push(eq(content.category, filter.category));
  if (filter.authorId) conditions.push(eq(content.authorId, filter.authorId));

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

export async function updateContent(
  id: string,
  input: UpdateContentInput
): Promise<Content> {
  const current = await findContentOrThrow(id);

  if (current.status !== "DRAFT" && current.status !== "REJECTED") {
    throw new InvalidContentTransitionError(
      `Cannot edit content in status "${current.status}". ` +
        `Content can only be edited while in DRAFT or REJECTED status.`
    );
  }

  const [updated] = await db
    .update(content)
    .set({
      ...(input.title !== undefined ? { title: input.title } : {}),
      ...(input.body !== undefined ? { body: input.body } : {}),
      ...(input.cropId !== undefined ? { cropId: input.cropId } : {}),
      ...(input.category !== undefined ? { category: input.category } : {}),
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

export async function submitForReview(
  input: SubmitForReviewInput
): Promise<Content> {
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "PENDING_REVIEW" as const;
  assertTransition(current.status, targetStatus);

  const [updated] = await db
    .update(content)
    .set({ status: "PENDING_REVIEW", updatedAt: new Date() })
    .where(eq(content.id, input.contentId))
    .returning();

  return updated;
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
        console.error('[AUDIT ERROR] Failed to record approve audit log:', e);
      }
    }
    console.log(`[DATABASE] Content approved: id=${input.contentId}`);
    return updated;
  });
}

export async function rejectContent(
  input: RejectContentInput
): Promise<Content> {
  console.log(`[SERVICE] Rejecting content id=${input.contentId}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "REJECTED" as const;
  assertTransition(current.status, targetStatus);

  return db.transaction(async (tx) => {
    const [updated] = await tx
      .update(content)
      .set({ status: "REJECTED", updatedAt: new Date() })
      .where(eq(content.id, input.contentId))
      .returning();

    await tx.insert(contentReviews).values({
      contentId: input.contentId,
      reviewerId: input.rejectedBy,
      status: "REJECTED",
      comments: input.comment ?? null,
    });
    console.log(`[DATABASE] Content rejected: id=${input.contentId}`);
    return updated;
  });
}

export async function publishContent(
  input: PublishContentInput
): Promise<Content> {
  console.log(`[SERVICE] Publishing content id=${input.contentId}`);
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "PUBLISHED" as const;
  assertTransition(current.status, targetStatus);

  const [updated] = await db
    .update(content)
    .set({ status: "PUBLISHED", updatedAt: new Date() })
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
      console.error('[AUDIT ERROR] Failed to record publish audit log:', e);
    }
  }

  // Automatic Targeting Service Query & Messaging Dispatch
  try {
    const matchedFarmers = await targetingService.findTargetFarmersForContent({
      cropId: updated.cropId,
    });

    const farmerIds = matchedFarmers.map((f) => f.id);
    console.log(
      `[TARGETING] Found ${farmerIds.length} matching farmers for published content id=${updated.id} (cropId=${updated.cropId})`
    );

    // Forward the target recipient list and published content payload directly to the Messaging Service
    const broadcastResult = await messageService.dispatchBroadcast({
      title: updated.title,
      body: updated.body,
      channel: "SMS",
      createdBy: input.publishedBy ?? updated.approvedBy ?? updated.authorId ?? undefined,
      farmerIds,
    });

    console.log(
      `[MESSAGING] Broadcast dispatched: messageId=${broadcastResult.message.id}, recipientsCount=${broadcastResult.recipients.length}`
    );
  } catch (err) {
    console.error(`[MESSAGING/TARGETING ERROR] Failed to broadcast published content ${updated.id}:`, err);
  }

  return updated;
}
