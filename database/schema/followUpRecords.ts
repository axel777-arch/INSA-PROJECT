import {
  pgTable,
  pgEnum,
  uuid,
  text,
  timestamp,
  index,
} from "drizzle-orm/pg-core";
import { users } from "./users";
import { farmers } from "./farmers";
import { fieldObservations } from "./fieldObservations";

export const followUpStatusEnum = pgEnum("follow_up_status", [
  "PENDING",
  "IN_PROGRESS",
  "COMPLETED",
  "CANCELLED",
]);

export const followUpRecords = pgTable(
  "follow_up_records",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),
    workerId: uuid("worker_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    observationId: uuid("observation_id").references(
      () => fieldObservations.id,
      { onDelete: "set null" }
    ),
    scheduledDate: timestamp("scheduled_date", { withTimezone: true })
      .notNull(),
    completedDate: timestamp("completed_date", { withTimezone: true }),
    status: followUpStatusEnum("status")
      .notNull()
      .default("PENDING"),
    notes: text("notes"),
    outcome: text("outcome"),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    farmerIdx: index("fur_farmer_idx").on(table.farmerId),
    workerIdx: index("fur_worker_idx").on(table.workerId),
    statusIdx: index("fur_status_idx").on(table.status),
  })
);

export type FollowUpRecord = typeof followUpRecords.$inferSelect;
export type NewFollowUpRecord = typeof followUpRecords.$inferInsert;
