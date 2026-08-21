"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsService = void 0;
const sms_simulator_1 = require("./sms.simulator");
class SmsService {
    simulator;
    constructor(simulator = new sms_simulator_1.SmsSimulator()) {
        this.simulator = simulator;
    }
    send(payload) {
        return this.simulator.send(payload);
    }
    updateStatus(id, status) {
        return this.simulator.updateStatus(id, status);
    }
}
exports.SmsService = SmsService;
