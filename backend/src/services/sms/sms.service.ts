import { SmsSimulator } from "./sms.simulator";
import type { SmsMessage, SmsSendPayload, SmsStatus } from "./sms.types";

export class SmsService {
  constructor(private readonly simulator = new SmsSimulator()) {}

  send(payload: SmsSendPayload): SmsMessage {
    return this.simulator.send(payload);
  }

  updateStatus(id: string, status: SmsStatus): SmsMessage {
    return this.simulator.updateStatus(id, status);
  }
}
