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
(0, node_test_1.default)('USSD callback endpoint returns the welcome menu for a new session', async () => {
    const server = app_1.default.listen(0);
    await (0, node_events_1.once)(server, 'listening');
    const address = server.address();
    const port = typeof address === 'object' && address ? address.port : 0;
    try {
        const response = await new Promise((resolve, reject) => {
            const payload = JSON.stringify({
                sessionId: 'ussd-callback-1',
                serviceCode: '*123#',
                phoneNumber: '+251911000001',
                text: '',
            });
            const req = node_http_1.default.request({
                hostname: '127.0.0.1',
                port,
                path: '/api/ussd',
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
        strict_1.default.match(response.body, /Welcome to Agri-Insight Beacon/i);
        strict_1.default.match(response.body, /1\. My profile/i);
    }
    finally {
        server.close();
    }
});
(0, node_test_1.default)('USSD callback endpoint advances the session for crop selection', async () => {
    const server = app_1.default.listen(0);
    await (0, node_events_1.once)(server, 'listening');
    const address = server.address();
    const port = typeof address === 'object' && address ? address.port : 0;
    try {
        const firstRequest = await new Promise((resolve, reject) => {
            const payload = JSON.stringify({
                sessionId: 'ussd-callback-2',
                serviceCode: '*123#',
                phoneNumber: '+251911000002',
                text: '',
            });
            const req = node_http_1.default.request({
                hostname: '127.0.0.1',
                port,
                path: '/api/ussd',
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
        strict_1.default.match(firstRequest.body, /Welcome to Agri-Insight Beacon/i);
        const secondRequest = await new Promise((resolve, reject) => {
            const payload = JSON.stringify({
                sessionId: 'ussd-callback-2',
                serviceCode: '*123#',
                phoneNumber: '+251911000002',
                text: '2',
            });
            const req = node_http_1.default.request({
                hostname: '127.0.0.1',
                port,
                path: '/api/ussd',
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
        strict_1.default.equal(secondRequest.statusCode, 200);
        strict_1.default.match(secondRequest.body, /Select crop/i);
        strict_1.default.match(secondRequest.body, /Maize/i);
    }
    finally {
        server.close();
    }
});
