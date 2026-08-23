import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";

export const fieldObservations = pgTable("field_observations", {
  id: uuid("id").defaultRandom().primaryKey(),
  createdBy: uuid("created_by").notNull().references(() => users.id),
  category: text("category").notNull(),
  crop: text("crop").notNull(),
  notes: text("notes").notNull(),
  location: text("location").notNull(),
  questions: text("questions").notNull().default(""),
  photoData: text("photo_data").array().notNull().default([]),
  status: text("status").notNull().default("SUBMITTED"),
  diagnosis: text("diagnosis"),
  recommendation: text("recommendation"),
  internalNotes: text("internal_notes"),
  respondedBy: uuid("responded_by").references(() => users.id),
  respondedAt: timestamp("responded_at", { withTimezone: true }),
  idempotencyKey: text("idempotency_key").notNull().unique(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});