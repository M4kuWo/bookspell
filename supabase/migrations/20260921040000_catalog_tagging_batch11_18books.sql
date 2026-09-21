-- Catalog tagging batch 11 (CLDA): 18 books tagged with full Book DNA,
-- prioritized via the tag-catalog-batch skill's partial-series-first query
-- (round-5 pool, "and b.archived = false"). Completes 15 series outright:
-- The Dresden Files (19/19), Children of Time (4/4), The Final Architecture
-- (3/3), Red Queen (4/4), The Riftwar Saga (3/3 tracked), Sword of Truth
-- (3/3 tracked), Legend (3/3), Caraval (3/3), Miss Peregrine's Peculiar
-- Children (3/3), Revelation Space (3/3 tracked), Uglies (3/3), Once Upon a
-- Broken Heart (3/3), Wayward Children (3/3 tracked), Ana and Din Mysteries
-- (3/3 tracked), Legends & Lattes (3/3 tracked), and Livesuit closes out
-- The Captive's War (3/3 tracked). Moves Cradle from 3/10 to 5/10 (Skysworn,
-- Ghostwater tagged; 5 more remain for a future batch).
--
-- Two books surfaced by Step 2's query were deliberately skipped, not
-- guessed at:
--   - "The Thorn of Emberlain" (Scott Lynch, Gentleman Bastard #4) is
--     UNPUBLISHED (confirmed via Wikipedia: "planned fourth of seven
--     books," no release date) -- it has no real text to tag. Flagging to
--     the repo owner in the batch report as a data-quality question (why
--     an unpublished book is sitting in the untagged catalog queue at
--     all) rather than resolving it myself.
--   - He Who Fights with Monsters books 5-8 (Cradle-adjacent LitRPG
--     opportunity, 3/8 tagged) were left for a future batch -- this
--     session's research budget went to the higher-value/safer series
--     completions above instead of a 5-book LitRPG stretch that deserves
--     its own careful person/POV verification pass (per this project's
--     Dungeon Crawler Carl precedent).
--
-- Step 1.5 (mandatory schema-drift check) caught real drift this session:
-- `narrator_cast` (Tier A, added in the 2026-08-29 audiobook_native
-- split -- "cheap to source, worth completing" per book-dna.schema.yaml)
-- was live in `book_dna` but silently absent from every prior batch's
-- inserts (null on all 1157 previously-tagged books) -- the skill's own
-- Step 1.5 text said "5 excluded Tier B audiobook columns" while Step 3
-- only ever named 4, so narrator_cast was getting folded into that
-- exclusion despite being explicitly Tier A metadata in schema.yaml's own
-- comments. Fixed .claude/skills/tag-catalog-batch/SKILL.md (Step 1.5,
-- Step 3's exception list, example INSERT) and docs/schema/book-dna.md's
-- stale Audiobook-native section (never updated for the 2026-08-29 tier
-- split) in this same session, per CLAUDE.md's schema-doc-sync rule.
-- Checked audiobook_editions for all 18 books in this batch: none have a
-- row yet (796/1483 catalog-wide do), so narrator_cast is left NULL on
-- every book_dna row below -- correctly, per the skill's fixed guidance,
-- not a gap introduced by this batch. Flagging the 1157-book backfill
-- opportunity (computable from existing audiobook_editions data for
-- already-tagged books) to the repo owner as a mechanical, scriptable
-- follow-up task, not per-book tagging work.
--
-- Author-field contamination found and fixed inline (verified via
-- Hardcover's cached_contributors GraphQL API):
--   - "War Storm" (Victoria Aveyard) author field was
--     "Victoria Aveyard, Vikas Adam, Amanda Dolan, Charlie Thurston,
--     Erin Spencer, Saskia Maarleveld" -- the latter 5 are all audiobook
--     Narrators (contribution: "Narrator"), not co-authors. Fixed to
--     "Victoria Aveyard".
--   - "He Who Fights with Monsters 4" author field included "Heath
--     Miller" (contribution: "Narrator") alongside the two genuine
--     co-author credits (Shirtaloon = Travis Deverell's pen name; both
--     legitimately listed as "Author" in Hardcover, not contamination
--     between them). Fixed to "Shirtaloon, Travis Deverell" even though
--     this specific book isn't part of this batch's tagging (found while
--     checking sibling HWFWM books for consistency before deciding not
--     to tag that series this round) -- a verified, evidence-backed,
--     single-row fix, applied inline rather than left to be
--     rediscovered.
--
-- HIGH_RISK_FIELDS applied throughout (person/pov_count verified against
-- each series' own established pattern via sibling book_dna rows queried
-- before tagging, not defaulted from genre reputation -- e.g. Beneath the
-- Sugar Sky's POV structure checked against Wayward Children's own
-- precedent rather than assumed single-POV like most of the series;
-- Champion/Finale/Library of Souls/Specials/Curse for True Love pace_shape
-- set to slow_burn_to_fast_finish as trilogy finales, a deliberate
-- deviation from their own series' "consistent" pattern).
--
-- Children of Strife (Adrian Tchaikovsky, published 2026-03-13) is AFTER
-- this session's January 2026 knowledge cutoff -- tagged from its real
-- Hardcover-sourced synopsis plus very strong 3-book series-pattern
-- calibration (every one of person/drive/scifi_hardness/worldbuilding_
-- density/romance fields/stakes_scope was UNANIMOUS across all 3
-- predecessors), not fabricated. Fields with genuinely weaker basis
-- (pov_count, timeline, violence_frequency/intensity, personal_stakes,
-- emotional_resolution) are recorded at real, honest low confidence via
-- book_field_confidence rather than guessed at full confidence -- see
-- the confidence inserts below.
-- ============================================================
-- Author-field contamination fixes (idempotent via != guard)
-- ============================================================

update books set author = 'Victoria Aveyard'
where title = 'War Storm' and author <> 'Victoria Aveyard';

update books set author = 'Shirtaloon, Travis Deverell'
where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4'
  and author <> 'Shirtaloon, Travis Deverell';

-- ============================================================
-- 1. Twelve Months (Jim Butcher, The Dresden Files #18) -- completes 19/19
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'moderate', 'bittersweet', 'subtle',
  'occasional', 'low', null,
  'frequent', 'graphic', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Twelve Months'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'urban_fantasy_setting','magically_binding_bargain','reluctant_hero',
  'noir_detective_structure','immortal_or_ageless_character','arranged_marriage'
]) as t
where title = 'Twelve Months'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Twelve Months'
union all
select id, 'body_horror', 'moderate', false from books where title = 'Twelve Months'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Twelve Months'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 2. Children of Strife (Adrian Tchaikovsky, Children of Time #4) -- completes 4/4
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'worldbuilding_driven',
  'moderate', 'light', 'tense', 'moderate',
  'none', 'na', null,
  'occasional', 'moderate', 'dense',
  null, 'self_contained',
  'bittersweet', 'resolved', 'long',
  null,
  'na', 'hard', 'moderate', 'moderate',
  'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'Children of Strife'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'uplift','terraforming_or_space_colonization','first_contact'
]) as t
where title = 'Children of Strife'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'moderate', false from books where title = 'Children of Strife'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, c, 'ai_inferred' from books,
  (values ('pov_count',0.5), ('timeline',0.4), ('violence_frequency',0.4),
          ('violence_intensity',0.4), ('personal_stakes',0.4), ('emotional_resolution',0.5)
  ) as v(f, c)
where title = 'Children of Strife'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 3. Lords of Uncreation (Adrian Tchaikovsky, The Final Architecture #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'dark', 'moderate', 'tense', 'moderate',
  'none', 'na', null,
  'frequent', 'graphic', 'dense',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  null,
  'na', 'soft', 'moderate', 'moderate',
  'moderate', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'Lords of Uncreation'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'space_opera','ancient_evil_awakens','found_family','multiple_alien_species','war_story'
]) as t
where title = 'Lords of Uncreation'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Lords of Uncreation'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'Lords of Uncreation'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 4. War Storm (Victoria Aveyard, Red Queen #4) -- completes 4/4
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'ya', 'standard', 'several', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'light', 'gut_punch', 'moderate',
  'occasional', 'low', 'melodramatic',
  'frequent', 'graphic', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'War Storm'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'dystopia','rebellion_against_empire','morally_grey_protagonist','court_intrigue','war_story'
]) as t
where title = 'War Storm'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'brief', false from books where title = 'War Storm'
union all
select id, 'war_trauma', 'moderate', false from books where title = 'War Storm'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'War Storm'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 5. A Darkness at Sethanon (Raymond E. Feist, The Riftwar Saga #3) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'dark', 'light', 'tense', 'subtle',
  'rare', 'low', null,
  'frequent', 'graphic', 'dense',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'lush', 'moderate',
  'moderate', 'global', 'high', 'demanding'
from books where title = 'A Darkness at Sethanon'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'epic_quest','high_fantasy_setting','wise_mentor','war_story','ancient_evil_awakens'
]) as t
where title = 'A Darkness at Sethanon'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'A Darkness at Sethanon'
on conflict do nothing;

-- ============================================================
-- 6. Blood of the Fold (Terry Goodkind, Sword of Truth #3 tracked) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'long', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'grimdark', 'light', 'gut_punch', 'heavy_handed',
  'frequent', 'moderate', 'melodramatic',
  'frequent', 'brutal', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  null,
  'soft', 'na', 'moderate', 'moderate',
  'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'Blood of the Fold'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'chosen_one','epic_quest','prophecy','war_story','dark_lord_or_evil_overlord'
]) as t
where title = 'Blood of the Fold'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Blood of the Fold'
union all
select id, 'war_trauma', 'moderate', false from books where title = 'Blood of the Fold'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, c, 'ai_inferred' from books,
  (values ('romance_tone',0.5), ('ends_on_cliffhanger',0.6),
          ('romance_heat_frequency',0.5), ('message_intensity',0.5)
  ) as v(f, c)
where title = 'Blood of the Fold'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 7. Champion (Marie Lu, Legend #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'balanced',
  'moderate', 'light', 'gut_punch', 'moderate',
  'occasional', 'low', 'mixed',
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  null,
  'na', 'soft', 'sparse', 'accessible',
  'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Champion'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'dystopia','hidden_talent_prodigy','court_intrigue','rebellion_against_empire','major_character_death'
]) as t
where title = 'Champion'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Champion'
union all
select id, 'classism', 'brief', false from books where title = 'Champion'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Champion'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 8. Finale (Stephanie Garber, Caraval #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'ya', 'standard', 'dual', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'occasional', 'low', 'melodramatic',
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'lush', 'accessible',
  'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Finale'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'found_family','twist_ending','forbidden_love','arranged_marriage','hidden_identity_romance'
]) as t
where title = 'Finale'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'Finale'
union all
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Finale'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Finale'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 9. Library of Souls (Ransom Riggs, Miss Peregrine's Peculiar Children #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'occasional', 'low', 'understated',
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Library of Souls'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'ancient_evil_awakens','coming_of_age','found_family','time_loop','portal_fantasy'
]) as t
where title = 'Library of Souls'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Library of Souls'
union all
select id, 'body_horror', 'moderate', false from books where title = 'Library of Souls'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Library of Souls'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 10. Redemption Ark (Alastair Reynolds, Revelation Space #2 tracked) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'adult', 'long', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven',
  'dark', 'none', 'tense', 'subtle',
  'rare', 'low', null,
  'occasional', 'graphic', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  null,
  'na', 'hard', 'lush', 'dense',
  'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Redemption Ark'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'ancient_evil_awakens','space_opera','cybernetic_enhancement','lost_civilizations','cryosleep'
]) as t
where title = 'Redemption Ark'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Redemption Ark'
on conflict do nothing;

-- ============================================================
-- 11. Specials (Scott Westerfeld, Uglies #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'moderate', 'light', 'tense', 'moderate',
  'occasional', 'low', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  null,
  'na', 'soft', 'sparse', 'accessible',
  'moderate', 'regional', 'high', 'accessible'
from books where title = 'Specials'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'coming_of_age','dystopia','underdog_rising','survivalist_ingenuity','rebellion_against_empire'
]) as t
where title = 'Specials'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Specials'
union all
select id, 'classism', 'brief', false from books where title = 'Specials'
on conflict do nothing;

-- ============================================================
-- 12. A Curse for True Love (Stephanie Garber, Once Upon a Broken Heart #3) -- completes 3/3
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'romance_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'occasional', 'low', 'mixed',
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'lush', 'accessible',
  'moderate', 'intimate', 'high', 'accessible'
from books where title = 'A Curse for True Love'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'cursed_protagonist','enemies_to_lovers','mythological_retelling','magically_binding_bargain','slow_burn_romance'
]) as t
where title = 'A Curse for True Love'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'A Curse for True Love'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'A Curse for True Love'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 13. Beneath the Sugar Sky (Seanan McGuire, Wayward Children #3 tracked) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'ya', 'short', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven',
  'moderate', 'moderate', 'bittersweet', 'subtle',
  'rare', 'low', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'short',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Beneath the Sugar Sky'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'found_family','portal_fantasy','epic_quest','long_journey'
]) as t
where title = 'Beneath the Sugar Sky'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', false from books where title = 'Beneath the Sugar Sky'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'personal_stakes', 0.5, 'ai_inferred' from books where title = 'Beneath the Sugar Sky'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 14. A Trade of Blood (Robert Jackson Bennett, Ana and Din Mysteries #3 tracked) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'none', 'na', null,
  'occasional', 'moderate', 'dense',
  null, 'requires_series',
  'bittersweet', 'resolved', 'standard',
  null,
  'hard', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'high', 'moderate'
from books where title = 'A Trade of Blood'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'court_intrigue','noir_detective_structure','new_weird_setting','hidden_talent_prodigy','powerful_artifact_macguffin'
]) as t
where title = 'A Trade of Blood'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'brief', false from books where title = 'A Trade of Blood'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, c, 'ai_inferred' from books,
  (values ('pov_count',0.5), ('narrative_closure',0.5)) as v(f, c)
where title = 'A Trade of Blood'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 15. Livesuit (James S. A. Corey, The Captive's War #1.5) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'light', 'tense', 'subtle',
  'rare', 'low', null,
  'frequent', 'graphic', 'moderate',
  null, 'self_contained',
  'tragic', 'resolved', 'short',
  null,
  'na', 'hard', 'sparse', 'moderate',
  'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Livesuit'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'space_opera','war_story','cybernetic_enhancement','multiple_alien_species'
]) as t
where title = 'Livesuit'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Livesuit'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, c, 'ai_inferred' from books,
  (values ('pov_count',0.5), ('worldbuilding_density',0.5)) as v(f, c)
where title = 'Livesuit'
on conflict (book_id, field_name) do nothing;

-- ============================================================
-- 16. Brigands & Breadknives (Travis Baldree, Legends & Lattes #3 tracked) -- completes 3/3 tracked
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'short', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven',
  'light', 'moderate', 'comfort_read', 'subtle',
  'occasional', 'low', 'understated',
  'rare', 'mild', 'light',
  null, 'self_contained',
  'happy', 'resolved', 'short',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'intimate', 'moderate', 'accessible'
from books where title = 'Brigands & Breadknives'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'found_family','multiple_fantasy_species','slow_burn_romance'
]) as t
where title = 'Brigands & Breadknives'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'Brigands & Breadknives'
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Brigands & Breadknives'
on conflict (book_id, field_name) do nothing;

update book_tropes set confidence = 0.5, source = 'ai_inferred'
where trope_id = 'slow_burn_romance'
  and book_id = (select id from books where title = 'Brigands & Breadknives');

-- ============================================================
-- 17. Skysworn (Will Wight, Cradle #4) -- Cradle now 4/10 tagged
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'short', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'none', 'na', null,
  'frequent', 'graphic', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'short',
  null,
  'hard', 'na', 'sparse', 'accessible',
  'escapist', 'regional', 'high', 'moderate'
from books where title = 'Skysworn'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'litrpg_or_progression_fantasy','hidden_talent_prodigy','underdog_rising','wise_mentor','deadly_competition_or_trial'
]) as t
where title = 'Skysworn'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'ableism_depicted', 'moderate', false from books where title = 'Skysworn'
on conflict do nothing;

-- ============================================================
-- 18. Ghostwater (Will Wight, Cradle #5) -- Cradle now 5/10 tagged
-- ============================================================

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['fantasy'], 'adult', 'short', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'none', 'na', null,
  'frequent', 'graphic', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'short',
  null,
  'hard', 'na', 'sparse', 'accessible',
  'escapist', 'regional', 'high', 'moderate'
from books where title = 'Ghostwater'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'litrpg_or_progression_fantasy','hidden_talent_prodigy','underdog_rising','wise_mentor','survivalist_ingenuity'
]) as t
where title = 'Ghostwater'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Ghostwater'
on conflict do nothing;
