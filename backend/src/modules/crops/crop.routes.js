"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const crop_controller_1 = require("./crop.controller");
const router = (0, express_1.Router)();
router.get("/", crop_controller_1.getCrops);
router.post("/", crop_controller_1.createCropHandler);
exports.default = router;
