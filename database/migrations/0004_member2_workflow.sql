CREATE TYPE "public"."observation_severity" AS ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');--> statement-breakpoint
CREATE TYPE "public"."observation_type" AS ENUM('PEST_INFESTATION', 'DISEASE', 'WEATHER_DAMAGE', 'SOIL_ISSUE', 'GENERAL_CHECKUP');--> statement-breakpoint
CREATE TYPE "public"."follow_up_status" AS ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD COLUMN "assignment_type" text DEFAULT 'PRIMARY' NOT NULL;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD COLUMN "status" text DEFAULT 'ACTIVE' NOT NULL;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD COLUMN "reason" text;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD COLUMN "updated_at" timestamp with time zone DEFAULT now() NOT NULL;
--> statement-breakpoint
CREATE TABLE "field_observations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"farmer_id" uuid NOT NULL,
	"worker_id" uuid NOT NULL,
	"crop_id" uuid,
	"observation_type" "observation_type" DEFAULT 'GENERAL_CHECKUP' NOT NULL,
	"severity" "observation_severity" DEFAULT 'LOW' NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"action_taken" text,
	"is_escalated" boolean DEFAULT false NOT NULL,
	"escalated_to_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "observation_attachments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"observation_id" uuid NOT NULL,
	"file_url" text NOT NULL,
	"file_type" text DEFAULT 'IMAGE' NOT NULL,
	"file_name" text,
	"uploaded_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "follow_up_records" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"farmer_id" uuid NOT NULL,
	"worker_id" uuid NOT NULL,
	"observation_id" uuid,
	"scheduled_date" timestamp with time zone NOT NULL,
	"completed_date" timestamp with time zone,
	"status" "follow_up_status" DEFAULT 'PENDING' NOT NULL,
	"notes" text,
	"outcome" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "farmers" DROP CONSTRAINT "farmers_user_id_users_id_fk";
--> statement-breakpoint
ALTER TABLE "farmers" ALTER COLUMN "user_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "preferred_language" text DEFAULT 'amharic';--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "has_app_access" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "farm_size" double precision;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "experience_years" double precision;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "primary_worker_id" uuid;--> statement-breakpoint
ALTER TABLE "field_observations" ADD CONSTRAINT "field_observations_farmer_id_farmers_id_fk" FOREIGN KEY ("farmer_id") REFERENCES "public"."farmers"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "field_observations" ADD CONSTRAINT "field_observations_worker_id_users_id_fk" FOREIGN KEY ("worker_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "field_observations" ADD CONSTRAINT "field_observations_crop_id_crops_id_fk" FOREIGN KEY ("crop_id") REFERENCES "public"."crops"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "field_observations" ADD CONSTRAINT "field_observations_escalated_to_id_users_id_fk" FOREIGN KEY ("escalated_to_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "observation_attachments" ADD CONSTRAINT "observation_attachments_observation_id_field_observations_id_fk" FOREIGN KEY ("observation_id") REFERENCES "public"."field_observations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follow_up_records" ADD CONSTRAINT "follow_up_records_farmer_id_farmers_id_fk" FOREIGN KEY ("farmer_id") REFERENCES "public"."farmers"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follow_up_records" ADD CONSTRAINT "follow_up_records_worker_id_users_id_fk" FOREIGN KEY ("worker_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follow_up_records" ADD CONSTRAINT "follow_up_records_observation_id_field_observations_id_fk" FOREIGN KEY ("observation_id") REFERENCES "public"."field_observations"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "fo_farmer_idx" ON "field_observations" USING btree ("farmer_id");--> statement-breakpoint
CREATE INDEX "fo_worker_idx" ON "field_observations" USING btree ("worker_id");--> statement-breakpoint
CREATE INDEX "fo_escalated_idx" ON "field_observations" USING btree ("is_escalated");--> statement-breakpoint
CREATE INDEX "oa_observation_idx" ON "observation_attachments" USING btree ("observation_id");--> statement-breakpoint
CREATE INDEX "fur_farmer_idx" ON "follow_up_records" USING btree ("farmer_id");--> statement-breakpoint
CREATE INDEX "fur_worker_idx" ON "follow_up_records" USING btree ("worker_id");--> statement-breakpoint
CREATE INDEX "fur_status_idx" ON "follow_up_records" USING btree ("status");--> statement-breakpoint
ALTER TABLE "farmers" ADD CONSTRAINT "farmers_primary_worker_id_users_id_fk" FOREIGN KEY ("primary_worker_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "farmers" ADD CONSTRAINT "farmers_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "farmers_phone_idx" ON "farmers" USING btree ("phone");--> statement-breakpoint
CREATE INDEX "farmers_worker_idx" ON "farmers" USING btree ("primary_worker_id");
