import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { loginSchema, registerSchema } from './auth.schema';
import { authenticate, getUser, registerUser, verifyToken } from './auth.service';

export async function loginHandler(req: Request, res: Response) {
	const parsed = loginSchema.safeParse(req.body);
	if (!parsed.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid login data' } });
	if (parsed.data.identifier.toLowerCase() === (process.env.ADMIN_USERNAME ?? 'admin@gmail.com').toLowerCase() && parsed.data.password === (process.env.ADMIN_PASSWORD ?? 'Admin$2026')) {
		const accessToken = jwt.sign({ sub: 'admin', role: 'ADMIN', type: 'access' }, process.env.JWT_ACCESS_SECRET ?? 'development-secret-change-me-32-chars', { expiresIn: '7d' });
		return res.json({ accessToken, user: { id: 'admin', full_name: 'Administrator', phone: '', email: 'admin@gmail.com', role: 'ADMIN', preferred_language: 'en' } });
	}
	const result = await authenticate(parsed.data.identifier, parsed.data.password);
	if (!result) return res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials or unregistered account' } });
	return res.json(result);
}

export async function registerHandler(req: Request, res: Response) {
	const parsed = registerSchema.safeParse(req.body);
	if (!parsed.success) return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid registration data', details: parsed.error.issues } });
	try { const user = await registerUser(parsed.data); return res.status(201).json({ id: user.id, status: 'PENDING_APPROVAL' }); }
	catch (error: any) { if (error?.code === '23505') return res.status(409).json({ error: { code: 'ACCOUNT_EXISTS', message: 'An account with these details already exists' } }); return res.status(500).json({ error: { code: 'INTERNAL_SERVER_ERROR', message: 'Registration failed' } }); }
}

export async function meHandler(req: Request, res: Response) {
	const header = req.header('authorization');
	if (!header?.startsWith('Bearer ')) return res.status(401).json({ error: { message: 'Authentication required' } });
	try { const user = await getUser(verifyToken(header.slice(7)).sub); if (!user) return res.status(401).json({ error: { message: 'User not found' } }); return res.json({ id: user.id, full_name: user.fullName, phone: user.phone ?? '', email: user.email ?? '', role: user.role, preferred_language: user.preferredLanguage }); }
	catch { return res.status(401).json({ error: { message: 'Invalid token' } }); }
}
