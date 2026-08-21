"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const crop_routes_1 = __importDefault(require("./modules/crops/crop.routes"));
const farmer_routes_1 = __importDefault(require("./modules/farmers/farmer.routes"));
const messaging_routes_1 = __importDefault(require("./modules/messaging/messaging.routes"));
const targeting_controller_1 = require("./services/targeting/targeting.controller");
const ussd_controller_1 = require("./services/ussd/ussd.controller");
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.get("/", (_req, res) => {
    res.json({
        message: "Agri-Insight Beacon API is running",
    });
});
app.use("/api/crops", crop_routes_1.default);
app.use("/api/farmers", farmer_routes_1.default);
app.post('/api/ussd', ussd_controller_1.handleUssdCallback);
app.use('/api/messaging', messaging_routes_1.default);
app.post('/api/targeting/match', targeting_controller_1.matchFarmers);
exports.default = app;
