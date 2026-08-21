"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleUssdCallback = handleUssdCallback;
const ussd_service_1 = require("./ussd.service");
const ussdService = new ussd_service_1.UssdSessionService();
function handleUssdCallback(req, res) {
    const payload = req.body ?? {};
    const sessionId = typeof payload.sessionId === 'string' ? payload.sessionId : '';
    const serviceCode = typeof payload.serviceCode === 'string' ? payload.serviceCode : '';
    const phoneNumber = typeof payload.phoneNumber === 'string' ? payload.phoneNumber : '';
    const text = typeof payload.text === 'string' ? payload.text : '';
    if (!sessionId || !serviceCode || !phoneNumber) {
        res.status(400).type('text/plain').send('END Invalid USSD callback payload.');
        return;
    }
    const response = ussdService.handleRequest({
        sessionId,
        serviceCode,
        phoneNumber,
        text,
    });
    res.type('text/plain').send(response);
}
