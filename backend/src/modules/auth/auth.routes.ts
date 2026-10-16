import { Router } from 'express';
import { loginHandler, registerHandler, meHandler, refreshHandler, logoutHandler } from './auth.controller';

const router = Router();
router.post('/login', loginHandler);
router.post('/register', registerHandler);
router.post('/refresh', refreshHandler);
router.post('/logout', logoutHandler);
router.get('/me', meHandler);
export default router;
