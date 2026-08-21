"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.contentReviews = exports.reviewDecisionEnum = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
const content_1 = require("./content");
exports.reviewDecisionEnum = (0, pg_core_1.pgEnum)("review_decision", [
    "APPROVED",
    "REJECTED",
]);
exports.contentReviews = (0, pg_core_1.pgTable)("content_reviews", {
    id: (0, pg_core_1.uuid)("id").primaryKey().defaultRandom(),
    contentId: (0, pg_core_1.uuid)("content_id")
        .notNull()
        .references(() => content_1.content.id),
    // Future FK to users.id — left as a plain UUID until that schema is finalized
    reviewerId: (0, pg_core_1.uuid)("reviewer_id").notNull(),
    decision: (0, exports.reviewDecisionEnum)("decision").notNull(),
    comment: (0, pg_core_1.text)("comment"),
    createdAt: (0, pg_core_1.timestamp)("created_at", { withTimezone: true }).notNull().defaultNow(),
});
