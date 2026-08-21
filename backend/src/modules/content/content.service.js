"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.InvalidContentTransitionError = exports.ContentNotFoundError = void 0;
exports.createContent = createContent;
exports.listContent = listContent;
exports.getContentById = getContentById;
exports.updateContent = updateContent;
exports.submitForReview = submitForReview;
exports.approveContent = approveContent;
exports.rejectContent = rejectContent;
exports.publishContent = publishContent;
exports.archiveContent = archiveContent;
const content_workflow_1 = require("./content.workflow");
const drizzle_orm_1 = require("drizzle-orm");
const content_db_1 = require("./content.db");
const content_1 = require("../../../../database/schema/content");
const contentReviews_1 = require("../../../../database/schema/contentReviews");
class ContentNotFoundError extends Error {
    constructor(id) {
        super(`Content with id "${id}" was not found.`);
        this.name = "ContentNotFoundError";
    }
}
exports.ContentNotFoundError = ContentNotFoundError;
class InvalidContentTransitionError extends Error {
    constructor(message) {
        super(message);
        this.name = "InvalidContentTransitionError";
    }
}
exports.InvalidContentTransitionError = InvalidContentTransitionError;
async function findContentOrThrow(id) {
    const [row] = await content_db_1.db.select().from(content_1.content).where((0, drizzle_orm_1.eq)(content_1.content.id, id)).limit(1);
    if (!row) {
        throw new ContentNotFoundError(id);
    }
    return row;
}
async function createContent(input) {
    const [created] = await content_db_1.db
        .insert(content_1.content)
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
async function listContent(filter) {
    const conditions = [];
    if (filter.status)
        conditions.push((0, drizzle_orm_1.eq)(content_1.content.status, filter.status));
    if (filter.cropId)
        conditions.push((0, drizzle_orm_1.eq)(content_1.content.cropId, filter.cropId));
    if (filter.language)
        conditions.push((0, drizzle_orm_1.eq)(content_1.content.language, filter.language));
    if (filter.location)
        conditions.push((0, drizzle_orm_1.eq)(content_1.content.location, filter.location));
    const query = content_db_1.db.select().from(content_1.content).orderBy((0, drizzle_orm_1.desc)(content_1.content.createdAt));
    if (conditions.length > 0) {
        return query.where((0, drizzle_orm_1.and)(...conditions));
    }
    return query;
}
async function getContentById(id) {
    return findContentOrThrow(id);
}
async function updateContent(id, input) {
    const current = await findContentOrThrow(id);
    if (current.status !== "DRAFT" && current.status !== "REJECTED") {
        throw new InvalidContentTransitionError(`Cannot edit content in status "${current.status}". ` +
            `Content can only be edited while in DRAFT or REJECTED status.`);
    }
    const [updated] = await content_db_1.db
        .update(content_1.content)
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
        .where((0, drizzle_orm_1.eq)(content_1.content.id, id))
        .returning();
    return updated;
}
async function submitForReview(input) {
    const current = await findContentOrThrow(input.contentId);
    const targetStatus = "IN_REVIEW";
    (0, content_workflow_1.assertTransition)(current.status, targetStatus);
    const [updated] = await content_db_1.db
        .update(content_1.content)
        .set({ status: "IN_REVIEW", updatedAt: new Date() })
        .where((0, drizzle_orm_1.eq)(content_1.content.id, input.contentId))
        .returning();
    return updated;
}
async function approveContent(input) {
    const current = await findContentOrThrow(input.contentId);
    const targetStatus = "APPROVED";
    (0, content_workflow_1.assertTransition)(current.status, targetStatus);
    const now = new Date();
    return content_db_1.db.transaction(async (tx) => {
        const [updated] = await tx
            .update(content_1.content)
            .set({
            status: "APPROVED",
            approvedBy: input.approvedBy,
            approvedAt: now,
            updatedAt: now,
        })
            .where((0, drizzle_orm_1.eq)(content_1.content.id, input.contentId))
            .returning();
        await tx.insert(contentReviews_1.contentReviews).values({
            contentId: input.contentId,
            reviewerId: input.approvedBy,
            decision: "APPROVED",
        });
        return updated;
    });
}
async function rejectContent(input) {
    const current = await findContentOrThrow(input.contentId);
    const targetStatus = "REJECTED";
    (0, content_workflow_1.assertTransition)(current.status, targetStatus);
    return content_db_1.db.transaction(async (tx) => {
        const [updated] = await tx
            .update(content_1.content)
            .set({ status: "REJECTED", updatedAt: new Date() })
            .where((0, drizzle_orm_1.eq)(content_1.content.id, input.contentId))
            .returning();
        await tx.insert(contentReviews_1.contentReviews).values({
            contentId: input.contentId,
            reviewerId: input.rejectedBy,
            decision: "REJECTED",
            comment: input.comment ?? null,
        });
        return updated;
    });
}
async function publishContent(input) {
    const current = await findContentOrThrow(input.contentId);
    const targetStatus = "PUBLISHED";
    (0, content_workflow_1.assertTransition)(current.status, targetStatus);
    const [updated] = await content_db_1.db
        .update(content_1.content)
        .set({ status: "PUBLISHED", updatedAt: new Date() })
        .where((0, drizzle_orm_1.eq)(content_1.content.id, input.contentId))
        .returning();
    return updated;
}
async function archiveContent(input) {
    const current = await findContentOrThrow(input.contentId);
    const targetStatus = "ARCHIVED";
    (0, content_workflow_1.assertTransition)(current.status, targetStatus);
    const [updated] = await content_db_1.db
        .update(content_1.content)
        .set({ status: "ARCHIVED", updatedAt: new Date() })
        .where((0, drizzle_orm_1.eq)(content_1.content.id, input.contentId))
        .returning();
    return updated;
}
