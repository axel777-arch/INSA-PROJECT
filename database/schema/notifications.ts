import { index, pgTable, text, timestamp, uuid, uniqueIndex } from "drizzle-orm/pg-core";
import { users } from "./users";

export const notifications = pgTable(
  "notifications",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    recipientId: uuid("recipient_id").notNull().references(() => users.id, { onDelete: "cascade" }),
    eventType: text("event_type").notNull(),
    resourceType: text("resource_type").notNull(),
    resourceId: text("resource_id").notNull(),
    title: text("title").notNull(),
    body: text("body").notNull(),
    route: text("route").notNull(),
    readAt: timestamp("read_at", { withTimezone: true }),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    recipientCreatedAtIdx: index("notifications_recipient_created_at_idx").on(table.recipientId, table.createdAt),
    resourceEventUnique: uniqueIndex("notifications_resource_event_unique").on(
      table.recipientId,
      table.eventType,
      table.resourceType,
      table.resourceId,
    ),
  }),
);

export type Notification = typeof notifications.$inferSelect;
