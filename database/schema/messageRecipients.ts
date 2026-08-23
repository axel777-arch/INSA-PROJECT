import { boolean, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { messages } from "./messages";

export const messageRecipients = pgTable("message_recipients", {
	id: uuid("id").defaultRandom().primaryKey(),
	messageId: uuid("message_id").notNull().references(() => messages.id, { onDelete: "cascade" }),
	recipientId: text("recipient_id").notNull(),
	read: boolean("read").notNull().default(false),
	readAt: timestamp("read_at", { withTimezone: true }),
});
