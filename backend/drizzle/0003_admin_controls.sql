ALTER TABLE "users"
ADD COLUMN IF NOT EXISTS "status" text DEFAULT 'PENDING_APPROVAL' NOT NULL;

ALTER TABLE "users"
ADD COLUMN IF NOT EXISTS "active" boolean DEFAULT true NOT NULL;

CREATE TABLE IF NOT EXISTS "audit_logs" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid () NOT NULL,
    "actor_id" text NOT NULL,
    "actor_role" text NOT NULL,
    "action" text NOT NULL,
    "target_type" text NOT NULL,
    "target_id" text,
    "details" text,
    "created_at" timestamp
    with
        time zone DEFAULT now() NOT NULL
);