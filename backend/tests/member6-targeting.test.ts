import test from 'node:test';
import assert from 'node:assert/strict';

import { ContentStatus, ContentService } from '../src/modules/content/content.service';
import { TargetingService } from '../src/services/targeting/targeting.service';
import { SmsSimulator } from '../src/services/sms/sms.simulator';
import { IvrSimulator } from '../src/services/ivr/ivr.simulator';

test('content workflow enforces valid status transitions', () => {
  const service = new ContentService();

  assert.equal(service.canTransition(ContentStatus.DRAFT, ContentStatus.IN_REVIEW), true);
  assert.equal(service.canTransition(ContentStatus.IN_REVIEW, ContentStatus.APPROVED), true);
  assert.equal(service.canTransition(ContentStatus.APPROVED, ContentStatus.PUBLISHED), true);
  assert.equal(service.canTransition(ContentStatus.DRAFT, ContentStatus.PUBLISHED), false);
});

test('targeting matches farmers by crop, location and language while excluding opt-outs', () => {
  const service = new TargetingService();

  const farmers = [
    { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
    { id: 'f2', preferredLanguage: 'en', region: 'AMHARA', alertEnabled: true, cropNames: ['Wheat'] },
    { id: 'f3', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
    { id: 'f4', preferredLanguage: 'am', region: 'SNNPR', alertEnabled: true, cropNames: ['Coffee'] },
  ];

  const matches = service.findTargetFarmers({
    cropName: 'Maize',
    location: 'OROMIA',
    language: 'am',
    farmers,
  });

  assert.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
});

test('sms simulator records queued, sent and delivered transitions', () => {
  const simulator = new SmsSimulator();

  const result = simulator.send({ recipient: '+251911000000', message: 'hello' });
  assert.equal(result.status, 'QUEUED');

  const sent = simulator.updateStatus(result.id, 'SENT');
  const delivered = simulator.updateStatus(sent.id, 'DELIVERED');

  assert.equal(delivered.status, 'DELIVERED');
});

test('ivr simulator allows valid stage transitions', () => {
  const simulator = new IvrSimulator();
  const call = simulator.createCall({ farmerId: 'f1', phone: '+251912000000' });

  const inProgress = simulator.updateCallStatus(call.id, 'IN_PROGRESS');
  const completed = simulator.updateCallStatus(inProgress.id, 'COMPLETED');

  assert.equal(completed.status, 'COMPLETED');
  assert.equal(simulator.canTransition('QUEUED', 'IN_PROGRESS'), true);
  assert.equal(simulator.canTransition('IN_PROGRESS', 'FAILED'), true);
  assert.equal(simulator.canTransition('COMPLETED', 'IN_PROGRESS'), false);
});
