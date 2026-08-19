import { boolean, text, uuid, doublePrecision, pgTable, timestamp } from "drizzle-orm/pg-core";

export const farmers = pgTable("farmers", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id").notNull(),
  region: text("region"),
  zone: text("zone"),
  woreda: text("woreda"),
  kebele: text("kebele"),
  latitude: doublePrecision("latitude"),
  longitude: doublePrecision("longitude"),
  alertEnabled: boolean("alert_enabled").notNull().default(true),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});
