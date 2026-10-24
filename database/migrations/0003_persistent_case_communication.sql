ALTER TABLE "cases"
  ADD COLUMN "creator_id" uuid,
  ADD COLUMN "assigned_to" uuid,
  ADD COLUMN "category" text DEFAULT 'GENERAL' NOT NULL,
  ADD COLUMN "priority" text DEFAULT 'NORMAL' NOT NULL,
  ADD COLUMN "source" text DEFAULT 'FARMER_QUESTION' NOT NULL,
  ADD COLUMN "observation_date" date,
  ADD COLUMN "preferred_response_language" text,
  ADD COLUMN "resolution_summary" text,
  ADD COLUMN "attachments" text;
--> statement-breakpoint
ALTER TABLE "content"
  ADD COLUMN "target_region" text,
  ADD COLUMN "target_zone" text,
  ADD COLUMN "target_woreda" text,
  ADD COLUMN "target_kebele" text,
  ADD COLUMN "target_language" text;
--> statement-breakpoint
ALTER TABLE "messages" ADD COLUMN "content_id" uuid;
--> statement-breakpoint
ALTER TABLE "messages"
  ADD CONSTRAINT "messages_content_id_content_id_fk" FOREIGN KEY ("content_id") REFERENCES "content"("id") ON DELETE SET NULL;
--> statement-breakpoint
CREATE UNIQUE INDEX "messages_content_channel_unique"
  ON "messages" ("content_id", "channel")
  WHERE "content_id" IS NOT NULL;
--> statement-breakpoint
UPDATE "cases" SET "status" = 'IN_PROGRESS' WHERE "status" = 'IN_REVIEW';
--> statement-breakpoint
ALTER TABLE "cases"
  ADD CONSTRAINT "cases_creator_id_users_id_fk" FOREIGN KEY ("creator_id") REFERENCES "users"("id") ON DELETE SET NULL,
  ADD CONSTRAINT "cases_assigned_to_users_id_fk" FOREIGN KEY ("assigned_to") REFERENCES "users"("id") ON DELETE SET NULL;
--> statement-breakpoint
CREATE TABLE "case_events" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "case_id" uuid NOT NULL REFERENCES "cases"("id") ON DELETE CASCADE,
  "actor_id" uuid REFERENCES "users"("id") ON DELETE SET NULL,
  "event_type" text NOT NULL,
  "details" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "case_events_case_created_at_idx" ON "case_events" ("case_id", "created_at");
--> statement-breakpoint
CREATE TABLE "case_messages" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "case_id" uuid NOT NULL REFERENCES "cases"("id") ON DELETE CASCADE,
  "sender_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "recipient_id" uuid REFERENCES "users"("id") ON DELETE SET NULL,
  "body" text NOT NULL,
  "visibility" text DEFAULT 'INTERNAL' NOT NULL,
  "attachments" text,
  "read_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "case_messages_case_created_at_idx" ON "case_messages" ("case_id", "created_at");
--> statement-breakpoint
CREATE TABLE "notifications" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "recipient_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "event_type" text NOT NULL,
  "resource_type" text NOT NULL,
  "resource_id" text NOT NULL,
  "title" text NOT NULL,
  "body" text NOT NULL,
  "route" text NOT NULL,
  "read_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "notifications_recipient_created_at_idx" ON "notifications" ("recipient_id", "created_at");
--> statement-breakpoint
CREATE UNIQUE INDEX "notifications_resource_event_unique"
  ON "notifications" ("recipient_id", "event_type", "resource_type", "resource_id");
--> statement-breakpoint
DELETE FROM "message_recipients" a
USING "message_recipients" b
WHERE a."message_id" = b."message_id"
  AND a."farmer_id" = b."farmer_id"
  AND a."id" > b."id";
--> statement-breakpoint
ALTER TABLE "message_recipients"
  ADD COLUMN "delivery_mode" text DEFAULT 'SIMULATED' NOT NULL,
  ADD COLUMN "failure_reason" text,
  ADD COLUMN "delivered_at" timestamp with time zone;
--> statement-breakpoint
CREATE UNIQUE INDEX "message_recipients_message_farmer_unique"
  ON "message_recipients" ("message_id", "farmer_id");
