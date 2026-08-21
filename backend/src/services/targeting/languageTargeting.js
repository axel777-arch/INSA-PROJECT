"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.matchesLanguage = matchesLanguage;
function matchesLanguage(farmer, language) {
    return farmer.preferredLanguage.trim().toLowerCase() === language.trim().toLowerCase();
}
