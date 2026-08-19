import type { FarmerTargetingProfile } from "./targeting.types";

export function matchesLanguage(farmer: FarmerTargetingProfile, language: string): boolean {
  return farmer.preferredLanguage.trim().toLowerCase() === language.trim().toLowerCase();
}
