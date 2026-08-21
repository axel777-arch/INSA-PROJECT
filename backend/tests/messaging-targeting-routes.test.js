"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const node_test_1 = __importDefault(require("node:test"));
const strict_1 = __importDefault(require("node:assert/strict"));
const node_events_1 = require("node:events");
const node_http_1 = __importDefault(require("node:http"));
const app_1 = __importDefault(require("../src/app"));
(0, node_test_1.default)('Messaging route: POST /api/messaging/sms returns a queued SMS response', async () => {
    const server = app_1.default.listen(0);
    await (0, node_events_1.once)(server, 'listening');
    const address = server.address();
    const port = typeof address === 'object' && address ? address.port : 0;
    try {
        const response = await new Promise((resolve, reject) => {
            const payload = JSON.stringify({
                recipient: '+251911000111',
                message: 'Irrigation update',
                createdBy: 'operator-1',
                contentId: 'content-1',
            });
            const req = node_http_1.default.request({
                hostname: '127.0.0.1',
                port,
                path: '/api/messaging/sms',
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(payload),
                },
            }, (res) => {
                const chunks = [];
                res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
                res.on('end', () => resolve({
                    statusCode: res.statusCode ?? 0,
                    body: Buffer.concat(chunks).toString('utf8'),
                }));
            });
            req.on('error', reject);
            req.write(payload);
            req.end();
        });
        strict_1.default.equal(response.statusCode, 201);
        strict_1.default.match(response.body, /QUEUED|queued/i);
    }
    finally {
        server.close();
    }
});
(0, node_test_1.default)('Targeting route: POST /api/targeting/match returns matching farmers only', async () => {
    const server = app_1.default.listen(0);
    await (0, node_events_1.once)(server, 'listening');
    const address = server.address();
    const port = typeof address === 'object' && address ? address.port : 0;
    try {
        const response = await new Promise((resolve, reject) => {
            const payload = JSON.stringify({
                cropName: 'Maize',
                location: 'OROMIA',
                language: 'am',
                farmers: [
                    { id: 'f1', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
                    { id: 'f2', preferredLanguage: 'en', region: 'OROMIA', alertEnabled: true, cropNames: ['Maize'] },
                    { id: 'f3', preferredLanguage: 'am', region: 'ADDIS ABABA', alertEnabled: true, cropNames: ['Maize'] },
                    { id: 'f4', preferredLanguage: 'am', region: 'OROMIA', alertEnabled: false, cropNames: ['Maize'] },
                ],
            });
            const req = node_http_1.default.request({
                hostname: '127.0.0.1',
                port,
                path: '/api/targeting/match',
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(payload),
                },
            }, (res) => {
                const chunks = [];
                res.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
                res.on('end', () => resolve({
                    statusCode: res.statusCode ?? 0,
                    body: Buffer.concat(chunks).toString('utf8'),
                }));
            });
            req.on('error', reject);
            req.write(payload);
            req.end();
        });
        strict_1.default.equal(response.statusCode, 200);
        strict_1.default.match(response.body, /f1/i);
        strict_1.default.doesNotMatch(response.body, /f2|f3|f4/i);
    }
    finally {
        server.close();
    }
});
