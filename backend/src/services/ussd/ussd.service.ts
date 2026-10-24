import type { UssdRequest, UssdSessionState } from './ussd.types';

export class UssdValidationError extends Error {}

export class UssdSessionService {
  private sessions = new Map<string, UssdSessionState>();

  getSession(sessionId: string): UssdSessionState | undefined {
    return this.sessions.get(sessionId);
  }

  getOrCreateSession(request: UssdRequest): UssdSessionState {
    const existing = this.sessions.get(request.sessionId);
    if (existing && (existing.phoneNumber !== request.phoneNumber || existing.serviceCode !== request.serviceCode)) {
      throw new UssdValidationError("USSD session identity does not match the original callback");
    }
    const session = existing ?? {
      sessionId: request.sessionId,
      phoneNumber: request.phoneNumber,
      serviceCode: request.serviceCode,
      currentStep: 'welcome',
      status: 'ACTIVE',
    };

    this.sessions.set(request.sessionId, session);
    return session;
  }

  handleRequest(request: UssdRequest): string {
    if (!/^[A-Za-z0-9_-]{1,128}$/.test(request.sessionId)
      || !/^\*[0-9*]{1,20}#$/.test(request.serviceCode)
      || !/^\+?[0-9]{7,15}$/.test(request.phoneNumber)
      || request.text.length > 256
      || !/^[0-9*#]*(?:\*[0-9*#]*)*$/.test(request.text)) {
      throw new UssdValidationError("Invalid USSD callback data");
    }
    const session = this.getOrCreateSession(request);
    const currentText = request.text.trim().split("*").filter(Boolean).at(-1) ?? "";

    if (currentText === '') {
      session.currentStep = 'welcome';
      return 'CON Welcome to Agri-Insight Beacon\n1. My profile\n2. Crop tips\n3. Alerts\n4. Exit';
    }

    if (session.currentStep === 'welcome' || session.currentStep === 'menu') {
      switch (currentText) {
        case '1':
          session.currentStep = 'complete';
          return 'END Your profile is available in the mobile app and farmer records.';
        case '2':
          session.currentStep = 'crop';
          return 'CON Select crop\n1. Maize\n2. Wheat\n3. Coffee\n4. Back';
        case '3':
          session.currentStep = 'complete';
          return 'END Alerts are managed from your farmer profile.';
        case '4':
          session.currentStep = 'complete';
          session.status = 'CANCELLED';
          return 'END Thank you for using Agri-Insight Beacon.';
        default:
          return 'CON Invalid selection. Please choose a valid option.';
      }
    }

    if (session.currentStep === 'crop') {
      switch (currentText) {
        case '1':
          session.selectedCrop = 'Maize';
          session.currentStep = 'content';
          return 'CON Relevant maize content\n1. Irrigation schedule\n2. Pest warning\n3. Back';
        case '2':
          session.selectedCrop = 'Wheat';
          session.currentStep = 'content';
          return 'CON Relevant wheat content\n1. Soil test reminder\n2. Harvest timing\n3. Back';
        case '3':
          session.selectedCrop = 'Coffee';
          session.currentStep = 'content';
          return 'CON Relevant coffee content\n1. Shade management\n2. Harvest timing\n3. Back';
        case '4':
          session.currentStep = 'menu';
          return 'CON Welcome to Agri-Insight Beacon\n1. My profile\n2. Crop tips\n3. Alerts\n4. Exit';
        default:
          return 'CON Invalid selection. Please select a crop option.';
      }
    }

    if (session.currentStep === 'content') {
      if (currentText === '3' || currentText === '4') {
        session.currentStep = 'crop';
        return 'CON Select crop\n1. Maize\n2. Wheat\n3. Coffee\n4. Back';
      }

      session.currentStep = 'complete';
      session.status = 'COMPLETED';
      return 'END Content sent for review. Thank you.';
    }

    return 'END Thank you for using Agri-Insight Beacon.';
  }
}
