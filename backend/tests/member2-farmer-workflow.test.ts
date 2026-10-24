import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { createFarmerSchema, updateFarmerSchema, assignFarmerSchema } from '../src/modules/farmers/farmer.schema';
import { createObservationSchema, updateObservationSchema } from '../src/modules/observations/observation.schema';
import { createFollowUpSchema, updateFollowUpSchema } from '../src/modules/followups/followup.schema';
import { hasPermission } from '../src/config/permissions';

const VALID_UUID_1 = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
const VALID_UUID_2 = 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

describe('Member 2: Farmer & Extension Worker Operational Workflows', () => {
  describe('Farmer Schemas & Permissions', () => {
    it('validates basic farmer creation without app account', () => {
      const payload = {
        fullName: 'Tesfaye Lemma',
        phone: '+251911223344',
        region: 'Oromia',
        zone: 'East Shewa',
        woreda: 'Ada\'a',
        kebele: '01',
        farmSize: 2.5,
        experienceYears: 10,
        preferredLanguage: 'amharic',
        createAppAccount: false,
      };
      const result = createFarmerSchema.safeParse(payload);
      assert.equal(result.success, true);
    });

    it('validates farmer creation requesting mobile app account', () => {
      const payload = {
        fullName: 'Almaz Ayana',
        phone: '+251922334455',
        region: 'Oromia',
        zone: 'East Shewa',
        woreda: 'Adama',
        kebele: '02',
        createAppAccount: true,
      };
      const result = createFarmerSchema.safeParse(payload);
      assert.equal(result.success, true);
      assert.equal(result.data?.createAppAccount, true);
    });

    it('rejects invalid phone numbers or short names', () => {
      const invalid = {
        fullName: 'A',
        phone: '123',
      };
      const result = createFarmerSchema.safeParse(invalid);
      assert.equal(result.success, false);
    });

    it('validates assignment schema with primary and temporary coverage', () => {
      const validAssignment = {
        workerId: VALID_UUID_1,
        assignmentType: 'TEMPORARY_COVERAGE',
        reason: 'Maternity leave cover',
      };
      const result = assignFarmerSchema.safeParse(validAssignment);
      assert.equal(result.success, true);
    });

    it('enforces RBAC permissions for extension workers and experts', () => {
      // Extension Worker permissions
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'farmer:assign'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'observation:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'followup:create'), true);
      assert.equal(hasPermission('EXTENSION_WORKER', 'content:approve'), false); // Only expert

      // Expert permissions
      assert.equal(hasPermission('EXPERT', 'observation:read'), true);
      assert.equal(hasPermission('EXPERT', 'content:approve'), true);
      assert.equal(hasPermission('EXPERT', 'farmer:create'), false); // Only worker/admin
    });
  });

  describe('Field Observation Schemas', () => {
    it('validates technical field observation with valid severity', () => {
      const payload = {
        farmerId: VALID_UUID_1,
        observationType: 'PEST_INFESTATION',
        severity: 'CRITICAL',
        title: 'Fall Armyworm Infestation Detected',
        description: 'Significant damage on whorl leaves across 40% of the maize plot.',
        actionTaken: 'Advised local neem spray and isolated affected crop perimeter.',
      };
      const result = createObservationSchema.safeParse(payload);
      assert.equal(result.success, true);
    });

    it('rejects field observations with short description', () => {
      const payload = {
        farmerId: VALID_UUID_1,
        title: 'Pests seen',
        description: 'Bad',
      };
      const result = createObservationSchema.safeParse(payload);
      assert.equal(result.success, false);
    });
  });

  describe('Follow-Up Visit Records', () => {
    it('validates follow-up schedule and status progression', () => {
      const schedule = {
        farmerId: VALID_UUID_1,
        scheduledDate: new Date().toISOString(),
        notes: 'Follow-up on pest treatment efficacy',
      };
      const result = createFollowUpSchema.safeParse(schedule);
      assert.equal(result.success, true);

      const update = {
        status: 'COMPLETED',
        outcome: 'Pest infestation under control, crop recovering well.',
      };
      const updateResult = updateFollowUpSchema.safeParse(update);
      assert.equal(updateResult.success, true);
    });
  });
});
