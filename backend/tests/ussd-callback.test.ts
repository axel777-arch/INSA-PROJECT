import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import http from 'node:http';

import app from '../src/app';

test('USSD callback endpoint returns the welcome menu for a new session', async () => {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const response = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const payload = JSON.stringify({
        sessionId: 'ussd-callback-1',
        serviceCode: '*123#',
        phoneNumber: '+251911000001',
        text: '',
      });

      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/ussd',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
      }, (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        res.on('end', () => resolve({
          statusCode: res.statusCode ?? 0,
          body: Buffer.concat(chunks).toString('utf8'),
        }));
      });

      req.on('error', reject);
      req.write(payload);
      req.end();
    });

    assert.equal(response.statusCode, 200);
    assert.match(response.body, /Welcome to Agri-Insight Beacon/i);
    assert.match(response.body, /1\. My profile/i);
  } finally {
    server.close();
  }
});

test('USSD callback endpoint advances the session for crop selection', async () => {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const firstRequest = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const payload = JSON.stringify({
        sessionId: 'ussd-callback-2',
        serviceCode: '*123#',
        phoneNumber: '+251911000002',
        text: '',
      });

      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/ussd',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
      }, (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        res.on('end', () => resolve({
          statusCode: res.statusCode ?? 0,
          body: Buffer.concat(chunks).toString('utf8'),
        }));
      });

      req.on('error', reject);
      req.write(payload);
      req.end();
    });

    assert.match(firstRequest.body, /Welcome to Agri-Insight Beacon/i);

    const secondRequest = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const payload = JSON.stringify({
        sessionId: 'ussd-callback-2',
        serviceCode: '*123#',
        phoneNumber: '+251911000002',
        text: '2',
      });

      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/ussd',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
      }, (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        res.on('end', () => resolve({
          statusCode: res.statusCode ?? 0,
          body: Buffer.concat(chunks).toString('utf8'),
        }));
      });

      req.on('error', reject);
      req.write(payload);
      req.end();
    });

    assert.equal(secondRequest.statusCode, 200);
    assert.match(secondRequest.body, /Select crop/i);
    assert.match(secondRequest.body, /Maize/i);
  } finally {
    server.close();
  }
});
