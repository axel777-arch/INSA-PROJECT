import { pgTable, pgEnum, uuid, text, timestamp } from "drizzle-orm/pg-core";
import { content } from "./content";

export const reviewDecisionEnum = pgEnum("review_decision", [
  "APPROVED",
  "REJECTED",
]);

export const contentReviews = pgTable("content_reviews", {
  id: uuid("id").primaryKey().defaultRandom(),

  contentId: uuid("content_id")
    .notNull()
    .references(() => content.id),

  // Future FK to users.id — left as a plain UUID until that schema is finalized
  reviewerId: uuid("reviewer_id").notNull(),

  decision: reviewDecisionEnum("decision").notNull(),
  comment: text("comment"),

  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type ContentReview = typeof contentReviews.$inferSelect;
export type NewContentReview = typeof contentReviews.$inferInsert;