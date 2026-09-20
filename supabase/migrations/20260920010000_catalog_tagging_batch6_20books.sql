-- Batch 6 catalog tagging: 20 books (CLDA, 2026-09-20)
-- Full book_dna + tropes + content_warnings for a round-4-expansion batch
-- picked from series with zero tagged books yet (round-4 partial-series pool
-- is fully exhausted catalog-wide as of 2026-09-16) -- each book tagged on its
-- own merits. Author-contamination check run via Hardcover cached_contributors
-- on the two flagged books: The Deep's 4-name author field confirmed genuine
-- (all 4 contributors carry no specific role -- clipping.'s Daveed Diggs/William
-- Hutson/Jonathan Snipes are real co-creators of the underlying concept, not
-- illustrator/narrator contamination); The Fold's "Ray Porter" confirmed the
-- audiobook narrator (contribution: "Narrator") and removed from author field.

update books set author = 'Peter Clines'
where title = 'The Fold' and author = 'Peter Clines, Ray Porter';

-- Aurora Rising
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'ya', 'standard', 'several', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'escapist', 'global', 'high', 'accessible'
from books where title = 'Aurora Rising'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'chosen_one', 0.5, 'ai_inferred' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multiple_alien_species' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cryosleep' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'secret_royalty', 0.5, 'ai_inferred' from books where title = 'Aurora Rising'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'moderate', false from books where title = 'Aurora Rising'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'Aurora Rising'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Aurora Rising'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Aurora Rising'
on conflict (book_id, field_name) do nothing;

-- Automatic Noodle
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'light', 'comfort_read', 'moderate', 'none', 'na', null, 'rare', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'low', 'accessible'
from books where title = 'Automatic Noodle'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Automatic Noodle'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Automatic Noodle'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'android_or_replicant_rights' from books where title = 'Automatic Noodle'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'Automatic Noodle'
on conflict (book_id, warning_id) do nothing;

-- Dauntless
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'moderate', 'global', 'high', 'accessible'
from books where title = 'Dauntless'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Dauntless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'reluctant_hero' from books where title = 'Dauntless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cryosleep' from books where title = 'Dauntless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Dauntless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'survivalist_ingenuity', 0.5, 'ai_inferred' from books where title = 'Dauntless'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Dauntless'
on conflict (book_id, warning_id) do nothing;

-- Gild
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Gild'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'Gild'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'Gild'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'fae_or_fairies' from books where title = 'Gild'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'reverse_harem_or_why_choose', 0.5, 'ai_inferred' from books where title = 'Gild'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'central_theme', false from books where title = 'Gild'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'central_theme', false from books where title = 'Gild'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Gild'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Gild'
on conflict (book_id, field_name) do nothing;

-- Let the Right One In
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'frequent', 'brutal', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'moderate'
from books where title = 'Let the Right One In'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'vampires' from books where title = 'Let the Right One In'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Let the Right One In'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Let the Right One In'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Let the Right One In'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'revenge', 0.5, 'ai_inferred' from books where title = 'Let the Right One In'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'bullying', 'central_theme', false from books where title = 'Let the Right One In'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', false from books where title = 'Let the Right One In'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_sexual_abuse', 'moderate', true from books where title = 'Let the Right One In'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Let the Right One In'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'suicide', 'moderate', true from books where title = 'Let the Right One In'
on conflict (book_id, warning_id) do nothing;

-- My Heart Is a Chainsaw
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'unreliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'moderate', 'gut_punch', 'moderate', 'none', 'na', null, 'frequent', 'brutal', 'light', null, 'requires_series', 'bittersweet', 'resolved', 'long', 'none', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'moderate'
from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_filled', 0.5, 'ai_inferred' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'revenge', 0.5, 'ai_inferred' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'central_theme', false from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'My Heart Is a Chainsaw'
on conflict (book_id, field_name) do nothing;

-- Neon Gods
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'frequent', 'explicit', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'high', 'gateway'
from books where title = 'Neon Gods'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'Neon Gods'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'arranged_marriage' from books where title = 'Neon Gods'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'Neon Gods'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'age_gap_romance', 0.5, 'ai_inferred' from books where title = 'Neon Gods'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'Neon Gods'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'moderate', false from books where title = 'Neon Gods'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'Neon Gods'
on conflict (book_id, warning_id) do nothing;

-- Orbital
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', null, 'none', 'na', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'hard', 'lush', 'dense', 'cerebral', 'intimate', 'low', 'demanding'
from books where title = 'Orbital'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Orbital'
on conflict (book_id, field_name) do nothing;

-- Phantasma
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'romance_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', null, 'frequent', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'gateway'
from books where title = 'Phantasma'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'deadly_competition_or_trial' from books where title = 'Phantasma'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'Phantasma'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'monster_or_fae_romance' from books where title = 'Phantasma'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'mythological_retelling', 0.5, 'ai_inferred' from books where title = 'Phantasma'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Phantasma'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Phantasma'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Phantasma'
on conflict (book_id, warning_id) do nothing;

-- Spark of the Everflame
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'Spark of the Everflame'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'enemies_to_lovers' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dragons' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'fated_mates', 0.5, 'ai_inferred' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'chosen_one', 0.5, 'ai_inferred' from books where title = 'Spark of the Everflame'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'Spark of the Everflame'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Spark of the Everflame'
on conflict (book_id, warning_id) do nothing;

-- The Bridge Kingdom
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'The Bridge Kingdom'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'enemies_to_lovers' from books where title = 'The Bridge Kingdom'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'arranged_marriage' from books where title = 'The Bridge Kingdom'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'The Bridge Kingdom'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'The Bridge Kingdom'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Bridge Kingdom'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Bridge Kingdom'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'brief', false from books where title = 'The Bridge Kingdom'
on conflict (book_id, warning_id) do nothing;

-- The Darkest Minds
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'ya', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Darkest Minds'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'government_experimentation_on_the_gifted' from books where title = 'The Darkest Minds'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Darkest Minds'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'The Darkest Minds'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'The Darkest Minds'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'The Darkest Minds'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', true from books where title = 'The Darkest Minds'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'central_theme', false from books where title = 'The Darkest Minds'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Darkest Minds'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'pandemic_or_epidemic', 'moderate', false from books where title = 'The Darkest Minds'
on conflict (book_id, warning_id) do nothing;

-- The Darkness That Comes Before
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'occasional', 'moderate', null, 'frequent', 'brutal', 'dense', null, 'requires_series', 'tragic', 'cliffhanger', 'long', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'The Darkness That Comes Before'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'villain_protagonist' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'prophecy' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'chosen_one', 0.5, 'ai_inferred' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'central_theme', false from books where title = 'The Darkness That Comes Before'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Darkness That Comes Before'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Darkness That Comes Before'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Darkness That Comes Before'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'The Darkness That Comes Before'
on conflict (book_id, field_name) do nothing;

-- The Deep
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'bittersweet', 'moderate', 'rare', 'low', null, 'rare', 'moderate', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high', 'moderate'
from books where title = 'The Deep'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'multi_generational_saga', 0.5, 'ai_inferred' from books where title = 'The Deep'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'sapphic_romance' from books where title = 'The Deep'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Deep'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'central_theme', false from books where title = 'The Deep'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Deep'
on conflict (book_id, warning_id) do nothing;

-- The Dispatcher
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'gateway'
from books where title = 'The Dispatcher'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'The Dispatcher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.6, 'ai_inferred' from books where title = 'The Dispatcher'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Dispatcher'
on conflict (book_id, warning_id) do nothing;

-- The Ex Hex
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'romance_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', null, 'rare', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'moderate', 'gateway'
from books where title = 'The Ex Hex'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'second_chance_romance' from books where title = 'The Ex Hex'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'urban_fantasy_setting' from books where title = 'The Ex Hex'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'The Ex Hex'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'grumpy_sunshine', 0.5, 'ai_inferred' from books where title = 'The Ex Hex'
on conflict (book_id, trope_id) do nothing;

-- The Fold
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Fold'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'cosmic_horror', 0.5, 'ai_inferred' from books where title = 'The Fold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.6, 'ai_inferred' from books where title = 'The Fold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'ancient_evil_awakens', 0.5, 'ai_inferred' from books where title = 'The Fold'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', true from books where title = 'The Fold'
on conflict (book_id, warning_id) do nothing;

-- The Gilded Ones
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Gilded Ones'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'chosen_one', 0.5, 'ai_inferred' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'revenge', 0.5, 'ai_inferred' from books where title = 'The Gilded Ones'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'central_theme', false from books where title = 'The Gilded Ones'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', false from books where title = 'The Gilded Ones'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Gilded Ones'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'The Gilded Ones'
on conflict (book_id, warning_id) do nothing;

-- The Girl Who Fell Beneath the Sea
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'moderate', 'light', 'bittersweet', 'subtle', 'occasional', 'low', null, 'rare', 'mild', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'portal_fantasy' from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'The Girl Who Fell Beneath the Sea'
on conflict (book_id, warning_id) do nothing;

-- The Hurricane Wars
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'dark', 'light', 'tense', 'subtle', 'occasional', 'moderate', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'high', 'moderate'
from books where title = 'The Hurricane Wars'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'enemies_to_lovers' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'secret_royalty', 0.5, 'ai_inferred' from books where title = 'The Hurricane Wars'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Hurricane Wars'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'central_theme', false from books where title = 'The Hurricane Wars'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'moderate', true from books where title = 'The Hurricane Wars'
on conflict (book_id, warning_id) do nothing;
