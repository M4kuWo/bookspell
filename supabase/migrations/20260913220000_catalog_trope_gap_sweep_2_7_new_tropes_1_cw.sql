-- Catalog-wide trope-gap sweep #2 (2026-09-13, CLDA), continuing
-- .claude/skills/catalog-trope-gap-sweep/SKILL.md into the ~366-book
-- pool of authors NOT covered by sweep #1 (commit 7e3f556, migration
-- 20260913170000). 6 parallel non-forked background agents (per
-- CLAUDE.md's agent-efficiency guidance), each covering a ~60-62 book
-- author cluster, per docs/project-log.md's 2026-09-13 "sweep #2" entry
-- for full per-trope evidence, candidates considered and rejected, and
-- what's deferred to docs/schema/book-dna.md's vocabulary-gap tracker.
--
-- 7 new trope concepts, each verified against 2+ real catalog books
-- sharing ZERO trope-level signal despite being the same recognizable
-- device/pattern:
--   monster_hunter_for_hire      -- promoted from sweep #1's tracker
--                                    (Witcher) via a genuine second
--                                    occurrence (Ilona Andrews' Kate
--                                    Daniels)
--   underworld_descent_journey   -- Kuang's Katabasis + Riordan's Percy
--                                    Jackson (2 books)
--   closed_circle_mystery        -- Turton (2 books) + Muir's Gideon
--                                    the Ninth
--   flintlock_fantasy_setting    -- McClellan's Powder Mage (4) +
--                                    Sanderson's Mistborn Era Two (4)
--   creation_turns_on_creator    -- Shelley's Frankenstein (both
--                                    editions) + Wells's The Island of
--                                    Doctor Moreau
--   engineered_creation_escapes_control -- Crichton's Jurassic Park /
--                                    Prey / The Lost World
--   royal_suitor_selection_competition  -- Cass's Selection trilogy +
--                                    Aveyard's Red Queen
--
-- Also promotes the already-tracked "climate/natural-disaster
-- mass-casualty" content-warning gap (docs/schema/book-dna.md's Future
-- fields backlog, open since 2026-09-09 on The Ministry for the
-- Future, re-checked-but-still-single-occurrence in sweep #1). This
-- sweep found TWO independent second occurrences from different
-- clusters (James Dashner's The Kill Order -- solar-flare disaster;
-- Neal Stephenson's Seveneves -- lunar-fragmentation "Hard Rain"
-- bombardment), neither of which is climate-specific, so the value is
-- named/scoped broadly as natural-disaster-driven mass casualty
-- (astronomical, geological, or climate in origin), not narrowly
-- "climate" -- see book-dna.md for the naming rationale.
--
-- Applied directly to HOSTED via a raw connection, NOT via `supabase
-- db push` -- CLDA's sandbox has no linked Supabase project and no
-- local Supabase stack running (same environment constraint as every
-- prior CLDA migration batch today, most recently 20260913170000).
-- Hosted's supabase_migrations tracking table does NOT know this
-- version was applied -- CLDO must run
-- `supabase migration repair --status applied --linked 20260913220000`
-- after confirming data matches (row counts on tropes/book_tropes/
-- content_warning_types/book_content_warnings, or a spot-check -- they
-- will match, this session applied and verified the real data
-- directly), per CLAUDE.md's documented recovery procedure. Do not
-- force through any resulting push error.

insert into tropes (id, group_name, spoiler) values
  ('monster_hunter_for_hire', 'plot_devices', false),
  ('underworld_descent_journey', 'plot_devices', false),
  ('closed_circle_mystery', 'plot_devices', false),
  ('flintlock_fantasy_setting', 'setting_worldbuilding', false),
  ('creation_turns_on_creator', 'craft_devices', false),
  ('engineered_creation_escapes_control', 'plot_devices', false),
  ('royal_suitor_selection_competition', 'romance_relationships', false)
on conflict (id) do nothing;

insert into content_warning_types (id) values
  ('natural_disaster_mass_casualty')
on conflict (id) do nothing;

-- monster_hunter_for_hire: 3 books (Witcher x2 already flagged by
-- sweep #1; Kate Daniels x2 is the new second-occurrence evidence)
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Last Wish'), 'monster_hunter_for_hire', null, 'ai_inferred'),
  ((select id from books where title = 'Sword of Destiny'), 'monster_hunter_for_hire', null, 'ai_inferred'),
  ((select id from books where title = 'Magic Bites'), 'monster_hunter_for_hire', null, 'ai_inferred'),
  ((select id from books where title = 'Magic Burns'), 'monster_hunter_for_hire', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- underworld_descent_journey: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Katabasis'), 'underworld_descent_journey', null, 'ai_inferred'),
  ((select id from books where title = 'The Lightning Thief'), 'underworld_descent_journey', null, 'ai_inferred'),
  ((select id from books where title = 'The House Of Hades'), 'underworld_descent_journey', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- closed_circle_mystery: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle'), 'closed_circle_mystery', null, 'ai_inferred'),
  ((select id from books where title = 'The Last Murder at the End of the World'), 'closed_circle_mystery', null, 'ai_inferred'),
  ((select id from books where title = 'Gideon the Ninth'), 'closed_circle_mystery', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- flintlock_fantasy_setting: 8 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Promise of Blood'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'The Crimson Campaign'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'The Autumn Republic'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'Forsworn'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'The Alloy of Law'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'Shadows of Self'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'The Bands of Mourning'), 'flintlock_fantasy_setting', null, 'ai_inferred'),
  ((select id from books where title = 'The Lost Metal'), 'flintlock_fantasy_setting', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- creation_turns_on_creator: 3 books (both Frankenstein editions +
-- The Island of Doctor Moreau)
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Frankenstein'), 'creation_turns_on_creator', null, 'ai_inferred'),
  ((select id from books where title = 'Frankenstein: The 1818 Text'), 'creation_turns_on_creator', null, 'ai_inferred'),
  ((select id from books where title = 'The Island of Doctor Moreau'), 'creation_turns_on_creator', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- engineered_creation_escapes_control: 3 books
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'Jurassic Park'), 'engineered_creation_escapes_control', null, 'ai_inferred'),
  ((select id from books where title = 'Prey'), 'engineered_creation_escapes_control', null, 'ai_inferred'),
  ((select id from books where title = 'The Lost World'), 'engineered_creation_escapes_control', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- royal_suitor_selection_competition: 4 books ('The One' is ambiguous
-- across authors -- title-only subselect would hit John Marrs's
-- unrelated thriller of the same name, so this one row is
-- author-scoped)
insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'The Selection'), 'royal_suitor_selection_competition', null, 'ai_inferred'),
  ((select id from books where title = 'The Elite'), 'royal_suitor_selection_competition', null, 'ai_inferred'),
  ((select id from books where title = 'The One' and author = 'Kiera Cass'), 'royal_suitor_selection_competition', null, 'ai_inferred'),
  ((select id from books where title = 'Red Queen' and author = 'Victoria Aveyard'), 'royal_suitor_selection_competition', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

-- natural_disaster_mass_casualty content warning: 3 books. Severity
-- central_theme on all three -- the disaster is each book's inciting/
-- defining event, not a background reference. reveals_spoiler false on
-- all three -- each disaster is established at or near the opening,
-- not a withheld late reveal.
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values
  ((select id from books where title = 'The Ministry for the Future'), 'natural_disaster_mass_casualty', 'central_theme', false),
  ((select id from books where title = 'The Kill Order'), 'natural_disaster_mass_casualty', 'central_theme', false),
  ((select id from books where title = 'Seveneves'), 'natural_disaster_mass_casualty', 'central_theme', false)
on conflict (book_id, warning_id) do nothing;
