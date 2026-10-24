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

export const assignmentTypeEnum = pgEnum("assignment_type", [
  "PRIMARY",
  "TEMPORARY_COVERAGE",
  "COLLABORATOR",
]);

export const assignmentStatusEnum = pgEnum("assignment_status", [
  "ACTIVE",
  "ENDED",
  "TRANSFERRED",
]);

export const farmerWorkerAssignments = pgTable(
  "farmer_worker_assignments",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),
    workerId: uuid("worker_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    assignedBy: uuid("assigned_by")
      .references(() => users.id, { onDelete: "set null" }),
    assignmentType: assignmentTypeEnum("assignment_type")
      .notNull()
      .default("PRIMARY"),
    status: assignmentStatusEnum("status")
      .notNull()
      .default("ACTIVE"),
    startDate: timestamp("start_date", { withTimezone: true })
      .notNull()
      .defaultNow(),
    endDate: timestamp("end_date", { withTimezone: true }),
    reason: text("reason"),
    note: text("note"),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    farmerIdx: index("fwa_farmer_idx").on(table.farmerId),
    workerIdx: index("fwa_worker_idx").on(table.workerId),
    statusIdx: index("fwa_status_idx").on(table.status),
  })
);

export type FarmerWorkerAssignment = typeof farmerWorkerAssignments.$inferSelect;
export type NewFarmerWorkerAssignment = typeof farmerWorkerAssignments.$inferInsert;
