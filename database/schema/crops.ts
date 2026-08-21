import { boolean, text, uuid, pgTable } from "drizzle-orm/pg-core";

export const crops = pgTable("crops", {
  id: uuid("id").defaultRandom().primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  active: boolean("active").notNull().default(true),
});
