"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.matchesLocation = matchesLocation;
function matchesLocation(farmer, location) {
    const targetLocation = location.trim().toLowerCase();
    const farmerLocation = farmer.region.trim().toLowerCase();
    return farmerLocation === targetLocation || farmer.zone?.trim().toLowerCase() === targetLocation;
}
