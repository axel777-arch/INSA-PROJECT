import { IvrSimulator } from "./ivr.simulator";
import type { IvrCall, IvrCallPayload, IvrCallStatus } from "./ivr.types";

export class IvrService {
  constructor(private readonly simulator = new IvrSimulator()) {}

  createCall(payload: IvrCallPayload): IvrCall {
    return this.simulator.createCall(payload);
  }

  updateCallStatus(id: string, status: IvrCallStatus): IvrCall {
    return this.simulator.updateCallStatus(id, status);
  }
}
