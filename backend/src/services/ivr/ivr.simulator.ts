import type { IvrCall, IvrCallPayload, IvrCallStatus, IvrProvider } from "./ivr.types";

export interface IvrSession {
  sessionId: string;
  phone: string;
  farmerId?: string;
  status: IvrCallStatus;
  currentMenu: string;
  prompt: string;
  lastInput?: string;
  createdAt: Date;
  updatedAt: Date;
}

export class IvrSimulator implements IvrProvider {
  private calls = new Map<string, IvrCall>();
  private sessions = new Map<string, IvrSession>();

  private readonly validTransitions: Record<IvrCallStatus, IvrCallStatus[]> = {
    QUEUED: ["IN_PROGRESS", "FAILED", "CANCELLED"],
    IN_PROGRESS: ["COMPLETED", "FAILED", "CANCELLED"],
    COMPLETED: [],
    FAILED: [],
    CANCELLED: [],
  };

  canTransition(from: IvrCallStatus, to: IvrCallStatus): boolean {
    return this.validTransitions[from]?.includes(to) ?? false;
  }

  createCall(payload: IvrCallPayload): IvrCall {
    const now = new Date();
    const call: IvrCall = {
      id: this.makeId(),
      farmerId: payload.farmerId,
      phone: payload.phone,
      status: "QUEUED",
      createdAt: now,
      updatedAt: now,
    };

    this.calls.set(call.id, call);
    return call;
  }

  updateCallStatus(id: string, status: IvrCallStatus): IvrCall {
    const current = this.calls.get(id);

    if (!current) {
      throw new Error(`IVR call ${id} was not found.`);
    }

    if (!this.canTransition(current.status, status)) {
      throw new Error(`IVR status transition from ${current.status} to ${status} is invalid.`);
    }

    const updated: IvrCall = {
      ...current,
      status,
      updatedAt: new Date(),
    };

    this.calls.set(id, updated);
    return updated;
  }

  startSession(params: { phone?: string; farmerId?: string }): IvrSession {
    const now = new Date();
    const call = this.createCall({
      farmerId: params.farmerId ?? "farmer-sim",
      phone: params.phone ?? "+251911000000",
    });
    this.updateCallStatus(call.id, "IN_PROGRESS");

    const session: IvrSession = {
      sessionId: call.id,
      phone: call.phone,
      farmerId: call.farmerId,
      status: "IN_PROGRESS",
      currentMenu: "language",
      prompt: "Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.",
      createdAt: now,
      updatedAt: now,
    };

    this.sessions.set(session.sessionId, session);
    return session;
  }

  handleDtmf(sessionId: string, key: string): IvrSession {
    let session = this.sessions.get(sessionId);

    if (!session) {
      session = this.startSession({});
      session.sessionId = sessionId;
      this.sessions.set(sessionId, session);
    }

    let menu = session.currentMenu;
    let prompt = session.prompt;

    if (menu === "language") {
      if (key === "1") {
        menu = "main";
        prompt = "English selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (key === "2") {
        menu = "main";
        prompt = "Amharic selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (key === "3") {
        menu = "main";
        prompt = "Oromo selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else {
        prompt = "Invalid option. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.";
      }
    } else if (menu === "main") {
      if (key === "1") {
        menu = "advisories";
        prompt = "Crop Advisories: Press 1 for Wheat Rust warning, Press 2 for Maize irrigation tips. Press * to return to Main Menu.";
      } else if (key === "2") {
        menu = "weather";
        prompt = "Weather Report: Fair agricultural weather conditions expected this week. Optimal temperature 24°C. Press * to return to Main Menu.";
      } else if (key === "3") {
        menu = "alerts";
        prompt = "Alert Settings: Press 1 to Enable SMS Alerts, Press 2 to Disable SMS Alerts. Press * to return to Main Menu.";
      } else {
        prompt = "Invalid option. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      }
    } else if (menu === "advisories") {
      if (key === "*") {
        menu = "main";
        prompt = "Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (key === "1") {
        prompt = "Wheat Rust Warning: High probability of fungal growth. Ensure chemical treatment is applied before morning dew. Press * to return to Main Menu.";
      } else if (key === "2") {
        prompt = "Maize irrigation tips: Drip irrigate crops during evenings. Avoid midday watering. Press * to return to Main Menu.";
      }
    } else if (menu === "alerts" || menu === "weather") {
      if (key === "*") {
        menu = "main";
        prompt = "Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (menu === "alerts" && key === "1") {
        prompt = "SMS alerts successfully enabled. You will receive agricultural updates on your phone. Press * to return to Main Menu.";
      } else if (menu === "alerts" && key === "2") {
        prompt = "SMS alerts disabled. Press * to return to Main Menu.";
      }
    }

    session.currentMenu = menu;
    session.prompt = prompt;
    session.lastInput = key;
    session.updatedAt = new Date();

    return session;
  }

  endSession(sessionId: string): IvrSession {
    const session = this.sessions.get(sessionId) ?? this.startSession({});
    session.status = "COMPLETED";
    session.prompt = "Call ended. Thank you for using Agri-Insight Beacon.";
    session.updatedAt = new Date();

    if (this.calls.has(sessionId)) {
      this.calls.get(sessionId)!.status = "COMPLETED";
    }

    return session;
  }

  getSession(sessionId: string): IvrSession | undefined {
    return this.sessions.get(sessionId);
  }

  private makeId(): string {
    return `ivr_${Math.random().toString(36).slice(2, 10)}`;
  }
}

export const ivrSimulator = new IvrSimulator();

