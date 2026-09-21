-- Catalog tagging batch 12: 18 books, full Book DNA (CLDA)
-- Round-5 pool, partial-series-first prioritization (Step 2 query).
--
-- Completes: Cradle (10/10), He Who Fights with Monsters (8/8),
-- The Founders Trilogy (3/3), The Daevabad Trilogy (3/3),
-- The Kane Chronicles (3/3), The Rain Wild Chronicles (3/3),
-- Shattered Sea (2/2 in-catalog), The Iron Druid Chronicles (2/2
-- in-catalog), Rivers of London (2/2 in-catalog). Moves The Faithful
-- and the Fallen closer (3/3 of what's in-catalog -- book 3 "Ruin"
-- was never ingested into this catalog at all, a real ingestion gap
-- flagged for the repo owner, not something this tagging batch fixes).
--
-- Author-field check: "He Who Fights with Monsters" 4-8 all list
-- author = 'Shirtaloon, Travis Deverell'. Verified via Hardcover's own
-- cached_contributors GraphQL data (author ids 241312 "Shirtaloon" and
-- 333525 "Travis Deverell") that BOTH names carry contributor role
-- "Author" on every one of these 5 books -- not an illustrator/
-- translator/narrator credit slipping in. This is the same person's
-- pen name and legal name both credited as author by Hardcover itself,
-- not contamination. No fix needed. Every other book in this batch has
-- a single, unambiguous author.
--
-- Genuine plot-detail uncertainty flagged inline via book_field_confidence
-- (scalar fields) and book_tropes.confidence (trope rows) rather than
-- guessed at full confidence -- this session's web-search budget was
-- exhausted before reaching this batch, so later-series plot specifics
-- for Cradle (books 6-10) and He Who Fights with Monsters (books 4-8)
-- lean on carried-forward series-craft consistency (same author's
-- established style across an unbroken series -- high confidence) plus
-- honest, lower-confidence calls on plot-specific escalation (mainly
-- stakes_scope, a HIGH_RISK_FIELD, and emotional_resolution/
-- romance_tone/worldbuilding_delivery where evidence wasn't directly
-- checked this session). See project-log.md's batch-12 entry.
--
-- Density note: this batch skews heavily toward action-adventure
-- progression-fantasy/LitRPG (10 of 18 books are Cradle or He Who
-- Fights with Monsters) plus one MG book (The Serpent's Shadow) --
-- genres that legitimately carry fewer content_warnings-vocabulary
-- hits than the catalog's grimdark/literary-fantasy-heavy average.
-- Checked, not skipped -- see project-log.md for the actual density
-- numbers and reasoning, not just the check having happened.

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'Underlord';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Underlord';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Underlord';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Underlord';
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Underlord';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Underlord';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Underlord'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'Uncrowned';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Uncrowned';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Uncrowned';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Uncrowned';
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Uncrowned';
insert into book_tropes (book_id, trope_id)
select id, 'deadly_competition_or_trial' from books where title = 'Uncrowned';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Uncrowned';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Uncrowned'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'Wintersteel';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Wintersteel';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Wintersteel';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Wintersteel';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'wise_mentor', 0.6, 'ai_inferred' from books where title = 'Wintersteel';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'ancient_evil_awakens', 0.6, 'ai_inferred' from books where title = 'Wintersteel';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'war_story', 0.5, 'ai_inferred' from books where title = 'Wintersteel';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Wintersteel';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Wintersteel';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'Wintersteel'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Wintersteel'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'Bloodline';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Bloodline';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Bloodline';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Bloodline';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'ancient_evil_awakens', 0.6, 'ai_inferred' from books where title = 'Bloodline';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'war_story', 0.5, 'ai_inferred' from books where title = 'Bloodline';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Bloodline';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Bloodline';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'Bloodline'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Bloodline'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'Reaper';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Reaper';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Reaper';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Reaper';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'ancient_evil_awakens', 0.6, 'ai_inferred' from books where title = 'Reaper';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'war_story', 0.5, 'ai_inferred' from books where title = 'Reaper';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Reaper';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Reaper';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'Reaper'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Reaper'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';

insert into book_tropes (book_id, trope_id)
select id, 'isekai' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';
insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'court_intrigue', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 4: He Who Fights with Monsters, Book 4'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'He Who Fights with Monsters 5';

insert into book_tropes (book_id, trope_id)
select id, 'isekai' from books where title = 'He Who Fights with Monsters 5';
insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights with Monsters 5';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'He Who Fights with Monsters 5';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'satirical_or_comedic_fantasy', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 5';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 5'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 5'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 5'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'He Who Fights With Monsters 6';

insert into book_tropes (book_id, trope_id)
select id, 'isekai' from books where title = 'He Who Fights With Monsters 6';
insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights With Monsters 6';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'He Who Fights With Monsters 6';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'found_family', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 6';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'underdog_rising', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 6';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 6'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 6'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 6'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'He Who Fights with Monsters 7';

insert into book_tropes (book_id, trope_id)
select id, 'isekai' from books where title = 'He Who Fights with Monsters 7';
insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights with Monsters 7';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'He Who Fights with Monsters 7';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'underdog_rising', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 7';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 7'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 7'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'He Who Fights with Monsters 7'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', null, 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'He Who Fights With Monsters 8';

insert into book_tropes (book_id, trope_id)
select id, 'isekai' from books where title = 'He Who Fights With Monsters 8';
insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights With Monsters 8';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'He Who Fights With Monsters 8';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'underdog_rising', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 8';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 8'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 8'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'He Who Fights With Monsters 8'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', null, 'frequent', 'graphic', 'dense', 'exposition_dump', 'self_contained', 'bittersweet', 'resolved', 'long', null, 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'Locklands';

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Locklands';
insert into book_tropes (book_id, trope_id)
select id, 'hive_mind' from books where title = 'Locklands';
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Locklands';
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Locklands';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Locklands';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'central_theme', false from books where title = 'Locklands';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Locklands'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'Locklands'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'brutal', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'epic', null, 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Empire of Gold';

insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Empire of Gold';
insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'The Empire of Gold';
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'The Empire of Gold';
insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'The Empire of Gold';
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'The Empire of Gold';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'moderate', false from books where title = 'The Empire of Gold';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Empire of Gold';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'moderate', true from books where title = 'The Empire of Gold';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'The Empire of Gold'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'ya', 'standard', 'dual', 'first', 'reliable', 'linear', 'framing_device', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'tense', 'subtle', 'occasional', 'low', null, 'occasional', 'mild', 'dense', null, 'self_contained', 'happy', 'resolved', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Serpent''s Shadow';

insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'The Serpent''s Shadow';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Serpent''s Shadow';
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'The Serpent''s Shadow';
insert into book_tropes (book_id, trope_id)
select id, 'villain_turns_ally' from books where title = 'The Serpent''s Shadow';


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', null, 'frequent', 'brutal', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'epic', null, 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'life_threatening', 'moderate'
from books where title = 'Wrath';

insert into book_tropes (book_id, trope_id)
select id, 'chosen_one' from books where title = 'Wrath';
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Wrath';
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Wrath';
insert into book_tropes (book_id, trope_id)
select id, 'prophecy' from books where title = 'Wrath';
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'Wrath';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Wrath';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Wrath'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'low', 'understated', 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', null, 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'demanding'
from books where title = 'The Dragon Keeper';

insert into book_tropes (book_id, trope_id)
select id, 'dragons' from books where title = 'The Dragon Keeper';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Dragon Keeper';
insert into book_tropes (book_id, trope_id)
select id, 'telepathic_animal_bond' from books where title = 'The Dragon Keeper';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Dragon Keeper';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'ableism_depicted', 'moderate', false from books where title = 'The Dragon Keeper';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'The Dragon Keeper'
on conflict (book_id, field_name) do nothing;


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'brutal', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', null, 'na', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Half the World';

insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Half the World';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Half the World';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Half the World';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Half the World';
insert into book_tropes (book_id, trope_id)
select id, 'long_journey' from books where title = 'Half the World';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Half the World';


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', null, 'frequent', 'moderate', 'dense', null, 'requires_series', 'happy', 'resolved', 'standard', null, 'hard', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Hexed';

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Hexed';
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Hexed';
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'Hexed';
insert into book_tropes (book_id, trope_id)
select id, 'telepathic_animal_bond' from books where title = 'Hexed';
insert into book_tropes (book_id, trope_id)
select id, 'urban_fantasy_setting' from books where title = 'Hexed';


insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', null, 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Moon Over Soho';

insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'Moon Over Soho';
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'Moon Over Soho';
insert into book_tropes (book_id, trope_id)
select id, 'urban_fantasy_setting' from books where title = 'Moon Over Soho';
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Moon Over Soho';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Moon Over Soho';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'moderate', true from books where title = 'Moon Over Soho';
