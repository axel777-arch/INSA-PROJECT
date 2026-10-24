"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const node_test_1 = __importDefault(require("node:test"));
const strict_1 = __importDefault(require("node:assert/strict"));
const content_service_1 = require("../src/modules/content/content.service");
const targeting_service_1 = require("../src/services/targeting/targeting.service");
const sms_simulator_1 = require("../src/services/sms/sms.simulator");
const ivr_simulator_1 = require("../src/services/ivr/ivr.simulator");
(0, node_test_1.default)('content workflow enforces valid status transitions', () => {
    const service = new content_service_1.ContentService();
    strict_1.default.equal(service.canTransition(content_service_1.ContentStatus.DRAFT, content_service_1.ContentStatus.IN_REVIEW), true);
    strict_1.default.equal(service.canTransition(content_service_1.ContentStatus.IN_REVIEW, content_service_1.ContentStatus.APPROVED), true);
    strict_1.default.equal(service.canTransition(content_service_1.ContentStatus.APPROVED, content_service_1.ContentStatus.PUBLISHED), true);
    strict_1.default.equal(service.canTransition(content_service_1.ContentStatus.DRAFT, content_service_1.ContentStatus.PUBLISHED), false);
});
(0, node_test_1.default)('targeting matches farmers by crop, location and language while excluding opt-outs', () => {
    const service = new targeting_service_1.TargetingService();
    const farmers = [
        { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
        { id: 'f2', preferredLanguage: 'en', region: 'AMHARA', alertEnabled: true, cropNames: ['Wheat'] },
        { id: 'f3', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
        { id: 'f4', preferredLanguage: 'am', region: 'SNNPR', alertEnabled: true, cropNames: ['Coffee'] },
    ];
    const matches = service.findTargetFarmers({
        cropName: 'Maize',
        location: 'OROMIA',
        language: 'am',
        farmers,
    });
    strict_1.default.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
});
(0, node_test_1.default)('sms simulator records queued, sent and delivered transitions', () => {
    const simulator = new sms_simulator_1.SmsSimulator();
    const result = simulator.send({ recipient: '+251911000000', message: 'hello' });
    strict_1.default.equal(result.status, 'QUEUED');
    const sent = simulator.updateStatus(result.id, 'SENT');
    const delivered = simulator.updateStatus(sent.id, 'DELIVERED');
    strict_1.default.equal(delivered.status, 'DELIVERED');
});
(0, node_test_1.default)('ivr simulator allows valid stage transitions', () => {
    const simulator = new ivr_simulator_1.IvrSimulator();
    const call = simulator.createCall({ farmerId: 'f1', phone: '+251912000000' });
    const inProgress = simulator.updateCallStatus(call.id, 'IN_PROGRESS');
    const completed = simulator.updateCallStatus(inProgress.id, 'COMPLETED');
    strict_1.default.equal(completed.status, 'COMPLETED');
    strict_1.default.equal(simulator.canTransition('QUEUED', 'IN_PROGRESS'), true);
    strict_1.default.equal(simulator.canTransition('IN_PROGRESS', 'FAILED'), true);
    strict_1.default.equal(simulator.canTransition('COMPLETED', 'IN_PROGRESS'), false);
});
