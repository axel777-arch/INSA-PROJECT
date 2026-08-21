"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.matchFarmers = matchFarmers;
const database_1 = require("../../config/database");
const targeting_service_1 = require("./targeting.service");
const targetingService = new targeting_service_1.TargetingService();
async function matchFarmers(req, res) {
    const payload = req.body ?? {};
    const cropName = typeof payload.cropName === 'string' ? payload.cropName : '';
    const location = typeof payload.location === 'string' ? payload.location : '';
    const language = typeof payload.language === 'string' ? payload.language : '';
    const farmers = Array.isArray(payload.farmers) ? payload.farmers : [];
    if (!cropName || !location || !language) {
        res.status(400).json({ error: 'cropName, location, and language are required.' });
        return;
    }
    let matches;
    if (farmers.length > 0) {
        matches = targetingService.findTargetFarmers({ cropName, location, language, farmers });
    }
    else if (database_1.db) {
        matches = await targetingService.findTargetFarmersFromDb({ cropName, location, language, db: database_1.db });
    }
    else {
        matches = [];
    }
    res.status(200).json({ matches });
}
