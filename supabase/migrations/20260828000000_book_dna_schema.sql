-- Book DNA schema -> Postgres tables
-- Generated from docs/schema/book-dna.schema.yaml (schema_version: 0.1.0-draft)
-- Design notes (see project-log.md for full reasoning):
--   - tropes/content_warnings get real lookup tables (per-value metadata + growth
--     without migrations); every other scalar field gets a CHECK constraint.
--   - book_dna is one wide table, one row per book.
--   - series/universe carry live status/book_count, not frozen tag data.

create extension if not exists "pgcrypto";

create table universe (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table series (
  id uuid primary key default gen_random_uuid(),
  universe_id uuid references universe(id) on delete set null,
  name text not null,
  status text not null check (status in ('ongoing', 'completed', 'hiatus')),
  book_count integer,  -- nullable/estimated while ongoing
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text not null,
  series_id uuid references series(id) on delete set null,
  universe_id uuid references universe(id) on delete set null,
  position_in_series numeric,  -- nullable; fractional for novellas/interquels
  isbn text,
  cover_url text,
  synopsis text,
  page_count integer,
  audiobook_duration_minutes integer,
  publication_year integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table tropes (
  id text primary key,
  group_name text not null,
  spoiler boolean not null default false
);

insert into tropes (id, group_name, spoiler) values
  ('chosen_one', 'character_archetypes', false),
  ('reluctant_hero', 'character_archetypes', false),
  ('anti_hero', 'character_archetypes', false),
  ('villain_protagonist', 'character_archetypes', false),
  ('cursed_protagonist', 'character_archetypes', false),
  ('morally_grey_protagonist', 'character_archetypes', false),
  ('secret_royalty', 'character_archetypes', false),
  ('immortal_or_ageless_character', 'character_archetypes', false),
  ('reincarnated_protagonist', 'character_archetypes', false),
  ('hidden_talent_prodigy', 'character_archetypes', false),
  ('wise_mentor', 'character_archetypes', false),
  ('underdog_rising', 'character_archetypes', false),
  ('dark_lord_or_evil_overlord', 'character_archetypes', false),
  ('enemies_to_lovers', 'romance_relationships', false),
  ('friends_to_lovers', 'romance_relationships', false),
  ('forbidden_love', 'romance_relationships', false),
  ('love_triangle', 'romance_relationships', false),
  ('fated_mates', 'romance_relationships', false),
  ('soulmate_bond', 'romance_relationships', false),
  ('arranged_marriage', 'romance_relationships', false),
  ('marriage_of_convenience', 'romance_relationships', false),
  ('fake_dating', 'romance_relationships', false),
  ('forced_proximity', 'romance_relationships', false),
  ('only_one_bed', 'romance_relationships', false),
  ('age_gap_romance', 'romance_relationships', false),
  ('second_chance_romance', 'romance_relationships', false),
  ('grumpy_sunshine', 'romance_relationships', false),
  ('slow_burn_romance', 'romance_relationships', false),
  ('found_family', 'romance_relationships', false),
  ('monster_or_fae_romance', 'romance_relationships', false),
  ('insta_love', 'romance_relationships', false),
  ('hidden_identity_romance', 'romance_relationships', false),
  ('reverse_harem_or_why_choose', 'romance_relationships', false),
  ('telepathic_animal_bond', 'romance_relationships', false),
  ('magic_school', 'setting_worldbuilding', false),
  ('portal_fantasy', 'setting_worldbuilding', false),
  ('medieval_european_setting', 'setting_worldbuilding', false),
  ('non_european_inspired_setting', 'setting_worldbuilding', false),
  ('lost_civilizations', 'setting_worldbuilding', false),
  ('fae_courts', 'setting_worldbuilding', false),
  ('high_fantasy_setting', 'setting_worldbuilding', false),
  ('urban_fantasy_setting', 'setting_worldbuilding', false),
  ('post_apocalyptic', 'setting_worldbuilding', false),
  ('dystopia', 'setting_worldbuilding', false),
  ('space_opera', 'setting_worldbuilding', false),
  ('cyberpunk', 'setting_worldbuilding', false),
  ('multiple_fantasy_species', 'setting_worldbuilding', false),
  ('dark_academia_setting', 'setting_worldbuilding', false),
  ('steampunk', 'setting_worldbuilding', false),
  ('litrpg_or_progression_fantasy', 'setting_worldbuilding', false),
  ('new_weird_setting', 'setting_worldbuilding', false),
  ('isekai', 'setting_worldbuilding', false),
  ('renaissance_or_mercantile_setting', 'setting_worldbuilding', false),
  ('vampires', 'setting_worldbuilding', false),
  ('epic_quest', 'plot_devices', false),
  ('court_intrigue', 'plot_devices', false),
  ('heist', 'plot_devices', false),
  ('rebellion_against_empire', 'plot_devices', false),
  ('time_loop', 'plot_devices', false),
  ('time_travel', 'plot_devices', false),
  ('parallel_universe_or_multiverse', 'plot_devices', false),
  ('prophecy', 'plot_devices', false),
  ('war_story', 'plot_devices', false),
  ('ancient_evil_awakens', 'plot_devices', false),
  ('powerful_artifact_macguffin', 'plot_devices', false),
  ('last_minute_rescue', 'plot_devices', false),
  ('black_and_white_morality', 'plot_devices', false),
  ('child_soldiers_in_warfare', 'plot_devices', false),
  ('noir_detective_structure', 'plot_devices', false),
  ('first_contact', 'scifi_specific', false),
  ('generation_ship', 'scifi_specific', false),
  ('dying_earth', 'scifi_specific', false),
  ('alien_invasion', 'scifi_specific', false),
  ('ai_consciousness', 'scifi_specific', false),
  ('cloning', 'scifi_specific', false),
  ('terraforming_or_space_colonization', 'scifi_specific', false),
  ('cryosleep', 'scifi_specific', false),
  ('mind_uploading_or_digital_immortality', 'scifi_specific', false),
  ('virtual_reality_or_simulated_world', 'scifi_specific', false),
  ('ai_uprising_or_rebellion', 'scifi_specific', false),
  ('android_or_replicant_rights', 'scifi_specific', false),
  ('cybernetic_enhancement', 'scifi_specific', false),
  ('hive_mind', 'scifi_specific', false),
  ('mecha_or_giant_robots', 'scifi_specific', false),
  ('self_replicating_consciousness', 'scifi_specific', false),
  ('species_divergence', 'scifi_specific', false),
  ('relativistic_time_dilation', 'scifi_specific', false),
  ('mutual_human_alien_war', 'scifi_specific', false),
  ('aging_reversal_or_rejuvenation', 'scifi_specific', false),
  ('satirical_or_comedic_scifi', 'scifi_specific', false),
  ('twist_ending', 'craft_devices', true),
  ('twist_filled', 'craft_devices', true),
  ('sanderlanche', 'craft_devices', false),
  ('redemption_arc', 'craft_devices', true),
  ('villain_turns_ally', 'craft_devices', true),
  ('major_character_death', 'craft_devices', true),
  ('mentor_death', 'craft_devices', true),
  ('mythological_retelling', 'craft_devices', false),
  ('shadow_self_confrontation', 'craft_devices', false);

create table content_warning_types (
  id text primary key
);

insert into content_warning_types (id) values
  ('sexual_assault'),
  ('dubious_consent'),
  ('self_harm'),
  ('suicide'),
  ('eating_disorder'),
  ('child_death'),
  ('child_abuse'),
  ('animal_harm'),
  ('domestic_abuse'),
  ('substance_abuse'),
  ('torture'),
  ('body_horror'),
  ('hate_speech_depicted'),
  ('ableism_depicted'),
  ('racism_depicted'),
  ('colonization_themes'),
  ('slavery'),
  ('genocide'),
  ('war_trauma'),
  ('religious_trauma_or_cults'),
  ('mental_illness_depiction'),
  ('pregnancy_loss'),
  ('kidnapping_or_captivity'),
  ('sexual_harassment'),
  ('emotional_abuse'),
  ('child_sexual_abuse'),
  ('stalking'),
  ('trafficking'),
  ('classism'),
  ('sexism_or_misogyny_depicted'),
  ('infertility'),
  ('abortion'),
  ('bullying');

create table book_dna (
  book_id uuid primary key references books(id) on delete cascade,
  genre text[] not null check (genre <@ array['sci_fi', 'fantasy']::text[]),
  age_category text check (age_category in ('middle_grade', 'ya', 'new_adult', 'adult')),
  book_length text check (book_length in ('short', 'standard', 'long', 'epic')),

  -- pov_structure
  pov_count text check (pov_count in ('single', 'multiple')),
  person text check (person in ('first', 'second', 'third_limited', 'third_omniscient', 'mixed')),
  narrator_reliability text check (narrator_reliability in ('reliable', 'unreliable')),
  timeline text check (timeline in ('linear', 'nonlinear', 'multi_timeline')),
  form text check (form in ('standard_prose', 'epistolary', 'framing_device', 'verse')),

  -- pacing_tone
  overall_pace text check (overall_pace in ('slow', 'medium', 'fast')),
  pace_shape text check (pace_shape in ('consistent', 'slow_burn_to_fast_finish', 'front_loaded', 'uneven')),
  drive text check (drive in ('character_driven', 'plot_driven', 'balanced', 'worldbuilding_driven')),
  darkness text check (darkness in ('light', 'moderate', 'dark', 'grimdark')),
  humor_level text check (humor_level in ('none', 'light', 'moderate', 'heavy')),
  emotional_register text check (emotional_register in ('comfort_read', 'bittersweet', 'tense', 'gut_punch')),
  message_intensity text check (message_intensity in ('subtle', 'moderate', 'heavy_handed')),

  -- content_shape (scalars only; content_warnings is its own join table)
  romance_heat_frequency text check (romance_heat_frequency in ('none', 'rare', 'occasional', 'frequent')),
  romance_heat_intensity text check (romance_heat_intensity in ('na', 'closed_door', 'low', 'moderate', 'explicit')),
  violence_frequency text check (violence_frequency in ('none', 'rare', 'occasional', 'frequent')),
  violence_intensity text check (violence_intensity in ('na', 'mild', 'moderate', 'graphic', 'brutal')),
  worldbuilding_density text check (worldbuilding_density in ('light', 'moderate', 'dense')),
  narrative_closure text check (narrative_closure in ('self_contained', 'requires_series')),
  emotional_resolution text check (emotional_resolution in ('happy', 'tragic', 'ambiguous', 'bittersweet')),
  ends_on_cliffhanger text check (ends_on_cliffhanger in ('resolved', 'cliffhanger')),

  -- audiobook_native
  narrator_performance text check (narrator_performance in ('poor', 'average', 'good', 'excellent')),
  narrator_cast text check (narrator_cast in ('single_narrator', 'dual_narrator', 'full_cast')),
  narration_pace_vs_prose text check (narration_pace_vs_prose in ('matches', 'slower', 'faster')),
  accent_authenticity text check (accent_authenticity in ('na', 'poor', 'adequate', 'excellent')),
  production_quality text check (production_quality in ('basic', 'standard', 'high')),
  audiobook_length text check (audiobook_length in ('short', 'standard', 'long', 'epic')),

  -- tropes_craft scalars (tropes list itself is its own join table)
  magic_system_hardness text check (magic_system_hardness in ('hard', 'soft', 'none', 'na')),
  scifi_hardness text check (scifi_hardness in ('hard', 'soft', 'na')),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table book_tropes (
  book_id uuid not null references books(id) on delete cascade,
  trope_id text not null references tropes(id),
  primary key (book_id, trope_id)
);

create table book_content_warnings (
  book_id uuid not null references books(id) on delete cascade,
  warning_id text not null references content_warning_types(id),
  severity text not null check (severity in ('brief', 'moderate', 'central_theme')),
  reveals_spoiler boolean not null default false,
  primary key (book_id, warning_id)
);

create index idx_books_series on books(series_id);
create index idx_books_universe on books(universe_id);
create index idx_book_tropes_trope on book_tropes(trope_id);
create index idx_book_cw_warning on book_content_warnings(warning_id);
create index idx_tropes_group on tropes(group_name);

