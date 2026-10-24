import { pgTable, pgEnum, uuid, text, timestamp } from "drizzle-orm/pg-core";
import { crops } from "./crops";
import { users } from "./users";

export const contentStatusEnum = pgEnum("content_status", [
  "DRAFT",
  "PENDING_REVIEW",
  "APPROVED",
  "PUBLISHED",
  "REJECTED",
]);

export const content = pgTable("content", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: text("title").notNull(),
  body: text("body").notNull(),
  cropId: uuid("crop_id").references(() => crops.id),
  category: text("category"),
  targetRegion: text("target_region"),
  targetZone: text("target_zone"),
  targetWoreda: text("target_woreda"),
  targetKebele: text("target_kebele"),
  targetLanguage: text("target_language"),
  status: contentStatusEnum("status").notNull().default("DRAFT"),
  authorId: uuid("author_id").references(() => users.id),
  approvedBy: uuid("approved_by").references(() => users.id),
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
});

export type Content = typeof content.$inferSelect;
export type NewContent = typeof content.$inferInsert;
