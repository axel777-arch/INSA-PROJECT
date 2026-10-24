import {
  index,
  pgTable,
  timestamp,
  uuid,
  text,
} from "drizzle-orm/pg-core";
import { farmers } from "./farmers";
import { users } from "./users";

export const farmerWorkerAssignments = pgTable(
  "farmer_worker_assignments",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),

    workerId: uuid("worker_id")
      .notNull()
      .references(() => users.id, { onDelete: "restrict" }),

    assignedBy: uuid("assigned_by")
      .notNull()
      .references(() => users.id, { onDelete: "restrict" }),

    effectiveFrom: timestamp("effective_from", { withTimezone: true })
      .notNull()
      .defaultNow(),

    effectiveTo: timestamp("effective_to", { withTimezone: true }),

    note: text("note"),

    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    farmerIdx: index("farmer_worker_assignments_farmer_idx").on(
      table.farmerId,
    ),
    workerIdx: index("farmer_worker_assignments_worker_idx").on(
      table.workerId,
    ),
  }),
);
