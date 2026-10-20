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
        status?: string;
        document_url?: string | null;
        active?: boolean;
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
      status: user.status ?? 'APPROVED',
      document_url: user.documentUrl ?? null,
      active: user.active,
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
  documentUrl?: string;
}) {
  console.log(`[AUTH] Registering new user: ${data.fullName} (${data.role})`);
  const passwordHash = await hashPassword(data.password);
  const requiresApproval = data.role === 'EXPERT' || data.role === 'EXTENSION_WORKER';
  const status = requiresApproval ? 'PENDING_APPROVAL' : 'APPROVED';
  const active = !requiresApproval;

  const [user] = await db
    .insert(users)
    .values({
      fullName: data.fullName,
      phone: data.phone,
      email: data.email ?? null,
      passwordHash,
      role: data.role,
      preferredLanguage: data.preferredLanguage,
      status,
      documentUrl: data.documentUrl ?? null,
      active,
    })
    .returning();
  console.log(`[DATABASE] User created: id=${user.id}, role=${user.role}, status=${user.status}`);
  return user;
}

export async function changePassword(
  userId: string,
  currentPass: string,
  newPass: string
): Promise<{ success: boolean; message: string }> {
  const [user] = await db.select().from(users).where(eq(users.id, userId)).limit(1);
  if (!user) {
    return { success: false, message: 'User not found' };
  }

  const isMatch = await verifyPassword(currentPass, user.passwordHash);
  if (!isMatch) {
    return { success: false, message: 'Incorrect current password' };
  }

  if (newPass.length < 8) {
    return { success: false, message: 'New password must be at least 8 characters long' };
  }

  const hasLetter = /[a-zA-Z]/.test(newPass);
  const hasDigit = /[0-9]/.test(newPass);
  if (!hasLetter || !hasDigit) {
    return { success: false, message: 'Password must contain both letters and digits' };
  }

  const newHash = await hashPassword(newPass);
  await db
    .update(users)
    .set({
      passwordHash: newHash,
      updatedAt: new Date(),
    })
    .where(eq(users.id, userId));

  return { success: true, message: 'Password changed successfully' };
}

export async function getUser(id: string) {
  const [user] = await db.select().from(users).where(eq(users.id, id)).limit(1);
  return user;
}

export { verifyAccessToken as verifyToken };
