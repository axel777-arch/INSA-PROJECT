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
(0, node_test_1.default)('ContentService: createDraft creates a valid draft item', () => {
    const service = new content_service_1.ContentService();
    const draft = service.createDraft({
        title: 'Maize irrigation advice',
        body: 'Use early morning watering for maize.',
        category: 'crop-care',
        createdBy: 'user-1',
    });
    strict_1.default.equal(draft.status, content_service_1.ContentStatus.DRAFT);
    strict_1.default.equal(draft.title, 'Maize irrigation advice');
    strict_1.default.equal(draft.category, 'crop-care');
    strict_1.default.equal(typeof draft.id, 'string');
});
(0, node_test_1.default)('ContentService: submitForReview rejects invalid transitions', () => {
    const service = new content_service_1.ContentService();
    const draft = service.createDraft({
        title: 'Test',
        body: 'Body',
        createdBy: 'user-1',
    });
    const submitted = service.submitForReview(draft);
    strict_1.default.equal(submitted.status, content_service_1.ContentStatus.IN_REVIEW);
    strict_1.default.throws(() => service.submitForReview(submitted), /cannot move from/);
});
(0, node_test_1.default)('TargetingService: blocks farmers with disabled alerts', () => {
    const service = new targeting_service_1.TargetingService();
    const farmers = [
        { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
        { id: 'f2', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
    ];
    const matches = service.findTargetFarmers({
        cropName: 'Maize',
        location: 'OROMIA',
        language: 'am',
        farmers,
    });
    strict_1.default.deepEqual(matches.map((farmer) => farmer.id), ['f1']);
});
(0, node_test_1.default)('TargetingService: returns unique matches only once', () => {
    const service = new targeting_service_1.TargetingService();
    const farmers = [
        { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize', 'Maize'] },
        { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
        { id: 'f2', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
    ];
    const matches = service.findTargetFarmers({
        cropName: 'Maize',
        location: 'OROMIA',
        language: 'am',
        farmers,
    });
    strict_1.default.deepEqual(matches.map((farmer) => farmer.id), ['f1', 'f2']);
});
(0, node_test_1.default)('SmsSimulator: queued SMS can advance to sent and delivered states', () => {
    const simulator = new sms_simulator_1.SmsSimulator();
    const message = simulator.send({ recipient: '+251911000111', message: 'Soil moisture update' });
    strict_1.default.equal(message.status, 'QUEUED');
    const sent = simulator.updateStatus(message.id, 'SENT');
    const delivered = simulator.updateStatus(sent.id, 'DELIVERED');
    strict_1.default.equal(sent.status, 'SENT');
    strict_1.default.equal(delivered.status, 'DELIVERED');
});
(0, node_test_1.default)('SmsSimulator: invalid SMS transition is rejected', () => {
    const simulator = new sms_simulator_1.SmsSimulator();
    const message = simulator.send({ recipient: '+251911000222', message: 'Late update' });
    strict_1.default.throws(() => simulator.updateStatus(message.id, 'DELIVERED'), /invalid/i);
});
(0, node_test_1.default)('IvrSimulator: creates a queued call and allows valid progress', () => {
    const simulator = new ivr_simulator_1.IvrSimulator();
    const call = simulator.createCall({ farmerId: 'farmer-1', phone: '+251911000333' });
    strict_1.default.equal(call.status, 'QUEUED');
    const started = simulator.updateCallStatus(call.id, 'IN_PROGRESS');
    const completed = simulator.updateCallStatus(started.id, 'COMPLETED');
    strict_1.default.equal(started.status, 'IN_PROGRESS');
    strict_1.default.equal(completed.status, 'COMPLETED');
});
(0, node_test_1.default)('IvrSimulator: invalid IVR call transition is rejected', () => {
    const simulator = new ivr_simulator_1.IvrSimulator();
    const call = simulator.createCall({ farmerId: 'farmer-2', phone: '+251911000444' });
    strict_1.default.throws(() => simulator.updateCallStatus(call.id, 'COMPLETED'), /invalid/i);
});
