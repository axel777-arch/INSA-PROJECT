import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import http from 'node:http';

import app from '../src/app';

test('Messaging route: POST /api/messaging/sms returns a queued SMS response', async () => {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const response = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const payload = JSON.stringify({
        recipient: '+251911000111',
        message: 'Irrigation update',
        createdBy: 'operator-1',
        contentId: 'content-1',
      });

      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/messaging/sms',
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

    assert.equal(response.statusCode, 201);
    assert.match(response.body, /QUEUED|queued/i);
  } finally {
    server.close();
  }
});

test('Targeting route: POST /api/targeting/match returns matching farmers only', async () => {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const response = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const payload = JSON.stringify({
        cropName: 'Maize',
        location: 'OROMIA',
        language: 'am',
        farmers: [
          { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
          { id: 'f2', preferredLanguage: 'en', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
          { id: 'f3', preferredLanguage: 'am', region: 'ADDIS ABABA', alertEnabled: true, cropNames: ['Maize'] },
          { id: 'f4', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
        ],
      });

      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/targeting/match',
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
    assert.match(response.body, /f1/i);
    assert.doesNotMatch(response.body, /f2|f3|f4/i);
  } finally {
    server.close();
  }
});
