ALTER TABLE "farmers" ADD COLUMN "full_name" text;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "phone" text;--> statement-breakpoint
ALTER TABLE "farmers" ADD COLUMN "registered_by" uuid;--> statement-breakpoint
ALTER TABLE "farmers" ADD CONSTRAINT "farmers_registered_by_users_id_fk" FOREIGN KEY ("registered_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;