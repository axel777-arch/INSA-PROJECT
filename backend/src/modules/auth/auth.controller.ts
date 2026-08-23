import { Request, Response } from 'express';
import { loginSchema, registerSchema } from './auth.schema';
import { authenticate, getUser, registerUser, verifyToken } from './auth.service';
import { signAccessToken } from './token.service';

export async function loginHandler(req: Request, res: Response) {
  console.log('[CONTROLLER] loginHandler called');
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid login data', details: parsed.error.issues } });
  }

  const { identifier, password } = parsed.data;

  // Admin shortcut — credentials from environment variables
  const adminUsername = process.env.ADMIN_USERNAME ?? 'admin@gmail.com';
  const adminPassword = process.env.ADMIN_PASSWORD ?? 'Admin$2026';

  if (identifier.toLowerCase() === adminUsername.toLowerCase() && password === adminPassword) {
    console.log('[AUTH] Admin login via env credentials');
    const accessToken = signAccessToken({ id: 'admin', role: 'ADMIN' });
    console.log('[JWT] Admin access token generated');
    return res.json({
      accessToken,
      user: { id: 'admin', full_name: 'Administrator', phone: '', email: adminUsername, role: 'ADMIN', preferred_language: 'en' },
    });
  }

  console.log(`[AUTH] Regular login for: ${identifier}`);
  const result = await authenticate(identifier, password);
  if (!result) {
    return res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials or unregistered account' } });
  }
  console.log(`[AUTH] Login successful: userId=${result.user.id}, role=${result.user.role}`);
  return res.json(result);
}

export async function registerHandler(req: Request, res: Response) {
  console.log('[CONTROLLER] registerHandler called');
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid registration data', details: parsed.error.issues } });
  }
  try {
    const user = await registerUser(parsed.data);
    console.log(`[AUTH] Registration successful: userId=${user.id}, role=${user.role}`);
    return res.status(201).json({ id: user.id, status: 'PENDING_APPROVAL' });
  } catch (error: any) {
    const code = error?.cause?.code ?? error?.code;
    if (code === '23505') {
      return res.status(409).json({ error: { code: 'ACCOUNT_EXISTS', message: 'An account with these details already exists' } });
    }
    console.error('[AUTH] Registration error:', error);
    return res.status(500).json({ error: { code: 'INTERNAL_SERVER_ERROR', message: 'Registration failed' } });
  }
}

export async function meHandler(req: Request, res: Response) {
  const header = req.header('authorization');
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ error: { message: 'Authentication required' } });
  }
  try {
    const payload = verifyToken(header.slice(7));
    // Admin virtual user
    if (payload.sub === 'admin') {
      return res.json({ id: 'admin', full_name: 'Administrator', phone: '', email: process.env.ADMIN_USERNAME ?? 'admin@gmail.com', role: 'ADMIN', preferred_language: 'en' });
    }
    const user = await getUser(payload.sub);
    if (!user) return res.status(401).json({ error: { message: 'User not found' } });
    return res.json({ id: user.id, full_name: user.fullName, phone: user.phone ?? '', email: user.email ?? '', role: user.role, preferred_language: user.preferredLanguage });
  } catch {
    return res.status(401).json({ error: { message: 'Invalid token' } });
  }
}
