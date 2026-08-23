import crypto from 'node:crypto';
import { eq, or } from 'drizzle-orm';
import { db } from '../../config/database';
import { users } from '../../../../database/schema/users';
import { signAccessToken, verifyAccessToken } from './token.service';

export type { AccessTokenPayload } from './token.service';

/**
 * Password hashing: SHA-256.
 * NOTE: For production, upgrade to bcrypt. SHA-256 is used here for
 * simplicity (no async overhead) and matches the existing seeded data.
 */
function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

export async function authenticate(identifier: string, password: string) {
  console.log(`[AUTH] Login attempt for identifier: ${identifier}`);
  const [user] = await db
    .select()
    .from(users)
    .where(or(eq(users.email, identifier), eq(users.phone, identifier)))
    .limit(1);

  if (!user) {
    console.log(`[AUTH] User not found for identifier: ${identifier}`);
    return null;
  }

  if (user.passwordHash !== hashPassword(password)) {
    console.log(`[AUTH] Invalid password for identifier: ${identifier}`);
    return null;
  }

  console.log(`[AUTH] Password verified for user: ${user.id} (${user.role})`);
  const accessToken = signAccessToken({ id: user.id, role: user.role as any });
  console.log(`[JWT] Access token generated for userId=${user.id}`);

  return {
    accessToken,
    user: {
      id: user.id,
      full_name: user.fullName,
      phone: user.phone ?? '',
      email: user.email ?? '',
      role: user.role,
      preferred_language: user.preferredLanguage,
    },
  };
}

export async function registerUser(data: {
  fullName: string;
  phone: string;
  email?: string;
  password: string;
  role: string;
  preferredLanguage: string;
}) {
  console.log(`[AUTH] Registering new user: ${data.fullName} (${data.role})`);
  const [user] = await db
    .insert(users)
    .values({
      fullName: data.fullName,
      phone: data.phone,
      email: data.email ?? null,
      passwordHash: hashPassword(data.password),
      role: data.role,
      preferredLanguage: data.preferredLanguage,
    })
    .returning();
  console.log(`[DATABASE] User created: id=${user.id}, role=${user.role}`);
  return user;
}

export async function getUser(id: string) {
  const [user] = await db.select().from(users).where(eq(users.id, id)).limit(1);
  return user;
}

export { verifyAccessToken as verifyToken };
