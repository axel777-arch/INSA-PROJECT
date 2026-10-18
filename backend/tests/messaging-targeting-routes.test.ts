import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import http from 'node:http';

import app from '../src/app';

async function postWithoutAuthentication(path: string): Promise<number> {
  const server = app.listen(0);
  await once(server, 'listening');

  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    return await new Promise<number>((resolve, reject) => {
      const payload = '{}';
      const req = http.request(
        {
          hostname: '127.0.0.1',
          port,
          path,
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(payload),
          },
        },
        (res) => {
          res.resume();
          res.on('end', () => resolve(res.statusCode ?? 0));
        },
      );

      req.on('error', reject);
      req.write(payload);
      req.end();
    });
  } finally {
    server.close();
  }
}

test('SMS dispatch requires authentication', async () => {
  assert.equal(await postWithoutAuthentication('/api/messaging/sms'), 401);
});

test('farmer targeting requires authentication', async () => {
  assert.equal(await postWithoutAuthentication('/api/targeting/match'), 401);
});

test('IVR simulator requires authentication on both route mounts', async () => {
  assert.equal(await postWithoutAuthentication('/api/simulation/ivr/start'), 401);
  assert.equal(await postWithoutAuthentication('/api/messaging/ivr/start'), 401);
});
