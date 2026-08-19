import type { IvrCall, IvrCallPayload, IvrCallStatus, IvrProvider } from "./ivr.types";

export class IvrSimulator implements IvrProvider {
  private calls = new Map<string, IvrCall>();

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

  private makeId(): string {
    return `ivr_${Math.random().toString(36).slice(2, 10)}`;
  }
}
