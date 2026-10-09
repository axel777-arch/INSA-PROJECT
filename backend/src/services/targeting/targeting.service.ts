import { and, eq, ilike, or } from "drizzle-orm";

import { db as defaultDb } from "../../db/index";
import { crops } from "../../../../database/schema/crops";
import { farmerCrops } from "../../../../database/schema/farmerCrops";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
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
        region: farmers.region,
        zone: farmers.zone,
        alertEnabled: farmers.alertEnabled,
      })
      .from(farmers)
      .leftJoin(farmerCrops, eq(farmerCrops.farmerId, farmers.id))
      .where(
        and(
          eq(farmers.alertEnabled, true),
          eq(farmerCrops.cropId, cropId),
          or(eq(farmers.region, location), eq(farmers.zone, location)),
        ),
      );

    const normalized: FarmerTargetingProfile[] = matchedRows.map((row: any) => ({
      id: row.id,
      preferredLanguage: language,
      region: row.region,
      zone: row.zone ?? undefined,
      alertEnabled: row.alertEnabled,
      cropNames: [cropName],
    }));

    return [...new Map(normalized.map((item) => [item.id, item])).values()];
  }

  async findTargetFarmersForContent({
    cropId,
    region,
    language,
    database = defaultDb,
  }: {
    cropId?: string | null;
    region?: string | null;
    language?: string | null;
    database?: any;
  }): Promise<{ id: string; userId: string; phone?: string | null; region?: string | null }[]> {
    if (!database) {
      return [];
    }

    try {
      let query = database
        .select({
          id: farmers.id,
          userId: farmers.userId,
          region: farmers.region,
          alertEnabled: farmers.alertEnabled,
          phone: users.phone,
          preferredLanguage: users.preferredLanguage,
        })
        .from(farmers)
        .leftJoin(users, eq(users.id, farmers.userId));

      if (cropId) {
        query = query
          .innerJoin(farmerCrops, eq(farmerCrops.farmerId, farmers.id))
          .where(
            and(
              eq(farmers.alertEnabled, true),
              eq(farmerCrops.cropId, cropId),
              ...(region ? [or(eq(farmers.region, region), eq(farmers.zone, region))] : []),
              ...(language ? [eq(users.preferredLanguage, language)] : []),
            )
          );
      } else {
        query = query.where(
          and(
            eq(farmers.alertEnabled, true),
            ...(region ? [or(eq(farmers.region, region), eq(farmers.zone, region))] : []),
            ...(language ? [eq(users.preferredLanguage, language)] : []),
          )
        );
      }

      const matchedRows = await query;
      const uniqueMap = new Map<string, { id: string; userId: string; phone?: string | null; region?: string | null }>();
      for (const row of matchedRows) {
        if (!uniqueMap.has(row.id)) {
          uniqueMap.set(row.id, {
            id: row.id,
            userId: row.userId,
            phone: row.phone,
            region: row.region,
          });
        }
      }

      return Array.from(uniqueMap.values());
    } catch (err) {
      console.error('[TARGETING ERROR] Failed to query target farmers for content:', err);
      return [];
    }
  }
}

export const targetingService = new TargetingService();

