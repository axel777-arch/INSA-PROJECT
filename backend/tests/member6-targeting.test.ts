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

  test('targeting supports kebele-level matches and still excludes duplicate recipients', () => {
    const service = new TargetingService();
    const farmers = [
      {
        id: 'f1', preferredLanguage: 'am', region: 'OROMIA', zone: 'EAST', woreda: 'W1',
        kebele: 'K1', alertEnabled: true, cropNames: ['Maize'],
      },
      {
        id: 'f1', preferredLanguage: 'am', region: 'OROMIA', zone: 'EAST', woreda: 'W1',
        kebele: 'K1', alertEnabled: true, cropNames: ['Maize'],
      },
      {
        id: 'f2', preferredLanguage: 'am', region: 'OROMIA', zone: 'EAST', woreda: 'W1',
        kebele: 'K2', alertEnabled: true, cropNames: ['Maize'],
      },
    ];

    const matches = service.findTargetFarmers({
      cropName: 'Maize',
      location: 'K1',
      language: 'am',
      farmers,
    });
    assert.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
  });

  assert.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
});

test('sms simulator records simulated queued, sent and delivered transitions', () => {
  const simulator = new SmsSimulator();

  const result = simulator.send({ recipient: '+251911000000', message: 'hello' });
  assert.equal(result.status, 'SIMULATED_QUEUED');

  const sent = simulator.updateStatus(result.id, 'SIMULATED_SENT');
  const delivered = simulator.updateStatus(sent.id, 'SIMULATED_DELIVERED');

  assert.equal(delivered.status, 'SIMULATED_DELIVERED');
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

test('ivr simulator supports language, crop selection, invalid selection, and back navigation', () => {
  const simulator = new IvrSimulator();
  const session = simulator.startSession({ phone: '+251911000777' });

  const languageMenu = simulator.handleDtmf(session.sessionId, '2');
  assert.equal(languageMenu.currentMenu, 'main');

  const advisoryMenu = simulator.handleDtmf(session.sessionId, '1');
  assert.equal(advisoryMenu.currentMenu, 'advisories');

  const invalid = simulator.handleDtmf(session.sessionId, '9');
  assert.equal(invalid.currentMenu, 'advisories');
  assert.ok(invalid.prompt.length > 0);
  assert.equal(invalid.lastInput, '9');

  const back = simulator.handleDtmf(session.sessionId, '*');
  assert.equal(back.currentMenu, 'main');
});
