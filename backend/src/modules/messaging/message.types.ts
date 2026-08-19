export type MessageChannel = "SMS" | "IVR";

export type MessageStatus = "QUEUED" | "SENT" | "DELIVERED" | "FAILED";

export type MessageRecord = {
  id: string;
  contentId: string;
  channel: MessageChannel;
  status: MessageStatus;
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
};

export type CreateMessageInput = {
  contentId: string;
  channel: MessageChannel;
  createdBy: string;
  farmerIds?: string[];
};
