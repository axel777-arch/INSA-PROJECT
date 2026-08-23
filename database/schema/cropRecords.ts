import { numeric, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";

export const cropRecords = pgTable("crop_records", {
  id: uuid("id").defaultRandom().primaryKey(),
  createdBy: uuid("created_by").notNull().references(() => users.id),
  crop: text("crop").notNull(),
  plantingDate: text("planting_date").notNull(),
  areaHectares: numeric("area_hectares").notNull(),
  growthStage: text("growth_stage").notNull(),
  idempotencyKey: text("idempotency_key").notNull().unique(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});