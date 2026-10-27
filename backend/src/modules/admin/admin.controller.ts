import type { Request, Response, NextFunction } from 'express';
import { listAllUsers, getUserById, setUserActive, setUserApproval, listAuditLogs, addAuditEntry } from './admin.service';
import { z } from 'zod';

// ── List all users ─────────────────────────────────────────────────────────
export async function listUsersHandler(req: Request, res: Response, next: NextFunction) {
  try {
    console.log('[CONTROLLER] listUsersHandler called');
    const allUsers = await listAllUsers();
    res.json(allUsers);
  } catch (err) {
    next(err);
  }
}

// ── Get single user ────────────────────────────────────────────────────────
export async function getUserHandler(req: Request, res: Response, next: NextFunction) {
  try {
    // Normalize id param (can be string | string[] depending on Express runtime)
    const rawId = req.params.id;
    const id = typeof rawId === 'string' ? rawId : Array.isArray(rawId) ? rawId[0] : String(rawId);

    const user = await getUserById(id);
    if (!user) return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'User not found' } });
    res.json(user);
  } catch (err) {
    next(err);
  }
}

// ── Update user status (approve / disable) ─────────────────────────────────────
const updateUserSchema = z
  .object({
    active: z.boolean().optional(),
    status: z.enum(['APPROVED', 'REJECTED']).optional(),
  })
  .refine((d) => d.active !== undefined || d.status !== undefined, {
    message: 'Provide active (boolean) or status (APPROVED | REJECTED)',
  });

export async function updateUserStatusHandler(req: Request, res: Response, next: NextFunction) {
  try {
    console.log('[CONTROLLER] updateUserStatusHandler called');
    const rawId = req.params.id;
    const id = typeof rawId === 'string' ? rawId : Array.isArray(rawId) ? rawId[0] : String(rawId);

    const parsed = updateUserSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Provide active (boolean) or status (APPROVED | REJECTED)', details: parsed.error.issues } });
    }

    const updated = parsed.data.status
      ? await setUserApproval(id, parsed.data.status)
      : await setUserActive(id, parsed.data.active as boolean);
    if (!updated) return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'User not found' } });

    // Record audit log entry
    if (req.user) {
      const actorUser = await getUserById(req.user.id).catch(() => null);
      addAuditEntry({
        actor: req.user.id,
        actorName: actorUser?.full_name ?? req.user.id,
        actorRole: req.user.role,
        action: parsed.data.status
          ? (parsed.data.status === 'APPROVED' ? 'USER_APPROVED' : 'USER_REJECTED')
          : (parsed.data.active ? 'USER_ENABLED' : 'USER_DISABLED'),
        target: `${updated.full_name} (${updated.role})`,
        targetId: id,
      });
    }

    res.json(updated);
  } catch (err) {
    next(err);
  }
}

// ── Audit logs ──────────────────────────────────────────────────────────
export async function listAuditLogsHandler(req: Request, res: Response, next: NextFunction) {
  try {
    console.log('[CONTROLLER] listAuditLogsHandler called');
    const role = typeof req.query.role === 'string' ? req.query.role : undefined;
    const limit = req.query.limit ? Number(req.query.limit) : 100;
    const logs = await listAuditLogs({ role, limit });
    console.log(`[DATABASE] Audit logs retrieved: ${logs.length}`);
    res.json(logs);
  } catch (err) {
    next(err);
  }
}
