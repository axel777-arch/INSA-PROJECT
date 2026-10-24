export type FarmerTargetingProfile = {
  id: string;
  preferredLanguage: string;
  region: string;
  zone?: string;
  alertEnabled: boolean;
  cropNames?: string[];
};

export type FindTargetFarmersInput = {
  cropName: string;
  location: string;
  language: string;
  farmers: FarmerTargetingProfile[];
};
