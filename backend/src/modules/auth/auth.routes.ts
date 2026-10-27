import { Router } from 'express';
import { loginHandler, registerHandler, meHandler, refreshHandler, logoutHandler } from './auth.controller';
import { requireAuth } from '../../middleware/auth.middleware';

const router = Router();
router.post('/login', loginHandler);
router.post('/register', registerHandler);
router.get('/me', meHandler);
router.post('/refresh', refreshHandler);
router.post('/logout', logoutHandler);

export default router;
