export type IvrCallStatus = "QUEUED" | "IN_PROGRESS" | "COMPLETED" | "FAILED" | "CANCELLED";

export type IvrCall = {
  id: string;
  farmerId: string;
  phone: string;
  status: IvrCallStatus;
  createdAt: Date;
  updatedAt: Date;
};

export type IvrCallPayload = {
  farmerId: string;
  phone: string;
};

export interface IvrProvider {
  createCall(payload: IvrCallPayload): IvrCall;
  updateCallStatus(id: string, status: IvrCallStatus): IvrCall;
}
