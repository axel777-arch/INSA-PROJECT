import assert from "node:assert/strict";
import test from "node:test";
import { assertTransition, canTransition } from "../content.workflow";
import type { ContentStatus } from "../content.types";

test("allows all valid content workflow lifecycle transitions", () => {
  const validTransitions: Array<[ContentStatus, ContentStatus]> = [
    ["DRAFT", "PENDING_REVIEW"],
    ["PENDING_REVIEW", "APPROVED"],
    ["PENDING_REVIEW", "NEEDS_REVISION"],
    ["PENDING_REVIEW", "REJECTED"],
    ["NEEDS_REVISION", "DRAFT"],
    ["NEEDS_REVISION", "PENDING_REVIEW"],
    ["REJECTED", "DRAFT"],
    ["REJECTED", "PENDING_REVIEW"],
    ["APPROVED", "PUBLISHED"],
    ["APPROVED", "ARCHIVED"],
    ["PUBLISHED", "ARCHIVED"],
  ];

  for (const [from, to] of validTransitions) {
    assert.equal(
      canTransition(from, to),
      true,
      `Expected transition ${from} -> ${to} to be allowed`
    );
    assert.doesNotThrow(() => assertTransition(from, to));
  }
});

test("handles status normalization aliases gracefully", () => {
  assert.equal(canTransition("IN_REVIEW", "APPROVED"), true);
  assert.equal(canTransition("IN_REVIEW", "REVISION_REQUESTED"), true);
  assert.equal(canTransition("REVISION_NEEDED", "PENDING_REVIEW"), true);
  assert.equal(canTransition("draft", "pending-review"), true);
});

test("rejects invalid content workflow transitions", () => {
  const invalidTransitions: Array<[ContentStatus, ContentStatus]> = [
    ["DRAFT", "APPROVED"],
    ["DRAFT", "PUBLISHED"],
    ["DRAFT", "ARCHIVED"],
    ["PENDING_REVIEW", "PUBLISHED"],
    ["PENDING_REVIEW", "DRAFT"],
    ["PENDING_REVIEW", "ARCHIVED"],
    ["APPROVED", "REJECTED"],
    ["APPROVED", "NEEDS_REVISION"],
    ["PUBLISHED", "DRAFT"],
    ["PUBLISHED", "PENDING_REVIEW"],
    ["PUBLISHED", "APPROVED"],
    ["ARCHIVED", "DRAFT"],
    ["ARCHIVED", "PUBLISHED"],
    ["ARCHIVED", "APPROVED"],
  ];

  for (const [from, to] of invalidTransitions) {
    assert.equal(
      canTransition(from, to),
      false,
      `Expected transition ${from} -> ${to} to be blocked`
    );
    assert.throws(
      () => assertTransition(from, to),
      /Invalid content status transition/
    );
  }
});
