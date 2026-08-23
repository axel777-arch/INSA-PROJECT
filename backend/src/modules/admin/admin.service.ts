/**
 * Admin service — user management and audit logs
 *
 * Provides:
 *   - listAllUsers()       GET  /api/admin/users
 *   - updateUserStatus()   PATCH /api/admin/users/:id
 *   - listAuditLogs()      GET  /api/admin/audit-logs
 *   - createAuditLog()     internal helper called by other services
 */
import { eq, desc, and } from 'drizzle-orm';
import { db } from '../../config/database';
import { users } from '../../../../database/schema/users';

// ── In-process audit log store ────────────────────────────────────────────────
// The DB schema file for auditLogs is empty, so we maintain a lightweight
// in-memory log that survives the server session and resets on restart.
// Entries are appended by addAuditEntry() which is called from controllers.

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

let _auditLogs: AuditLogEntry[] = [];
let _logSeq = 0;

export function addAuditEntry(entry: Omit<AuditLogEntry, 'id' | 'timestamp'>): void {
  _auditLogs.unshift({
    ...entry,
    id: `log-${Date.now()}-${++_logSeq}`,
    timestamp: new Date(),
  });
  // Keep only the last 500 entries in memory
  if (_auditLogs.length > 500) _auditLogs = _auditLogs.slice(0, 500);
  console.log(`[AUDIT] ${entry.actorRole} ${entry.actorName}: ${entry.action} → ${entry.target}`);
}

export function listAuditLogs(filters: { role?: string; limit?: number }): AuditLogEntry[] {
  let results = _auditLogs;
  if (filters.role) {
    results = results.filter((l) => l.actorRole === filters.role);
  }
  return results.slice(0, filters.limit ?? 100);
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

// We track disabled users in memory until a proper `active` DB column is added.
const _disabledUsers = new Set<string>();

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
    active: !_disabledUsers.has(u.id),
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
    active: !_disabledUsers.has(u.id),
    created_at: u.createdAt,
  };
}

export async function setUserActive(id: string, active: boolean): Promise<UserRecord | null> {
  console.log(`[SERVICE] Setting user ${id} active=${active}`);
  const user = await getUserById(id);
  if (!user) return null;
  if (active) {
    _disabledUsers.delete(id);
  } else {
    _disabledUsers.add(id);
  }
  console.log(`[DATABASE] User ${id} active status set to ${active}`);
  return { ...user, active };
}
