import argon2 from 'argon2';
import { eq, or, sql } from 'drizzle-orm';
import { db } from '../../db/index';
import { users } from '../../../../database/schema/users';
import { signAccessToken, verifyAccessToken } from './token.service';

export type { AccessTokenPayload } from './token.service';

export type AuthResult =
  | {
      success: true;
      accessToken: string;
      token: string;
      user: {
        id: string;
        full_name: string;
        phone: string;
        email: string;
        role: string;
        preferred_language: string;
      };
    }
  | {
      success: false;
      reason: 'USER_NOT_FOUND';
    }
  | {
      success: false;
      reason: 'PASSWORD_MISMATCH';
      userId: string;
    };

/**
 * Hash password using Argon2id.
 */
export async function hashPassword(password: string): Promise<string> {
  return argon2.hash(password, { type: argon2.argon2id });
}

/**
 * Verify password against Argon2id hash.
 */
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, password);
  } catch {
    return false;
  }
}

export async function authenticate(identifier: string, password: string): Promise<AuthResult> {
  const trimmed = identifier.trim();
  console.log(`[AUTH] Login attempt for identifier: "${trimmed}"`);

  // Phone variation support: 09XXXXXXXX <-> +2519XXXXXXXX
  let altPhone: string | null = null;
  if (trimmed.startsWith('+251') && trimmed.length === 13) {
    altPhone = '0' + trimmed.slice(4);
  } else if (trimmed.startsWith('09') && trimmed.length === 10) {
    altPhone = '+251' + trimmed.slice(1);
  }

  const conditions = [
    sql`lower(${users.email}) = ${trimmed.toLowerCase()}`,
    eq(users.phone, trimmed),
  ];
  if (altPhone) {
    conditions.push(eq(users.phone, altPhone));
  }

  const [user] = await db
    .select()
    .from(users)
    .where(or(...conditions))
    .limit(1);

  if (!user) {
    console.log(`[AUTH] User not found for identifier: "${trimmed}"`);
    return { success: false, reason: 'USER_NOT_FOUND' };
  }

  const isValid = await verifyPassword(password, user.passwordHash);
  if (!isValid) {
    console.log(`[AUTH] Invalid password for identifier: "${trimmed}"`);
    return { success: false, reason: 'PASSWORD_MISMATCH', userId: user.id };
  }

  console.log(`[AUTH] Password verified for user: ${user.id} (${user.role})`);
  const accessToken = signAccessToken({ id: user.id, role: user.role as any });
  console.log(`[JWT] Access token generated for userId=${user.id}`);

  return {
    success: true,
    accessToken,
    token: accessToken,
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
  const passwordHash = await hashPassword(data.password);
  const [user] = await db
    .insert(users)
    .values({
      fullName: data.fullName,
      phone: data.phone,
      email: data.email ?? null,
      passwordHash,
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
