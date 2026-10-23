import { pgTable, uuid, text, timestamp, integer } from "drizzle-orm/pg-core";
import { content } from "./content";
import { crops } from "./crops";
import { users } from "./users";

export const contentVersions = pgTable("content_versions", {
  id: uuid("id").primaryKey().defaultRandom(),
  contentId: uuid("content_id")
    .notNull()
    .references(() => content.id, { onDelete: "cascade" }),
  versionNumber: integer("version_number").notNull(),
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
  statusAtVersion: text("status_at_version").notNull(),
  authorId: uuid("author_id").references(() => users.id),
  changeSummary: text("change_summary"),
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
});

export type ContentVersion = typeof contentVersions.$inferSelect;
export type NewContentVersion = typeof contentVersions.$inferInsert;
