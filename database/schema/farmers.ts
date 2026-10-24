import {
  boolean,
  doublePrecision,
  index,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from "drizzle-orm/pg-core";
import { users } from "./users";

export const farmers = pgTable(
  "farmers",
  {
    id: uuid("id").defaultRandom().primaryKey(),

    userId: uuid("user_id").references(() => users.id, {
      onDelete: "set null",
    }),

    fullName: text("full_name"),
    phone: text("phone"),

    registeredBy: uuid("registered_by").references(() => users.id, {
      onDelete: "set null",
    }),

    preferredLanguage: text("preferred_language").default("amharic"),
    hasAppAccess: boolean("has_app_access").notNull().default(false),
    farmSize: doublePrecision("farm_size"),
    experienceYears: doublePrecision("experience_years"),

    primaryWorkerId: uuid("primary_worker_id").references(() => users.id, {
      onDelete: "set null",
    }),

    region: text("region"),
    zone: text("zone"),
    woreda: text("woreda"),
    kebele: text("kebele"),

    latitude: doublePrecision("latitude"),
    longitude: doublePrecision("longitude"),

    alertEnabled: boolean("alert_enabled").notNull().default(true),

    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),

    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    userIdUnique: uniqueIndex("farmers_user_id_unique").on(table.userId),
    phoneIdx: index("farmers_phone_idx").on(table.phone),
    workerIdx: index("farmers_worker_idx").on(table.primaryWorkerId),
  }),
);
