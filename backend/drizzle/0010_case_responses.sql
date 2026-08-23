ALTER TABLE "field_observations"
  ADD COLUMN IF NOT EXISTS "diagnosis" text,
  ADD COLUMN IF NOT EXISTS "recommendation" text,
  ADD COLUMN IF NOT EXISTS "internal_notes" text,
  ADD COLUMN IF NOT EXISTS "photo_data" text[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS "responded_by" uuid REFERENCES "users"("id"),
  ADD COLUMN IF NOT EXISTS "responded_at" timestamp with time zone;
