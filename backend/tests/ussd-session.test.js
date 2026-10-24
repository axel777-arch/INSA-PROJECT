"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const node_test_1 = __importDefault(require("node:test"));
const strict_1 = __importDefault(require("node:assert/strict"));
const ussd_service_1 = require("../src/services/ussd/ussd.service");
(0, node_test_1.default)('UssdSessionService: welcome menu is returned for a new session', () => {
    const service = new ussd_service_1.UssdSessionService();
    const response = service.handleRequest({
        sessionId: 'sess-1',
        serviceCode: '*123#',
        phoneNumber: '+251911000001',
        text: '',
    });
    strict_1.default.match(response, /Welcome to Agri-Insight Beacon/i);
    strict_1.default.match(response, /1\. My profile/i);
    strict_1.default.equal(service.getSession('sess-1')?.currentStep, 'welcome');
});
(0, node_test_1.default)('UssdSessionService: selecting crop menu advances session state', () => {
    const service = new ussd_service_1.UssdSessionService();
    service.handleRequest({
        sessionId: 'sess-2',
        serviceCode: '*123#',
        phoneNumber: '+251911000002',
        text: '',
    });
    const cropResponse = service.handleRequest({
        sessionId: 'sess-2',
        serviceCode: '*123#',
        phoneNumber: '+251911000002',
        text: '2',
    });
    strict_1.default.match(cropResponse, /Select crop/i);
    strict_1.default.match(cropResponse, /Maize/i);
    strict_1.default.equal(service.getSession('sess-2')?.currentStep, 'crop');
});
(0, node_test_1.default)('UssdSessionService: invalid input returns fallback message', () => {
    const service = new ussd_service_1.UssdSessionService();
    const response = service.handleRequest({
        sessionId: 'sess-3',
        serviceCode: '*123#',
        phoneNumber: '+251911000003',
        text: '99',
    });
    strict_1.default.match(response, /Invalid selection/i);
});
