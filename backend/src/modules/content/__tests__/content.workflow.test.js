"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const strict_1 = __importDefault(require("node:assert/strict"));
const node_test_1 = __importDefault(require("node:test"));
const content_workflow_js_1 = require("../content.workflow.js");
(0, node_test_1.default)("allows the valid content workflow transitions", () => {
    const validTransitions = [
        ["DRAFT", "IN_REVIEW"],
        ["IN_REVIEW", "APPROVED"],
        ["IN_REVIEW", "REJECTED"],
        ["REJECTED", "DRAFT"],
        ["REJECTED", "IN_REVIEW"],
        ["APPROVED", "PUBLISHED"],
        ["PUBLISHED", "ARCHIVED"],
    ];
    for (const [from, to] of validTransitions) {
        strict_1.default.equal((0, content_workflow_js_1.canTransition)(from, to), true);
        strict_1.default.doesNotThrow(() => (0, content_workflow_js_1.assertTransition)(from, to));
    }
});
(0, node_test_1.default)("rejects invalid content workflow transitions", () => {
    const invalidTransitions = [
        ["DRAFT", "APPROVED"],
        ["DRAFT", "PUBLISHED"],
        ["IN_REVIEW", "PUBLISHED"],
        ["IN_REVIEW", "DRAFT"],
        ["APPROVED", "REJECTED"],
        ["PUBLISHED", "DRAFT"],
        ["ARCHIVED", "DRAFT"],
        ["ARCHIVED", "PUBLISHED"],
    ];
    for (const [from, to] of invalidTransitions) {
        strict_1.default.equal((0, content_workflow_js_1.canTransition)(from, to), false);
        strict_1.default.throws(() => (0, content_workflow_js_1.assertTransition)(from, to), /Invalid content status transition/);
    }
});
