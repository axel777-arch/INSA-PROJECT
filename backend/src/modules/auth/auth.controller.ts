import { Request, Response } from 'express';
import { loginSchema, registerSchema } from './auth.schema';
import { authenticate, getUser, registerUser, verifyToken } from './auth.service';

export async function loginHandler(req: Request, res: Response) {
  console.log('[CONTROLLER] loginHandler called');

  // Check 1: Missing or empty request body
  if (!req.body || typeof req.body !== 'object' || Object.keys(req.body).length === 0) {
    console.warn('[AUTH LOGIN FAILURE] Request failed: Missing or empty request body');
    return res.status(400).json({
      success: false,
      message: 'Request body is missing',
      errors: [],
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Request body is missing',
        details: [],
      },
    });
  }

  // Check 2: Validation schema parse
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    console.warn('[AUTH LOGIN FAILURE] Request failed: Validation schema error', parsed.error.issues);
    return res.status(400).json({
      success: false,
      message: 'Invalid login data',
      errors: parsed.error.issues,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid login data',
        details: parsed.error.issues,
      },
    });
  }

  const { identifier, password } = parsed.data;

  console.log(`[AUTH] Processing login attempt for: "${identifier}"`);
  const result = await authenticate(identifier, password);

  // Check 3: Authentication failure (non-existent user vs password mismatch)
  if (!result.success) {
    if (result.reason === 'USER_NOT_FOUND') {
      console.warn(`[AUTH LOGIN FAILURE] Request failed: Non-existent user for identifier "${identifier}"`);
    } else if (result.reason === 'PASSWORD_MISMATCH') {
      console.warn(`[AUTH LOGIN FAILURE] Request failed: Password mismatch for identifier "${identifier}" (userId=${result.userId})`);
    }

    return res.status(401).json({
      success: false,
      message: 'Invalid credentials or unregistered account',
      errors: [],
      error: {
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid credentials or unregistered account',
        details: [],
      },
    });
  }

  // Success: Set HTTP headers and return standardized JSON payload
  console.log(`[AUTH LOGIN SUCCESS] Login successful: userId=${result.user.id}, role=${result.user.role}`);
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Cache-Control', 'no-store');

  return res.status(200).json({
    accessToken: result.accessToken,
    token: result.accessToken,
    user: result.user,
  });
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
    const user = await getUser(payload.sub);
    if (!user) return res.status(401).json({ error: { message: 'User not found' } });
    return res.json({ id: user.id, full_name: user.fullName, phone: user.phone ?? '', email: user.email ?? '', role: user.role, preferred_language: user.preferredLanguage });
  } catch {
    return res.status(401).json({ error: { message: 'Invalid token' } });
  }
}
