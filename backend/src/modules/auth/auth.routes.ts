import { Router } from 'express';
import { loginHandler, registerHandler, meHandler, logoutHandler, changePasswordHandler } from './auth.controller';

const router = Router();
router.post('/login', loginHandler);
router.post('/register', registerHandler);
router.post('/logout', logoutHandler);
router.post('/change-password', changePasswordHandler);
router.get('/me', meHandler);
export default router;
