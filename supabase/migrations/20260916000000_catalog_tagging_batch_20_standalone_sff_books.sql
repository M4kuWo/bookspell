-- Round-4 standalone SFF batch: 20 pre-screened books tagged with full Book DNA
-- (CLDA session, 2026-09-16, following .claude/skills/tag-catalog-batch/SKILL.md).
-- Titles hand-picked by CLDO from the 119-book standalone-untagged pool as confidently
-- in-scope SFF standalones with no series dependencies (docs/TODO.md 'Catalog expansion
-- round 4' entry). Every book_id resolved via a title subselect (never a raw UUID) per
-- CLAUDE.md convention -- hosted/local have different row UUIDs for the same book.
-- Author-field fix: 'The Daughter of Doctor Moreau' carried 'Silvia Moreno-Garcia, Gisela
-- Chipe' -- Chipe is confirmed (Hardcover cached_contributors, contribution: Narrator) to
-- be the audiobook narrator, not a co-author -- corrected to the genuine author only.

update books set author = 'Silvia Moreno-Garcia'
where title = 'The Daughter of Doctor Moreau' and author = 'Silvia Moreno-Garcia, Gisela Chipe';

-- ============ Accelerando ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'few',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'consistent',
  'worldbuilding_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'moderate',
  'rare',
  'low',
  null,
  'rare',
  'mild',
  'dense',
  'exposition_dump',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'moderate',
  'dense',
  'cerebral',
  'global',
  'moderate',
  'veteran_only'
from books where title = 'Accelerando'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'self_replicating_consciousness' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multi_generational_saga' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cybernetic_enhancement' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hive_mind' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_scifi' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'Accelerando'
on conflict (book_id, trope_id) do nothing;

-- confidence note: worldbuilding_delivery -- exposition-heavy Stross style, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Accelerando'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- satirical wit assumed from Stross's known register, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Accelerando'
on conflict (book_id, field_name) do nothing;

-- ============ Alien Clay ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'first',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'character_driven',
  'dark',
  'light',
  'tense',
  'heavy_handed',
  'rare',
  'moderate',
  null,
  'frequent',
  'graphic',
  'dense',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'moderate',
  'moderate',
  'cerebral',
  'regional',
  'life_threatening',
  'demanding'
from books where title = 'Alien Clay'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'first_contact' from books where title = 'Alien Clay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hive_mind' from books where title = 'Alien Clay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dystopia' from books where title = 'Alien Clay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'Alien Clay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Alien Clay'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'Alien Clay'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Alien Clay'
on conflict (book_id, warning_id) do nothing;

-- confidence note: worldbuilding_delivery -- scientist-discovery framing but narrator also lectures on biology
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Alien Clay'
on conflict (book_id, field_name) do nothing;

-- ============ Annie Bot ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'consistent',
  'character_driven',
  'dark',
  'light',
  'tense',
  'moderate',
  'occasional',
  'explicit',
  'understated',
  'occasional',
  'moderate',
  'light',
  null,
  'self_contained',
  'ambiguous',
  'resolved',
  'standard',
  'na',
  'soft',
  'sparse',
  'accessible',
  'moderate',
  'intimate',
  'life_threatening',
  'accessible'
from books where title = 'Annie Bot'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Annie Bot'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'android_or_replicant_rights' from books where title = 'Annie Bot'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'central_theme', false from books where title = 'Annie Bot'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'central_theme', false from books where title = 'Annie Bot'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', true from books where title = 'Annie Bot'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'Annie Bot'
on conflict (book_id, warning_id) do nothing;

-- confidence note: humor_level -- kirkus review didn't confirm humor content directly
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Annie Bot'
on conflict (book_id, field_name) do nothing;
-- confidence note: romance_tone -- clinical/restrained narration voice observed via review, but not a scene-level quote
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Annie Bot'
on conflict (book_id, field_name) do nothing;

-- ============ Aurora ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'long',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'framing_device',
  'slow',
  'uneven',
  'worldbuilding_driven',
  'moderate',
  'light',
  'bittersweet',
  'heavy_handed',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'dense',
  'exposition_dump',
  'self_contained',
  'bittersweet',
  'resolved',
  'long',
  'na',
  'hard',
  'lush',
  'dense',
  'cerebral',
  'global',
  'high',
  'veteran_only'
from books where title = 'Aurora'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'generation_ship' from books where title = 'Aurora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'Aurora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Aurora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'relativistic_time_dilation' from books where title = 'Aurora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multi_generational_saga' from books where title = 'Aurora'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'infertility', 'moderate', false from books where title = 'Aurora'
on conflict (book_id, warning_id) do nothing;

-- confidence note: humor_level -- AI narrator's literal computational voice can read as dry humor, not fully certain
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Aurora'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- AI-narrator exposition is a known structural device of this book
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Aurora'
on conflict (book_id, field_name) do nothing;

-- ============ Diaspora ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'few',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'slow',
  'uneven',
  'worldbuilding_driven',
  'moderate',
  'none',
  'bittersweet',
  'moderate',
  'rare',
  'low',
  null,
  'rare',
  'mild',
  'dense',
  'exposition_dump',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'sparse',
  'dense',
  'cerebral',
  'cosmic',
  'moderate',
  'veteran_only'
from books where title = 'Diaspora'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'self_replicating_consciousness' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'species_divergence' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'relativistic_time_dilation' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'virtual_reality_or_simulated_world' from books where title = 'Diaspora'
on conflict (book_id, trope_id) do nothing;

-- confidence note: worldbuilding_delivery -- Egan is well-known for heavy technical exposition chapters
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Diaspora'
on conflict (book_id, field_name) do nothing;

-- ============ Embassytown ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'first',
  'reliable',
  'nonlinear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'worldbuilding_driven',
  'dark',
  'light',
  'tense',
  'moderate',
  'occasional',
  'moderate',
  'understated',
  'occasional',
  'graphic',
  'dense',
  'mixed',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'lush',
  'dense',
  'cerebral',
  'regional',
  'high',
  'veteran_only'
from books where title = 'Embassytown'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'Embassytown'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dystopia' from books where title = 'Embassytown'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'sudden_apocalypse_event' from books where title = 'Embassytown'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'central_theme', false from books where title = 'Embassytown'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'moderate', false from books where title = 'Embassytown'
on conflict (book_id, warning_id) do nothing;

-- confidence note: timeline -- recalled alternating past/present structure, not re-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Embassytown'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- Miéville's irony assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Embassytown'
on conflict (book_id, field_name) do nothing;
-- confidence note: romance_tone -- cerebral/restrained narration voice observed generally, not a specific scene quote
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Embassytown'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- genuine tie between insider narration and explicit Language-mechanics dialogue
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Embassytown'
on conflict (book_id, field_name) do nothing;

-- ============ Fall or, Dodge in Hell ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi','fantasy'],
  'adult',
  'epic',
  'several',
  'mixed',
  'reliable',
  'linear',
  'standard_prose',
  'slow',
  'uneven',
  'worldbuilding_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'heavy_handed',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'dense',
  'exposition_dump',
  'self_contained',
  'bittersweet',
  'resolved',
  'epic',
  'soft',
  'hard',
  'lush',
  'dense',
  'cerebral',
  'cosmic',
  'moderate',
  'veteran_only'
from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'virtual_reality_or_simulated_world' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dark_lord_or_evil_overlord' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_scifi' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, warning_id) do nothing;

-- confidence note: person -- real-world half reads third_limited; Bitworld half reads more mythic/omniscient
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- classic Stephenson infodump style
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Fall or, Dodge in Hell'
on conflict (book_id, field_name) do nothing;

-- ============ Gods of Jade and Shadow ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['fantasy'],
  'adult',
  'standard',
  'dual',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'character_driven',
  'moderate',
  'light',
  'bittersweet',
  'subtle',
  'occasional',
  'low',
  'understated',
  'occasional',
  'moderate',
  'moderate',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'soft',
  'na',
  'lush',
  'moderate',
  'moderate',
  'regional',
  'high',
  'moderate'
from books where title = 'Gods of Jade and Shadow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'slow_burn_romance' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'long_journey' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'moderate', false from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, warning_id) do nothing;

-- confidence note: pov_count -- recall occasional Martín interludes alongside Casiopea's primary POV
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, field_name) do nothing;
-- confidence note: romance_tone -- recall a quiet, dignified parting scene rather than a dramatic one
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- mythology revealed through the journey, not lecture
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Gods of Jade and Shadow'
on conflict (book_id, field_name) do nothing;

-- ============ Heartless ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['fantasy'],
  'ya',
  'standard',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'romance_driven',
  'moderate',
  'moderate',
  'gut_punch',
  'subtle',
  'occasional',
  'closed_door',
  'understated',
  'rare',
  'moderate',
  'moderate',
  'woven',
  'self_contained',
  'tragic',
  'resolved',
  'standard',
  'soft',
  'na',
  'moderate',
  'accessible',
  'escapist',
  'regional',
  'high',
  'gateway'
from books where title = 'Heartless'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'tragic_reversal_of_fortune' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'corruption_arc' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_fantasy' from books where title = 'Heartless'
on conflict (book_id, trope_id) do nothing;

-- confidence note: romance_tone -- conventional heightened YA courtship beats recalled, but no specific presentation-level scene verified either way
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Heartless'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- whimsical Wonderland discovery assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Heartless'
on conflict (book_id, field_name) do nothing;

-- ============ Hell Followed with Us ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'ya',
  'standard',
  'single',
  'first',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'consistent',
  'character_driven',
  'dark',
  'light',
  'gut_punch',
  'heavy_handed',
  'occasional',
  'low',
  'understated',
  'frequent',
  'brutal',
  'moderate',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'moderate',
  'accessible',
  'moderate',
  'global',
  'life_threatening',
  'moderate'
from books where title = 'Hell Followed with Us'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'sudden_apocalypse_event' from books where title = 'Hell Followed with Us'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Hell Followed with Us'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Hell Followed with Us'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Hell Followed with Us'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'Hell Followed with Us'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'Hell Followed with Us'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'self_harm', 'moderate', false from books where title = 'Hell Followed with Us'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'Hell Followed with Us'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'hate_speech_depicted', 'moderate', false from books where title = 'Hell Followed with Us'
on conflict (book_id, warning_id) do nothing;

-- confidence note: romance_tone -- recalled as a tender found-family counterpoint to the horror, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Hell Followed with Us'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- some found-family banter recalled amid horror, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Hell Followed with Us'
on conflict (book_id, field_name) do nothing;

-- ============ Lord of Light ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi','fantasy'],
  'adult',
  'standard',
  'few',
  'third_omniscient',
  'reliable',
  'nonlinear',
  'standard_prose',
  'medium',
  'uneven',
  'plot_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'moderate',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'dense',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'soft',
  'soft',
  'moderate',
  'dense',
  'cerebral',
  'global',
  'life_threatening',
  'veteran_only'
from books where title = 'Lord of Light'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'reincarnated_protagonist' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dystopia' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Lord of Light'
on conflict (book_id, trope_id) do nothing;

-- confidence note: person -- mythic god's-eye narrative voice recalled, third_limited-with-omniscient-qualities is a judgment call
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Lord of Light'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- embedded in mythic storytelling voice, not a dry lecture, but genuinely dense
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Lord of Light'
on conflict (book_id, field_name) do nothing;

-- ============ Pushing Ice ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'long',
  'few',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'character_driven',
  'dark',
  'light',
  'bittersweet',
  'subtle',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'dense',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'long',
  'na',
  'hard',
  'moderate',
  'moderate',
  'cerebral',
  'cosmic',
  'high',
  'demanding'
from books where title = 'Pushing Ice'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'first_contact' from books where title = 'Pushing Ice'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'Pushing Ice'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multi_generational_saga' from books where title = 'Pushing Ice'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Pushing Ice'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Pushing Ice'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Pushing Ice'
on conflict (book_id, warning_id) do nothing;

-- confidence note: pov_count -- Bella/Svetlana dual-lead rivalry is central; other crew get briefer POV, few vs dual is a judgment call
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Pushing Ice'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- mystery unfolds through exploration, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Pushing Ice'
on conflict (book_id, field_name) do nothing;

-- ============ Replay ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'uneven',
  'character_driven',
  'moderate',
  'light',
  'bittersweet',
  'moderate',
  'occasional',
  'moderate',
  'understated',
  'rare',
  'mild',
  'light',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'moderate',
  'accessible',
  'moderate',
  'intimate',
  'life_threatening',
  'gateway'
from books where title = 'Replay'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'time_loop' from books where title = 'Replay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'second_chance_romance' from books where title = 'Replay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'tragic_reversal_of_fortune' from books where title = 'Replay'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', true from books where title = 'Replay'
on conflict (book_id, warning_id) do nothing;

-- confidence note: romance_tone -- recalled as tender/melancholic rather than melodramatic, not a specific scene quote
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Replay'
on conflict (book_id, field_name) do nothing;

-- ============ Shroud ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'dual',
  'first',
  'reliable',
  'linear',
  'framing_device',
  'fast',
  'consistent',
  'plot_driven',
  'dark',
  'light',
  'tense',
  'subtle',
  'rare',
  'low',
  null,
  'occasional',
  'graphic',
  'dense',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'lush',
  'moderate',
  'cerebral',
  'intimate',
  'life_threatening',
  'moderate'
from books where title = 'Shroud'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'first_contact' from books where title = 'Shroud'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Shroud'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cosmic_horror' from books where title = 'Shroud'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Shroud'
on conflict (book_id, warning_id) do nothing;

-- confidence note: person -- recalled as first-person survival narration, WebSearch budget exhausted before full verification
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Shroud'
on conflict (book_id, field_name) do nothing;
-- confidence note: pov_count -- recalled two alternating survivors, genuinely uncertain
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.4, 'ai_inferred' from books where title = 'Shroud'
on conflict (book_id, field_name) do nothing;
-- confidence note: form -- Tchaikovsky's typical case-note/framing interludes assumed by author pattern, not confirmed for this specific book
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'form', 0.5, 'ai_inferred' from books where title = 'Shroud'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- Tchaikovsky's typical dry wit assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Shroud'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- sensory-discovery survival framing assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Shroud'
on conflict (book_id, field_name) do nothing;

-- ============ Six Wakes ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'several',
  'third_limited',
  'ambiguous',
  'multi_timeline',
  'standard_prose',
  'fast',
  'consistent',
  'plot_driven',
  'dark',
  'light',
  'tense',
  'moderate',
  'rare',
  'low',
  null,
  'occasional',
  'graphic',
  'moderate',
  'mixed',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'moderate',
  'accessible',
  'moderate',
  'intimate',
  'life_threatening',
  'accessible'
from books where title = 'Six Wakes'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'cloning' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'closed_circle_mystery' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'amnesia_driven_narrative' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'redemption_arc' from books where title = 'Six Wakes'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'Six Wakes'
on conflict (book_id, warning_id) do nothing;

-- confidence note: narrator_reliability -- amnesia is structurally central so nobody's account of events is fully trustworthy, incl. narration
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Six Wakes'
on conflict (book_id, field_name) do nothing;
-- confidence note: scifi_hardness -- mind-backup/cloning tech leans narrative-convenience rather than rigorously explained
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'Six Wakes'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- genuine tie between flashback-discovery structure and explicit cloning-rules exposition
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Six Wakes'
on conflict (book_id, field_name) do nothing;

-- ============ Termination Shock ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'long',
  'several',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'uneven',
  'worldbuilding_driven',
  'moderate',
  'moderate',
  'tense',
  'heavy_handed',
  'rare',
  'low',
  null,
  'occasional',
  'graphic',
  'dense',
  'exposition_dump',
  'self_contained',
  'ambiguous',
  'resolved',
  'long',
  'na',
  'hard',
  'moderate',
  'moderate',
  'cerebral',
  'global',
  'high',
  'demanding'
from books where title = 'Termination Shock'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_scifi' from books where title = 'Termination Shock'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Termination Shock'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'natural_disaster_mass_casualty', 'central_theme', false from books where title = 'Termination Shock'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Termination Shock'
on conflict (book_id, warning_id) do nothing;

-- ============ The Bright Sword ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['fantasy'],
  'adult',
  'epic',
  'few',
  'third_limited',
  'reliable',
  'nonlinear',
  'standard_prose',
  'slow',
  'uneven',
  'character_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'moderate',
  'occasional',
  'moderate',
  'understated',
  'occasional',
  'moderate',
  'dense',
  'mixed',
  'self_contained',
  'bittersweet',
  'resolved',
  'epic',
  'soft',
  'na',
  'lush',
  'moderate',
  'cerebral',
  'regional',
  'high',
  'veteran_only'
from books where title = 'The Bright Sword'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'redemption_arc' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Bright Sword'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Bright Sword'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'moderate', false from books where title = 'The Bright Sword'
on conflict (book_id, warning_id) do nothing;

-- confidence note: pov_count -- Collum is the throughline but ~5 knights get substantial individual backstory chapters
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Bright Sword'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- Grossman's typical wit assumed, not confirmed for this book specifically
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'The Bright Sword'
on conflict (book_id, field_name) do nothing;
-- confidence note: romance_tone -- Guinevere/knights romantic content confirmed present but no presentation-level scene verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Bright Sword'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- blends in-scene main plot with expository legend/myth backstory chapters
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'The Bright Sword'
on conflict (book_id, field_name) do nothing;

-- ============ The Daughter of Doctor Moreau ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'dual',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'character_driven',
  'dark',
  'none',
  'bittersweet',
  'moderate',
  'occasional',
  'low',
  'understated',
  'occasional',
  'graphic',
  'moderate',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'lush',
  'moderate',
  'moderate',
  'regional',
  'life_threatening',
  'moderate'
from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'creation_turns_on_creator' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'shadow_self_confrontation' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'moderate', false from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, warning_id) do nothing;

-- confidence note: romance_tone -- Eduardo's possessive framing is content evidence, not clean presentation-style evidence
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- dual-POV discovery structure assumed woven, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'The Daughter of Doctor Moreau'
on conflict (book_id, field_name) do nothing;

-- ============ The Deep Sky ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'first',
  'reliable',
  'multi_timeline',
  'standard_prose',
  'medium',
  'uneven',
  'balanced',
  'moderate',
  'light',
  'tense',
  'moderate',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'moderate',
  'woven',
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'moderate',
  'accessible',
  'moderate',
  'global',
  'high',
  'accessible'
from books where title = 'The Deep Sky'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'generation_ship' from books where title = 'The Deep Sky'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'The Deep Sky'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'closed_circle_mystery' from books where title = 'The Deep Sky'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'The Deep Sky'
on conflict (book_id, trope_id) do nothing;

-- confidence note: person -- recalled as first-person personal narration, moderately confident
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Deep Sky'
on conflict (book_id, field_name) do nothing;
-- confidence note: drive -- kirkus explicitly frames both humanity-wide and personal-scale focus as co-equal
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Deep Sky'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- not confirmed via research
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'The Deep Sky'
on conflict (book_id, field_name) do nothing;
-- confidence note: scifi_hardness -- generation-ship premise handled more character-focused than rigorously hard
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'The Deep Sky'
on conflict (book_id, field_name) do nothing;
-- confidence note: worldbuilding_delivery -- investigation-driven discovery assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'The Deep Sky'
on conflict (book_id, field_name) do nothing;

-- ============ The Echo Wife ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id,
  array['sci_fi'],
  'adult',
  'short',
  'single',
  'first',
  'reliable',
  'nonlinear',
  'standard_prose',
  'medium',
  'slow_burn_to_fast_finish',
  'character_driven',
  'dark',
  'light',
  'gut_punch',
  'moderate',
  'rare',
  'low',
  null,
  'occasional',
  'graphic',
  'light',
  null,
  'self_contained',
  'ambiguous',
  'resolved',
  'standard',
  'na',
  'soft',
  'sparse',
  'accessible',
  'moderate',
  'intimate',
  'life_threatening',
  'accessible'
from books where title = 'The Echo Wife'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'cloning' from books where title = 'The Echo Wife'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'shadow_self_confrontation' from books where title = 'The Echo Wife'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'corruption_arc' from books where title = 'The Echo Wife'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The Echo Wife'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'central_theme', false from books where title = 'The Echo Wife'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Echo Wife'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'central_theme', false from books where title = 'The Echo Wife'
on conflict (book_id, warning_id) do nothing;

-- confidence note: timeline -- significant interwoven marriage-backstory flashbacks recalled, nonlinear vs linear is a judgment call
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Echo Wife'
on conflict (book_id, field_name) do nothing;
-- confidence note: humor_level -- Gailey's typical dry wit assumed, not scene-verified
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'The Echo Wife'
on conflict (book_id, field_name) do nothing;

