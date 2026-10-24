import { and, desc, eq, inArray, isNull } from "drizzle-orm";
import { db } from "../../db/index";
import { notifications } from "../../../../database/schema/notifications";
import { users } from "../../../../database/schema/users";

export interface NotificationItem {
  id: string;
  title: string;
  body: string;
  type: string;
  resourceType: "USER" | "CASE" | "CONTENT" | "MESSAGE" | "SYSTEM";
  resourceId: string;
  route: string;
  read: boolean;
  createdAt: string;
}

export interface CreateNotificationInput {
  recipientId: string;
  eventType: string;
  resourceType: NotificationItem["resourceType"];
  resourceId: string;
  title: string;
  body: string;
  route: string;
}

export async function createNotification(input: CreateNotificationInput): Promise<void> {
  await db
    .insert(notifications)
    .values(input)
    .onConflictDoNothing();
}

export async function notifyRoles(
  roleNames: string[],
  input: Omit<CreateNotificationInput, "recipientId">,
): Promise<void> {
  if (roleNames.length === 0) return;
  const recipients = await db
    .select({ id: users.id })
    .from(users)
    .where(and(inArray(users.role, roleNames), eq(users.active, true), eq(users.status, "APPROVED")));

  for (const recipient of recipients) {
    await createNotification({ ...input, recipientId: recipient.id });
  }
}

export async function markNotificationAsRead(id: string, recipientId: string): Promise<boolean> {
  const rows = await db
    .update(notifications)
    .set({ readAt: new Date() })
    .where(and(eq(notifications.id, id), eq(notifications.recipientId, recipientId), isNull(notifications.readAt)))
    .returning({ id: notifications.id });
  if (rows.length > 0) return true;

  const [existing] = await db
    .select({ id: notifications.id })
    .from(notifications)
    .where(and(eq(notifications.id, id), eq(notifications.recipientId, recipientId)))
    .limit(1);
  return Boolean(existing);
}

export async function getNotificationsForUser(userId: string): Promise<NotificationItem[]> {
  const rows = await db
    .select()
    .from(notifications)
    .where(eq(notifications.recipientId, userId))
    .orderBy(desc(notifications.createdAt))
    .limit(100);

  return rows.map((item) => ({
    id: item.id,
    title: item.title,
    body: item.body,
    type: item.eventType,
    resourceType: item.resourceType as NotificationItem["resourceType"],
    resourceId: item.resourceId,
    route: item.route,
    read: item.readAt !== null,
    createdAt: item.createdAt.toISOString(),
  }));
}
