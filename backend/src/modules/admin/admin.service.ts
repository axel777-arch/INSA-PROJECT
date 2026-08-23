import { alias } from "drizzle-orm/pg-core";
import { desc, eq, ilike, or, sql } from "drizzle-orm";
import { db } from "../../config/database";
import { auditLogs } from "../../../../database/schema/auditLogs";
import { content } from "../../../../database/schema/content";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { messages } from "../../../../database/schema/messages";
import { cropRecords } from "../../../../database/schema/cropRecords";
import { fieldObservations } from "../../../../database/schema/fieldObservations";
import { farmerCrops } from "../../../../database/schema/farmerCrops";
import { adminSettings } from "../../db/schema/admin-settings";

type AdminActor = { id: string; role: string };

async function writeAudit(
  actor: AdminActor,
  action: string,
  targetId: string | undefined,
  details?: string,
) {
  if (targetId) {
    const [existing] = await db.select({ id: auditLogs.id })
      .from(auditLogs)
      .where(eq(auditLogs.targetId, targetId))
      .orderBy(desc(auditLogs.createdAt))
      .limit(1);
    if (existing) {
      await db.update(auditLogs).set({ actorId: actor.id, actorRole: actor.role, action, details, createdAt: new Date() }).where(eq(auditLogs.id, existing.id));
      return;
    }
  }
  await db.insert(auditLogs).values({ actorId: actor.id, actorRole: actor.role, action, targetType: "USER", targetId, details });
}

export async function getOverview() {
  const [rows, contentRows, farmerRows, messageRows, regionRows] = await Promise.all([
    db
      .select({
        role: users.role,
        status: users.status,
        count: sql<number>`count(*)::int`,
      })
      .from(users)
      .groupBy(users.role, users.status),
    db
      .select({ status: content.status, count: sql<number>`count(*)::int` })
      .from(content)
      .groupBy(content.status),
    db.select({ count: sql<number>`count(*)::int` }).from(users).where(eq(users.role, "FARMER")),
    db.select({ status: messages.status, count: sql<number>`count(*)::int` }).from(messages).groupBy(messages.status),
    db.select({ region: farmers.region, count: sql<number>`count(*)::int` }).from(farmers).groupBy(farmers.region),
  ]);

  const summary = rows.reduce<Record<string, unknown>>((result, row) => {
    result[`${row.status.toLowerCase()}_${row.role.toLowerCase()}`] = row.count;
    result.totalUsers = ((result.totalUsers as number | undefined) ?? 0) + row.count;
    if (row.status === "PENDING_APPROVAL")
      result.pendingApprovals = ((result.pendingApprovals as number | undefined) ?? 0) + row.count;
    return result;
  }, {});
  for (const row of contentRows)
    summary[`${row.status.toLowerCase()}Content`] = row.count;
  summary.totalFarmers = farmerRows[0]?.count ?? 0;
  for (const row of messageRows) summary[`${row.status.toLowerCase()}Messages`] = row.count;
  summary.totalMessages = messageRows.reduce((total, row) => total + row.count, 0);
  summary.deliveredMessages = messageRows.find((row) => row.status === "DELIVERED")?.count ?? 0;
  const totalMessages = summary.totalMessages as number;
  const deliveredMessages = summary.deliveredMessages as number;
  summary.deliveryRate = totalMessages
    ? Math.round((deliveredMessages / totalMessages) * 1000) / 10
    : 0;
  summary.regionCounts = Object.fromEntries(regionRows.map((row) => [row.region ?? "Unknown", row.count]));
  return summary;
}

export async function listUsers(filters: {
  search?: string;
  role?: string;
  status?: string;
}) {
  const conditions = [];
  if (filters.role && filters.role !== "ALL")
    conditions.push(eq(users.role, filters.role));
  if (filters.status === "ACTIVE") conditions.push(eq(users.active, true));
  if (filters.status === "DISABLED") conditions.push(eq(users.active, false));
  if (filters.status && !["ALL", "ACTIVE", "DISABLED"].includes(filters.status))
    conditions.push(eq(users.status, filters.status));
  if (filters.search) {
    const search = `%${filters.search}%`;
    conditions.push(
      or(
        ilike(users.fullName, search),
        ilike(users.phone, search),
        ilike(users.email, search),
      ),
    );
  }

  return db
    .select({
      id: users.id,
      fullName: users.fullName,
      phone: users.phone,
      email: users.email,
      role: users.role,
      status: users.status,
      active: users.active,
      preferredLanguage: users.preferredLanguage,
      createdAt: users.createdAt,
    })
    .from(users)
    .where(conditions.length ? sql.join(conditions, sql` AND `) : undefined)
    .orderBy(desc(users.createdAt));
}

export async function changeUserStatus(
  actor: AdminActor,
  userId: string,
  status: "APPROVED" | "REJECTED",
) {
  const [updated] = await db
    .update(users)
    .set({ status, active: status === "APPROVED" })
    .where(eq(users.id, userId))
    .returning();
  if (!updated) return null;
  await writeAudit(actor, `USER_${status}`, userId);
  return updated;
}

export async function setUserActive(
  actor: AdminActor,
  userId: string,
  active: boolean,
) {
  const [updated] = await db
    .update(users)
    .set({ active })
    .where(eq(users.id, userId))
    .returning();
  if (!updated) return null;
  await writeAudit(actor, active ? "USER_ENABLED" : "USER_DISABLED", userId);
  return updated;
}

export async function deleteUser(actor: AdminActor, userId: string) {
  const [target] = await db.select({ id: users.id, fullName: users.fullName })
    .from(users).where(eq(users.id, userId)).limit(1);
  if (!target) return null;
  await db.transaction(async (tx) => {
    const farmerRows = await tx.select({ id: farmers.id }).from(farmers).where(eq(farmers.userId, userId));
    for (const farmer of farmerRows) {
      await tx.delete(farmerCrops).where(eq(farmerCrops.farmerId, farmer.id));
    }
    await tx.delete(cropRecords).where(eq(cropRecords.createdBy, userId));
    await tx.delete(fieldObservations).where(eq(fieldObservations.createdBy, userId));
    await tx.delete(fieldObservations).where(eq(fieldObservations.respondedBy, userId));
    await tx.delete(users).where(eq(users.id, userId));
  });
  const deleted = target;
  if (!deleted) return null;
  await writeAudit(actor, "USER_DELETED", userId, `Deleted user ${deleted.fullName}`);
  return deleted;
}

export async function listAuditLogs() {
  const actorUser = alias(users, "audit_actor");
  const targetUser = alias(users, "audit_target");

  return db
    .select({
      id: auditLogs.id,
      action: auditLogs.action,
      actorRole: auditLogs.actorRole,
      actorId: auditLogs.actorId,
      actorName: sql<string>`coalesce(${actorUser.fullName}, case when ${auditLogs.actorId} = 'admin' then 'Administrator' else ${auditLogs.actorId} end)`,
      targetId: auditLogs.targetId,
      targetName: sql<string>`coalesce(${targetUser.fullName}, ${auditLogs.targetId}, 'System')`,
      targetPhone: targetUser.phone,
      targetEmail: targetUser.email,
      targetRole: targetUser.role,
      status: sql<string>`case
        when ${auditLogs.action} like '%APPROVED%' or ${auditLogs.action} like '%ENABLED%' then 'APPROVED'
        when ${auditLogs.action} like '%REJECTED%' or ${auditLogs.action} like '%DISABLED%' then 'REJECTED'
        when ${auditLogs.action} = 'USER_LOGIN' then 'LOGGED IN'
        else ${auditLogs.action}
      end`,
      targetType: auditLogs.targetType,
      details: auditLogs.details,
      createdAt: auditLogs.createdAt,
    })
    .from(auditLogs)
    .leftJoin(actorUser, sql`${auditLogs.actorId} = ${actorUser.id}::text`)
    .leftJoin(targetUser, sql`${auditLogs.targetId} = ${targetUser.id}::text`)
    .where(sql`not (${auditLogs.actorRole} = 'FARMER' and ${auditLogs.action} = 'USER_LOGIN')`)
    .orderBy(desc(auditLogs.createdAt))
    .limit(100);
}

const defaultSettings = {
  instanceName: "Agri-Insight Beacon",
  defaultLanguage: "English",
  supportEmail: "support@agri-insight.com",
  smsBroadcastEnabled: true,
  maintenanceMode: false,
  autoEscalationHours: 24,
};

export async function getSettings() {
  const [settings] = await db.select().from(adminSettings).limit(1);
  if (settings) return settings;
  const [created] = await db.insert(adminSettings).values(defaultSettings).returning();
  return created;
}

export async function updateSettings(input: Record<string, unknown>) {
  const current = await getSettings();
  const [updated] = await db
    .update(adminSettings)
    .set({
      instanceName: typeof input.instanceName === "string" ? input.instanceName.trim() : current.instanceName,
      defaultLanguage: typeof input.defaultLanguage === "string" ? input.defaultLanguage : current.defaultLanguage,
      supportEmail: typeof input.supportEmail === "string" ? input.supportEmail.trim() : current.supportEmail,
      smsBroadcastEnabled: typeof input.smsBroadcastEnabled === "boolean" ? input.smsBroadcastEnabled : current.smsBroadcastEnabled,
      maintenanceMode: typeof input.maintenanceMode === "boolean" ? input.maintenanceMode : current.maintenanceMode,
      autoEscalationHours: typeof input.autoEscalationHours === "number" ? input.autoEscalationHours : current.autoEscalationHours,
      updatedAt: new Date(),
    })
    .where(eq(adminSettings.id, current.id))
    .returning();
  return updated;
}
