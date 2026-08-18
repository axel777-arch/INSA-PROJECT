import type { FarmerTargetingProfile } from "./targeting.types";

export function matchesCrop(farmer: FarmerTargetingProfile, cropName: string): boolean {
  const targetCrop = cropName.trim().toLowerCase();

  return (farmer.cropNames ?? []).some((crop) => crop.trim().toLowerCase() === targetCrop);
}
