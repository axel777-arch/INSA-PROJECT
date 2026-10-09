import pg from 'pg';
import jwt from 'jsonwebtoken';

const BASE_URL = 'http://localhost:3000/api';
const DB_URL = 'postgresql://agri_user:agri_password@localhost:5433/agri_insight';

interface TestResult {
  step: string;
  name: string;
  status: 'PASSED' | 'FAILED';
  details: string;
  error?: string;
}

const results: TestResult[] = [];

async function runVerification() {
  const pool = new pg.Pool({ connectionString: DB_URL });
  console.log('════════════════════════════════════════════════════════════════');
  console.log('🚀 AGRI-INSIGHT BEACON FULL E2E SYSTEM VERIFICATION');
  console.log('════════════════════════════════════════════════════════════════\n');

  try {
    // ──────────────────────────────────────────────────────────────────────────
    // 4a. AUTHENTICATION & AUTHORIZATION
    // ──────────────────────────────────────────────────────────────────────────
    console.log('▶ [Step 4a] Authentication & Authorization Verification...');

    // 1. Admin login
    const adminLoginRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        identifier: 'admin@gmail.com',
        password: 'Admin$2026',
      }),
    });
    const adminLoginData = await adminLoginRes.json();

    if (!adminLoginRes.ok || !adminLoginData.accessToken) {
      throw new Error(`Admin login failed: ${JSON.stringify(adminLoginData)}`);
    }

    const adminToken = adminLoginData.accessToken;
    const adminUser = adminLoginData.user;
    const decodedAdmin = jwt.decode(adminToken) as any;
    const adminUserId = decodedAdmin.sub || decodedAdmin.userId;

    // Check UUID in DB
    const adminDbCheck = await pool.query('SELECT id, email, role FROM users WHERE id = $1', [adminUserId]);
    const isRealAdminUuid = adminDbCheck.rows.length === 1 && adminDbCheck.rows[0].email === 'admin@gmail.com';

    if (isRealAdminUuid) {
      results.push({
        step: '4a.1',
        name: 'Admin Login & PostgreSQL UUID Token Verification',
        status: 'PASSED',
        details: `Admin authenticated successfully. Real DB UUID: ${adminUserId}, Role: ${adminUser.role}`,
      });
      console.log(`  ✔ Admin Login: Real DB UUID verified (${adminUserId})`);
    } else {
      results.push({
        step: '4a.1',
        name: 'Admin Login & PostgreSQL UUID Token Verification',
        status: 'FAILED',
        details: 'Admin token does not match real PostgreSQL user UUID',
      });
    }

    // 2. Farmer Registration & Login (+251911223344 / Farmer$2026)
    const existingCheck = await pool.query("SELECT id FROM users WHERE phone = '+251911223344'");
    let farmerUser: any;
    let farmerToken: string;

    if (existingCheck.rows.length === 0) {
      const registerRes = await fetch(`${BASE_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fullName: 'Abebe Verification Farmer',
          phone: '+251911223344',
          password: 'Farmer$2026',
          role: 'FARMER',
          preferredLanguage: 'am',
        }),
      });
      const registerData = await registerRes.json();
      if (!registerRes.ok) {
        throw new Error(`Farmer registration failed: ${JSON.stringify(registerData)}`);
      }
    }

    const farmerLoginRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        identifier: '+251911223344',
        password: 'Farmer$2026',
      }),
    });
    const farmerLoginData = await farmerLoginRes.json();
    farmerUser = farmerLoginData.user;
    farmerToken = farmerLoginData.accessToken;

    if (farmerLoginRes.ok && farmerUser && farmerUser.phone === '+251911223344') {
      results.push({
        step: '4a.2',
        name: 'Farmer Register & Login (+251911223344) Without Regex Lockout',
        status: 'PASSED',
        details: `Registered and logged in farmer ID: ${farmerUser.id}, Phone: ${farmerUser.phone}, Lang: ${farmerUser.preferred_language}`,
      });
      console.log(`  ✔ Farmer Registration & Login: Phone +251911223344 passed regex validation (UUID: ${farmerUser.id})`);
    } else {
      results.push({
        step: '4a.2',
        name: 'Farmer Register & Login (+251911223344) Without Regex Lockout',
        status: 'FAILED',
        details: `Farmer login failed: ${JSON.stringify(farmerLoginData)}`,
      });
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 4b. FARMER & CROP MANAGEMENT
    // ──────────────────────────────────────────────────────────────────────────
    console.log('\n▶ [Step 4b] Farmer & Crop Management Verification...');

    // Fetch crops
    const cropsRes = await fetch(`${BASE_URL}/crops`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const cropsData = await cropsRes.json();
    const teffCrop = cropsData.find((c: any) => c.name.toLowerCase().includes('teff')) || cropsData[0];

    // Create Farmer profile if not existing
    const existingFarmerProfile = await pool.query('SELECT * FROM farmers WHERE user_id = $1', [farmerUser.id]);
    let createdFarmer: any;

    if (existingFarmerProfile.rows.length === 0) {
      const createFarmerRes = await fetch(`${BASE_URL}/farmers`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          userId: farmerUser.id,
          region: 'Oromia',
          zone: 'East Shewa',
          woreda: 'Adaa',
          kebele: '01',
          alertEnabled: true,
        }),
      });
      createdFarmer = await createFarmerRes.json();

      if (!createFarmerRes.ok) {
        throw new Error(`Farmer profile creation failed: ${JSON.stringify(createdFarmer)}`);
      }
    } else {
      createdFarmer = existingFarmerProfile.rows[0];
    }

    // Assign Crop to Farmer if not already assigned
    const existingCropAssign = await pool.query(
      'SELECT * FROM farmer_crops WHERE farmer_id = $1 AND crop_id = $2',
      [createdFarmer.id, teffCrop.id]
    );

    if (existingCropAssign.rows.length === 0) {
      const assignCropRes = await fetch(`${BASE_URL}/farmers/${createdFarmer.id}/crops`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          cropId: teffCrop.id,
        }),
      });
      const assignCropData = await assignCropRes.json();
    }

    // Confirm in DB
    const farmerDbCheck = await pool.query('SELECT * FROM farmers WHERE id = $1', [createdFarmer.id]);
    const farmerCropDbCheck = await pool.query(
      'SELECT * FROM farmer_crops WHERE farmer_id = $1 AND crop_id = $2',
      [createdFarmer.id, teffCrop.id]
    );

    if (farmerDbCheck.rows.length === 1 && farmerCropDbCheck.rows.length === 1) {
      results.push({
        step: '4b',
        name: 'Farmer Profile & Crop Association in PostgreSQL',
        status: 'PASSED',
        details: `Farmer profile created (${createdFarmer.id}) and assigned crop ${teffCrop.name} (${teffCrop.id}) verified in DB`,
      });
      console.log(`  ✔ Farmer Profile created and Crop (${teffCrop.name}) assigned. Verified in farmers & farmer_crops tables.`);
    } else {
      results.push({
        step: '4b',
        name: 'Farmer Profile & Crop Association in PostgreSQL',
        status: 'FAILED',
        details: 'Records missing in farmers or farmer_crops table',
      });
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 4c. CONTENT ADVISORY LIFECYCLE
    // ──────────────────────────────────────────────────────────────────────────
    console.log('\n▶ [Step 4c] Content Advisory Lifecycle Verification...');

    // Login as Expert
    const expertLoginRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        identifier: 'expert@gmail.com',
        password: 'Expert$2026',
      }),
    });
    const expertLoginData = await expertLoginRes.json();
    const expertToken = expertLoginData.accessToken;

    // Create Advisory Content (DRAFT)
    const createContentRes = await fetch(`${BASE_URL}/content`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${expertToken}`,
      },
      body: JSON.stringify({
        title: 'Highland Teff Rust Prevention Guide',
        body: 'Inspect teff fields for yellow/orange pustules. Apply fungicide if infection exceeds 5%.',
        cropId: teffCrop.id,
        category: 'Pest & Disease Advisory',
      }),
    });
    const createdContent = await createContentRes.json();

    // Submit for review (DRAFT -> PENDING_REVIEW)
    const submitReviewRes = await fetch(`${BASE_URL}/content/${createdContent.id}/submit-review`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${expertToken}` },
    });
    const submittedContent = await submitReviewRes.json();

    // Admin approves (PENDING_REVIEW -> APPROVED)
    const approveRes = await fetch(`${BASE_URL}/content/${createdContent.id}/approve`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const approvedContent = await approveRes.json();

    // Admin publishes (APPROVED -> PUBLISHED)
    const publishRes = await fetch(`${BASE_URL}/content/${createdContent.id}/publish`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    const publishedContent = await publishRes.json();

    // Check DB status
    const contentDbCheck = await pool.query('SELECT status, approved_by FROM content WHERE id = $1', [createdContent.id]);
    const finalStatus = contentDbCheck.rows[0]?.status;

    if (finalStatus === 'PUBLISHED') {
      results.push({
        step: '4c',
        name: 'Content Lifecycle (DRAFT -> PENDING_REVIEW -> APPROVED -> PUBLISHED)',
        status: 'PASSED',
        details: `Content id ${createdContent.id} successfully traversed lifecycle to PUBLISHED`,
      });
      console.log(`  ✔ Advisory Content Lifecycle: DRAFT -> PENDING_REVIEW -> APPROVED -> PUBLISHED verified in PostgreSQL`);
    } else {
      results.push({
        step: '4c',
        name: 'Content Lifecycle (DRAFT -> PENDING_REVIEW -> APPROVED -> PUBLISHED)',
        status: 'FAILED',
        details: `Expected status PUBLISHED, got ${finalStatus}`,
      });
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 4d. TARGETING, SMS & SIMULATION VERIFICATION
    // ──────────────────────────────────────────────────────────────────────────
    console.log('\n▶ [Step 4d] Targeting, SMS & Simulation Verification...');

    // Query messages and message_recipients for the published content
    const msgQuery = await pool.query(
      `SELECT m.id, m.title, m.channel, m.status, COUNT(mr.id) as recipient_count
       FROM messages m
       LEFT JOIN message_recipients mr ON m.id = mr.message_id
       WHERE m.title = $1
       GROUP BY m.id, m.title, m.channel, m.status`,
      ['Highland Teff Rust Prevention Guide']
    );

    const hasMessageAndRecipients = msgQuery.rows.length > 0 && parseInt(msgQuery.rows[0].recipient_count, 10) > 0;

    if (hasMessageAndRecipients) {
      const msgRow = msgQuery.rows[0];
      results.push({
        step: '4d.1',
        name: 'Targeting Engine & PostgreSQL Message Persistence',
        status: 'PASSED',
        details: `Master message created (${msgRow.id}, channel: ${msgRow.channel}) with ${msgRow.recipient_count} matched recipients in DB`,
      });
      console.log(`  ✔ Targeting Engine triggered: Broadcast message persisted with ${msgRow.recipient_count} recipient(s) in message_recipients`);
    } else {
      results.push({
        step: '4d.1',
        name: 'Targeting Engine & PostgreSQL Message Persistence',
        status: 'FAILED',
        details: `Message or recipients not found for published content`,
      });
    }

    // Test IVR simulation endpoint
    const ivrStartRes = await fetch(`${BASE_URL}/simulation/ivr/start`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone: '+251911223344',
        farmerId: createdFarmer.id,
      }),
    });
    const ivrStartData = await ivrStartRes.json();

    const ivrDtmfRes = await fetch(`${BASE_URL}/simulation/ivr/dtmf`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        sessionId: ivrStartData.sessionId,
        key: '1',
      }),
    });
    const ivrDtmfData = await ivrDtmfRes.json();

    if (ivrStartRes.ok && ivrStartData.sessionId && ivrDtmfRes.ok && ivrDtmfData.status) {
      results.push({
        step: '4d.2',
        name: 'IVR Voice Simulation Service (Start & DTMF Traversal)',
        status: 'PASSED',
        details: `IVR session started (${ivrStartData.sessionId}), DTMF '1' handled, status: ${ivrDtmfData.status}`,
      });
      console.log(`  ✔ IVR Simulation verified: Session ${ivrStartData.sessionId} navigated menu via DTMF input`);
    } else {
      results.push({
        step: '4d.2',
        name: 'IVR Voice Simulation Service (Start & DTMF Traversal)',
        status: 'FAILED',
        details: `IVR simulation failed: ${JSON.stringify(ivrStartData)}`,
      });
    }

    // ──────────────────────────────────────────────────────────────────────────
    // 4e. SECURITY AUDIT LOG VERIFICATION
    // ──────────────────────────────────────────────────────────────────────────
    console.log('\n▶ [Step 4e] Security Audit Log Verification...');

    const auditQuery = await pool.query(
      `SELECT al.id, al.user_id, al.action, al.entity_type, al.entity_id, al.created_at, u.email
       FROM audit_logs al
       LEFT JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC
       LIMIT 10`
    );

    const auditLogsCount = auditQuery.rows.length;
    const actions = auditQuery.rows.map((r: any) => `${r.action} (${r.entity_type})`).join(', ');

    if (auditLogsCount > 0) {
      results.push({
        step: '4e',
        name: 'PostgreSQL Audit Log Verification',
        status: 'PASSED',
        details: `Retrieved ${auditLogsCount} audit entries. Recent actions: ${actions}`,
      });
      console.log(`  ✔ Audit Logs verified: ${auditLogsCount} recent audit entries in audit_logs table.`);
      console.log(`    Actions recorded: ${actions}`);
    } else {
      results.push({
        step: '4e',
        name: 'PostgreSQL Audit Log Verification',
        status: 'FAILED',
        details: 'No audit logs found in PostgreSQL audit_logs table',
      });
    }

  } catch (err: any) {
    console.error('❌ Verification error:', err);
    results.push({
      step: 'Error',
      name: 'System Verification',
      status: 'FAILED',
      details: err.message,
      error: err.stack,
    });
  } finally {
    await pool.end();
  }

  console.log('\n════════════════════════════════════════════════════════════════');
  console.log('📊 VERIFICATION SUMMARY');
  console.log('════════════════════════════════════════════════════════════════');
  console.table(results.map(r => ({ Step: r.step, Test: r.name, Status: r.status, Details: r.details.substring(0, 75) })));
}

runVerification();
