import { Router } from 'express';
import { loginHandler, registerHandler, meHandler } from './auth.controller';

const router = Router();
router.post('/login', loginHandler);
router.post('/register', registerHandler);
router.get('/me', meHandler);
export default router;
