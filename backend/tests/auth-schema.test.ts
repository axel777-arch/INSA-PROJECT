import test from 'node:test';
import assert from 'node:assert/strict';
import { registerSchema } from '../src/modules/auth/auth.schema';

const validRegistration = {
  fullName: 'Test User',
  phone: '+251912345678',
  password: 'CorrectHorseBatteryStaple1!',
  preferredLanguage: 'en',
};

test('registration accepts only self-registerable roles', () => {
  assert.equal(
    registerSchema.safeParse({
      ...validRegistration,
      role: 'EXTENSION_WORKER',
    }).success,
    true,
  );
  assert.equal(
    registerSchema.safeParse({
      ...validRegistration,
      role: 'FARMER',
    }).success,
    true,
  );
  assert.equal(
    registerSchema.safeParse({
      ...validRegistration,
      role: 'EXPERT',
    }).success,
    false,
  );
  assert.equal(
    registerSchema.safeParse({
      ...validRegistration,
      role: 'ADMIN',
    }).success,
    false,
  );
});
