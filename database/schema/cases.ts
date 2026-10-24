import { pgTable, uuid, text, timestamp, date } from "drizzle-orm/pg-core";
import { users } from "./users";
import { farmers } from "./farmers";
import { crops } from "./crops";

export const cases = pgTable("cases", {
  id: uuid("id").primaryKey().defaultRandom(),
  farmerId: uuid("farmer_id").references(() => farmers.id, { onDelete: "cascade" }),
  creatorId: uuid("creator_id").references(() => users.id, { onDelete: "set null" }),
  assignedTo: uuid("assigned_to").references(() => users.id, { onDelete: "set null" }),
  cropId: uuid("crop_id").references(() => crops.id, { onDelete: "set null" }),
  title: text("title").notNull(),
  description: text("description").notNull(),
  location: text("location"),
  category: text("category").notNull().default("GENERAL"),
  priority: text("priority").notNull().default("NORMAL"),
  source: text("source").notNull().default("FARMER_QUESTION"),
  observationDate: date("observation_date", { mode: "string" }),
  preferredResponseLanguage: text("preferred_response_language"),
  resolutionSummary: text("resolution_summary"),
  status: text("status").notNull().default("OPEN"),
  attachments: text("attachments"),
  images: text("images"),
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

export const caseEvents = pgTable("case_events", {
  id: uuid("id").primaryKey().defaultRandom(),
  caseId: uuid("case_id").notNull().references(() => cases.id, { onDelete: "cascade" }),
  actorId: uuid("actor_id").references(() => users.id, { onDelete: "set null" }),
  eventType: text("event_type").notNull(),
  details: text("details"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const caseMessages = pgTable("case_messages", {
  id: uuid("id").primaryKey().defaultRandom(),
  caseId: uuid("case_id").notNull().references(() => cases.id, { onDelete: "cascade" }),
  senderId: uuid("sender_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  recipientId: uuid("recipient_id").references(() => users.id, { onDelete: "set null" }),
  body: text("body").notNull(),
  visibility: text("visibility").notNull().default("INTERNAL"),
  attachments: text("attachments"),
  readAt: timestamp("read_at", { withTimezone: true }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Case = typeof cases.$inferSelect;
export type NewCase = typeof cases.$inferInsert;
export type CaseResponse = typeof caseResponses.$inferSelect;
export type NewCaseResponse = typeof caseResponses.$inferInsert;
