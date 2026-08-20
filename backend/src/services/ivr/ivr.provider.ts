import type { IvrCall, IvrCallPayload, IvrCallStatus } from "./ivr.types";

export interface IvrProviderContract {
  createCall(payload: IvrCallPayload): IvrCall;
  updateCallStatus(id: string, status: IvrCallStatus): IvrCall;
}
