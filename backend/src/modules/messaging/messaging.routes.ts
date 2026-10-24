import { Router } from 'express';

import { createSmsMessage } from './message.controller';

const router = Router();

router.post('/sms', createSmsMessage);

export default router;
