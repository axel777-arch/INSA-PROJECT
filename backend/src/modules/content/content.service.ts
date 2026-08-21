import { assertTransition } from "./content.workflow";
import { and, desc, eq } from "drizzle-orm";
import { db } from "./content.db";
import { content } from "../../../../database/schema/content";
import { contentReviews } from "../../../../database/schema/contentReviews";
import type {
  Content,
  ContentFilter,
  CreateContentInput,
  UpdateContentInput,
  SubmitForReviewInput,
  ApproveContentInput,
  RejectContentInput,
  PublishContentInput,
  ArchiveContentInput,
} from "./content.types";

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



async function findContentOrThrow(id: string): Promise<Content> {
  const [row] = await db.select().from(content).where(eq(content.id, id)).limit(1);

  if (!row) {
    throw new ContentNotFoundError(id);
  }

  return row;
}


export async function createContent(input: CreateContentInput): Promise<Content> {
  const [created] = await db
    .insert(content)
    .values({
      title: input.title,
      body: input.body,
      cropId: input.cropId ?? null,
      language: input.language,
      location: input.location ?? null,
      createdBy: input.createdBy,
    })
    .returning();

  return created;
}

export async function listContent(filter: ContentFilter): Promise<Content[]> {
  const conditions = [];

  if (filter.status) conditions.push(eq(content.status, filter.status));
  if (filter.cropId) conditions.push(eq(content.cropId, filter.cropId));
  if (filter.language) conditions.push(eq(content.language, filter.language));
  if (filter.location) conditions.push(eq(content.location, filter.location));

  const query = db.select().from(content).orderBy(desc(content.createdAt));

  if (conditions.length > 0) {
    return query.where(and(...conditions));
  }

  return query;
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
    ...(input.language !== undefined ? { language: input.language } : {}),
    ...(input.location !== undefined ? { location: input.location } : {}),
    ...(current.status === "REJECTED"
      ? {
          status: "DRAFT",
          approvedBy: null,
          approvedAt: null,
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

const targetStatus = "IN_REVIEW" as const;
assertTransition(current.status, targetStatus);

  const [updated] = await db
    .update(content)
    .set({ status: "IN_REVIEW", updatedAt: new Date() })
    .where(eq(content.id, input.contentId))
    .returning();

  return updated;
}

export async function approveContent(
  input: ApproveContentInput
): Promise<Content> {
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
        approvedAt: now,
        updatedAt: now,
      })
      .where(eq(content.id, input.contentId))
      .returning();

    await tx.insert(contentReviews).values({
      contentId: input.contentId,
      reviewerId: input.approvedBy,
      decision: "APPROVED",
    });

    return updated;
  });
}

export async function rejectContent(
  input: RejectContentInput
): Promise<Content> {
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
      decision: "REJECTED",
      comment: input.comment ?? null,
    });

    return updated;
  });
}

export async function publishContent(
  input: PublishContentInput
): Promise<Content> {
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "PUBLISHED" as const;
assertTransition(current.status, targetStatus);

  const [updated] = await db
    .update(content)
    .set({ status: "PUBLISHED", updatedAt: new Date() })
    .where(eq(content.id, input.contentId))
    .returning();

  return updated;
}

export async function archiveContent(
  input: ArchiveContentInput
): Promise<Content> {
  const current = await findContentOrThrow(input.contentId);

  const targetStatus = "ARCHIVED" as const;
  assertTransition(current.status, targetStatus);

  const [updated] = await db
    .update(content)
    .set({ status: "ARCHIVED", updatedAt: new Date() })
    .where(eq(content.id, input.contentId))
    .returning();

  return updated;
}
