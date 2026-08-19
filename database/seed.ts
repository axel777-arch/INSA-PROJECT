import { eq, and } from "drizzle-orm";
import { db } from "../backend/src/config/database";
import { farmers } from "./schema/farmers";
import { crops } from "./schema/crops";
import { farmerCrops } from "./schema/farmerCrops";

// Deterministic synthetic UUIDs for demo data.
// These are valid UUIDs so PostgreSQL accepts them.
const DEMO_CROPS = [
  {
    id: "a1000000-0000-4000-8000-000000000001",
    name: "Teff",
    description:
      "Cereal crop staple cultivated for grain and injera production.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000002",
    name: "Wheat",
    description:
      "Major highland cereal grain cultivated during meher season.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000003",
    name: "Maize",
    description:
      "High-yield coarse grain grown across mid-altitude zones.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000004",
    name: "Coffee (Arabica)",
    description:
      "High-value perennial cash crop grown in forest and garden systems.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000005",
    name: "Barley",
    description:
      "Cold-tolerant highland cereal adapted to acidic soils.",
    active: true,
  },
  {
    id: "a1000000-0000-4000-8000-000000000006",
    name: "Chickpea",
    description:
      "Cool-season legume fixing nitrogen in residual moisture rotations.",
    active: true,
  },
];

// Synthetic demo farmer profiles.
// userId values are now VALID UUIDs.
const DEMO_FARMERS = [
  {
    id: "f1000000-0000-4000-8000-000000000001",
    userId: "b1000000-0000-4000-8000-000000000001",
    region: "Oromia",
    zone: "East Shewa",
    woreda: "Ada'a",
    kebele: "Kebele 01",
    latitude: 8.7521,
    longitude: 38.9812,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000001",
      "a1000000-0000-4000-8000-000000000002",
      "a1000000-0000-4000-8000-000000000006",
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000002",
    userId: "b1000000-0000-4000-8000-000000000002",
    region: "Amhara",
    zone: "West Gojjam",
    woreda: "Bure",
    kebele: "Kebele 04",
    latitude: 10.7022,
    longitude: 37.0655,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000003",
      "a1000000-0000-4000-8000-000000000002",
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000003",
    userId: "b1000000-0000-4000-8000-000000000003",
    region: "Sidama",
    zone: "Aleta Chuko",
    woreda: "Chuko",
    kebele: "Kebele 02",
    latitude: 6.7824,
    longitude: 38.4121,
    alertEnabled: true,
    cropIds: [
      "a1000000-0000-4000-8000-000000000004",
      "a1000000-0000-4000-8000-000000000003",
    ],
  },
  {
    id: "f1000000-0000-4000-8000-000000000004",
    userId: "b1000000-0000-4000-8000-000000000004",
    region: "Tigray",
    zone: "Eastern Tigray",
    woreda: "Kilte Awulaelo",
    kebele: "Kebele 03",
    latitude: 13.7225,
    longitude: 39.5987,
    alertEnabled: false,
    cropIds: [
      "a1000000-0000-4000-8000-000000000005",
      "a1000000-0000-4000-8000-000000000002",
    ],
  },
];

export async function seedDemoData() {
  console.log(
    "🌱 Starting seed: Crops, Farmers, and Farmer-Crop associations..."
  );

  // 1. Seed crops
  for (const cropData of DEMO_CROPS) {
    const existingCrop = await db
      .select({ id: crops.id })
      .from(crops)
      .where(eq(crops.id, cropData.id));

    if (existingCrop.length === 0) {
      await db.insert(crops).values({
        id: cropData.id,
        name: cropData.name,
        description: cropData.description,
        active: cropData.active,
      });

      console.log(`  + Seeded crop: ${cropData.name}`);
    } else {
      console.log(`  ~ Crop already exists: ${cropData.name}`);
    }
  }

  // 2. Seed farmers and farmer-crop relationships
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

      console.log(
        `  + Seeded farmer: ${farmerData.id} (${farmerData.woreda}, ${farmerData.region})`
      );
    } else {
      console.log(`  ~ Farmer already exists: ${farmerData.id}`);
    }

    // 3. Associate crops with the farmer
    for (const cropId of farmerData.cropIds) {
      const existingAssociation = await db
        .select()
        .from(farmerCrops)
        .where(
          and(
            eq(farmerCrops.farmerId, farmerData.id),
            eq(farmerCrops.cropId, cropId)
          )
        );

      if (existingAssociation.length === 0) {
        await db.insert(farmerCrops).values({
          farmerId: farmerData.id,
          cropId: cropId,
        });

        console.log(
          `    + Associated crop ${cropId} with farmer ${farmerData.id}`
        );
      }
    }
  }

  console.log("✅ Seed completed successfully.");
}

// Allow direct CLI invocation
if (require.main === module) {
  seedDemoData()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error("❌ Seed failed:", error);
      process.exit(1);
    });
}