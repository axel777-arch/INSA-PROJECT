import { and, eq, ilike, or } from "drizzle-orm";

import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";
import { farmers } from "../../../../database/schema/farmers";
import { matchesCrop } from "./cropTargeting";
import { matchesLanguage } from "./languageTargeting";
import { matchesLocation } from "./locationTargeting";
import type { FarmerTargetingProfile, FindTargetFarmersInput } from "./targeting.types";

export class TargetingService {
  findTargetFarmers({ cropName, location, language, farmers }: FindTargetFarmersInput): FarmerTargetingProfile[] {
    const seen = new Set<string>();

    return farmers.filter((farmer) => {
      const matches =
        farmer.alertEnabled &&
        matchesCrop(farmer, cropName) &&
        matchesLocation(farmer, location) &&
        matchesLanguage(farmer, language);

      if (!matches || seen.has(farmer.id)) {
        return false;
      }

      seen.add(farmer.id);
      return true;
    });
  }

  async findTargetFarmersFromDb({
    cropName,
    location,
    language,
    db,
  }: {
    cropName: string;
    location: string;
    language: string;
    db: any;
  }): Promise<FarmerTargetingProfile[]> {
    if (!db) {
      return [];
    }

    const cropRecords = await db.select().from(crops).where(ilike(crops.name, cropName)).limit(1);

    if (!cropRecords.length) {
      return [];
    }

    const cropId = cropRecords[0].id;

    const matchedRows = await db
      .select({
        id: farmers.id,
        preferredLanguage: farmers.preferredLanguage,
        region: farmers.region,
        zone: farmers.zone,
        alertEnabled: farmers.alertEnabled,
      })
      .from(farmers)
      .leftJoin(farmerCrops, eq(farmerCrops.farmerId, farmers.id))
      .where(
        and(
          eq(farmers.alertEnabled, true),
          eq(farmers.preferredLanguage, language),
          eq(farmerCrops.cropId, cropId),
          or(eq(farmers.region, location), eq(farmers.zone, location)),
        ),
      );

    const normalized = matchedRows.map((row) => ({
      id: row.id,
      preferredLanguage: row.preferredLanguage,
      region: row.region,
      zone: row.zone ?? undefined,
      alertEnabled: row.alertEnabled,
      cropNames: [cropName],
    }));

    return [...new Map(normalized.map((item) => [item.id, item])).values()];
  }
}
