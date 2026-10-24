export type SmsStatus =
  | "SIMULATED_QUEUED"
  | "SIMULATED_SENT"
  | "SIMULATED_DELIVERED"
  | "SIMULATED_FAILED";

export type SmsMessage = {
  id: string;
  recipient: string;
  message: string;
  status: SmsStatus;
  createdAt: Date;
  updatedAt: Date;
};

export type SmsSendPayload = {
  recipient: string;
  message: string;
};

export interface SmsProvider {
  send(payload: SmsSendPayload): SmsMessage;
  updateStatus(id: string, status: SmsStatus): SmsMessage;
}
