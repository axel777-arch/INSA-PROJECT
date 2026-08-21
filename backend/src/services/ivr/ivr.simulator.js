"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IvrSimulator = void 0;
class IvrSimulator {
    calls = new Map();
    validTransitions = {
        QUEUED: ["IN_PROGRESS", "FAILED", "CANCELLED"],
        IN_PROGRESS: ["COMPLETED", "FAILED", "CANCELLED"],
        COMPLETED: [],
        FAILED: [],
        CANCELLED: [],
    };
    canTransition(from, to) {
        return this.validTransitions[from]?.includes(to) ?? false;
    }
    createCall(payload) {
        const now = new Date();
        const call = {
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
    updateCallStatus(id, status) {
        const current = this.calls.get(id);
        if (!current) {
            throw new Error(`IVR call ${id} was not found.`);
        }
        if (!this.canTransition(current.status, status)) {
            throw new Error(`IVR status transition from ${current.status} to ${status} is invalid.`);
        }
        const updated = {
            ...current,
            status,
            updatedAt: new Date(),
        };
        this.calls.set(id, updated);
        return updated;
    }
    makeId() {
        return `ivr_${Math.random().toString(36).slice(2, 10)}`;
    }
}
exports.IvrSimulator = IvrSimulator;
