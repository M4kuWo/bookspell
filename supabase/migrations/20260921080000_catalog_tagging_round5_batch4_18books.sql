-- Round-5 tagging batch 4 (CLDA). 18 books, full Book DNA.
-- Prioritized partial-series completion per tag-catalog-batch's Step 2 query:
-- completes Codex Alera (Jim Butcher, 5/5), The Belgariad (David Eddings, 5/5),
-- Sookie Stackhouse (Charlaine Harris, 4/4), The Legend of Drizzt's Sojourn +
-- The Crystal Shard (R.A. Salvatore, brings that series to 3/3), and completes
-- 5 two-book series (The Carls, Jackpot, Memory Sorrow and Thorn, Magic 2.0,
-- Expeditionary Force) to 2/2 each -- 9 series unlocked/completed for Series DNA
-- in one batch.
--
-- Skipped per instructions: The Thorn of Emberlain (Scott Lynch, confirmed
-- unpublished) and Holly (Stephen King, round-4 open scope question), both
-- surfaced by the Step 2 query but explicitly out of scope for this batch.
-- Also skipped: The Book of the New Sun (Gene Wolfe) and 1Q84: Book 1
-- (Murakami) -- both are the omnibus/compilation-duplicate situation flagged
-- in docs/schema/book-dna.md's Future fields backlog (the same underlying
-- work already has 2 tagged catalog entries under different edition titles --
-- "The Shadow of the Torturer"/"Shadow & Claw" and "1Q84" respectively) --
-- not mine to resolve, flagged for the repo owner instead of tagged.
--
-- Author-field contamination fix (Hardcover cached_contributors verified):
-- "The Crystal Shard" carried "R. A. Salvatore, Larry Elmore" -- Larry Elmore
-- is the cover illustrator (confirmed via Hardcover API contributor_role_name
-- = "Illustrator"), not a co-author. Fixed inline below, same migration.
--
-- narrator_cast: none of these 18 books have an audiobook_editions row yet,
-- so it's left NULL throughout (per the skill's data-doesn't-exist-yet rule),
-- not computed/guessed.

-- ============ Author contamination fix ============
update books set author = 'R. A. Salvatore'
where title = 'The Crystal Shard' and author = 'R. A. Salvatore, Larry Elmore';

-- ============ Codex Alera (Jim Butcher) #3-6 ============

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
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'rare', 'low', null,
  'frequent', 'graphic', 'dense',
  'woven', 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Cursor''s Fury'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Cursor''s Fury'
on conflict (book_id, field_name) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'dark', 'light', 'tense', 'subtle',
  'occasional', 'low', null,
  'frequent', 'graphic', 'dense',
  'woven', 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Captain''s Fury'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Captain''s Fury'
on conflict (book_id, field_name) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'dark', 'light', 'tense', 'subtle',
  'occasional', 'low', null,
  'frequent', 'graphic', 'dense',
  'woven', 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Princeps'' Fury'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Princeps'' Fury'
on conflict (book_id, field_name) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'light', 'tense', 'subtle',
  'occasional', 'low', null,
  'frequent', 'graphic', 'dense',
  'woven', 'self_contained',
  'happy', 'resolved', 'long',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'First Lord''s Fury'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'First Lord''s Fury'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['war_story','found_family','rebellion_against_empire','coming_of_age']) as t
where title = 'Cursor''s Fury'
on conflict do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'slow_burn_romance', 0.4, 'ai_inferred' from books where title = 'Cursor''s Fury'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['war_story','court_intrigue','multiple_fantasy_species','last_minute_rescue','found_family']) as t
where title = 'Captain''s Fury'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['war_story','court_intrigue','multiple_fantasy_species','last_minute_rescue']) as t
where title = 'Princeps'' Fury'
on conflict do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'major_character_death', 0.5, 'ai_inferred' from books where title = 'Princeps'' Fury'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['war_story','court_intrigue','multiple_fantasy_species','last_minute_rescue','underdog_rising']) as t
where title = 'First Lord''s Fury'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Cursor''s Fury'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, 'moderate', false from books, unnest(array['war_trauma','body_horror']) as w
where title = 'Captain''s Fury'
on conflict do nothing;
update book_content_warnings set severity = 'central_theme'
where book_id = (select id from books where title = 'Captain''s Fury') and warning_id = 'war_trauma';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Princeps'' Fury'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, 'moderate', false from books, unnest(array['war_trauma','body_horror']) as w
where title = 'First Lord''s Fury'
on conflict do nothing;
update book_content_warnings set severity = 'central_theme'
where book_id = (select id from books where title = 'First Lord''s Fury') and warning_id = 'war_trauma';

-- ============ The Belgariad (David Eddings) #2-5 ============

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'light', 'moderate', 'comfort_read', 'subtle',
  'rare', 'low', null,
  'rare', 'mild', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'sparse', 'accessible',
  'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'Queen of Sorcery'
on conflict (book_id) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'light', 'moderate', 'comfort_read', 'subtle',
  'rare', 'low', null,
  'rare', 'mild', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'sparse', 'accessible',
  'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'Magician''s Gambit'
on conflict (book_id) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'comfort_read', 'subtle',
  'occasional', 'low', null,
  'occasional', 'moderate', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'sparse', 'accessible',
  'escapist', 'global', 'high', 'gateway'
from books where title = 'Castle of Wizardry'
on conflict (book_id) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'comfort_read', 'subtle',
  'occasional', 'low', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'sparse', 'accessible',
  'escapist', 'global', 'life_threatening', 'gateway'
from books where title = 'Enchanters'' End Game'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['epic_quest','prophecy','chosen_one','long_journey','coming_of_age','powerful_artifact_macguffin']) as t
where title = 'Queen of Sorcery'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['epic_quest','prophecy','chosen_one','long_journey','found_family','powerful_artifact_macguffin']) as t
where title = 'Magician''s Gambit'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['epic_quest','prophecy','chosen_one','secret_royalty','underdog_rising','ancient_evil_awakens','powerful_artifact_macguffin']) as t
where title = 'Castle of Wizardry'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['epic_quest','prophecy','chosen_one','secret_royalty','underdog_rising','ancient_evil_awakens','powerful_artifact_macguffin','war_story']) as t
where title = 'Enchanters'' End Game'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, 'moderate', false from books, unnest(array['slavery','substance_abuse']) as w
where title = 'Queen of Sorcery'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'Magician''s Gambit'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Castle of Wizardry'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Enchanters'' End Game'
on conflict do nothing;

-- ============ Sookie Stackhouse (Charlaine Harris) #2-4 ============

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'moderate', 'moderate', 'comfort_read', 'subtle',
  'frequent', 'explicit', 'understated',
  'occasional', 'graphic', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Living Dead in Dallas'
on conflict (book_id) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'moderate', 'moderate', 'comfort_read', 'subtle',
  'frequent', 'explicit', 'understated',
  'occasional', 'graphic', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Club Dead'
on conflict (book_id) do nothing;

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
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'moderate', 'moderate', 'comfort_read', 'subtle',
  'frequent', 'explicit', 'understated',
  'occasional', 'graphic', 'moderate',
  null, 'requires_series',
  'bittersweet', 'resolved', 'standard',
  null,
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Dead to the World'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books
where title in ('Living Dead in Dallas', 'Club Dead', 'Dead to the World')
on conflict (book_id, field_name) do nothing;

-- Dead to the World is a genuine judgment call between character_driven (kept,
-- matching the series' consistent narrative identity) and romance_driven
-- (the amnesiac-Eric plot is unusually romance-heavy for this series) --
-- recorded as real uncertainty rather than silently picking one.
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Dead to the World'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['monster_or_fae_romance','vampires','noir_detective_structure','infiltration_or_undercover_plot']) as t
where title = 'Living Dead in Dallas'
on conflict do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.4, 'ai_inferred' from books where title = 'Living Dead in Dallas'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['monster_or_fae_romance','vampires','noir_detective_structure','love_triangle','infiltration_or_undercover_plot']) as t
where title = 'Club Dead'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['monster_or_fae_romance','vampires','noir_detective_structure','love_triangle','forced_proximity','amnesia_driven_narrative']) as t
where title = 'Dead to the World'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'Living Dead in Dallas'
on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Living Dead in Dallas'
on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'brief', false from books where title = 'Living Dead in Dallas'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Club Dead'
on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'Club Dead'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Dead to the World'
on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'Dead to the World'
on conflict do nothing;

-- ============ The Legend of Drizzt (R.A. Salvatore) ============

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
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'dark', 'light', 'bittersweet', 'moderate',
  'none', 'na', null,
  'occasional', 'graphic', 'dense',
  'woven', 'requires_series',
  'bittersweet', 'resolved', 'standard',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'Sojourn'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Sojourn'
on conflict (book_id, field_name) do nothing;

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
select id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'none', 'na', null,
  'frequent', 'graphic', 'dense',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'hard', 'na', 'moderate', 'accessible',
  'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Crystal Shard'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['survivalist_ingenuity','wise_mentor','multiple_fantasy_species','underdog_rising']) as t
where title = 'Sojourn'
on conflict do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'mentor_death', 0.5, 'ai_inferred' from books where title = 'Sojourn'
on conflict do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['powerful_artifact_macguffin','dark_lord_or_evil_overlord','found_family','war_story','underdog_rising','dragons','multiple_fantasy_species']) as t
where title = 'The Crystal Shard'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Sojourn'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Crystal Shard'
on conflict do nothing;

-- ============ 5 two-book-series completions ============

-- The Carls (Hank Green) #2 -- series finale
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
select id, array['sci_fi'], 'adult', 'standard', 'several', 'mixed',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven',
  'dark', 'moderate', 'tense', 'moderate',
  'occasional', 'low', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  null,
  'na', 'soft', 'moderate', 'accessible',
  'cerebral', 'global', 'high', 'moderate'
from books where title = 'A Beautifully Foolish Endeavor'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'A Beautifully Foolish Endeavor'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['ai_consciousness','first_contact','corruption_arc','found_family']) as t
where title = 'A Beautifully Foolish Endeavor'
on conflict do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.5, 'ai_inferred' from books where title = 'A Beautifully Foolish Endeavor'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'moderate', false from books where title = 'A Beautifully Foolish Endeavor'
on conflict do nothing;

-- Jackpot (William Gibson) #2
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
select id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_limited',
  'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'dark', 'light', 'tense', 'moderate',
  'rare', 'low', null,
  'occasional', 'moderate', 'dense',
  null, 'requires_series',
  'ambiguous', 'cliffhanger', 'standard',
  null,
  'na', 'hard', 'lush', 'dense',
  'cerebral', 'cosmic', 'high', 'demanding'
from books where title = 'Agency'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['ai_consciousness','parallel_universe_or_multiverse','virtual_reality_or_simulated_world','cybernetic_enhancement','corruption_arc']) as t
where title = 'Agency'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, 'brief', false from books, unnest(array['war_trauma','substance_abuse','classism']) as w
where title = 'Agency'
on conflict do nothing;

-- Memory, Sorrow, and Thorn (Tad Williams) #2
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
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven',
  'dark', 'light', 'tense', 'subtle',
  'rare', 'low', null,
  'occasional', 'graphic', 'dense',
  'exposition_dump', 'requires_series',
  'bittersweet', 'cliffhanger', 'epic',
  null,
  'soft', 'na', 'moderate', 'dense',
  'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'Stone of Farewell'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Stone of Farewell'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['ancient_evil_awakens','chosen_one','coming_of_age','epic_quest','high_fantasy_setting','long_journey','medieval_european_setting','multiple_fantasy_species','powerful_artifact_macguffin','prophecy','war_story','wise_mentor']) as t
where title = 'Stone of Farewell'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Stone of Farewell'
on conflict do nothing;

-- Magic 2.0 (Scott Meyer) #2
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
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'light', 'heavy', 'comfort_read', 'subtle',
  'rare', 'low', null,
  'rare', 'mild', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'hard', 'soft', 'sparse', 'accessible',
  'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'Spell or High Water'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['satirical_or_comedic_fantasy','modern_knowledge_as_power_source','found_family','medieval_european_setting','portal_fantasy','time_travel']) as t
where title = 'Spell or High Water'
on conflict do nothing;

-- Expeditionary Force (Craig Alanson) #2
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
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'heavy', 'tense', 'subtle',
  'none', 'na', null,
  'frequent', 'moderate', 'moderate',
  null, 'requires_series',
  'happy', 'resolved', 'standard',
  null,
  'na', 'soft', 'sparse', 'accessible',
  'escapist', 'global', 'life_threatening', 'gateway'
from books where title = 'SpecOps'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['ai_consciousness','found_family','mutual_human_alien_war','satirical_or_comedic_scifi','war_story','space_opera','lost_civilizations']) as t
where title = 'SpecOps'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'SpecOps'
on conflict do nothing;
