export type SmsStatus = "QUEUED" | "SENT" | "DELIVERED" | "FAILED";

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
