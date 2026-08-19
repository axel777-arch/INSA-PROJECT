import type { SmsMessage, SmsSendPayload, SmsStatus } from "./sms.types";

export interface SmsProviderContract {
  send(payload: SmsSendPayload): SmsMessage;
  updateStatus(id: string, status: SmsStatus): SmsMessage;
}
