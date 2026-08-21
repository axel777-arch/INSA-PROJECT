"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.farmerRouter = void 0;
const express_1 = require("express");
const farmer_controller_1 = require("./farmer.controller");
const router = (0, express_1.Router)();
exports.farmerRouter = router;
// Farmer profile endpoints
router.post("/", farmer_controller_1.createFarmerHandler);
router.get("/", farmer_controller_1.listFarmersHandler);
router.get("/:id", farmer_controller_1.getFarmerByIdHandler);
router.patch("/:id", farmer_controller_1.updateFarmerHandler);
// Farmer-crop relationship endpoints
router.post("/:id/crops", farmer_controller_1.addCropToFarmerHandler);
router.get("/:id/crops", farmer_controller_1.getFarmerCropsHandler);
exports.default = router;
