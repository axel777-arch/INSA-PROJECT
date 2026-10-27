import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { createFollowUpSchema, updateFollowUpSchema } from '../src/modules/followups/followup.schema';
import { createObservationSchema, escalateObservationSchema } from '../src/modules/observations/observation.schema';

const UUID_1 = 'a1000000-0000-4000-8000-000000000001';
const UUID_2 = 'b1000000-0000-4000-8000-000000000002';
const UUID_EXPERT = 'b1000000-0000-4000-8000-000000000002';

describe('Record Authorization & Workflow Schemas', () => {
  describe('Follow-Up Visit Schemas', () => {
    it('validates a complete follow-up visit creation', () => {
      const valid = {
        farmerId: UUID_1,
        observationId: UUID_2,
        scheduledDate: '2026-11-05T09:00:00.000Z',
        notes: 'Inspect wheat rust progression after fungicide application',
      };
      const result = createFollowUpSchema.safeParse(valid);
      assert.equal(result.success, true);
      assert.equal(result.data?.farmerId, UUID_1);
    });

    it('rejects follow-up creation without farmerId', () => {
      const invalid = {
        scheduledDate: '2026-11-05T09:00:00.000Z',
      };
      const result = createFollowUpSchema.safeParse(invalid);
      assert.equal(result.success, false);
    });

    it('validates follow-up update with status and outcome', () => {
      const validUpdate = {
        status: 'COMPLETED',
        completedDate: '2026-11-05T11:30:00.000Z',
        notes: 'Rust lesions have dried; farmer instructed on secondary spray',
        outcome: 'Condition stabilized',
      };
      const result = updateFollowUpSchema.safeParse(validUpdate);
      assert.equal(result.success, true);
      assert.equal(result.data?.status, 'COMPLETED');
    });

    it('rejects invalid follow-up status', () => {
      const invalidUpdate = {
        status: 'NON_EXISTENT_STATUS',
      };
      const result = updateFollowUpSchema.safeParse(invalidUpdate);
      assert.equal(result.success, false);
    });
  });

  describe('Observation Escalation Schema', () => {
    it('validates observation creation', () => {
      const observation = {
        farmerId: UUID_1,
        cropId: UUID_2,
        title: 'Severe stem rust suspected in Field 4',
        description: 'Over 40% of wheat stems show dark red pustules across 3 hectares.',
        severity: 'HIGH',
        observationType: 'DISEASE',
      };
      const result = createObservationSchema.safeParse(observation);
      assert.equal(result.success, true);
    });

    it('validates observation escalation schema with expert ID', () => {
      const escalation = {
        escalatedToId: UUID_EXPERT,
      };
      const result = escalateObservationSchema.safeParse(escalation);
      assert.equal(result.success, true);
      assert.equal(result.data?.escalatedToId, UUID_EXPERT);
    });
  });
});
