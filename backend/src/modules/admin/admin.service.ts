/**
 * Admin service — user management and audit logs
 *
 * Provides:
 *   - listAllUsers()       GET  /api/admin/users
 *   - updateUserStatus()   PATCH /api/admin/users/:id
 *   - listAuditLogs()      GET  /api/admin/audit-logs
 *   - createAuditLog()     internal helper called by other services
 */
import { eq, desc } from 'drizzle-orm';
import { db } from '../../db/index';
import { users } from '../../../../database/schema/users';
import { auditLogs } from '../../../../database/schema/auditLogs';

// ── Persistent audit log store ────────────────────────────────────────────────
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export interface AuditLogEntry {
  id: string;
  actor: string;        // userId
  actorName: string;    // display name
  actorRole: string;
  action: string;       // e.g. "USER_APPROVED"
  target: string;       // human-readable target description
  targetId?: string;
  timestamp: Date;
}

export async function addAuditEntry(entry: Omit<AuditLogEntry, 'id' | 'timestamp'>): Promise<void> {
  const validUserId = entry.actor && UUID_REGEX.test(entry.actor) ? entry.actor : null;
  const details = JSON.stringify({
    actorName: entry.actorName,
    actorRole: entry.actorRole,
    target: entry.target,
  });

  try {
    await db.insert(auditLogs).values({
      userId: validUserId,
      action: entry.action,
      entityType: 'USER',
      entityId: entry.targetId ?? null,
      details,
    });
    console.log(`[AUDIT] ${entry.actorRole} ${entry.actorName}: ${entry.action} → ${entry.target}`);
  } catch (err) {
    console.error('[AUDIT ERROR] Failed to persist audit entry to database:', err);
  }
}

export async function listAuditLogs(filters: { role?: string; limit?: number }): Promise<AuditLogEntry[]> {
  const queryLimit = filters.limit ?? 100;

  const rows = await db
    .select({
      id: auditLogs.id,
      userId: auditLogs.userId,
      action: auditLogs.action,
      entityType: auditLogs.entityType,
      entityId: auditLogs.entityId,
      details: auditLogs.details,
      createdAt: auditLogs.createdAt,
      userRole: users.role,
      userFullName: users.fullName,
    })
    .from(auditLogs)
    .leftJoin(users, eq(users.id, auditLogs.userId))
    .orderBy(desc(auditLogs.createdAt))
    .limit(queryLimit);

  const results: AuditLogEntry[] = rows.map((r) => {
    let parsed: any = {};
    if (r.details) {
      try {
        parsed = JSON.parse(r.details);
      } catch {
        parsed = { target: r.details };
      }
    }

    const actorRole = r.userRole ?? parsed.actorRole ?? 'SYSTEM';
    const actorName = r.userFullName ?? parsed.actorName ?? 'System User';
    const target = parsed.target ?? `${r.entityType} ${r.entityId ?? ''}`.trim();

    return {
      id: r.id,
      actor: r.userId ?? '',
      actorName,
      actorRole,
      action: r.action,
      target,
      targetId: r.entityId ?? undefined,
      timestamp: r.createdAt,
    };
  });

  if (filters.role) {
    return results.filter((l) => l.actorRole === filters.role);
  }

  return results;
}

// ── User management ───────────────────────────────────────────────────────────

export interface UserRecord {
  id: string;
  full_name: string;
  phone: string;
  email: string;
  role: string;
  preferred_language: string;
  active: boolean;
  created_at: Date;
}

export async function listAllUsers(): Promise<UserRecord[]> {
  console.log('[SERVICE] Listing all users');
  const rows = await db.select().from(users).orderBy(desc(users.createdAt));
  console.log(`[DATABASE] Users retrieved: ${rows.length}`);
  return rows.map((u) => ({
    id: u.id,
    full_name: u.fullName,
    phone: u.phone ?? '',
    email: u.email ?? '',
    role: u.role,
    preferred_language: u.preferredLanguage,
    active: u.active ?? true,
    created_at: u.createdAt,
  }));
}

export async function getUserById(id: string): Promise<UserRecord | null> {
  const [u] = await db.select().from(users).where(eq(users.id, id)).limit(1);
  if (!u) return null;
  return {
    id: u.id,
    full_name: u.fullName,
    phone: u.phone ?? '',
    email: u.email ?? '',
    role: u.role,
    preferred_language: u.preferredLanguage,
    active: u.active ?? true,
    created_at: u.createdAt,
  };
}

export async function setUserActive(id: string, active: boolean): Promise<UserRecord | null> {
  console.log(`[SERVICE] Setting user ${id} active=${active}`);
  const [updated] = await db
    .update(users)
    .set({
      active,
      updatedAt: new Date(),
    })
    .where(eq(users.id, id))
    .returning();

  if (!updated) return null;
  console.log(`[DATABASE] User ${id} active status set to ${active}`);
  return {
    id: updated.id,
    full_name: updated.fullName,
    phone: updated.phone ?? '',
    email: updated.email ?? '',
    role: updated.role,
    preferred_language: updated.preferredLanguage,
    active: updated.active ?? true,
    created_at: updated.createdAt,
  };
}
