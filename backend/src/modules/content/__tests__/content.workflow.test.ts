import assert from "node:assert/strict";
import test from "node:test";
import { assertTransition, canTransition } from "../content.workflow.js";
import type { ContentStatus } from "../content.types.js";

test("allows the valid content workflow transitions", () => {
  const validTransitions: Array<[ContentStatus, ContentStatus]> = [
    ["DRAFT", "PENDING_REVIEW"],
    ["PENDING_REVIEW", "APPROVED"],
    ["PENDING_REVIEW", "REJECTED"],
    ["REJECTED", "DRAFT"],
    ["REJECTED", "PENDING_REVIEW"],
    ["APPROVED", "PUBLISHED"],
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
    ["PENDING_REVIEW", "PUBLISHED"],
    ["PENDING_REVIEW", "DRAFT"],
    ["APPROVED", "REJECTED"],
    ["PUBLISHED", "DRAFT"],
  ];

  for (const [from, to] of invalidTransitions) {
    assert.equal(canTransition(from, to), false);
    assert.throws(() => assertTransition(from, to), /Invalid content status transition/);
  }
});
