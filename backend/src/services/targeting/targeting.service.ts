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
}
