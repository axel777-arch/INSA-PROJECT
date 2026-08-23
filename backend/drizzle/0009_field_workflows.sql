CREATE TABLE IF NOT EXISTS "crop_records" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "created_by" uuid NOT NULL REFERENCES "users"("id"),
  "crop" text NOT NULL,
  "planting_date" text NOT NULL,
  "area_hectares" numeric NOT NULL,
  "growth_stage" text NOT NULL,
  "idempotency_key" text NOT NULL UNIQUE,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS "field_observations" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "created_by" uuid NOT NULL REFERENCES "users"("id"),
  "category" text NOT NULL,
  "crop" text NOT NULL,
  "notes" text NOT NULL,
  "location" text NOT NULL,
  "questions" text DEFAULT '' NOT NULL,
  "status" text DEFAULT 'SUBMITTED' NOT NULL,
  "idempotency_key" text NOT NULL UNIQUE,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);