import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import http from 'node:http';

import app from '../src/app';

test('Messaging route: SMS broadcast requires authenticated message-send permission', async () => {
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

    assert.equal(response.statusCode, 401);
    assert.match(response.body, /UNAUTHENTICATED/);
  } finally {
    server.close();
  }
});

test('Case routes require authentication before exposing case records', async () => {
  const server = app.listen(0);
  await once(server, 'listening');
  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const response = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/cases',
        method: 'GET',
      }, (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        res.on('end', () => resolve({
          statusCode: res.statusCode ?? 0,
          body: Buffer.concat(chunks).toString('utf8'),
        }));
      });
      req.on('error', reject);
      req.end();
    });
    assert.equal(response.statusCode, 401);
    assert.match(response.body, /UNAUTHENTICATED/);
  } finally {
    server.close();
  }
});

test('Targeting route requires authenticated message-send permission', async () => {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    const response = await new Promise<{ statusCode: number; body: string }>((resolve, reject) => {
      const req = http.request({
        hostname: '127.0.0.1',
        port,
        path: '/api/targeting/match',
        method: 'POST',
      }, (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        res.on('end', () => resolve({
          statusCode: res.statusCode ?? 0,
          body: Buffer.concat(chunks).toString('utf8'),
        }));
      });

      req.on('error', reject);
      req.end();
    });

    assert.equal(response.statusCode, 401);
    assert.match(response.body, /UNAUTHENTICATED/);
  } finally {
    server.close();
  }
});
