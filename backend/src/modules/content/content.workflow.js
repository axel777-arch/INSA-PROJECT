"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.canTransition = canTransition;
exports.assertTransition = assertTransition;
const allowedTransitions = {
    DRAFT: ["IN_REVIEW"],
    IN_REVIEW: ["APPROVED", "REJECTED"],
    APPROVED: ["PUBLISHED"],
    REJECTED: ["DRAFT", "IN_REVIEW"],
    PUBLISHED: ["ARCHIVED"],
    ARCHIVED: [],
};
function canTransition(from, to) {
    return allowedTransitions[from].includes(to);
}
function assertTransition(from, to) {
    if (!canTransition(from, to)) {
        throw new Error(`Invalid content status transition: ${from} -> ${to}`);
    }
}
