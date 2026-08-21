import assert from "node:assert/strict";
import test from "node:test";
import { assertTransition, canTransition } from "../content.workflow.js";
import type { ContentStatus } from "../content.types.js";

test("allows the valid content workflow transitions", () => {
  const validTransitions: Array<[ContentStatus, ContentStatus]> = [
    ["DRAFT", "IN_REVIEW"],
    ["IN_REVIEW", "APPROVED"],
    ["IN_REVIEW", "REJECTED"],
    ["REJECTED", "DRAFT"],
    ["REJECTED", "IN_REVIEW"],
    ["APPROVED", "PUBLISHED"],
    ["PUBLISHED", "ARCHIVED"],
  ];

  for (const [from, to] of validTransitions) {
    assert.equal(canTransition(from, to), true);
    assert.doesNotThrow(() => assertTransition(from, to));
  }
});

test("rejects invalid content workflow transitions", () => {
  const invalidTransitions: Array<[ContentStatus, ContentStatus]> = [
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
    assert.equal(canTransition(from, to), false);
    assert.throws(() => assertTransition(from, to), /Invalid content status transition/);
  }
});
