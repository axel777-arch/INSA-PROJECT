ALTER TYPE "public"."content_status" ADD VALUE 'NEEDS_REVISION' BEFORE 'APPROVED';--> statement-breakpoint
ALTER TYPE "public"."content_status" ADD VALUE 'ARCHIVED';--> statement-breakpoint
CREATE TABLE "content_versions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"content_id" uuid NOT NULL,
	"version_number" integer NOT NULL,
	"title" text NOT NULL,
	"summary" text,
	"body" text NOT NULL,
	"crop_id" uuid,
	"category" text,
	"language" text DEFAULT 'en' NOT NULL,
	"region" text,
	"zone" text,
	"woreda" text,
	"kebele" text,
	"season" text,
	"crop_stage" text,
	"priority" text DEFAULT 'NORMAL' NOT NULL,
	"valid_from" timestamp with time zone,
	"valid_until" timestamp with time zone,
	"source_info" text,
	"attachments" text,
	"status_at_version" text NOT NULL,
	"author_id" uuid,
	"change_summary" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "summary" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "language" text DEFAULT 'en' NOT NULL;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "region" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "zone" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "woreda" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "kebele" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "season" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "crop_stage" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "priority" text DEFAULT 'NORMAL' NOT NULL;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "valid_from" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "valid_until" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "source_info" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "attachments" text;--> statement-breakpoint
ALTER TABLE "content" ADD COLUMN "version" integer DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE "content_versions" ADD CONSTRAINT "content_versions_content_id_content_id_fk" FOREIGN KEY ("content_id") REFERENCES "public"."content"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "content_versions" ADD CONSTRAINT "content_versions_crop_id_crops_id_fk" FOREIGN KEY ("crop_id") REFERENCES "public"."crops"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "content_versions" ADD CONSTRAINT "content_versions_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;