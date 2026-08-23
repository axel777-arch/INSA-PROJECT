import crypto from 'node:crypto';
import { and, eq, or } from 'drizzle-orm';
import jwt from 'jsonwebtoken';
import { db } from '../../config/database';
import { users } from '../../../../database/schema/users';
import { auditLogs } from '../../../../database/schema/auditLogs';

const secret = process.env.JWT_ACCESS_SECRET ?? 'development-secret-change-me-32-chars';
const hashPassword = (password: string) => crypto.createHash('sha256').update(password).digest('hex');

export async function authenticate(identifier: string, password: string) {
	const [user] = await db.select().from(users).where(or(eq(users.email, identifier), eq(users.phone, identifier))).limit(1);
	if (!user || user.passwordHash !== hashPassword(password)) return null;
	if (user.status !== 'APPROVED' || !user.active) return { pending: true };
	if (user.role !== 'FARMER') {
		const [existingLogin] = await db.select({ id: auditLogs.id }).from(auditLogs).where(and(eq(auditLogs.actorId, user.id), eq(auditLogs.action, 'USER_LOGIN'))).limit(1);
		if (existingLogin) {
			await db.update(auditLogs).set({ createdAt: new Date(), targetId: user.id }).where(eq(auditLogs.id, existingLogin.id));
		} else {
			await db.insert(auditLogs).values({ actorId: user.id, actorRole: user.role, action: 'USER_LOGIN', targetType: 'USER', targetId: user.id });
		}
	}
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
