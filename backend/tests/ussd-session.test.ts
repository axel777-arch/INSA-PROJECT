import test from 'node:test';
import assert from 'node:assert/strict';

import { UssdSessionService } from '../src/services/ussd/ussd.service';

test('UssdSessionService: welcome menu is returned for a new session', () => {
  const service = new UssdSessionService();
  const response = service.handleRequest({
    sessionId: 'sess-1',
    serviceCode: '*123#',
    phoneNumber: '+251911000001',
    text: '',
  });

  assert.match(response, /Welcome to Agri-Insight Beacon/i);
  assert.match(response, /1\. My profile/i);
  assert.equal(service.getSession('sess-1')?.currentStep, 'welcome');
});

test('UssdSessionService: selecting crop menu advances session state', () => {
  const service = new UssdSessionService();

  service.handleRequest({
    sessionId: 'sess-2',
    serviceCode: '*123#',
    phoneNumber: '+251911000002',
    text: '',
  });

  const cropResponse = service.handleRequest({
    sessionId: 'sess-2',
    serviceCode: '*123#',
    phoneNumber: '+251911000002',
    text: '2',
  });

  assert.match(cropResponse, /Select crop/i);
  assert.match(cropResponse, /Maize/i);
  assert.equal(service.getSession('sess-2')?.currentStep, 'crop');
});

test('UssdSessionService: invalid input returns fallback message', () => {
  const service = new UssdSessionService();

  const response = service.handleRequest({
    sessionId: 'sess-3',
    serviceCode: '*123#',
    phoneNumber: '+251911000003',
    text: '99',
  });

  assert.match(response, /Invalid selection/i);
});
