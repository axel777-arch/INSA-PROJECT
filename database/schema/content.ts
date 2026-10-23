import { pgTable, pgEnum, uuid, text, timestamp, integer } from "drizzle-orm/pg-core";
import { crops } from "./crops";
import { users } from "./users";

export const contentStatusEnum = pgEnum("content_status", [
  "DRAFT",
  "PENDING_REVIEW",
  "NEEDS_REVISION",
  "APPROVED",
  "PUBLISHED",
  "REJECTED",
  "ARCHIVED",
]);

export const content = pgTable("content", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: text("title").notNull(),
  summary: text("summary"),
  body: text("body").notNull(),
  cropId: uuid("crop_id").references(() => crops.id),
  category: text("category"),
  language: text("language").notNull().default("en"),
  region: text("region"),
  zone: text("zone"),
  woreda: text("woreda"),
  kebele: text("kebele"),
  season: text("season"),
  cropStage: text("crop_stage"),
  priority: text("priority").notNull().default("NORMAL"),
  validFrom: timestamp("valid_from", { withTimezone: true }),
  validUntil: timestamp("valid_until", { withTimezone: true }),
  sourceInfo: text("source_info"),
  attachments: text("attachments"),
  version: integer("version").notNull().default(1),
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

