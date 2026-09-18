-- Tag "The Traitor God" (Cameron Johnston, Age of Tyranny #1) -- the
-- repo owner's real suggest-a-book test submission, ingested in
-- 20260919000000_ingest_the_traitor_god.sql this same session.
--
-- Tagged from real research (cross-checked across ~5 independent
-- reviews -- FanFiAddict, Fantasy-Hive, Hippogriff's Aerie, SF&F
-- Reviews, Hobbleit -- not pattern-matched from grimdark-genre
-- convention), per this project's HIGH_RISK_FIELDS discipline for
-- person/pov_count/narrator_reliability/magic_system_hardness/
-- overall_pace/drive/stakes_scope/narrative_closure/humor_level.
-- Notable checked facts: magic system is confirmed SOFT (dramatic,
-- addictive effects described atmospherically, no explained rule
-- taxonomy -- not assumed hard just because grimdark magic systems
-- often are); ending confirmed non-cliffhanger/self-contained
-- ("no cliffhangers", per Fantasy-Hive) despite being book 1 of an
-- ongoing 2-book series so far. `drive` and `stakes_scope` are the two
-- calls where the evidence was suggestive but not fully definitive --
-- flagged via book_field_confidence below, not silently guessed.
-- romance_tone left null: reviews describe only minor one-sided
-- flirtation (Walker/Eva), not enough romantic content to judge tone.

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven',
  'grimdark', 'moderate', 'tense', 'moderate',
  'rare', 'low', null,
  'frequent', 'brutal', 'moderate',
  'woven', 'self_contained',
  'bittersweet', 'resolved', 'standard',
  'soft', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'life_threatening', 'accessible'
  -- genre_accessibility: prose_complexity=accessible(0), overall_pace=
  -- fast (inverted: 0), worldbuilding_density=moderate(0.5),
  -- pov_count=single(0), intellectual_weight=moderate(0.5) -> avg 0.2
  -- -> 'accessible' tier. No premise-familiarity adjustment: a
  -- conventional secondary-world city fantasy, neither unusually
  -- mainstream nor unusually exotic in premise.
from books where title = 'The Traitor God';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'noir_detective_structure', 'revenge', 'anti_hero',
  'powerful_artifact_macguffin', 'high_fantasy_setting', 'corruption_arc'
]) as t
where title = 'The Traitor God'
on conflict do nothing;

-- torture: the inciting incident (a friend skinned alive) -- not a
-- spoiler, it's in the book's own back-cover synopsis.
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'central_theme', false from books where title = 'The Traitor God'
on conflict do nothing;
-- body_horror: daemons/monstrous creations described as a recurring,
-- visceral element throughout, not a single incident.
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Traitor God'
on conflict do nothing;
-- substance_abuse: magic use itself is explicitly written as addictive,
-- with a real cost that erodes the user's humanity the more it's used --
-- a literal addiction mechanic, not just a vague power-corrupts theme.
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'The Traitor God'
on conflict do nothing;

-- Genuinely uncertain calls, not silently guessed -- see the header
-- comment above.
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.6, 'ai_inferred' from books where title = 'The Traitor God'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'The Traitor God'
on conflict (book_id, field_name) do nothing;

-- Real, verified audiobook edition (Tantor Audio, narrator Paul
-- Woodson, 14h2m) -- found while researching audiobook_length above,
-- confirmed directly via Audible's own listing rather than guessed,
-- so recorded now rather than left for a future bulk pass to
-- rediscover.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select id, 'standard', array['Paul Woodson'], 'Tantor Audio', 842,
  'fully_released', null, null,
  'https://www.audible.com/pd/The-Traitor-God-Audiobook/1977334571', current_date
from books where title = 'The Traitor God'
on conflict (book_id, source_url) do nothing;
