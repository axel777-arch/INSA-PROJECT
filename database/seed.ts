import argon2 from "argon2";
import { and, eq } from "drizzle-orm";
import { db } from "../backend/src/db/index";
import {
  users,
  farmers,
  crops,
  farmerCrops,
  content,
  contentReviews,
  auditLogs,
  messages,
  messageRecipients,
} from "./schema/index";

// ── 1. Deterministic System Users ─────────────────────────────────────────────
const SYSTEM_USERS = [
  {
    id: "b1000000-0000-4000-8000-000000000001",
    fullName: "System Administrator",
    email: "admin@gmail.com",
    phone: "+251900000000",
    rawPassword: "Admin$2026",
    role: "ADMIN",
    preferredLanguage: "en",
  },
  {
    id: "b1000000-0000-4000-8000-000000000002",
    fullName: "Agricultural Domain Expert",
    email: "expert@gmail.com",
    phone: "+251912000001",
    rawPassword: "Expert$2026",
    role: "EXPERT",
    preferredLanguage: "en",
  },
  {
    id: "b1000000-0000-4000-8000-000000000003",
    fullName: "Lead Extension Worker",
    email: "worker@gmail.com",
    phone: "+251911000001",
    rawPassword: "Worker$2026",
    role: "EXTENSION_WORKER",
    preferredLanguage: "am",
  },
  {
    id: "b1000000-0000-4000-8000-000000000004",
    fullName: "Abebe Balcha (Farmer)",
    email: "farmer@gmail.com",
    phone: "+251911223344",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "am",
  },
  {
    id: "b1000000-0000-4000-8000-000000000005",
    fullName: "Fatuma Ahmed (Farmer)",
    email: "farmer2@gmail.com",
    phone: "+251911223345",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "or",
  },
  {
    id: "b1000000-0000-4000-8000-000000000006",
    fullName: "Chala Dejene (Farmer)",
    email: "farmer3@gmail.com",
    phone: "+251911223346",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "am",
  },
  {
    id: "b1000000-0000-4000-8000-000000000007",
    fullName: "Tadesse Hailu (Farmer)",
    email: "farmer4@gmail.com",
    phone: "+251911223347",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "ti",
  },
];

// ── 2. Sample Crops ───────────────────────────────────────────────────────────
const SAMPLE_CROPS = [
  {
    id: "a1000000-0000-4000-8000-000000000001",
    name: "Teff",
    description: "Cereal crop staple cultivated for grain and injera production across Ethiopian highlands.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000002",
    name: "Maize",
    description: "High-yield cereal grain widely grown across mid-altitude and lowland zones.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000003",
    name: "Wheat",
    description: "Major highland cereal grain cultivated during meher season for commercial flour and consumption.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000004",
    name: "Coffee",
    description: "High-value Arabica perennial cash crop grown in forest and garden agroforestry systems.",
    active: true,
  },
];

// ── 3. Farmer Profiles ────────────────────────────────────────────────────────
const DEMO_FARMERS = [
  {
    id: "f1000000-0000-4000-8000-000000000001",
    userId: "b1000000-0000-4000-8000-000000000004", // Abebe Balcha (+251911223344)
    region: "Oromia",
    zone: "East Shewa",
    woreda: "Ada'a",
    kebele: "Kebele 01",
    latitude: 8.7521,
    longitude: 38.9812,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000001", // Teff
      "a1000000-0000-4000-8000-000000000002", // Maize
      "a1000000-0000-4000-8000-000000000003", // Wheat
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000002",
    userId: "b1000000-0000-4000-8000-000000000005", // Fatuma Ahmed
    region: "Amhara",
    zone: "West Gojjam",
    woreda: "Bure",
    kebele: "Kebele 04",
    latitude: 10.7022,
    longitude: 37.0655,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000002", // Maize
      "a1000000-0000-4000-8000-000000000003", // Wheat
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000003",
    userId: "b1000000-0000-4000-8000-000000000006", // Chala Dejene
    region: "Sidama",
    zone: "Aleta Chuko",
    woreda: "Chuko",
    kebele: "Kebele 02",
    latitude: 6.7824,
    longitude: 38.4121,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000004", // Coffee
      "a1000000-0000-4000-8000-000000000002", // Maize
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000004",
    userId: "b1000000-0000-4000-8000-000000000007", // Tadesse Hailu
    region: "Tigray",
    zone: "Eastern Tigray",
    woreda: "Kilte Awulaelo",
    kebele: "Kebele 03",
    latitude: 13.7225,
    longitude: 39.5987,
    alertEnabled: false,
    cropIds: [
      "a1000000-0000-4000-8000-000000000001", // Teff
      "a1000000-0000-4000-8000-000000000003", // Wheat
    ],
  },
];

export async function seedDemoData() {
  console.log("════════════════════════════════════════════════════════════");
  console.log("🌱 AGRI-INSIGHT BEACON DATABASE SEEDING (PHASE 2)");
  console.log("════════════════════════════════════════════════════════════\n");

  // 1. Seed Users with Argon2id Password Hashes
  console.log("1. Seeding system users with Argon2id hashes...");
  for (const u of SYSTEM_USERS) {
    const existing = await db
      .select({ id: users.id })
      .from(users)
      .where(eq(users.id, u.id));

    const passwordHash = await argon2.hash(u.rawPassword);

    if (existing.length === 0) {
      await db.insert(users).values({
        id: u.id,
        fullName: u.fullName,
        email: u.email,
        phone: u.phone,
        passwordHash,
        role: u.role,
        preferredLanguage: u.preferredLanguage,
      });
      console.log(`  + [CREATED] ${u.role}: ${u.fullName} (${u.email || u.phone})`);
    } else {
      await db
        .update(users)
        .set({
          fullName: u.fullName,
          email: u.email,
          phone: u.phone,
          passwordHash,
          role: u.role,
          preferredLanguage: u.preferredLanguage,
          updatedAt: new Date(),
        })
        .where(eq(users.id, u.id));
      console.log(`  ~ [UPDATED] ${u.role}: ${u.fullName} (${u.email || u.phone})`);
    }
  }

  // 2. Seed Sample Crops
  console.log("\n2. Seeding agricultural crops...");
  for (const cropData of SAMPLE_CROPS) {
    const existing = await db
      .select({ id: crops.id })
      .from(crops)
      .where(eq(crops.id, cropData.id));

    if (existing.length === 0) {
      await db.insert(crops).values(cropData);
      console.log(`  + [CREATED] Crop: ${cropData.name}`);
    } else {
      await db
        .update(crops)
        .set({
          name: cropData.name,
          description: cropData.description,
          active: cropData.active,
        })
        .where(eq(crops.id, cropData.id));
      console.log(`  ~ [UPDATED] Crop: ${cropData.name}`);
    }
  }

  // 3. Seed Farmers & Farmer-Crop Associations
  console.log("\n3. Seeding farmer profiles and crop associations...");
  for (const farmerData of DEMO_FARMERS) {
    const existingFarmer = await db
      .select({ id: farmers.id })
      .from(farmers)
      .where(eq(farmers.id, farmerData.id));

    if (existingFarmer.length === 0) {
      await db.insert(farmers).values({
        id: farmerData.id,
        userId: farmerData.userId,
        region: farmerData.region,
        zone: farmerData.zone,
        woreda: farmerData.woreda,
        kebele: farmerData.kebele,
        latitude: farmerData.latitude,
        longitude: farmerData.longitude,
        alertEnabled: farmerData.alertEnabled,
      });
      console.log(`  + [CREATED] Farmer Profile: ${farmerData.id} (${farmerData.woreda}, ${farmerData.region})`);
    } else {
      await db
        .update(farmers)
        .set({
          region: farmerData.region,
          zone: farmerData.zone,
          woreda: farmerData.woreda,
          kebele: farmerData.kebele,
          latitude: farmerData.latitude,
          longitude: farmerData.longitude,
          alertEnabled: farmerData.alertEnabled,
          updatedAt: new Date(),
        })
        .where(eq(farmers.id, farmerData.id));
      console.log(`  ~ [UPDATED] Farmer Profile: ${farmerData.id}`);
    }

    for (const cropId of farmerData.cropIds) {
      const existingAssoc = await db
        .select()
        .from(farmerCrops)
        .where(
          and(
            eq(farmerCrops.farmerId, farmerData.id),
            eq(farmerCrops.cropId, cropId)
          )
        );

      if (existingAssoc.length === 0) {
        await db.insert(farmerCrops).values({
          farmerId: farmerData.id,
          cropId,
        });
        console.log(`    + Associated crop ${cropId} with farmer ${farmerData.id}`);
      }
    }
  }

  // 4. Seed Demonstration Advisory Content & Reviews
  console.log("\n4. Seeding advisory content, reviews, audit logs, and messages...");
  const contentId = "c1000000-0000-4000-8000-000000000001";
  const existingContent = await db
    .select({ id: content.id })
    .from(content)
    .where(eq(content.id, contentId));

  if (existingContent.length === 0) {
    await db.insert(content).values({
      id: contentId,
      title: "Recommended Teff Sowing Dates for Early Meher Season",
      body: "Farmers in mid-to-highland zones are advised to prepare soil and plant Teff between early and mid-July to optimize rainfall utilization.",
      cropId: "a1000000-0000-4000-8000-000000000001",
      category: "Agronomy Advisory",
      status: "APPROVED",
      authorId: "b1000000-0000-4000-8000-000000000003", // Extension Worker
      approvedBy: "b1000000-0000-4000-8000-000000000002", // Expert
    });
    console.log(`  + [CREATED] Advisory Content: ${contentId}`);

    await db.insert(contentReviews).values({
      contentId,
      reviewerId: "b1000000-0000-4000-8000-000000000002", // Expert
      status: "APPROVED",
      comments: "Technical guidelines verified against national research institute agronomy standards.",
    });
    console.log(`  + [CREATED] Content Review for content: ${contentId}`);
  }

  // 5. Seed Demonstration Audit Log
  const existingAudit = await db.select().from(auditLogs).limit(1);
  if (existingAudit.length === 0) {
    await db.insert(auditLogs).values({
      userId: "b1000000-0000-4000-8000-000000000001", // Admin
      action: "database.seed",
      entityType: "system",
      entityId: "system-init",
      details: JSON.stringify({ phase: "Phase 2", version: "1.0.0" }),
    });
    console.log("  + [CREATED] Initial System Audit Log");
  }

  // 6. Seed Demonstration Message & Recipient
  const messageId = "e1000000-0000-4000-8000-000000000001";
  const existingMsg = await db.select().from(messages).where(eq(messages.id, messageId));
  if (existingMsg.length === 0) {
    await db.insert(messages).values({
      id: messageId,
      title: "Urgent Pest Warning",
      body: "Fall armyworm scout reports in Ada'a woreda. Inspect early whorl maize leaves immediately.",
      channel: "SMS",
      status: "SENT",
      createdBy: "b1000000-0000-4000-8000-000000000003", // Extension Worker
    });
    console.log(`  + [CREATED] Broadcast Message: ${messageId}`);

    await db.insert(messageRecipients).values({
      messageId,
      farmerId: "f1000000-0000-4000-8000-000000000001", // Abebe Balcha
      status: "DELIVERED",
      sentAt: new Date(),
    });
    console.log(`  + [CREATED] Message Recipient for farmer f1000000-0000-4000-8000-000000000001`);
  }

  console.log("\n════════════════════════════════════════════════════════════");
  console.log("✅ SEEDING COMPLETE: All 9 system tables successfully populated!");
  console.log("════════════════════════════════════════════════════════════");
}

if (require.main === module) {
  seedDemoData()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("❌ Seed failed:", error);
      process.exit(1);
    });
}