import { pgTable, uuid, text, timestamp, boolean } from "drizzle-orm/pg-core";
import { users } from "./users";
import { farmers } from "./farmers";
import { crops } from "./crops";

export const cases = pgTable("cases", {
  id: uuid("id").primaryKey().defaultRandom(),
  farmerId: uuid("farmer_id").references(() => farmers.id, { onDelete: "cascade" }),
  cropId: uuid("crop_id").references(() => crops.id, { onDelete: "set null" }),
  title: text("title").notNull(),
  description: text("description").notNull(),
  location: text("location"),
  status: text("status").notNull().default("OPEN"), // OPEN, IN_REVIEW, RESOLVED, CLOSED
  images: text("images"), // comma-separated or json string
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const caseResponses = pgTable("case_responses", {
  id: uuid("id").primaryKey().defaultRandom(),
  caseId: uuid("case_id").notNull().references(() => cases.id, { onDelete: "cascade" }),
  expertId: uuid("expert_id").references(() => users.id, { onDelete: "set null" }),
  diagnosis: text("diagnosis").notNull(),
  recommendation: text("recommendation").notNull(),
  internalNotes: text("internal_notes"),
  images: text("images"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Case = typeof cases.$inferSelect;
export type NewCase = typeof cases.$inferInsert;
export type CaseResponse = typeof caseResponses.$inferSelect;
export type NewCaseResponse = typeof caseResponses.$inferInsert;
