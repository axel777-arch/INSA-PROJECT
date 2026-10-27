CREATE TABLE "farmer_worker_assignments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"farmer_id" uuid NOT NULL,
	"worker_id" uuid NOT NULL,
	"assigned_by" uuid NOT NULL,
	"effective_from" timestamp with time zone DEFAULT now() NOT NULL,
	"effective_to" timestamp with time zone,
	"note" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "farmers" DROP CONSTRAINT "farmers_user_id_users_id_fk";
--> statement-breakpoint
ALTER TABLE "farmers" ALTER COLUMN "user_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD CONSTRAINT "farmer_worker_assignments_farmer_id_farmers_id_fk" FOREIGN KEY ("farmer_id") REFERENCES "public"."farmers"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD CONSTRAINT "farmer_worker_assignments_worker_id_users_id_fk" FOREIGN KEY ("worker_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "farmer_worker_assignments" ADD CONSTRAINT "farmer_worker_assignments_assigned_by_users_id_fk" FOREIGN KEY ("assigned_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "farmer_worker_assignments_farmer_idx" ON "farmer_worker_assignments" USING btree ("farmer_id");--> statement-breakpoint
CREATE INDEX "farmer_worker_assignments_worker_idx" ON "farmer_worker_assignments" USING btree ("worker_id");--> statement-breakpoint
ALTER TABLE "farmers" ADD CONSTRAINT "farmers_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;