import { pgTable, uuid, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";
import { messages } from "./messages";
import { farmers } from "./farmers";

export const messageRecipients = pgTable(
  "message_recipients",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    messageId: uuid("message_id")
      .notNull()
      .references(() => messages.id, { onDelete: "cascade" }),
    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),
    status: text("status").notNull().default("PENDING"),
    deliveryMode: text("delivery_mode").notNull().default("SIMULATED"),
    failureReason: text("failure_reason"),
    sentAt: timestamp("sent_at", { withTimezone: true }),
    deliveredAt: timestamp("delivered_at", { withTimezone: true }),
  },
  (table) => ({
    messageFarmerUnique: uniqueIndex("message_recipients_message_farmer_unique").on(
      table.messageId,
      table.farmerId,
    ),
  }),
);

export type MessageRecipient = typeof messageRecipients.$inferSelect;
export type NewMessageRecipient = typeof messageRecipients.$inferInsert;
