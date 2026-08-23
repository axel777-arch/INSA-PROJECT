import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

export const messages = pgTable("messages", {
	id: uuid("id").defaultRandom().primaryKey(),
	contentId: text("content_id").notNull(),
	channel: text("channel").notNull(),
	body: text("body").notNull().default(""),
	status: text("status").notNull().default("QUEUED"),
	createdBy: text("created_by").notNull(),
	createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
	updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});
