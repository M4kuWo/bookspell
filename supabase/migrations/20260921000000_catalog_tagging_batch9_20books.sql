-- Catalog tagging batch 9 (CLDA): 20 books, full Book DNA + tropes + content
-- warnings, plus 5 inline author-field contamination fixes (verified via
-- Hardcover cached_contributors). Deliberately genre-blend/borderline-literary
-- picks (Orlando, Life After Life, If I Stay, Ficciones, The House of the
-- Spirits) screened and selected by the coordinating CLDA session -- each has a
-- real, specific, checkable speculative-fiction mechanism, not just genre vibes.
-- This is the last clean batch of round-4 tagging; the ~118 remaining untagged
-- books are non-SFF leakage needing a repo-owner scope decision (see TODO.md).

-- ===== 14 =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'closed_door', null, 'occasional', 'graphic', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = '14';

insert into book_tropes (book_id, trope_id) select id, 'engineered_creation_escapes_control' from books where title = '14';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = '14';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = '14';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = '14';
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = '14';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = '14';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = '14' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = '14' on conflict (book_id, field_name) do nothing;


-- ===== A Dirty Job =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'bittersweet', 'subtle', 'rare', 'closed_door', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'A Dirty Job';

insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Dirty Job';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Dirty Job';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'A Dirty Job';
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'A Dirty Job';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'A Dirty Job';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'A Dirty Job' on conflict (book_id, field_name) do nothing;


-- ===== Anthem =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'heavy_handed', 'rare', 'closed_door', null, 'rare', 'moderate', 'moderate', 'exposition_dump', 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'accessible'
from books where title = 'Anthem';

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Anthem';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Anthem';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Anthem';


-- ===== Brave New World / Brave New World Revisited =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'few', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'occasional', 'low', null, 'rare', 'mild', 'dense', 'exposition_dump', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'moderate', 'demanding'
from books where title = 'Brave New World / Brave New World Revisited';

insert into book_tropes (book_id, trope_id) select id, 'caste_or_faction_stratified_society' from books where title = 'Brave New World / Brave New World Revisited';
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'Brave New World / Brave New World Revisited';
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Brave New World / Brave New World Revisited';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Brave New World / Brave New World Revisited';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'central_theme', false from books where title = 'Brave New World / Brave New World Revisited';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', true from books where title = 'Brave New World / Brave New World Revisited';


-- ===== Ficciones =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy','sci_fi'], 'adult', 'short', 'single', 'mixed', 'ambiguous', 'nonlinear', 'framing_device', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'dense', 'mixed', 'self_contained', 'ambiguous', 'resolved', 'short', 'soft', 'soft', 'sparse', 'dense', 'cerebral', 'cosmic', 'moderate', 'veteran_only'
from books where title = 'Ficciones';

insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Ficciones';
insert into book_tropes (book_id, trope_id) select id, 'impossible_or_non_euclidean_architecture' from books where title = 'Ficciones';
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Ficciones';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Ficciones' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Ficciones' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Ficciones' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Ficciones' on conflict (book_id, field_name) do nothing;


-- ===== Galápagos =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'nonlinear', 'framing_device', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'heavy', 'bittersweet', 'heavy_handed', 'rare', 'closed_door', null, 'rare', 'moderate', 'moderate', 'exposition_dump', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'cerebral', 'global', 'moderate', 'moderate'
from books where title = 'Galápagos';

insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Galápagos';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Galápagos';
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Galápagos';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Galápagos';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'infertility', 'central_theme', false from books where title = 'Galápagos';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.6, 'ai_inferred' from books where title = 'Galápagos' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Galápagos' on conflict (book_id, field_name) do nothing;


-- ===== If I Stay =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'ya', 'short', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'closed_door', 'understated', 'rare', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'If I Stay';

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'If I Stay';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'If I Stay';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'If I Stay' on conflict (book_id, field_name) do nothing;


-- ===== Lamb: The Gospel According to Biff, Christ's Childhood Pal =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'bittersweet', 'moderate', 'occasional', 'moderate', 'melodramatic', 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal';

insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Lamb: The Gospel According to Biff, Christ''s Childhood Pal' on conflict (book_id, field_name) do nothing;


-- ===== Later =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'gateway'
from books where title = 'Later';

insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'Later';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Later';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Later';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Later';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', true from books where title = 'Later';


-- ===== Life After Life =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'global', 'life_threatening', 'accessible'
from books where title = 'Life After Life';

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'Life After Life';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Life After Life';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Life After Life';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Life After Life';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Life After Life' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Life After Life' on conflict (book_id, field_name) do nothing;


-- ===== Orlando =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'short', 'single', 'third_omniscient', 'unreliable', 'linear', 'framing_device', 'medium', 'uneven', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'occasional', 'low', null, 'rare', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'none', 'na', 'lush', 'dense', 'cerebral', 'intimate', 'low', 'moderate'
from books where title = 'Orlando';

insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Orlando';
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Orlando';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Orlando';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Orlando' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Orlando' on conflict (book_id, field_name) do nothing;


-- ===== Out of the Silent Planet =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'dense', 'woven', 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Out of the Silent Planet';

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Out of the Silent Planet';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Out of the Silent Planet';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Out of the Silent Planet';


-- ===== The Buried Giant =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'short', 'few', 'mixed', 'ambiguous', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'bittersweet', 'moderate', 'rare', 'closed_door', 'understated', 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'ambiguous', 'resolved', 'short', 'soft', 'na', 'sparse', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'The Buried Giant';

insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Buried Giant';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Buried Giant';
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Buried Giant';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Buried Giant';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', true from books where title = 'The Buried Giant';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Buried Giant';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', true from books where title = 'The Buried Giant';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'The Buried Giant' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Buried Giant' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'The Buried Giant' on conflict (book_id, field_name) do nothing;


-- ===== The Dog Stars =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'subtle', 'rare', 'low', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'moderate', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The Dog Stars';

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Dog Stars';
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Dog Stars';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Dog Stars';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Dog Stars';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Dog Stars' on conflict (book_id, field_name) do nothing;


-- ===== The Employees =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'short', 'ensemble', 'first', 'ambiguous', 'nonlinear', 'epistolary', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'moderate', 'mixed', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'sparse', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'demanding'
from books where title = 'The Employees';

insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'The Employees';
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'The Employees';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'The Employees' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Employees' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Employees' on conflict (book_id, field_name) do nothing;


-- ===== The Ferryman =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'long', 'few', 'third_limited', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'occasional', 'moderate', null, 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'The Ferryman';

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Ferryman';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Ferryman';
insert into book_tropes (book_id, trope_id) select id, 'caste_or_faction_stratified_society' from books where title = 'The Ferryman';
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'The Ferryman';
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Ferryman';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'The Ferryman';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Ferryman' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Ferryman' on conflict (book_id, field_name) do nothing;


-- ===== The Grace Year =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'occasional', 'moderate', null, 'frequent', 'graphic', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The Grace Year';

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Grace Year';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Grace Year';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Grace Year';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Grace Year';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'The Grace Year';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Grace Year';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'central_theme', false from books where title = 'The Grace Year';


-- ===== The House of the Spirits =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'adult', 'standard', 'few', 'mixed', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', null, 'frequent', 'brutal', 'light', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'none', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'life_threatening', 'moderate'
from books where title = 'The House of the Spirits';

insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'The House of the Spirits';
insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'The House of the Spirits';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The House of the Spirits';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The House of the Spirits';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', true from books where title = 'The House of the Spirits';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', true from books where title = 'The House of the Spirits';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The House of the Spirits';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'The House of the Spirits';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'The House of the Spirits' on conflict (book_id, field_name) do nothing;


-- ===== The Phantom Tollbooth =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['fantasy'], 'middle_grade', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'none', 'na', null, 'rare', 'mild', 'dense', 'woven', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'low', 'accessible'
from books where title = 'The Phantom Tollbooth';

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Phantom Tollbooth';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Phantom Tollbooth';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Phantom Tollbooth';


-- ===== The Yiddish Policemen's Union =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'The Yiddish Policemen''s Union';

insert into book_tropes (book_id, trope_id) select id, 'alternate_history' from books where title = 'The Yiddish Policemen''s Union';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Yiddish Policemen''s Union';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Yiddish Policemen''s Union';


-- ===== Author-field contamination fixes (verified via Hardcover cached_contributors) =====
-- 14: Jean-Pierre Pugi credited as Translator on Hardcover -- not a co-author.
update books set author = 'Peter Clines' where title = '14' and author = 'Peter Clines, Jean-Pierre Pugi';

-- Anthem: Leonard Peikoff credited as Introduction writer on Hardcover -- not a co-author.
update books set author = 'Ayn Rand' where title = 'Anthem' and author = 'Ayn Rand, Leonard Peikoff';

-- Brave New World / Brave New World Revisited: Christopher Hitchens credited as Foreword writer on Hardcover (primary:false) -- not a co-author; Huxley is primary:true, contribution:Author.
update books set author = 'Aldous Huxley' where title = 'Brave New World / Brave New World Revisited' and author = 'Aldous Huxley, Christopher Hitchens';

-- The Employees: Martin Aitken is the book's Danish-to-English translator (confirmed real-world knowledge; Hardcover cached_contributors lists him as a secondary, non-Author-role contributor alongside primary author Ravn).
update books set author = 'Olga Ravn' where title = 'The Employees' and author = 'Olga Ravn, Martin Aitken';

-- The Phantom Tollbooth: Jules Feiffer credited as Illustrator on Hardcover -- not a co-author.
update books set author = 'Norton Juster' where title = 'The Phantom Tollbooth' and author = 'Norton Juster, Jules Feiffer';
