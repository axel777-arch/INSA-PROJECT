export type MessageChannel = "SMS" | "IVR" | "USSD";

export type MessageStatus = "QUEUED" | "SENT" | "DELIVERED" | "FAILED";

export type MessageRecord = {
  id: string;
  contentId?: string;
  title?: string | null;
  body?: string;
  channel: MessageChannel;
  status: string;
  createdBy: string;
  createdAt: Date;
  updatedAt?: Date;
};

export type CreateMessageInput = {
  contentId?: string;
  title?: string;
  body?: string;
  channel: MessageChannel;
  createdBy: string;
  farmerIds?: string[];
  recipientPhone?: string;
};

export type BroadcastMessageInput = {
  title?: string;
  body: string;
  channel?: MessageChannel;
  createdBy?: string;
  farmerIds: string[];
};

export type BroadcastResult = {
  message: {
    id: string;
    title: string | null;
    body: string;
    channel: MessageChannel;
    status: string;
    createdBy: string;
    createdAt: Date;
  };
  recipients: {
    id: string;
    messageId: string;
    farmerId: string;
    status: string;
    sentAt: Date | null;
  }[];
};
