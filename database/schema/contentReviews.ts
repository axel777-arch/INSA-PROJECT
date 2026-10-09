import { pgTable, pgEnum, uuid, text, timestamp } from "drizzle-orm/pg-core";
import { content } from "./content";
import { users } from "./users";

export const contentReviewStatusEnum = pgEnum("content_review_status", [
  "APPROVED",
  "REJECTED",
  "NEEDS_REVISION",
]);

export const contentReviews = pgTable("content_reviews", {
  id: uuid("id").primaryKey().defaultRandom(),
  contentId: uuid("content_id")
    .notNull()
    .references(() => content.id, { onDelete: "cascade" }),
  reviewerId: uuid("reviewer_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  status: contentReviewStatusEnum("status").notNull(),
  comments: text("comments"),
  reviewedAt: timestamp("reviewed_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
});

export type ContentReview = typeof contentReviews.$inferSelect;
export type NewContentReview = typeof contentReviews.$inferInsert;