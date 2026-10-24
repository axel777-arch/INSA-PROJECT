import type { FarmerTargetingProfile } from "./targeting.types";

export function matchesLocation(farmer: FarmerTargetingProfile, location: string): boolean {
  const targetLocation = location.trim().toLowerCase();
  const farmerLocation = farmer.region.trim().toLowerCase();

  return farmerLocation === targetLocation || farmer.zone?.trim().toLowerCase() === targetLocation;
}
