


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."audiobook_editions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "book_id" "uuid" NOT NULL,
    "edition_type" "text" NOT NULL,
    "narrators" "text"[],
    "production_company" "text",
    "runtime_minutes" integer,
    "release_status" "text" DEFAULT 'fully_released'::"text" NOT NULL,
    "parts_released" integer,
    "parts_total" integer,
    "source_url" "text",
    "last_verified_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "audiobook_editions_edition_type_check" CHECK (("edition_type" = ANY (ARRAY['standard'::"text", 'dramatized_full_cast'::"text", 'abridged'::"text", 'other'::"text"]))),
    CONSTRAINT "audiobook_editions_release_status_check" CHECK (("release_status" = ANY (ARRAY['fully_released'::"text", 'in_progress'::"text", 'announced'::"text"])))
);


ALTER TABLE "public"."audiobook_editions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_content_warnings" (
    "book_id" "uuid" NOT NULL,
    "warning_id" "text" NOT NULL,
    "severity" "text" NOT NULL,
    "reveals_spoiler" boolean DEFAULT false NOT NULL,
    CONSTRAINT "book_content_warnings_severity_check" CHECK (("severity" = ANY (ARRAY['brief'::"text", 'moderate'::"text", 'central_theme'::"text"])))
);


ALTER TABLE "public"."book_content_warnings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_dna" (
    "book_id" "uuid" NOT NULL,
    "genre" "text"[] NOT NULL,
    "age_category" "text",
    "book_length" "text",
    "pov_count" "text",
    "person" "text",
    "narrator_reliability" "text",
    "timeline" "text",
    "form" "text",
    "overall_pace" "text",
    "pace_shape" "text",
    "drive" "text",
    "darkness" "text",
    "humor_level" "text",
    "emotional_register" "text",
    "message_intensity" "text",
    "romance_heat_frequency" "text",
    "romance_heat_intensity" "text",
    "violence_frequency" "text",
    "violence_intensity" "text",
    "worldbuilding_density" "text",
    "narrative_closure" "text",
    "emotional_resolution" "text",
    "ends_on_cliffhanger" "text",
    "narrator_performance" "text",
    "narrator_cast" "text",
    "narration_pace_vs_prose" "text",
    "accent_authenticity" "text",
    "production_quality" "text",
    "audiobook_length" "text",
    "magic_system_hardness" "text",
    "scifi_hardness" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "prose_density" "text",
    "prose_complexity" "text",
    "intellectual_weight" "text",
    "stakes_scope" "text",
    "personal_stakes" "text",
    "genre_accessibility" "text",
    "romance_tone" "text",
    "worldbuilding_delivery" "text",
    CONSTRAINT "book_dna_accent_authenticity_check" CHECK (("accent_authenticity" = ANY (ARRAY['na'::"text", 'poor'::"text", 'adequate'::"text", 'excellent'::"text"]))),
    CONSTRAINT "book_dna_age_category_check" CHECK (("age_category" = ANY (ARRAY['middle_grade'::"text", 'ya'::"text", 'new_adult'::"text", 'adult'::"text"]))),
    CONSTRAINT "book_dna_audiobook_length_check" CHECK (("audiobook_length" = ANY (ARRAY['short'::"text", 'standard'::"text", 'long'::"text", 'epic'::"text"]))),
    CONSTRAINT "book_dna_book_length_check" CHECK (("book_length" = ANY (ARRAY['short'::"text", 'standard'::"text", 'long'::"text", 'epic'::"text"]))),
    CONSTRAINT "book_dna_darkness_check" CHECK (("darkness" = ANY (ARRAY['light'::"text", 'moderate'::"text", 'dark'::"text", 'grimdark'::"text"]))),
    CONSTRAINT "book_dna_drive_check" CHECK (("drive" = ANY (ARRAY['character_driven'::"text", 'plot_driven'::"text", 'balanced'::"text", 'worldbuilding_driven'::"text", 'romance_driven'::"text"]))),
    CONSTRAINT "book_dna_emotional_register_check" CHECK (("emotional_register" = ANY (ARRAY['comfort_read'::"text", 'bittersweet'::"text", 'tense'::"text", 'gut_punch'::"text"]))),
    CONSTRAINT "book_dna_emotional_resolution_check" CHECK (("emotional_resolution" = ANY (ARRAY['happy'::"text", 'tragic'::"text", 'ambiguous'::"text", 'bittersweet'::"text"]))),
    CONSTRAINT "book_dna_ends_on_cliffhanger_check" CHECK (("ends_on_cliffhanger" = ANY (ARRAY['resolved'::"text", 'cliffhanger'::"text"]))),
    CONSTRAINT "book_dna_form_check" CHECK (("form" = ANY (ARRAY['standard_prose'::"text", 'epistolary'::"text", 'framing_device'::"text", 'verse'::"text", 'embedded_system_text'::"text", 'script_or_stage_play'::"text"]))),
    CONSTRAINT "book_dna_genre_accessibility_check" CHECK (("genre_accessibility" = ANY (ARRAY['gateway'::"text", 'accessible'::"text", 'moderate'::"text", 'demanding'::"text", 'veteran_only'::"text"]))),
    CONSTRAINT "book_dna_genre_check" CHECK (("genre" <@ ARRAY['sci_fi'::"text", 'fantasy'::"text"])),
    CONSTRAINT "book_dna_humor_level_check" CHECK (("humor_level" = ANY (ARRAY['none'::"text", 'light'::"text", 'moderate'::"text", 'heavy'::"text"]))),
    CONSTRAINT "book_dna_intellectual_weight_check" CHECK (("intellectual_weight" = ANY (ARRAY['escapist'::"text", 'moderate'::"text", 'cerebral'::"text"]))),
    CONSTRAINT "book_dna_magic_system_hardness_check" CHECK (("magic_system_hardness" = ANY (ARRAY['hard'::"text", 'soft'::"text", 'none'::"text", 'na'::"text"]))),
    CONSTRAINT "book_dna_message_intensity_check" CHECK (("message_intensity" = ANY (ARRAY['subtle'::"text", 'moderate'::"text", 'heavy_handed'::"text"]))),
    CONSTRAINT "book_dna_narration_pace_vs_prose_check" CHECK (("narration_pace_vs_prose" = ANY (ARRAY['matches'::"text", 'slower'::"text", 'faster'::"text"]))),
    CONSTRAINT "book_dna_narrative_closure_check" CHECK (("narrative_closure" = ANY (ARRAY['self_contained'::"text", 'requires_series'::"text"]))),
    CONSTRAINT "book_dna_narrator_cast_check" CHECK (("narrator_cast" = ANY (ARRAY['single_narrator'::"text", 'dual_narrator'::"text", 'full_cast'::"text"]))),
    CONSTRAINT "book_dna_narrator_performance_check" CHECK (("narrator_performance" = ANY (ARRAY['poor'::"text", 'average'::"text", 'good'::"text", 'excellent'::"text"]))),
    CONSTRAINT "book_dna_narrator_reliability_check" CHECK (("narrator_reliability" = ANY (ARRAY['reliable'::"text", 'unreliable'::"text", 'ambiguous'::"text"]))),
    CONSTRAINT "book_dna_overall_pace_check" CHECK (("overall_pace" = ANY (ARRAY['slow'::"text", 'medium'::"text", 'fast'::"text"]))),
    CONSTRAINT "book_dna_pace_shape_check" CHECK (("pace_shape" = ANY (ARRAY['consistent'::"text", 'slow_burn_to_fast_finish'::"text", 'front_loaded'::"text", 'uneven'::"text"]))),
    CONSTRAINT "book_dna_person_check" CHECK (("person" = ANY (ARRAY['first'::"text", 'second'::"text", 'third_limited'::"text", 'third_omniscient'::"text", 'mixed'::"text"]))),
    CONSTRAINT "book_dna_personal_stakes_check" CHECK (("personal_stakes" = ANY (ARRAY['low'::"text", 'moderate'::"text", 'high'::"text", 'life_threatening'::"text"]))),
    CONSTRAINT "book_dna_pov_count_check" CHECK (("pov_count" = ANY (ARRAY['single'::"text", 'dual'::"text", 'few'::"text", 'several'::"text", 'ensemble'::"text"]))),
    CONSTRAINT "book_dna_production_quality_check" CHECK (("production_quality" = ANY (ARRAY['basic'::"text", 'standard'::"text", 'high'::"text"]))),
    CONSTRAINT "book_dna_prose_complexity_check" CHECK (("prose_complexity" = ANY (ARRAY['accessible'::"text", 'moderate'::"text", 'dense'::"text"]))),
    CONSTRAINT "book_dna_prose_density_check" CHECK (("prose_density" = ANY (ARRAY['sparse'::"text", 'moderate'::"text", 'lush'::"text"]))),
    CONSTRAINT "book_dna_romance_heat_frequency_check" CHECK (("romance_heat_frequency" = ANY (ARRAY['none'::"text", 'rare'::"text", 'occasional'::"text", 'frequent'::"text"]))),
    CONSTRAINT "book_dna_romance_heat_intensity_check" CHECK (("romance_heat_intensity" = ANY (ARRAY['na'::"text", 'closed_door'::"text", 'low'::"text", 'moderate'::"text", 'explicit'::"text"]))),
    CONSTRAINT "book_dna_romance_tone_check" CHECK (("romance_tone" = ANY (ARRAY['understated'::"text", 'melodramatic'::"text", 'mixed'::"text"]))),
    CONSTRAINT "book_dna_scifi_hardness_check" CHECK (("scifi_hardness" = ANY (ARRAY['hard'::"text", 'soft'::"text", 'na'::"text"]))),
    CONSTRAINT "book_dna_stakes_scope_check" CHECK (("stakes_scope" = ANY (ARRAY['intimate'::"text", 'regional'::"text", 'global'::"text", 'cosmic'::"text"]))),
    CONSTRAINT "book_dna_timeline_check" CHECK (("timeline" = ANY (ARRAY['linear'::"text", 'nonlinear'::"text", 'multi_timeline'::"text"]))),
    CONSTRAINT "book_dna_violence_frequency_check" CHECK (("violence_frequency" = ANY (ARRAY['none'::"text", 'rare'::"text", 'occasional'::"text", 'frequent'::"text"]))),
    CONSTRAINT "book_dna_violence_intensity_check" CHECK (("violence_intensity" = ANY (ARRAY['na'::"text", 'mild'::"text", 'moderate'::"text", 'graphic'::"text", 'brutal'::"text"]))),
    CONSTRAINT "book_dna_worldbuilding_delivery_check" CHECK (("worldbuilding_delivery" = ANY (ARRAY['woven'::"text", 'exposition_dump'::"text", 'mixed'::"text"]))),
    CONSTRAINT "book_dna_worldbuilding_density_check" CHECK (("worldbuilding_density" = ANY (ARRAY['light'::"text", 'moderate'::"text", 'dense'::"text"])))
);


ALTER TABLE "public"."book_dna" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_field_confidence" (
    "book_id" "uuid" NOT NULL,
    "field_name" "text" NOT NULL,
    "confidence" numeric NOT NULL,
    "source" "text" DEFAULT 'ai_inferred'::"text" NOT NULL,
    CONSTRAINT "book_field_confidence_confidence_check" CHECK ((("confidence" >= (0)::numeric) AND ("confidence" <= (1)::numeric))),
    CONSTRAINT "book_field_confidence_source_check" CHECK (("source" = ANY (ARRAY['ai_inferred'::"text", 'verified_external'::"text", 'manual_review'::"text", 'community_tagged'::"text", 'community_confirmed'::"text"])))
);


ALTER TABLE "public"."book_field_confidence" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."book_tropes" (
    "book_id" "uuid" NOT NULL,
    "trope_id" "text" NOT NULL,
    "confidence" numeric,
    "source" "text" DEFAULT 'ai_inferred'::"text" NOT NULL,
    CONSTRAINT "book_tropes_confidence_check" CHECK ((("confidence" >= (0)::numeric) AND ("confidence" <= (1)::numeric))),
    CONSTRAINT "book_tropes_source_check" CHECK (("source" = ANY (ARRAY['ai_inferred'::"text", 'verified_external'::"text", 'manual_review'::"text", 'community_tagged'::"text", 'community_confirmed'::"text"])))
);


ALTER TABLE "public"."book_tropes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."books" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "author" "text" NOT NULL,
    "series_id" "uuid",
    "universe_id" "uuid",
    "position_in_series" numeric,
    "isbn" "text",
    "cover_url" "text",
    "synopsis" "text",
    "page_count" integer,
    "audiobook_duration_minutes" integer,
    "publication_year" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "hardcover_id" integer,
    "narrators" "text"[],
    "work_type" "text" DEFAULT 'novel'::"text" NOT NULL,
    CONSTRAINT "books_work_type_check" CHECK (("work_type" = ANY (ARRAY['novella'::"text", 'novel'::"text", 'audio_original'::"text"])))
);


ALTER TABLE "public"."books" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."content_warning_types" (
    "id" "text" NOT NULL
);


ALTER TABLE "public"."content_warning_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."rating_submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "rater_name" "text" NOT NULL,
    "book_id" "uuid" NOT NULL,
    "book_title" "text" NOT NULL,
    "rating" "text" NOT NULL,
    "submitted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "rating_submissions_rating_check" CHECK (("rating" = ANY (ARRAY['loved'::"text", 'liked'::"text", 'it_was_okay'::"text", 'disliked'::"text", 'hated'::"text"])))
);


ALTER TABLE "public"."rating_submissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."series" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "universe_id" "uuid",
    "name" "text" NOT NULL,
    "status" "text" NOT NULL,
    "book_count" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "hardcover_id" integer,
    "parent_series_id" "uuid",
    CONSTRAINT "series_status_check" CHECK (("status" = ANY (ARRAY['ongoing'::"text", 'completed'::"text", 'hiatus'::"text"])))
);


ALTER TABLE "public"."series" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tropes" (
    "id" "text" NOT NULL,
    "group_name" "text" NOT NULL,
    "spoiler" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."tropes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."universe" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."universe" OWNER TO "postgres";


ALTER TABLE ONLY "public"."audiobook_editions"
    ADD CONSTRAINT "audiobook_editions_book_source_unique" UNIQUE ("book_id", "source_url");



ALTER TABLE ONLY "public"."audiobook_editions"
    ADD CONSTRAINT "audiobook_editions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."book_content_warnings"
    ADD CONSTRAINT "book_content_warnings_pkey" PRIMARY KEY ("book_id", "warning_id");



ALTER TABLE ONLY "public"."book_dna"
    ADD CONSTRAINT "book_dna_pkey" PRIMARY KEY ("book_id");



ALTER TABLE ONLY "public"."book_field_confidence"
    ADD CONSTRAINT "book_field_confidence_pkey" PRIMARY KEY ("book_id", "field_name");



ALTER TABLE ONLY "public"."book_tropes"
    ADD CONSTRAINT "book_tropes_pkey" PRIMARY KEY ("book_id", "trope_id");



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_hardcover_id_key" UNIQUE ("hardcover_id");



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."content_warning_types"
    ADD CONSTRAINT "content_warning_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rating_submissions"
    ADD CONSTRAINT "rating_submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."series"
    ADD CONSTRAINT "series_hardcover_id_key" UNIQUE ("hardcover_id");



ALTER TABLE ONLY "public"."series"
    ADD CONSTRAINT "series_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tropes"
    ADD CONSTRAINT "tropes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."universe"
    ADD CONSTRAINT "universe_pkey" PRIMARY KEY ("id");



CREATE INDEX "audiobook_editions_book_id_idx" ON "public"."audiobook_editions" USING "btree" ("book_id");



CREATE INDEX "idx_book_cw_warning" ON "public"."book_content_warnings" USING "btree" ("warning_id");



CREATE INDEX "idx_book_tropes_trope" ON "public"."book_tropes" USING "btree" ("trope_id");



CREATE INDEX "idx_books_series" ON "public"."books" USING "btree" ("series_id");



CREATE INDEX "idx_books_universe" ON "public"."books" USING "btree" ("universe_id");



CREATE INDEX "idx_tropes_group" ON "public"."tropes" USING "btree" ("group_name");



ALTER TABLE ONLY "public"."audiobook_editions"
    ADD CONSTRAINT "audiobook_editions_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_content_warnings"
    ADD CONSTRAINT "book_content_warnings_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_content_warnings"
    ADD CONSTRAINT "book_content_warnings_warning_id_fkey" FOREIGN KEY ("warning_id") REFERENCES "public"."content_warning_types"("id");



ALTER TABLE ONLY "public"."book_dna"
    ADD CONSTRAINT "book_dna_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_field_confidence"
    ADD CONSTRAINT "book_field_confidence_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id");



ALTER TABLE ONLY "public"."book_tropes"
    ADD CONSTRAINT "book_tropes_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."book_tropes"
    ADD CONSTRAINT "book_tropes_trope_id_fkey" FOREIGN KEY ("trope_id") REFERENCES "public"."tropes"("id");



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_series_id_fkey" FOREIGN KEY ("series_id") REFERENCES "public"."series"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_universe_id_fkey" FOREIGN KEY ("universe_id") REFERENCES "public"."universe"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."rating_submissions"
    ADD CONSTRAINT "rating_submissions_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id");



ALTER TABLE ONLY "public"."series"
    ADD CONSTRAINT "series_parent_series_id_fkey" FOREIGN KEY ("parent_series_id") REFERENCES "public"."series"("id");



ALTER TABLE ONLY "public"."series"
    ADD CONSTRAINT "series_universe_id_fkey" FOREIGN KEY ("universe_id") REFERENCES "public"."universe"("id") ON DELETE SET NULL;



ALTER TABLE "public"."book_content_warnings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_dna" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_field_confidence" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."book_tropes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."books" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."content_warning_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "public insert only" ON "public"."rating_submissions" FOR INSERT TO "anon" WITH CHECK (true);



CREATE POLICY "public read access" ON "public"."book_content_warnings" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."book_dna" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."book_field_confidence" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."book_tropes" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."books" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."content_warning_types" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."series" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."tropes" FOR SELECT USING (true);



CREATE POLICY "public read access" ON "public"."universe" FOR SELECT USING (true);



ALTER TABLE "public"."rating_submissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."series" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tropes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."universe" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON TABLE "public"."audiobook_editions" TO "anon";
GRANT ALL ON TABLE "public"."audiobook_editions" TO "authenticated";
GRANT ALL ON TABLE "public"."audiobook_editions" TO "service_role";



GRANT ALL ON TABLE "public"."book_content_warnings" TO "anon";
GRANT ALL ON TABLE "public"."book_content_warnings" TO "authenticated";
GRANT ALL ON TABLE "public"."book_content_warnings" TO "service_role";



GRANT ALL ON TABLE "public"."book_dna" TO "anon";
GRANT ALL ON TABLE "public"."book_dna" TO "authenticated";
GRANT ALL ON TABLE "public"."book_dna" TO "service_role";



GRANT ALL ON TABLE "public"."book_field_confidence" TO "anon";
GRANT ALL ON TABLE "public"."book_field_confidence" TO "authenticated";
GRANT ALL ON TABLE "public"."book_field_confidence" TO "service_role";



GRANT ALL ON TABLE "public"."book_tropes" TO "anon";
GRANT ALL ON TABLE "public"."book_tropes" TO "authenticated";
GRANT ALL ON TABLE "public"."book_tropes" TO "service_role";



GRANT ALL ON TABLE "public"."books" TO "anon";
GRANT ALL ON TABLE "public"."books" TO "authenticated";
GRANT ALL ON TABLE "public"."books" TO "service_role";



GRANT ALL ON TABLE "public"."content_warning_types" TO "anon";
GRANT ALL ON TABLE "public"."content_warning_types" TO "authenticated";
GRANT ALL ON TABLE "public"."content_warning_types" TO "service_role";



GRANT ALL ON TABLE "public"."rating_submissions" TO "anon";
GRANT ALL ON TABLE "public"."rating_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."rating_submissions" TO "service_role";



GRANT ALL ON TABLE "public"."series" TO "anon";
GRANT ALL ON TABLE "public"."series" TO "authenticated";
GRANT ALL ON TABLE "public"."series" TO "service_role";



GRANT ALL ON TABLE "public"."tropes" TO "anon";
GRANT ALL ON TABLE "public"."tropes" TO "authenticated";
GRANT ALL ON TABLE "public"."tropes" TO "service_role";



GRANT ALL ON TABLE "public"."universe" TO "anon";
GRANT ALL ON TABLE "public"."universe" TO "authenticated";
GRANT ALL ON TABLE "public"."universe" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































