-- Catalog-wide trope-gap sweep (2026-09-13, CLDA), 5 new trope concepts
-- verified against 2+ real catalog books each currently sharing ZERO
-- trope-level signal despite being the same recognizable device -- see
-- docs/project-log.md's 2026-09-13 gap-sweep entry for full per-trope
-- evidence and the candidates considered and rejected for not clearing
-- the "does this change what gets recommended" bar (including 3 real,
-- single-series patterns deliberately deferred to docs/schema/book-dna.md's
-- vocabulary-gap tracker rather than added here).
--
-- Applied directly to HOSTED via a raw connection, NOT via `supabase db
-- push` -- CLDA's sandbox has no linked Supabase project (no project
-- ref/access token, confirmed via `supabase migration list --linked`
-- failing with LegacyProjectNotLinkedError) and no local Supabase stack
-- running (127.0.0.1:54322 connection refused, confirmed) -- and this
-- session's .env DATABASE_URL resolves to a *.pooler.supabase.com host,
-- i.e. hosted itself. Applied via a direct autocommit psycopg2
-- connection, per the established CLDA workaround (see CLAUDE.md's
-- "Database & migrations" section and every prior CLDA migration batch,
-- e.g. the series.status/book_count batches). Hosted's
-- supabase_migrations tracking table does NOT know this version was
-- applied -- CLDO must run
-- `supabase migration repair --status applied --linked 20260913170000`
-- after confirming data matches (row counts on `tropes`/`book_tropes`,
-- or a spot-check -- they will match, this session applied and verified
-- the real data directly), per CLAUDE.md's documented recovery
-- procedure. Do not force through any resulting push error.

insert into tropes (id, group_name, spoiler) values
  ('anthropomorphic_personification_protagonist', 'craft_devices', false),
  ('government_experimentation_on_the_gifted', 'plot_devices', false),
  ('magically_binding_bargain', 'plot_devices', false),
  ('predictive_social_science', 'scifi_specific', false),
  ('post_scarcity_utopia', 'setting_worldbuilding', false)
on conflict (id) do nothing;

-- anthropomorphic_personification_protagonist: 4 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Mort'), 'anthropomorphic_personification_protagonist', null, 'ai_inferred'),
  ((select id from books where title = 'Reaper Man'), 'anthropomorphic_personification_protagonist', null, 'ai_inferred'),
  ((select id from books where title = 'Hogfather'), 'anthropomorphic_personification_protagonist', null, 'ai_inferred'),
  ((select id from books where title = 'Soul Music'), 'anthropomorphic_personification_protagonist', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- government_experimentation_on_the_gifted: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Firestarter'), 'government_experimentation_on_the_gifted', null, 'ai_inferred'),
  ((select id from books where title = 'The Institute'), 'government_experimentation_on_the_gifted', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- magically_binding_bargain: 6 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Changes'), 'magically_binding_bargain', null, 'ai_inferred'),
  ((select id from books where title = 'Cold Days'), 'magically_binding_bargain', null, 'ai_inferred'),
  ((select id from books where title = 'Skin Game'), 'magically_binding_bargain', null, 'ai_inferred'),
  ((select id from books where title = 'Peace Talks'), 'magically_binding_bargain', null, 'ai_inferred'),
  ((select id from books where title = 'A Court of Thorns and Roses'), 'magically_binding_bargain', null, 'ai_inferred'),
  ((select id from books where title = 'A Court of Mist and Fury'), 'magically_binding_bargain', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- predictive_social_science: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Foundation'), 'predictive_social_science', null, 'ai_inferred'),
  ((select id from books where title = 'Second Foundation'), 'predictive_social_science', null, 'ai_inferred'),
  ((select id from books where title = 'Foundation''s Edge'), 'predictive_social_science', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- post_scarcity_utopia: 9 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Consider Phlebas'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'The Player of Games'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'Use of Weapons'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'Excession'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'Look to Windward'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'Matter'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'Surface Detail'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'A Psalm for the Wild-Built'), 'post_scarcity_utopia', null, 'ai_inferred'),
  ((select id from books where title = 'A Prayer for the Crown-Shy'), 'post_scarcity_utopia', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;
