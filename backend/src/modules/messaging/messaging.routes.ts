import { Router } from 'express';

import { createSmsMessage } from './message.controller';
import { requireAuth } from '../../middleware/auth.middleware';
import { requirePermission } from '../../middleware/role.middleware';

const router = Router();

router.use(requireAuth, requirePermission('message:send'));
router.post('/sms', createSmsMessage);

export default router;
