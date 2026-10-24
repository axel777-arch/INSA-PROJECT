import { Router } from 'express';
import {
  startIvrSessionHandler,
  sendIvrDtmfHandler,
  endIvrSessionHandler,
  getIvrSessionHandler,
} from './ivr.controller';

const router = Router();

router.post('/', startIvrSessionHandler);
router.post('/start', startIvrSessionHandler);
router.post('/session', startIvrSessionHandler);
router.post('/dtmf', sendIvrDtmfHandler);
router.post('/end', endIvrSessionHandler);
router.get('/:sessionId', getIvrSessionHandler);

export default router;
