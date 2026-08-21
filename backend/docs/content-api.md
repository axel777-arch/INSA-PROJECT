# Content API Contracts

## Overview

The Content API manages agricultural content through a controlled review and publishing workflow.

### Content Workflow

```text
DRAFT → IN_REVIEW → APPROVED → PUBLISHED → ARCHIVED

DRAFT → IN_REVIEW → REJECTED
REJECTED → DRAFT
1. Create Content
Endpoint

POST /api/content

Creates a new agricultural content item.

Initial Status

DRAFT

Request Body
{
  "title": "Example agricultural information",
  "body": "Agricultural information for farmers.",
  "cropId": "optional-uuid",
  "language": "en",
  "location": "Addis Ababa"
}

The authenticated user's ID is used as createdBy.

2. List Content
Endpoint

GET /api/content

Returns content items and supports filtering by content status, crop, language, and location.

Query Parameters
status
cropId
language
location
3. Get Content
Endpoint

GET /api/content/:id

Returns a single content item by ID.

4. Update Content
Endpoint

PATCH /api/content/:id

Updates an existing content item.

Content can only be edited while in:

DRAFT
REJECTED

When rejected content is edited, its status returns to:

REJECTED → DRAFT

5. Submit for Review
Endpoint

POST /api/content/:id/submit-review

Permission

content:submit-review

Status Transition
DRAFT → IN_REVIEW

Submits draft content for expert review.

6. Approve Content
Endpoint

POST /api/content/:id/approve

Permission

content:approve

Status Transition
IN_REVIEW → APPROVED

The authenticated reviewer is recorded as the approver.

An approval review record is created.

7. Reject Content
Endpoint

POST /api/content/:id/reject

Permission

content:reject

Status Transition
IN_REVIEW → REJECTED
Request Body
{
  "comment": "Please provide more specific agricultural information."
}

The rejection reason is stored in the content review record.

8. Publish Content
Endpoint

POST /api/content/:id/publish

Permission

content:publish

Status Transition
APPROVED → PUBLISHED

Only approved content can be published.

9. Archive Content
Endpoint

POST /api/content/:id/archive

Permission

content:archive

Status Transition
PUBLISHED → ARCHIVED

Archived content cannot transition to another status.

Status Transition Rules
Current Status	Allowed Next Status
DRAFT	      IN_REVIEW
IN_REVIEW	APPROVED, REJECTED
APPROVED	PUBLISHED
REJECTED	DRAFT, IN_REVIEW
PUBLISHED	ARCHIVED
ARCHIVED	None

Invalid status transitions are rejected by the content workflow.

Authorization

The following operations require specific permissions:

Operation	Permission
Submit for review	content:submit-review
Approve	content:approve
Reject	content:reject
Publish	content:publish
Archive	content:archive

The authenticated user's identity is used for author and reviewer-related fields rather than accepting those identities directly from the client.

Review Records

Approval and rejection actions create records in the content review history.

A review record contains:

Content ID
Reviewer ID
Decision
Optional rejection comment
Creation timestamp

Approval decisions use:

APPROVED

Rejection decisions use:

REJECTED



### 5. Save the file


Then run:


```bash
git status --short

You should see something like:

 M package.json
?? docs/content-api.md
?? src/modules/content/__tests__/