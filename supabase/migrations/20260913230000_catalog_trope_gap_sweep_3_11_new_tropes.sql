-- Catalog-wide trope-gap sweep #3 (2026-09-13, CLDA), the third and final
-- regular pass of .claude/skills/catalog-trope-gap-sweep/SKILL.md for now,
-- covering the ~224-book pool of single-tagged-book authors NOT reached by
-- sweep #1 (commit 7e3f556, migration 20260913170000) or sweep #2
-- (migration 20260913220000). Unlike those two author-clustered sweeps,
-- this pool is ~99% single-book authors, so Step 3 clustered by
-- subgenre/narrative-mechanism/theme instead (7 parallel non-forked
-- background agents per CLAUDE.md's agent-efficiency guidance) -- full
-- per-cluster book lists, evidence, and rejected candidates in
-- docs/project-log.md's 2026-09-13 "sweep #3" entry.
--
-- 11 new trope concepts, each verified against 2+ real catalog books
-- sharing ZERO trope-level signal despite being the same recognizable
-- device/pattern, with every candidate cross-checked against the full
-- 141-trope/38-CW vocabulary AND the relevant scalar fields (timeline,
-- narrator_reliability, prose_density/complexity, etc.) before landing --
-- one strong-looking candidate (`fragmented_nonlinear_structure`, from
-- Infinite Jest/Gravity's Rainbow) was caught and REJECTED this way,
-- confirmed via direct DB query that both evidence books already carry
-- `timeline: nonlinear` -- the same redundancy trap sweep #1 caught with
-- `non_linear_timeline_narrative`. A content-warning candidate
-- (`cannibalism`, re-surfaced from Tender Is the Flesh + The Road) was
-- also deliberately NOT added -- it reopens a specific, already-documented
-- rejection from the 30-book pilot (see book-dna.md's future-fields
-- backlog); flagged for repo-owner reconsideration rather than overridden
-- unilaterally.
--
--   forced_psychological_reconditioning -- 1984/Animal Farm, A Clockwork
--                                    Orange, We (3 books)
--   incomprehensible_alien_contact  -- Solaris, Roadside Picnic (confirmed
--                                    distinct from cosmic_horror -- neither
--                                    evidence book carries that tag)
--   impossible_or_non_euclidean_architecture -- House of Leaves, The
--                                    Library at Mount Char, Acceptance
--   mass_unexplained_sensory_or_memory_loss -- Blindness, The Memory Police
--   animated_construct_companion    -- The Wonderful Wizard of Oz, Howl's
--                                    Moving Castle, The Neverending Story
--   institutional_time_travel_bureaucracy -- The Ministry of Time,
--                                    Doomsday Book
--   secret_magical_bureaucracy      -- Rivers of London, The Rook
--   old_faith_displaced_by_new_religion -- The Bear and the Nightingale,
--                                    The Mists of Avalon
--   state_mandated_body_harvesting_or_modification -- The Bone Shard
--                                    Daughter, Perdido Street Station
--   modern_knowledge_as_power_source -- Off to Be the Wizard, The
--                                    Wandering Inn
--   caste_or_faction_stratified_society -- PROMOTED from sweep #2's
--                                    single-occurrence tracker: a genuine
--                                    new confirming instance (Brave New
--                                    World's Alpha-Epsilon castes) plus,
--                                    critically, real discriminating
--                                    counter-evidence this round (Battle
--                                    Royale and The Knife of Never Letting
--                                    Go are both dystopia-tagged with NO
--                                    caste/faction-sorting mechanism at
--                                    all) resolving sweep #2's self-flagged
--                                    risk that it would just co-occur with
--                                    `dystopia` catalog-wide. Full evidence:
--                                    Divergent, Red Rising, The Selection,
--                                    Empire of Silence (original sweep #2
--                                    evidence, never landed since the trope
--                                    itself didn't exist yet) + Brave New
--                                    World (new).
--
-- Applied directly to HOSTED via a raw connection, NOT via `supabase
-- db push` -- CLDA's sandbox has no linked Supabase project and no local
-- Supabase stack running (same environment constraint as every prior CLDA
-- migration batch today: 20260913170000, 20260913220000). Hosted's
-- supabase_migrations tracking table does NOT know this version was
-- applied -- CLDO must run
-- `supabase migration repair --status applied --linked 20260913230000`
-- after confirming data matches (row counts on tropes/book_tropes, or a
-- spot-check -- they will match, this session applied and verified the
-- real data directly), per CLAUDE.md's documented recovery procedure.
-- This is now the THIRD migration today waiting on this same repair step,
-- alongside 20260913170000 and 20260913220000 -- all three can be
-- repaired together. Do not force through any resulting push error.

insert into tropes (id, group_name, spoiler) values
  ('forced_psychological_reconditioning', 'plot_devices', false),
  ('incomprehensible_alien_contact', 'scifi_specific', false),
  ('impossible_or_non_euclidean_architecture', 'setting_worldbuilding', false),
  ('mass_unexplained_sensory_or_memory_loss', 'plot_devices', false),
  ('animated_construct_companion', 'character_archetypes', false),
  ('institutional_time_travel_bureaucracy', 'scifi_specific', false),
  ('secret_magical_bureaucracy', 'setting_worldbuilding', false),
  ('old_faith_displaced_by_new_religion', 'setting_worldbuilding', false),
  ('state_mandated_body_harvesting_or_modification', 'setting_worldbuilding', false),
  ('modern_knowledge_as_power_source', 'plot_devices', false),
  ('caste_or_faction_stratified_society', 'setting_worldbuilding', false)
on conflict (id) do nothing;

-- forced_psychological_reconditioning: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = '1984 / Animal Farm'), 'forced_psychological_reconditioning', null, 'ai_inferred'),
  ((select id from books where title = 'A Clockwork Orange'), 'forced_psychological_reconditioning', null, 'ai_inferred'),
  ((select id from books where title = 'We'), 'forced_psychological_reconditioning', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- incomprehensible_alien_contact: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Solaris'), 'incomprehensible_alien_contact', null, 'ai_inferred'),
  ((select id from books where title = 'Roadside Picnic'), 'incomprehensible_alien_contact', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- impossible_or_non_euclidean_architecture: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'House of Leaves'), 'impossible_or_non_euclidean_architecture', null, 'ai_inferred'),
  ((select id from books where title = 'The Library at Mount Char'), 'impossible_or_non_euclidean_architecture', null, 'ai_inferred'),
  ((select id from books where title = 'Acceptance'), 'impossible_or_non_euclidean_architecture', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- mass_unexplained_sensory_or_memory_loss: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Blindness'), 'mass_unexplained_sensory_or_memory_loss', null, 'ai_inferred'),
  ((select id from books where title = 'The Memory Police'), 'mass_unexplained_sensory_or_memory_loss', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- animated_construct_companion: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Wonderful Wizard of Oz'), 'animated_construct_companion', null, 'ai_inferred'),
  ((select id from books where title = 'Howl''s Moving Castle'), 'animated_construct_companion', null, 'ai_inferred'),
  ((select id from books where title = 'The Neverending Story'), 'animated_construct_companion', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- institutional_time_travel_bureaucracy: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Ministry of Time'), 'institutional_time_travel_bureaucracy', null, 'ai_inferred'),
  ((select id from books where title = 'Doomsday Book'), 'institutional_time_travel_bureaucracy', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- secret_magical_bureaucracy: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Rivers of London'), 'secret_magical_bureaucracy', null, 'ai_inferred'),
  ((select id from books where title = 'The Rook'), 'secret_magical_bureaucracy', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- old_faith_displaced_by_new_religion: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Bear and the Nightingale'), 'old_faith_displaced_by_new_religion', null, 'ai_inferred'),
  ((select id from books where title = 'The Mists of Avalon'), 'old_faith_displaced_by_new_religion', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- state_mandated_body_harvesting_or_modification: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Bone Shard Daughter'), 'state_mandated_body_harvesting_or_modification', null, 'ai_inferred'),
  ((select id from books where title = 'Perdido Street Station'), 'state_mandated_body_harvesting_or_modification', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- modern_knowledge_as_power_source: 2 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Off to Be the Wizard'), 'modern_knowledge_as_power_source', null, 'ai_inferred'),
  ((select id from books where title = 'The Wandering Inn'), 'modern_knowledge_as_power_source', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- caste_or_faction_stratified_society: 5 books (4 original sweep #2
-- evidence books, never backfilled since the trope didn't exist yet,
-- plus 1 new confirming book from this sweep)
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Divergent'), 'caste_or_faction_stratified_society', null, 'ai_inferred'),
  ((select id from books where title = 'Red Rising'), 'caste_or_faction_stratified_society', null, 'ai_inferred'),
  ((select id from books where title = 'The Selection'), 'caste_or_faction_stratified_society', null, 'ai_inferred'),
  ((select id from books where title = 'Empire of Silence'), 'caste_or_faction_stratified_society', null, 'ai_inferred'),
  ((select id from books where title = 'Brave New World'), 'caste_or_faction_stratified_society', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;
