import { Router } from 'express';

import { createSmsMessage, listContacts, listMessages, markMessageRead, sendDirectMessage } from './message.controller';
import { requireAuth } from '../../middleware/auth.middleware';
import { requirePermission } from '../../middleware/role.middleware';
import { broadcastMessage } from './message.controller';

const router = Router();

router.post('/sms', createSmsMessage);
router.post('/direct', requireAuth, requirePermission('message:send'), sendDirectMessage);
router.get('/', requireAuth, requirePermission('message:read'), listMessages);
router.get('/contacts', requireAuth, requirePermission('message:send'), listContacts);
router.post('/broadcast', requireAuth, requirePermission('message:send'), broadcastMessage);
router.patch('/:id/read', requireAuth, requirePermission('message:read'), markMessageRead);

export default router;
