import type { FarmerTargetingProfile } from "./targeting.types";

export function matchesLocation(farmer: FarmerTargetingProfile, location: string): boolean {
  const targetLocation = location.trim().toLowerCase();
  const targetLocations = [farmer.region, farmer.zone, farmer.woreda, farmer.kebele]
    .filter((value): value is string => Boolean(value))
    .map((value) => value.trim().toLowerCase());

  return targetLocations.includes(targetLocation);
}
