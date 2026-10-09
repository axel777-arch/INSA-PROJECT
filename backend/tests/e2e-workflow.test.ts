import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import http from 'node:http';
import { eq, desc } from 'drizzle-orm';

import app from '../src/app';
import { db } from '../src/db/index';
import { users } from '../../database/schema/users';
import { crops } from '../../database/schema/crops';
import { farmers } from '../../database/schema/farmers';
import { farmerCrops } from '../../database/schema/farmerCrops';
import { content } from '../../database/schema/content';
import { messages } from '../../database/schema/messages';
import { messageRecipients } from '../../database/schema/messageRecipients';
import { auditLogs } from '../../database/schema/auditLogs';
import { hashPassword } from '../src/modules/auth/auth.service';

async function makeRequest(
  port: number,
  method: string,
  path: string,
  body?: any,
  token?: string
): Promise<{ status: number; data: any; raw: string }> {
  return new Promise((resolve, reject) => {
    const payload = body !== undefined ? (typeof body === 'string' ? body : JSON.stringify(body)) : undefined;
    const headers: Record<string, string> = {};

    if (payload !== undefined) {
      headers['Content-Type'] = typeof body === 'string' ? 'text/plain' : 'application/json';
      headers['Content-Length'] = Buffer.byteLength(payload).toString();
    }
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(
      {
        hostname: '127.0.0.1',
        port,
        path,
        method,
        headers,
      },
      (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (c) => chunks.push(Buffer.from(c)));
        res.on('end', () => {
          const raw = Buffer.concat(chunks).toString('utf8');
          let parsed: any;
          try {
            parsed = JSON.parse(raw);
          } catch {
            parsed = raw;
          }
          resolve({ status: res.statusCode ?? 0, data: parsed, raw });
        });
      }
    );

    req.on('error', reject);
    if (payload !== undefined) {
      req.write(payload);
    }
    req.end();
  });
}

test('Full End-to-End Workflow: Content Lifecycle -> Targeting -> Messaging DB -> IVR/USSD Simulation', async () => {
  const server = app.listen(0);
  await once(server, 'listening');
  const address = server.address();
  const port = typeof address === 'object' && address ? address.port : 0;

  try {
    // 0. Ensure seed entities exist in DB
    const adminPasswordHash = await hashPassword('Admin@1234');
    const expertPasswordHash = await hashPassword('Expert@1234');

    // 0a. Admin User
    let [adminUser] = await db.select().from(users).where(eq(users.email, 'admin@agri-insight.et')).limit(1);
    if (!adminUser) {
      [adminUser] = await db
        .insert(users)
        .values({
          fullName: 'System Administrator',
          phone: '+251911223344',
          email: 'admin@agri-insight.et',
          passwordHash: adminPasswordHash,
          role: 'ADMIN',
          preferredLanguage: 'en',
          active: true,
        })
        .returning();
    }

    // 0b. Expert User
    let [expertUser] = await db.select().from(users).where(eq(users.email, 'expert@agri-insight.et')).limit(1);
    if (!expertUser) {
      [expertUser] = await db
        .insert(users)
        .values({
          fullName: 'Agricultural Expert',
          phone: '+251922334455',
          email: 'expert@agri-insight.et',
          passwordHash: expertPasswordHash,
          role: 'EXPERT',
          preferredLanguage: 'en',
          active: true,
        })
        .returning();
    }

    // 0c. Target Crop
    let [testCrop] = await db.select().from(crops).where(eq(crops.name, 'Teff Special')).limit(1);
    if (!testCrop) {
      [testCrop] = await db
        .insert(crops)
        .values({
          name: 'Teff Special',
          description: 'High-yield grain',
          active: true,
        })
        .returning();
    }

    // 0d. Target Farmer User & Farmer Record
    let [farmerUser] = await db.select().from(users).where(eq(users.email, 'farmer.target@agri-insight.et')).limit(1);
    if (!farmerUser) {
      [farmerUser] = await db
        .insert(users)
        .values({
          fullName: 'Target Teff Farmer',
          phone: '+251933445566',
          email: 'farmer.target@agri-insight.et',
          passwordHash: expertPasswordHash,
          role: 'FARMER',
          preferredLanguage: 'am',
          active: true,
        })
        .returning();
    }

    let [targetFarmer] = await db.select().from(farmers).where(eq(farmers.userId, farmerUser.id)).limit(1);
    if (!targetFarmer) {
      [targetFarmer] = await db
        .insert(farmers)
        .values({
          userId: farmerUser.id,
          region: 'OROMIA',
          zone: 'EAST_SHEWA',
          alertEnabled: true,
        })
        .returning();
    }

    // Link farmer to crop
    const existingFarmerCrop = await db
      .select()
      .from(farmerCrops)
      .where(eq(farmerCrops.farmerId, targetFarmer.id));
    if (!existingFarmerCrop.some((fc) => fc.cropId === testCrop.id)) {
      await db.insert(farmerCrops).values({
        farmerId: targetFarmer.id,
        cropId: testCrop.id,
      });
    }

    // 1. STEP 1: Login as Expert
    const expertLoginRes = await makeRequest(port, 'POST', '/api/auth/login', {
      identifier: 'expert@agri-insight.et',
      password: 'Expert@1234',
    });
    assert.equal(expertLoginRes.status, 200, `Expert login failed: ${expertLoginRes.raw}`);
    const expertToken = expertLoginRes.data.accessToken || expertLoginRes.data.token;
    assert.ok(expertToken, 'Expected token in expert login response');

    // 2. STEP 2: Create Advisory Content (DRAFT)
    const createDraftRes = await makeRequest(
      port,
      'POST',
      '/api/content',
      {
        title: 'Critical Teff Rust Advisory',
        body: 'Early signs of rust detected. Apply recommended fungicide immediately.',
        cropId: testCrop.id,
        category: 'Disease Alert',
      },
      expertToken
    );
    assert.equal(createDraftRes.status, 201, `Create content failed: ${createDraftRes.raw}`);
    const createdContent = createDraftRes.data.data ?? createDraftRes.data;
    assert.equal(createdContent.status, 'DRAFT');
    assert.equal(createdContent.cropId, testCrop.id);
    const contentId = createdContent.id;

    // 3. STEP 3: Submit Content for Review (PENDING_REVIEW)
    const submitReviewRes = await makeRequest(
      port,
      'POST',
      `/api/content/${contentId}/submit`,
      {},
      expertToken
    );
    assert.equal(submitReviewRes.status, 200, `Submit review failed: ${submitReviewRes.raw}`);
    const submittedContent = submitReviewRes.data.data ?? submitReviewRes.data;
    assert.equal(submittedContent.status, 'PENDING_REVIEW');

    // 4. STEP 4: Login as Admin
    const adminLoginRes = await makeRequest(port, 'POST', '/api/auth/login', {
      identifier: 'admin@agri-insight.et',
      password: 'Admin@1234',
    });
    assert.equal(adminLoginRes.status, 200, `Admin login failed: ${adminLoginRes.raw}`);
    const adminToken = adminLoginRes.data.accessToken || adminLoginRes.data.token;
    assert.ok(adminToken, 'Expected token in admin login response');

    // 5. STEP 5: Approve Content (APPROVED)
    const approveRes = await makeRequest(
      port,
      'POST',
      `/api/content/${contentId}/approve`,
      {},
      adminToken
    );
    assert.equal(approveRes.status, 200, `Approve failed: ${approveRes.raw}`);
    const approvedContent = approveRes.data.data ?? approveRes.data;
    assert.equal(approvedContent.status, 'APPROVED');

    // 6. STEP 6: Publish Content (PUBLISHED) -> Automatically triggers Targeting & Messaging
    const publishRes = await makeRequest(
      port,
      'POST',
      `/api/content/${contentId}/publish`,
      {},
      adminToken
    );
    assert.equal(publishRes.status, 200, `Publish failed: ${publishRes.raw}`);
    const publishedContent = publishRes.data.data ?? publishRes.data;
    assert.equal(publishedContent.status, 'PUBLISHED');

    // 7. STEP 7: Verify Database Persistence for Messaging & Recipients
    const [dbContent] = await db.select().from(content).where(eq(content.id, contentId)).limit(1);
    assert.equal(dbContent?.status, 'PUBLISHED');

    // Check master message in PostgreSQL `messages` table
    const dbMessages = await db
      .select()
      .from(messages)
      .where(eq(messages.title, 'Critical Teff Rust Advisory'))
      .orderBy(desc(messages.createdAt));
    assert.ok(dbMessages.length > 0, 'Expected persistent row in messages table');
    const masterMsg = dbMessages[0];
    assert.equal(masterMsg.body, 'Early signs of rust detected. Apply recommended fungicide immediately.');
    assert.equal(masterMsg.channel, 'SMS');

    // Check recipient in PostgreSQL `message_recipients` table
    const recipients = await db
      .select()
      .from(messageRecipients)
      .where(eq(messageRecipients.messageId, masterMsg.id));
    assert.ok(recipients.length > 0, 'Expected persistent rows in message_recipients table');
    const matchedRecipient = recipients.find((r) => r.farmerId === targetFarmer.id);
    assert.ok(matchedRecipient, `Expected farmerId ${targetFarmer.id} among message recipients`);
    assert.equal(matchedRecipient.status, 'SENT');
    assert.ok(matchedRecipient.sentAt, 'Expected valid sentAt timestamp');

    // 8. STEP 8: Trigger IVR Session & DTMF endpoints
    const ivrStartRes = await makeRequest(port, 'POST', '/api/simulation/ivr/start', {
      phone: '+251933445566',
      farmerId: targetFarmer.id,
    });
    assert.equal(ivrStartRes.status, 200, `IVR start failed: ${ivrStartRes.raw}`);
    assert.ok(ivrStartRes.data.sessionId, 'Expected sessionId from IVR start');
    assert.equal(ivrStartRes.data.currentMenu, 'language');
    const ivrSessionId = ivrStartRes.data.sessionId;

    // Send DTMF key '1' (English) -> advances to main menu
    const ivrDtmfRes = await makeRequest(port, 'POST', '/api/simulation/ivr/dtmf', {
      sessionId: ivrSessionId,
      key: '1',
    });
    assert.equal(ivrDtmfRes.status, 200, `IVR dtmf failed: ${ivrDtmfRes.raw}`);
    assert.equal(ivrDtmfRes.data.currentMenu, 'main');
    assert.match(ivrDtmfRes.data.prompt, /English selected/i);

    // End IVR session
    const ivrEndRes = await makeRequest(port, 'POST', '/api/simulation/ivr/end', {
      sessionId: ivrSessionId,
    });
    assert.equal(ivrEndRes.status, 200, `IVR end failed: ${ivrEndRes.raw}`);
    assert.equal(ivrEndRes.data.status, 'COMPLETED');

    // 9. STEP 9: Trigger USSD callback endpoint
    const ussdRes = await makeRequest(port, 'POST', '/api/ussd', {
      sessionId: 'ussd-e2e-session-1',
      serviceCode: '*123#',
      phoneNumber: '+251933445566',
      text: '',
    });
    assert.equal(ussdRes.status, 200);
    assert.match(ussdRes.raw, /Welcome to Agri-Insight Beacon/i);

    // 10. STEP 10: Verify Audit Logs DB Persistence
    const auditRes = await makeRequest(port, 'GET', '/api/admin/audit-logs', undefined, adminToken);
    assert.equal(auditRes.status, 200, `Admin audit logs failed: ${auditRes.raw}`);
    assert.ok(Array.isArray(auditRes.data), 'Expected array of audit logs');
  } finally {
    server.close();
  }
});
