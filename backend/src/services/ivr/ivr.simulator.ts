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
    const sessionAny = session as any;

    if (menu === "language") {
      if (key === "1") {
        menu = "main";
        sessionAny.lang = "en";
        prompt = "English selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (key === "2") {
        menu = "main";
        sessionAny.lang = "am";
        prompt = "አማርኛ ተመርጧል። ዋና ማውጫ፦ ለሰብል ምክሮች 1 ይጫኑ፣ ለአየር ሁኔታ መረጃ 2 ይጫኑ፣ ለአደጋ ጥንቃቄ ቅንብሮች 3 ይጫኑ።";
      } else if (key === "3") {
        menu = "main";
        sessionAny.lang = "om";
        prompt = "Afaan Oromoo filatameera. Baafata Guddaa: Gorsa midhaaniif 1 tuqi, Haala qilleensaaf 2 tuqi, Qophii akeekkachiisaaf 3 tuqi.";
      } else {
        prompt = "Invalid option. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.";
      }
    } else if (menu === "main") {
      const isAm = sessionAny.lang === "am";
      if (key === "1") {
        menu = "advisories";
        prompt = isAm
          ? "የሰብል ምክሮች፦ ለስንዴ ዋግ በሽታ 1 ይጫኑ፣ የበቆሎ መስኖ ምክር ለማግኘት 2 ይጫኑ። ወደ ዋናው ማውጫ ለመመለስ * ይጫኑ።"
          : "Crop Advisories: Press 1 for Wheat Rust warning, Press 2 for Maize irrigation tips. Press * to return to Main Menu.";
      } else if (key === "2") {
        menu = "weather";
        prompt = isAm
          ? "የአየር ሁኔታ መረጃ፦ በዚህ ሳምንት ተስማሚ የግብርና አየር ሁኔታ ይጠበቃል። አማካይ ሙቀት 24 ዲግሪ ሴልሺየስ ነው። ወደ ዋናው ማውጫ ለመመለስ * ይጫኑ።"
          : "Weather Report: Fair agricultural weather conditions expected this week. Optimal temperature 24°C. Press * to return to Main Menu.";
      } else if (key === "3") {
        menu = "alerts";
        prompt = isAm
          ? "የማንቂያ ቅንብሮች (ማስመሰያ ብቻ)፦ 1 ለማብራት፣ 2 ለማጥፋት። * ወደ ዋናው ማውጫ።"
          : "Alert Settings (simulator only): Press 1 to enable SMS alerts, 2 to disable; * to return. No preference is changed.";
      } else {
        prompt = isAm
          ? "ልክ ያልሆነ ምርጫ። ዋና ማውጫ፦ ለሰብል ምክሮች 1 ይጫኑ፣ ለአየር ሁኔታ መረጃ 2 ይጫኑ፣ ለአደጋ ጥንቃቄ 3 ይጫኑ።"
          : "Invalid option. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      }
    } else if (menu === "advisories") {
      const isAm = sessionAny.lang === "am";
      if (key === "*") {
        menu = "main";
        prompt = isAm
          ? "ዋና ማውጫ፦ ለሰብል ምክሮች 1 ይጫኑ፣ ለአየር ሁኔታ መረጃ 2 ይጫኑ፣ ለአደጋ ጥንቃቄ 3 ይጫኑ።"
          : "Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (key === "1") {
        prompt = isAm
          ? "የስንዴ ዋግ በሽታ ማስጠንቀቂያ፦ ከፍተኛ የፈንገስ ስርጭት ስጋት አለ። የጠዋት ጤዛ ከመድረቁ በፊት ፀረ-ፈንገስ መድኃኒት ይርጩ። ወደ ዋናው ማውጫ ለመመለስ * ይጫኑ።"
          : "Wheat Rust Warning: High probability of fungal growth. Ensure chemical treatment is applied before morning dew. Press * to return to Main Menu.";
      } else if (key === "2") {
        prompt = isAm
          ? "የበቆሎ መስኖ ምክሮች፦ ሰብሎችን በማታ ወይም ማለዳ በመስኖ ያጠጡ። በቀትር ፀሐይ ወቅት ማጠጣት አይመከርም። ወደ ዋናው ማውጫ ለመመለስ * ይጫኑ።"
          : "Maize irrigation tips: Drip irrigate crops during evenings. Avoid midday watering. Press * to return to Main Menu.";
      } else {
        prompt = isAm
          ? "ልክ ያልሆነ ምርጫ። 1 ወይም 2 ይጫኑ፣ ወይም * ወደ ዋና ማውጫ ይመለሱ።"
          : "Invalid selection. Press 1 for wheat, 2 for maize, or * to return to the main menu.";
      }
    } else if (menu === "alerts" || menu === "weather") {
      const isAm = sessionAny.lang === "am";
      if (key === "*") {
        menu = "main";
        prompt = isAm
          ? "ዋና ማውጫ፦ ለሰብል ምክሮች 1 ይጫኑ፣ ለአየር ሁኔታ መረጃ 2 ይጫኑ፣ ለአደጋ ጥንቃቄ 3 ይጫኑ።"
          : "Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.";
      } else if (menu === "alerts" && key === "1") {
        prompt = isAm
          ? "የማንቂያ ቅንብር በማስመሰያው ውስጥ ተመርጧል፤ ምንም ቅንብር አልተቀየረም። * ወደ ዋናው ማውጫ።"
          : "Simulation only: SMS alerts would be enabled; no preference was changed. Press * to return.";
      } else if (menu === "alerts" && key === "2") {
        prompt = isAm
          ? "የማንቂያ ቅንብር በማስመሰያው ውስጥ ተመርጧል፤ ምንም ቅንብር አልተቀየረም። * ወደ ዋናው ማውጫ።"
          : "Simulation only: SMS alerts would be disabled; no preference was changed. Press * to return.";
      } else if (menu === "alerts") {
        prompt = isAm
          ? "ልክ ያልሆነ ምርጫ። 1 ለማብራት፣ 2 ለማጥፋት ይጫኑ።"
          : "Invalid selection. Press 1 to enable or 2 to disable alerts (simulated only).";
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
