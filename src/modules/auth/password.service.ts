/**
 * Password hashing service — Member 3
 *
 * Argon2id (B1 requirement). Parameters follow the OWASP minimum
 * recommendation for Argon2id: memory 19 MiB, 2 iterations, parallelism 1.
 * The algorithm + parameters are embedded in the hash string, so hashes
 * remain verifiable if parameters are tuned later.
 */
import argon2 from 'argon2';

const ARGON2_OPTIONS: argon2.Options = {
  type: argon2.argon2id,
  memoryCost: 19456, // 19 MiB
  timeCost: 2,
  parallelism: 1,
};

export async function hashPassword(plainPassword: string): Promise<string> {
  return argon2.hash(plainPassword, ARGON2_OPTIONS);
}

/** Constant-time-safe verification; returns false on any error (e.g. corrupt hash). */
export async function verifyPassword(passwordHash: string, plainPassword: string): Promise<boolean> {
  try {
    return await argon2.verify(passwordHash, plainPassword);
  } catch {
    return false;
  }
}
