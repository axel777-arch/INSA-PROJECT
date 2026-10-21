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
  cases,
  caseResponses,
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
    status: "APPROVED",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000002",
    fullName: "Dr. Daniel Kassa (Expert)",
    email: "expert@gmail.com",
    phone: "+251912000001",
    rawPassword: "Expert$2026",
    role: "EXPERT",
    preferredLanguage: "en",
    status: "APPROVED",
    documentUrl: "https://storage.agri-insight.et/credentials/dr_daniel_license.pdf",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000003",
    fullName: "Helen Worku (Extension Worker)",
    email: "worker@gmail.com",
    phone: "+251911000001",
    rawPassword: "Worker$2026",
    role: "EXTENSION_WORKER",
    preferredLanguage: "am",
    status: "APPROVED",
    documentUrl: "https://storage.agri-insight.et/credentials/helen_worku_cert.pdf",
    active: true,
  },
  // Pending approvals for Admin testing
  {
    id: "b1000000-0000-4000-8000-000000000010",
    fullName: "Dr. Bekele Tolosa",
    email: "bekele.expert@agri.et",
    phone: "+251911223388",
    rawPassword: "Expert$2026",
    role: "EXPERT",
    preferredLanguage: "en",
    status: "PENDING_APPROVAL",
    documentUrl: "https://storage.agri-insight.et/credentials/bekele_phd_certificate.pdf",
    active: false,
  },
  {
    id: "b1000000-0000-4000-8000-000000000011",
    fullName: "Meseret Tadesse",
    email: "meseret.worker@agri.et",
    phone: "+251912445599",
    rawPassword: "Worker$2026",
    role: "EXTENSION_WORKER",
    preferredLanguage: "am",
    status: "PENDING_APPROVAL",
    documentUrl: "https://storage.agri-insight.et/credentials/meseret_extension_license.pdf",
    active: false,
  },
  // Farmers
  {
    id: "b1000000-0000-4000-8000-000000000004",
    fullName: "Abebe Balcha",
    email: "farmer@gmail.com",
    phone: "+251911223344",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "am",
    status: "APPROVED",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000005",
    fullName: "Fatuma Ahmed",
    email: "farmer2@gmail.com",
    phone: "+251911223345",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "or",
    status: "APPROVED",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000006",
    fullName: "Chala Dejene",
    email: "farmer3@gmail.com",
    phone: "+251911223346",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "am",
    status: "APPROVED",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000007",
    fullName: "Tadesse Hailu",
    email: "farmer4@gmail.com",
    phone: "+251911223347",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "ti",
    status: "APPROVED",
    active: true,
  },
  {
    id: "b1000000-0000-4000-8000-000000000008",
    fullName: "Mulugeta Wolde",
    email: "farmer5@gmail.com",
    phone: "+251911223348",
    rawPassword: "Farmer$2026",
    role: "FARMER",
    preferredLanguage: "am",
    status: "APPROVED",
    active: true,
  },
];

// ── 2. Ethiopian Agricultural Crops ───────────────────────────────────────────
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
  {
    id: "a1000000-0000-4000-8000-000000000005",
    name: "Barley",
    description: "Cold-tolerant highland staple cultivated for traditional foods and beverage malt.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000006",
    name: "Sorghum",
    description: "Drought-resilient coarse grain staple thriving in semi-arid and lowland Ethiopian valleys.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000007",
    name: "Sesame",
    description: "High-grade oilseed export crop cultivated extensively in Humera, Metema, and lowland plains.",
    active: true,
  },
];

// ── 3. Farmer Profiles with Ethiopian Administrative Hierarchy ────────────────
const DEMO_FARMERS = [
  {
    id: "f1000000-0000-4000-8000-000000000001",
    userId: "b1000000-0000-4000-8000-000000000004", // Abebe Balcha
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
      "a1000000-0000-4000-8000-000000000005", // Barley
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
      "a1000000-0000-4000-8000-000000000006", // Sorghum
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000005",
    userId: "b1000000-0000-4000-8000-000000000008", // Mulugeta Wolde
    region: "SNNPR",
    zone: "Gurage",
    woreda: "Butajira",
    kebele: "Kebele 02",
    latitude: 8.1214,
    longitude: 38.3752,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000001", // Teff
      "a1000000-0000-4000-8000-000000000003", // Wheat
      "a1000000-0000-4000-8000-000000000007", // Sesame
    ],
  },
];

export async function seedDemoData() {
  console.log("════════════════════════════════════════════════════════════");
  console.log("🌱 AGRI-INSIGHT BEACON ETHIOPIAN SEEDING SUITE");
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
        status: u.status,
        documentUrl: u.documentUrl ?? null,
        active: u.active,
      });
      console.log(`  + [CREATED] ${u.role}: ${u.fullName} (${u.status})`);
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
          status: u.status,
          documentUrl: u.documentUrl ?? null,
          active: u.active,
          updatedAt: new Date(),
        })
        .where(eq(users.id, u.id));
      console.log(`  ~ [UPDATED] ${u.role}: ${u.fullName} (${u.status})`);
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
      console.log(`  + [CREATED] Farmer: ${farmerData.id} (${farmerData.woreda}, ${farmerData.region})`);
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
      console.log(`  ~ [UPDATED] Farmer: ${farmerData.id}`);
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
      }
    }
  }

  // 4. Seed Content and Reviews
  console.log("\n4. Seeding content and reviews...");
  const contentItems = [
    {
      id: "c1000000-0000-4000-8000-000000000001",
      title: "Recommended Teff Sowing Dates for Early Meher Season",
      body: "Farmers in mid-to-highland zones are advised to prepare soil and plant Teff between early and mid-July to optimize rainfall utilization.",
      cropId: "a1000000-0000-4000-8000-000000000001",
      category: "Agronomy Advisory",
      status: "PUBLISHED" as const,
      authorId: "b1000000-0000-4000-8000-000000000003",
      approvedBy: "b1000000-0000-4000-8000-000000000002",
    },
    {
      id: "c1000000-0000-4000-8000-000000000002",
      title: "Wheat Rust Prevention and Spray Guidelines",
      body: "High humidity levels detected in Ada'a woreda. Apply systemic fungicides at first appearance of orange-yellow pustules.",
      cropId: "a1000000-0000-4000-8000-000000000003",
      category: "Disease Alert",
      status: "APPROVED" as const,
      authorId: "b1000000-0000-4000-8000-000000000003",
      approvedBy: "b1000000-0000-4000-8000-000000000002",
    },
    {
      id: "c1000000-0000-4000-8000-000000000003",
      title: "Coffee Berry Disease Organic Management",
      body: "Proper canopy pruning and shade control reduce CBD sporulation. Consult your extension officer for copper spray timing.",
      cropId: "a1000000-0000-4000-8000-000000000004",
      category: "Integrated Pest Management",
      status: "PENDING_REVIEW" as const,
      authorId: "b1000000-0000-4000-8000-000000000003",
      approvedBy: null,
    },
    {
      id: "c1000000-0000-4000-8000-000000000004",
      title: "Maize Fall Armyworm Early Scouting Protocol",
      body: "Field draft: Inspect 20 plants across 5 spots per hectare. Record window-pane feeding symptoms on whorl leaves.",
      cropId: "a1000000-0000-4000-8000-000000000002",
      category: "Field Observation Draft",
      status: "DRAFT" as const,
      authorId: "b1000000-0000-4000-8000-000000000003",
      approvedBy: null,
    },
  ];

  for (const item of contentItems) {
    const existing = await db.select({ id: content.id }).from(content).where(eq(content.id, item.id));
    if (existing.length === 0) {
      await db.insert(content).values(item);
      console.log(`  + [CREATED] Advisory: "${item.title}" (${item.status})`);
    } else {
      await db.update(content).set(item).where(eq(content.id, item.id));
    }
  }

  // 5. Seed Field Cases and Expert Responses
  console.log("\n5. Seeding field cases and expert responses...");
  const demoCases = [
    {
      id: "d1000000-0000-4000-8000-000000000001",
      farmerId: "f1000000-0000-4000-8000-000000000001", // Abebe Balcha
      cropId: "a1000000-0000-4000-8000-000000000003", // Wheat
      title: "Yellow Rust Pustules on Wheat Leaves",
      description: "Observed powdery yellow-orange stripe lesions on lower leaf surfaces across 2 hectares of meher wheat in Kebele 01, Ada'a.",
      location: "Ada'a, East Shewa, Oromia",
      status: "OPEN",
    },
    {
      id: "d1000000-0000-4000-8000-000000000002",
      farmerId: "f1000000-0000-4000-8000-000000000002", // Fatuma Ahmed
      cropId: "a1000000-0000-4000-8000-000000000002", // Maize
      title: "Fall Armyworm Frass and Leaf Ragged Holes",
      description: "Severe feeding damage on 4-week maize crop whorls with characteristic sawdust-like frass.",
      location: "Bure, West Gojjam, Amhara",
      status: "IN_REVIEW",
    },
    {
      id: "d1000000-0000-4000-8000-000000000003",
      farmerId: "f1000000-0000-4000-8000-000000000003", // Chala Dejene
      cropId: "a1000000-0000-4000-8000-000000000004", // Coffee
      title: "Coffee Berry Dark Lesions",
      description: "Sunken dark brown spots on green developing berries causing premature dropping.",
      location: "Chuko, Aleta Chuko, Sidama",
      status: "RESOLVED",
    },
  ];

  for (const c of demoCases) {
    const existing = await db.select({ id: cases.id }).from(cases).where(eq(cases.id, c.id));
    if (existing.length === 0) {
      await db.insert(cases).values(c);
      console.log(`  + [CREATED] Case: "${c.title}" (${c.status})`);
    }
  }

  // Seed response for resolved case
  const resolvedCaseId = "d1000000-0000-4000-8000-000000000003";
  const existingResponse = await db.select({ id: caseResponses.id }).from(caseResponses).where(eq(caseResponses.caseId, resolvedCaseId));
  if (existingResponse.length === 0) {
    await db.insert(caseResponses).values({
      caseId: resolvedCaseId,
      expertId: "b1000000-0000-4000-8000-000000000002",
      diagnosis: "Confirmed Colletotrichum kahawae (Coffee Berry Disease).",
      recommendation: "Apply recommended copper-based formulation (Copper Hydroxide 50% WP) during berry swelling. Ensure adequate pruning for aeration.",
      internalNotes: "Case reviewed and resolved based on submitted leaf/berry imagery.",
    });
    console.log(`  + [CREATED] Expert Response for Case ${resolvedCaseId}`);
  }

  // 6. Seed Messages & Audit Logs
  console.log("\n6. Seeding messages and audit logs...");
  const messageId = "e1000000-0000-4000-8000-000000000001";
  const existingMsg = await db.select().from(messages).where(eq(messages.id, messageId));
  if (existingMsg.length === 0) {
    await db.insert(messages).values({
      id: messageId,
      title: "Urgent Pest Warning",
      body: "Fall armyworm scout reports in Ada'a woreda. Inspect early whorl maize leaves immediately.",
      channel: "SMS",
      status: "SENT",
      createdBy: "b1000000-0000-4000-8000-000000000003",
    });

    await db.insert(messageRecipients).values({
      messageId,
      farmerId: "f1000000-0000-4000-8000-000000000001",
      status: "DELIVERED",
      sentAt: new Date(),
    });
    console.log(`  + [CREATED] Message & Recipient (${messageId})`);
  }

  await db.insert(auditLogs).values({
    userId: "b1000000-0000-4000-8000-000000000001",
    action: "SYSTEM_SEEDED",
    entityType: "system",
    entityId: "seed-v2",
    details: JSON.stringify({ regions: ["Oromia", "Amhara", "Sidama", "SNNPR", "Tigray"], countCrops: 7 }),
  });

  console.log("\n════════════════════════════════════════════════════════════");
  console.log("✅ ETHIOPIAN SAMPLE SEED COMPLETE!");
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