"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.matchesCrop = matchesCrop;
function matchesCrop(farmer, cropName) {
    const targetCrop = cropName.trim().toLowerCase();
    return (farmer.cropNames ?? []).some((crop) => crop.trim().toLowerCase() === targetCrop);
}
