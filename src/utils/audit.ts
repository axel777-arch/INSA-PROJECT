/**
 * Audit logging helper — Member 3
 *
 * Basic audit logging is an MVP requirement (A4). This helper writes to the
 * audit_logs table and NEVER throws — an audit failure must not break a
 * business request (the failure is logged to the server console instead).
 *
 * USAGE (Members 5/6 — required for sensitive actions):
 *   import { auditLog } from '../../utils/audit.js';
 *   await auditLog(req, {
 *     action: 'content.approve',
 *     entityType: 'content',
 *     entityId: contentId,
 *     metadata: { decision: 'APPROVED' },
 *   });
 *
 * Never put passwords, tokens, or message bodies in `metadata`.
 */
import type { Request } from 'express';
import { db } from '../db/index.js';
import { auditLogs } from '../db/schema/audit-logs.js';
import { logger } from './logger.js';

export interface AuditEntry {
  action: string;
  entityType: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
}

export async function auditLog(req: Request, entry: AuditEntry): Promise<void> {
  try {
    await db.insert(auditLogs).values({
      actorUserId: req.user?.id ?? null,
      action: entry.action,
      entityType: entry.entityType,
      entityId: entry.entityId ?? null,
      metadata: entry.metadata ?? null,
    });
  } catch (err) {
    logger.error('Failed to write audit log', { action: entry.action, error: err });
  }
}
