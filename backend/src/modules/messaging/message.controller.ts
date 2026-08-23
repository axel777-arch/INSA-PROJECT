import type { Request, Response } from "express";
import { and, desc, eq, or, sql } from "drizzle-orm";

import { SmsSimulator } from "../../services/sms/sms.simulator";
import { MessageService } from "./message.service";
import { db } from "../../config/database";
import { messages } from "../../../../database/schema/messages";
import { messageRecipients } from "../../../../database/schema/messageRecipients";
import { users } from "../../../../database/schema/users";
import { farmers } from "../../../../database/schema/farmers";
import { db as database } from "../../config/database";

const smsSimulator = new SmsSimulator();
const messageService = new MessageService();

export async function createSmsMessage(
  req: Request,
  res: Response,
): Promise<void> {
  const payload = req.body ?? {};
  const recipient =
    typeof payload.recipient === "string" ? payload.recipient : "";
  const messageText =
    typeof payload.message === "string" ? payload.message : "";
  const contentId =
    typeof payload.contentId === "string" ? payload.contentId : "";
  const createdBy =
    typeof payload.createdBy === "string" ? payload.createdBy : "";

  if (!recipient || !messageText || !contentId || !createdBy) {
    res
      .status(400)
      .json({
        error: "recipient, message, contentId, and createdBy are required.",
      });
    return;
  }

  const message = smsSimulator.send({ recipient, message: messageText });

  const record = messageService.createMessage({
    contentId,
    channel: "SMS",
    createdBy,
  });

  await db.insert(messages).values({
    contentId: record.contentId,
    channel: record.channel,
    status: record.status,
    createdBy: record.createdBy,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  });

  res.status(201).json({
    message,
    record,
    status: "QUEUED",
  });
}

const allowedRecipients: Record<string, string[]> = {
  ADMIN: ["EXPERT"],
  EXPERT: ["EXTENSION_WORKER", "ADMIN"],
  EXTENSION_WORKER: ["FARMER", "EXPERT"],
  FARMER: ["EXTENSION_WORKER"],
};

function authUser(req: Request) {
  if (!req.user) throw new Error("Authenticated user is missing.");
  return req.user;
}

export async function sendDirectMessage(
  req: Request,
  res: Response,
): Promise<void> {
  const sender = authUser(req);
  const recipientId =
    typeof req.body?.recipientId === "string" ? req.body.recipientId : "";
  const body = typeof req.body?.body === "string" ? req.body.body.trim() : "";
  if (!recipientId || !body) {
    res
      .status(400)
      .json({ error: { message: "recipientId and body are required." } });
    return;
  }
  const [recipient] =
    recipientId === "admin"
      ? [{ id: "admin", role: "ADMIN" }]
      : await database
          .select({ id: users.id, role: users.role })
          .from(users)
          .where(eq(users.id, recipientId))
          .limit(1);
  if (!recipient) {
    res.status(404).json({ error: { message: "Recipient not found." } });
    return;
  }
  if (!allowedRecipients[sender.role]?.includes(recipient.role)) {
    res
      .status(403)
      .json({
        error: {
          message: `A ${sender.role} cannot message a ${recipient.role}.`,
        },
      });
    return;
  }
  const [message] = await database
    .insert(messages)
    .values({
      contentId: "DIRECT",
      channel: "DIRECT",
      body,
      status: "DELIVERED",
      createdBy: sender.id,
    })
    .returning();
  await database
    .insert(messageRecipients)
    .values({ messageId: message.id, recipientId: recipient.id });
  res.status(201).json({ ...message, recipientId: recipient.id, read: false });
}

export async function broadcastMessage(req: Request, res: Response): Promise<void> {
  const sender = authUser(req);
  if (sender.role !== 'EXPERT') {
    res.status(403).json({ error: { message: 'Only agricultural experts can broadcast alerts.' } });
    return;
  }
  const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';
  const location = typeof req.body?.location === 'string' ? req.body.location.trim() : '';
  if (!body) {
    res.status(400).json({ error: { message: 'Alert body is required.' } });
    return;
  }
  const recipients = await database
    .select({ userId: users.id })
    .from(users)
    .innerJoin(farmers, eq(farmers.userId, users.id))
    .where(and(
      eq(users.role, 'FARMER'),
      eq(users.active, true),
      eq(farmers.alertEnabled, true),
      ...(location ? [eq(farmers.region, location)] : []),
    ));
  const [message] = await database.insert(messages).values({
    contentId: 'BROADCAST', channel: 'DIRECT', body, status: 'DELIVERED', createdBy: sender.id,
  }).returning();
  if (recipients.length) {
    await database.insert(messageRecipients).values(recipients.map((farmer) => ({ messageId: message.id, recipientId: farmer.userId })));
  }
  res.status(201).json({ ...message, recipientCount: recipients.length, location: location || null });
}

export async function listMessages(req: Request, res: Response): Promise<void> {
  const user = authUser(req);
  const rows = await database
    .select({
      id: messages.id,
      body: messages.body,
      channel: messages.channel,
      status: messages.status,
      createdAt: messages.createdAt,
      senderId: messages.createdBy,
      senderName: sql<string>`coalesce(${users.fullName}, 'System')`,
      senderRole: users.role,
      recipientId: messageRecipients.recipientId,
      read: sql<boolean>`${messageRecipients.read} or ${messages.createdBy} = ${user.id}`,
      recipientName: sql<string>`coalesce((select full_name from users where id::text = ${messageRecipients.recipientId}), 'User')`,
      isOutgoing: sql<boolean>`${messages.createdBy} = ${user.id}`,
    })
    .from(messageRecipients)
    .innerJoin(messages, eq(messageRecipients.messageId, messages.id))
    .leftJoin(users, sql`${messages.createdBy} = ${users.id}::text`)
    .where(
      or(
        eq(messageRecipients.recipientId, user.id),
        eq(messages.createdBy, user.id),
      ),
    )
    .orderBy(desc(messages.createdAt));
  res.json(rows);
}

export async function listContacts(req: Request, res: Response): Promise<void> {
  const user = authUser(req);
  const roles = allowedRecipients[user.role] ?? [];
  const rows = await database
    .select({
      id: users.id,
      fullName: users.fullName,
      phone: users.phone,
      email: users.email,
      role: users.role,
    })
    .from(users)
    .where(
      sql`${users.role} in (${sql.join(
        roles.map((role) => sql`${role}`),
        sql`, `,
      )}) and ${users.status} = 'APPROVED' and ${users.active} = true`,
    )
    .orderBy(users.fullName);
  if (user.role === "EXPERT") {
    rows.push({
      id: "admin",
      fullName: "Administrator",
      phone: null,
      email: "admin@gmail.com",
      role: "ADMIN",
    });
  }
  res.json(rows);
}

export async function markMessageRead(
  req: Request,
  res: Response,
): Promise<void> {
  const user = authUser(req);
  const [updated] = await database
    .update(messageRecipients)
    .set({ read: true, readAt: new Date() })
    .where(
      and(
        eq(messageRecipients.messageId, String(req.params.id)),
        eq(messageRecipients.recipientId, user.id),
      ),
    )
    .returning();
  updated
    ? res.json(updated)
    : res.status(404).json({ error: { message: "Message not found." } });
}
