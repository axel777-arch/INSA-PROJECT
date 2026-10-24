import {
  boolean,
  doublePrecision,
  pgTable,
  text,
  timestamp,
  uuid,
  uniqueIndex,
  index,
} from "drizzle-orm/pg-core";

import { users } from "./users";

export const farmers = pgTable(
  "farmers",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    // Nullable for farmers who use basic phones or do not have an app login account
    userId: uuid("user_id").references(() => users.id, { onDelete: "set null" }),

    // Demographic and contact details
    fullName: text("full_name"),
    phoneNumber: text("phone_number"),
    preferredLanguage: text("preferred_language").default("amharic"),
    hasAppAccess: boolean("has_app_access").notNull().default(false),

    // Farm details
    farmSize: doublePrecision("farm_size"),
    experienceYears: doublePrecision("experience_years"),

    // Geographic location
    region: text("region"),
    zone: text("zone"),
    woreda: text("woreda"),
    kebele: text("kebele"),

    latitude: doublePrecision("latitude"),
    longitude: doublePrecision("longitude"),

    // Extension worker tracking
    primaryWorkerId: uuid("primary_worker_id").references(() => users.id, {
      onDelete: "set null",
    }),

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
    phoneIdx: index("farmers_phone_idx").on(table.phoneNumber),
    workerIdx: index("farmers_worker_idx").on(table.primaryWorkerId),
  }),
);
