import { pgTable, pgEnum, uuid, text, varchar, timestamp } from "drizzle-orm/pg-core";

export const contentStatusEnum = pgEnum("content_status", [
  "DRAFT",
  "IN_REVIEW",
  "APPROVED",
  "REJECTED",
  "PUBLISHED",
  "ARCHIVED",
]);

export const content = pgTable("content", {
  id: uuid("id").primaryKey().defaultRandom(),

  title: varchar("title", { length: 255 }).notNull(),
  body: text("body").notNull(),

  // Targeting metadata (future FK to crops.id)
  cropId: uuid("crop_id"),
  language: varchar("language", { length: 50 }).notNull(),
  location: varchar("location", { length: 255 }),

  // Review / approval workflow state
  status: contentStatusEnum("status").notNull().default("DRAFT"),

  // Authorship / approval (future FKs to users.id)
  createdBy: uuid("created_by").notNull(),
  approvedBy: uuid("approved_by"),
  approvedAt: timestamp("approved_at", { withTimezone: true }),

  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Content = typeof content.$inferSelect;
export type NewContent = typeof content.$inferInsert;
