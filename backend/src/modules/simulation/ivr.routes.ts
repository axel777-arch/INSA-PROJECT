import { Router } from 'express';
import {
  startIvrSessionHandler,
  sendIvrDtmfHandler,
  endIvrSessionHandler,
  getIvrSessionHandler,
} from './ivr.controller';
import { requireAuth } from '../../middleware/auth.middleware';
import { requirePermission } from '../../middleware/role.middleware';

const router = Router();

router.use(requireAuth, requirePermission('simulator:use'));
router.post('/', startIvrSessionHandler);
router.post('/start', startIvrSessionHandler);
router.post('/session', startIvrSessionHandler);
router.post('/dtmf', sendIvrDtmfHandler);
router.post('/end', endIvrSessionHandler);
router.get('/:sessionId', getIvrSessionHandler);

export default router;
