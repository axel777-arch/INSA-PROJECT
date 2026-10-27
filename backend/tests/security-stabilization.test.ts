import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { registerSchema, loginSchema } from '../src/modules/auth/auth.schema';
import { registerUser } from '../src/modules/auth/auth.service';
import { signAccessToken, verifyAccessToken } from '../src/modules/auth/token.service';
import { hasPermission } from '../src/config/permissions';
import { canTransition, assertTransition } from '../src/modules/content/content.workflow';
import type { ContentStatus } from '../src/modules/content/content.types';

describe('Security & Stabilization Verification Suite', () => {
  describe('Authentication & Role Escalation Prevention', () => {
    it('public registration schema rejects ADMIN role', () => {
      const payload = {
        fullName: 'Attacker Name',
        phone: '+251911000099',
        password: 'Password$2026',
        role: 'ADMIN',
        preferredLanguage: 'en',
      };
      const result = registerSchema.safeParse(payload);
      assert.equal(result.success, false);
      const issues = result.error?.issues ?? [];
      assert.ok(issues.some((i) => i.path.includes('role')));
    });

    it('public registration schema allows valid user roles', () => {
      const validRoles = ['FARMER', 'EXTENSION_WORKER', 'EXPERT'] as const;
      for (const role of validRoles) {
        const payload = {
          fullName: 'Valid User',
          phone: '+251911000099',
          password: 'Password$2026',
          role,
          preferredLanguage: 'en',
        };
        const result = registerSchema.safeParse(payload);
        assert.equal(result.success, true);
      }
    });

    it('registerUser service rejects ADMIN role', async () => {
      await assert.rejects(
        async () => {
          await registerUser({
            fullName: 'Malicious Admin Attempt',
            phone: '+251911000099',
            password: 'Password$2026',
            role: 'ADMIN',
            preferredLanguage: 'en',
          });
        },
        {
          name: 'ForbiddenError',
          message: /ADMIN accounts cannot be self-registered/,
        }
      );
    });

    it('validates login schema accepting phone or email as identifier', () => {
      const phoneLogin = loginSchema.safeParse({
        identifier: '+251911000001',
        password: 'Password$2026',
      });
      assert.equal(phoneLogin.success, true);

      const emailLogin = loginSchema.safeParse({
        identifier: 'worker@gmail.com',
        password: 'Password$2026',
      });
      assert.equal(emailLogin.success, true);

      const emptyLogin = loginSchema.safeParse({
        identifier: '',
        password: 'Password$2026',
      });
      assert.equal(emptyLogin.success, false);
    });

    it('signs and verifies access tokens correctly', () => {
      const token = signAccessToken({
        id: 'b1000000-0000-4000-8000-000000000003',
        role: 'EXTENSION_WORKER',
      });
      assert.ok(typeof token === 'string' && token.length > 20);

      const payload = verifyAccessToken(token);
      assert.equal(payload.sub, 'b1000000-0000-4000-8000-000000000003');
      assert.equal(payload.role, 'EXTENSION_WORKER');
      assert.equal(payload.type, 'access');
    });

    it('rejects tampered access tokens', () => {
      assert.throws(
        () => verifyAccessToken('invalid.token.signature'),
        /Invalid access token/
      );
    });
  });

  describe('Role-Based Access Control (RBAC) Permissions', () => {
    it('enforces FARMER permissions boundaries', () => {
      assert.equal(hasPermission('FARMER', 'farmer:read'), false);
      assert.equal(hasPermission('FARMER', 'farmer:create'), false);
      assert.equal(hasPermission('FARMER', 'farmer:edit'), false);
      assert.equal(hasPermission('FARMER', 'farmer:assign'), false);
      assert.equal(hasPermission('FARMER', 'content:approve'), false);
      assert.equal(hasPermission('FARMER', 'message:read'), true);
      assert.equal(hasPermission('FARMER', 'case:read'), true);
    });

    it('enforces EXTENSION_WORKER permissions boundaries', () => {
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:read'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:edit'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:assign'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'observation:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'followup:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'content:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'content:approve'), false);
    });

    it('enforces EXPERT permissions boundaries', () => {
      assert.equal(hasPermission('EXPERT', 'content:approve'), true);
      assert.equal(hasPermission('EXPERT', 'content:publish'), true);
      assert.equal(hasPermission('EXPERT', 'case:manage'), true);
      assert.equal(hasPermission('EXPERT', 'farmer:create'), false);
    });

    it('enforces ADMIN permissions boundaries', () => {
      assert.equal(hasPermission('ADMIN', 'audit:read'), true);
      assert.equal(hasPermission('ADMIN', 'farmer:create'), true);
      assert.equal(hasPermission('ADMIN', 'farmer:read'), true);
      assert.equal(hasPermission('ADMIN', 'content:publish'), true);
      assert.equal(hasPermission('ADMIN', 'case:manage'), true);
    });
  });

  describe('Advisory & Case Workflow Validations', () => {
    it('validates advisory content status progression', () => {
      assert.equal(canTransition('DRAFT', 'PENDING_REVIEW'), true);
      assert.equal(canTransition('PENDING_REVIEW', 'APPROVED'), true);
      assert.equal(canTransition('APPROVED', 'PUBLISHED'), true);
      assert.equal(canTransition('PENDING_REVIEW', 'REJECTED'), true);
      assert.equal(canTransition('REJECTED', 'DRAFT'), true);
    });

    it('maps client IN_REVIEW status string to PENDING_REVIEW', () => {
      assert.equal(canTransition('IN_REVIEW', 'APPROVED'), true);
      assert.equal(canTransition('DRAFT', 'IN_REVIEW'), true);
    });

    it('rejects unauthorized content jumps', () => {
      assert.equal(canTransition('DRAFT', 'PUBLISHED'), false);
      assert.equal(canTransition('PENDING_REVIEW', 'PUBLISHED'), false);
      assert.throws(
        () => assertTransition('DRAFT', 'PUBLISHED'),
        /Invalid content status transition/
      );
    });
  });
});
