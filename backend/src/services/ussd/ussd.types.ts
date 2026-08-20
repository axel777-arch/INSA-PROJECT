export type UssdRequest = {
  sessionId: string;
  serviceCode: string;
  phoneNumber: string;
  text: string;
};

export type UssdSessionState = {
  sessionId: string;
  phoneNumber: string;
  serviceCode: string;
  currentStep: 'welcome' | 'menu' | 'crop' | 'content' | 'complete';
  selectedCrop?: string;
  selectedLanguage?: string;
  status: 'ACTIVE' | 'COMPLETED' | 'CANCELLED';
};
