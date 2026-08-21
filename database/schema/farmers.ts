import {
  boolean,
  doublePrecision,
  pgTable,
  text,
  timestamp,
  uuid,
  uniqueIndex,
} from "drizzle-orm/pg-core";

import { users } from "./users";

export const farmers = pgTable(
  "farmers",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),

    region: text("region"),
    zone: text("zone"),
    woreda: text("woreda"),
    kebele: text("kebele"),

    latitude: doublePrecision("latitude"),
    longitude: doublePrecision("longitude"),

    alertEnabled: boolean("alert_enabled")
      .notNull()
      .default(true),

    createdAt: timestamp("created_at", {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),

    updatedAt: timestamp("updated_at", {
      withTimezone: true,
    })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    userIdUnique: uniqueIndex("farmers_user_id_unique").on(table.userId),
  }),
);