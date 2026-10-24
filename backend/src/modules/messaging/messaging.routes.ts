import { Router } from 'express';

import { createSmsMessage } from './message.controller';
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

router.post('/sms', requireAuth, requirePermission("message:send"), createSmsMessage);

export default router;
