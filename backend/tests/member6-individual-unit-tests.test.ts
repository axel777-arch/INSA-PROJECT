import test from 'node:test';
import assert from 'node:assert/strict';

import { ContentService, ContentStatus } from '../src/modules/content/content.service';
import { TargetingService } from '../src/services/targeting/targeting.service';
import { SmsSimulator } from '../src/services/sms/sms.simulator';
import { IvrSimulator } from '../src/services/ivr/ivr.simulator';

test('ContentService: createDraft creates a valid draft item', () => {
  const service = new ContentService();
  const draft = service.createDraft({
    title: 'Maize irrigation advice',
    body: 'Use early morning watering for maize.',
    category: 'crop-care',
    createdBy: 'user-1',
  });

  assert.equal(draft.status, ContentStatus.DRAFT);
  assert.equal(draft.title, 'Maize irrigation advice');
  assert.equal(draft.category, 'crop-care');
  assert.equal(typeof draft.id, 'string');
});

test('ContentService: submitForReview rejects invalid transitions', () => {
  const service = new ContentService();
  const draft = service.createDraft({
    title: 'Test',
    body: 'Body',
    createdBy: 'user-1',
  });

  const submitted = service.submitForReview(draft);
  assert.equal(submitted.status, ContentStatus.IN_REVIEW);

  assert.throws(() => service.submitForReview(submitted), /cannot move from/);
});

test('TargetingService: blocks farmers with disabled alerts', () => {
  const service = new TargetingService();

  const farmers = [
    { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
    { id: 'f2', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
  ];

  const matches = service.findTargetFarmers({
    cropName: 'Maize',
    location: 'OROMIA',
    language: 'am',
    farmers,
  });

  assert.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
});

test('TargetingService: returns unique matches only once', () => {
  const service = new TargetingService();

  const farmers = [
    { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize', 'Maize'] },
    { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
    { id: 'f2', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
  ];

  const matches = service.findTargetFarmers({
    cropName: 'Maize',
    location: 'OROMIA',
    language: 'am',
    farmers,
  });

  assert.deepEqual(matches.map((farmer) => farmer.id), ['f1', 'f2']);
});

test('SmsSimulator: queued SMS can advance to sent and delivered states', () => {
  const simulator = new SmsSimulator();
  const message = simulator.send({ recipient: '+251911000111', message: 'Soil moisture update' });

  assert.equal(message.status, 'QUEUED');

  const sent = simulator.updateStatus(message.id, 'SENT');
  const delivered = simulator.updateStatus(sent.id, 'DELIVERED');

  assert.equal(sent.status, 'SENT');
  assert.equal(delivered.status, 'DELIVERED');
});

test('SmsSimulator: invalid SMS transition is rejected', () => {
  const simulator = new SmsSimulator();
  const message = simulator.send({ recipient: '+251911000222', message: 'Late update' });

  assert.throws(() => simulator.updateStatus(message.id, 'DELIVERED'), /invalid/i);
});

test('IvrSimulator: creates a queued call and allows valid progress', () => {
  const simulator = new IvrSimulator();
  const call = simulator.createCall({ farmerId: 'farmer-1', phone: '+251911000333' });

  assert.equal(call.status, 'QUEUED');

  const started = simulator.updateCallStatus(call.id, 'IN_PROGRESS');
  const completed = simulator.updateCallStatus(started.id, 'COMPLETED');

  assert.equal(started.status, 'IN_PROGRESS');
  assert.equal(completed.status, 'COMPLETED');
});

test('IvrSimulator: invalid IVR call transition is rejected', () => {
  const simulator = new IvrSimulator();
  const call = simulator.createCall({ farmerId: 'farmer-2', phone: '+251911000444' });

  assert.throws(() => simulator.updateCallStatus(call.id, 'COMPLETED'), /invalid/i);
});
