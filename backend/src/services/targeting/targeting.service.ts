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
        preferredLanguage: users.preferredLanguage,
        region: farmers.region,
        zone: farmers.zone,
        woreda: farmers.woreda,
        kebele: farmers.kebele,
        alertEnabled: farmers.alertEnabled,
      })
      .from(farmers)
      .innerJoin(users, eq(users.id, farmers.userId))
      .leftJoin(farmerCrops, eq(farmerCrops.farmerId, farmers.id))
      .where(
        and(
          eq(farmers.alertEnabled, true),
          eq(users.active, true),
          eq(users.status, "APPROVED"),
          eq(users.preferredLanguage, language),
          eq(farmerCrops.cropId, cropId),
          or(
            eq(farmers.region, location),
            eq(farmers.zone, location),
            eq(farmers.woreda, location),
            eq(farmers.kebele, location),
          ),
        ),
      );

    const normalized: FarmerTargetingProfile[] = matchedRows.map((row: any) => ({
      id: row.id,
      preferredLanguage: row.preferredLanguage,
      region: row.region,
      zone: row.zone ?? undefined,
      woreda: row.woreda ?? undefined,
      kebele: row.kebele ?? undefined,
      alertEnabled: row.alertEnabled,
      cropNames: [cropName],
    }));

    return [...new Map(normalized.map((item) => [item.id, item])).values()];
  }

  async findTargetFarmersForContent({
    cropId,
    region,
    zone,
    woreda,
    kebele,
    language,
    database = defaultDb,
  }: {
    cropId?: string | null;
    region?: string | null;
    zone?: string | null;
    woreda?: string | null;
    kebele?: string | null;
    language?: string | null;
    database?: any;
  }): Promise<{ id: string; userId: string; phone?: string | null; region?: string | null }[]> {
    if (!database || !(cropId || region || zone || woreda || kebele || language)) {
      return [];
    }

    const locationConditions = [
      region ? eq(farmers.region, region) : undefined,
      zone ? eq(farmers.zone, zone) : undefined,
      woreda ? eq(farmers.woreda, woreda) : undefined,
      kebele ? eq(farmers.kebele, kebele) : undefined,
    ].filter((condition): condition is NonNullable<typeof condition> => condition !== undefined);
    const conditions = [
      eq(farmers.alertEnabled, true),
      eq(users.active, true),
      eq(users.status, "APPROVED"),
      cropId ? eq(farmerCrops.cropId, cropId) : undefined,
      ...locationConditions,
      language ? eq(users.preferredLanguage, language) : undefined,
    ].filter((condition): condition is NonNullable<typeof condition> => condition !== undefined);

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
      .innerJoin(users, eq(users.id, farmers.userId));
    if (cropId) {
      query = query.innerJoin(farmerCrops, eq(farmerCrops.farmerId, farmers.id));
    }
    const matchedRows = await query.where(and(...conditions));
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
  }
}

export const targetingService = new TargetingService();
