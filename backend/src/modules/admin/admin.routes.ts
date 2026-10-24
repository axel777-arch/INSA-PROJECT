import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.middleware';
import { requireRole } from '../../middleware/role.middleware';
import { listUsersHandler, getUserHandler, updateUserStatusHandler, listAuditLogsHandler } from './admin.controller';

const router = Router();

// All admin routes require authentication and ADMIN role
router.use(requireAuth);
router.use(requireRole('ADMIN'));

// GET  /api/admin/users
router.get('/users', listUsersHandler);

// GET  /api/admin/users/:id
router.get('/users/:id', getUserHandler);

// PATCH /api/admin/users/:id  — { active: true/false }
router.patch('/users/:id', updateUserStatusHandler);

// GET  /api/admin/audit-logs
router.get('/audit-logs', listAuditLogsHandler);

export default router;
