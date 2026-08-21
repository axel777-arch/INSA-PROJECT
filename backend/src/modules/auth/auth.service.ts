import crypto from 'node:crypto';
import { eq, or } from 'drizzle-orm';
import jwt from 'jsonwebtoken';
import { db } from '../../config/database';
import { users } from '../../../../database/schema/users';

const secret = process.env.JWT_ACCESS_SECRET ?? 'development-secret-change-me-32-chars';
const hashPassword = (password: string) => crypto.createHash('sha256').update(password).digest('hex');

export async function authenticate(identifier: string, password: string) {
	const [user] = await db.select().from(users).where(or(eq(users.email, identifier), eq(users.phone, identifier))).limit(1);
	if (!user || user.passwordHash !== hashPassword(password)) return null;
	const accessToken = jwt.sign({ sub: user.id, role: user.role, type: 'access' }, secret, { expiresIn: '7d' });
	return { accessToken, user: { id: user.id, full_name: user.fullName, phone: user.phone ?? '', email: user.email ?? '', role: user.role, preferred_language: user.preferredLanguage } };
}

export async function registerUser(data: { fullName: string; phone: string; email?: string; password: string; role: string; preferredLanguage: string }) {
	const [user] = await db.insert(users).values({ fullName: data.fullName, phone: data.phone, email: data.email ?? null, passwordHash: hashPassword(data.password), role: data.role, preferredLanguage: data.preferredLanguage }).returning();
	return user;
}

export async function getUser(id: string) {
	const [user] = await db.select().from(users).where(eq(users.id, id)).limit(1);
	return user;
}

export const verifyToken = (token: string) => jwt.verify(token, secret) as { sub: string };
