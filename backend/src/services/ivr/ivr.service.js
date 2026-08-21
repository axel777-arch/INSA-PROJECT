"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IvrService = void 0;
const ivr_simulator_1 = require("./ivr.simulator");
class IvrService {
    simulator;
    constructor(simulator = new ivr_simulator_1.IvrSimulator()) {
        this.simulator = simulator;
    }
    createCall(payload) {
        return this.simulator.createCall(payload);
    }
    updateCallStatus(id, status) {
        return this.simulator.updateCallStatus(id, status);
    }
}
exports.IvrService = IvrService;
