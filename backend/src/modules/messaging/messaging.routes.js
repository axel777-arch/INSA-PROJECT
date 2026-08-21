"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const message_controller_1 = require("./message.controller");
const router = (0, express_1.Router)();
router.post('/sms', message_controller_1.createSmsMessage);
exports.default = router;
