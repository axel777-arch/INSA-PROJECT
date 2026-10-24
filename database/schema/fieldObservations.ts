import {
  pgTable,
  pgEnum,
  uuid,
  text,
  boolean,
  timestamp,
  index,
} from "drizzle-orm/pg-core";
import { users } from "./users";
import { farmers } from "./farmers";
import { crops } from "./crops";

export const observationTypeEnum = pgEnum("observation_type", [
  "PEST_INFESTATION",
  "DISEASE",
  "WEATHER_DAMAGE",
  "SOIL_ISSUE",
  "GENERAL_CHECKUP",
]);

export const observationSeverityEnum = pgEnum("observation_severity", [
  "LOW",
  "MEDIUM",
  "HIGH",
  "CRITICAL",
]);

export const fieldObservations = pgTable(
  "field_observations",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),
    workerId: uuid("worker_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    cropId: uuid("crop_id").references(() => crops.id, {
      onDelete: "set null",
    }),
    observationType: observationTypeEnum("observation_type")
      .notNull()
      .default("GENERAL_CHECKUP"),
    severity: observationSeverityEnum("severity")
      .notNull()
      .default("LOW"),
    title: text("title").notNull(),
    description: text("description").notNull(),
    actionTaken: text("action_taken"),
    isEscalated: boolean("is_escalated").notNull().default(false),
    escalatedToId: uuid("escalated_to_id").references(() => users.id, {
      onDelete: "set null",
    }),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    farmerIdx: index("fo_farmer_idx").on(table.farmerId),
    workerIdx: index("fo_worker_idx").on(table.workerId),
    escalatedIdx: index("fo_escalated_idx").on(table.isEscalated),
  })
);

export const observationAttachments = pgTable(
  "observation_attachments",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    observationId: uuid("observation_id")
      .notNull()
      .references(() => fieldObservations.id, { onDelete: "cascade" }),
    fileUrl: text("file_url").notNull(),
    fileType: text("file_type").notNull().default("IMAGE"),
    fileName: text("file_name"),
    uploadedAt: timestamp("uploaded_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    observationIdx: index("oa_observation_idx").on(table.observationId),
  })
);

export type FieldObservation = typeof fieldObservations.$inferSelect;
export type NewFieldObservation = typeof fieldObservations.$inferInsert;
export type ObservationAttachment = typeof observationAttachments.$inferSelect;
export type NewObservationAttachment = typeof observationAttachments.$inferInsert;
