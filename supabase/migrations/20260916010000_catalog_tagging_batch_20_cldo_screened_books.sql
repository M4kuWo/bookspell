-- Catalog tagging batch: 20 CLDO-screened standalone/cold-start SFF books
-- (CLDA session, 2026-09-16). Full Book DNA (schema fields, tropes, content
-- warnings) for 20 titles hand-picked by CLDO from the 258-book untagged
-- standalone pool -- see docs/TODO.md's "Catalog expansion round 4" entry and
-- docs/project-log.md's 2026-09-16 entry for full detail (density self-check,
-- HIGH_RISK_FIELDS checks, romance_tone/worldbuilding_delivery evidence, two
-- author-field contamination fixes verified against Hardcover's own
-- cached_contributors data before tagging).
--
-- Two author-field contamination fixes (verified via Hardcover GraphQL
-- cached_contributors before touching either): Elric of Melniboné and Other
-- Stories' "Alan Moore" credit is a foreword writer, not a co-author; Leviathan's
-- "Alan Cumming" credit is the audiobook narrator, not a co-author.

-- Author-field contamination fixes
update books set author = 'Michael Moorcock'
where title = 'Elric of Melniboné and Other Stories'
  and author = 'Michael Moorcock, Alan Moore';

update books set author = 'Scott Westerfeld'
where title = 'Leviathan'
  and author = 'Scott Westerfeld, Alan Cumming';

-- Alanna: The First Adventure
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'comfort_read', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'requires_series', 'happy', 'resolved', 'short', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'gateway'
from books where title = 'Alanna: The First Adventure'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'bullying', 'moderate', false from books where title = 'Alanna: The First Adventure'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Alanna: The First Adventure'
on conflict (book_id, field_name) do nothing;

-- Congo
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'Congo'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'lost_civilizations' from books where title = 'Congo'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Congo'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'central_theme', false from books where title = 'Congo'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Congo'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Congo'
on conflict (book_id, field_name) do nothing;

-- Daughter of the Empire
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Daughter of the Empire'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Daughter of the Empire'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Daughter of the Empire'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'arranged_marriage' from books where title = 'Daughter of the Empire'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'Daughter of the Empire'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Daughter of the Empire'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'central_theme', false from books where title = 'Daughter of the Empire'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Daughter of the Empire'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'moderate', false from books where title = 'Daughter of the Empire'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Daughter of the Empire'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Daughter of the Empire'
on conflict (book_id, field_name) do nothing;

-- Dreamcatcher
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'none', 'na', null, 'frequent', 'brutal', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Dreamcatcher'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'alien_invasion' from books where title = 'Dreamcatcher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Dreamcatcher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Dreamcatcher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.5, 'ai_inferred' from books where title = 'Dreamcatcher'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'Dreamcatcher'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Dreamcatcher'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Dreamcatcher'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Dreamcatcher'
on conflict (book_id, field_name) do nothing;

-- Elric of Melniboné and Other Stories
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'occasional', 'low', 'melodramatic', 'frequent', 'brutal', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'anti_hero' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cursed_protagonist' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'tragic_reversal_of_fortune' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'central_theme', false from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.3, 'ai_inferred' from books where title = 'Elric of Melniboné and Other Stories'
on conflict (book_id, field_name) do nothing;

-- Feed
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'dense', 'exposition_dump', 'requires_series', 'tragic', 'resolved', 'long', 'na', 'hard', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Feed'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'Feed'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Feed'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'noir_detective_structure', 0.5, 'ai_inferred' from books where title = 'Feed'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'engineered_creation_escapes_control' from books where title = 'Feed'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Feed'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Feed'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Feed'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Feed'
on conflict (book_id, field_name) do nothing;

-- Gateway
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', 'understated', 'rare', 'moderate', 'moderate', 'woven', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening', 'moderate'
from books where title = 'Gateway'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'lost_civilizations' from books where title = 'Gateway'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Gateway'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'retrospective_memoir_narration' from books where title = 'Gateway'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'tragic_reversal_of_fortune' from books where title = 'Gateway'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Gateway'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Gateway'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'Gateway'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.3, 'ai_inferred' from books where title = 'Gateway'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Gateway'
on conflict (book_id, field_name) do nothing;

-- Horus Rising
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'frequent', 'graphic', 'dense', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Horus Rising'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Horus Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'corruption_arc' from books where title = 'Horus Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Horus Rising'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'ancient_evil_awakens', 0.4, 'ai_inferred' from books where title = 'Horus Rising'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Horus Rising'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Horus Rising'
on conflict (book_id, field_name) do nothing;

-- Ilium
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi','fantasy'], 'adult', 'epic', 'several', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'brutal', 'dense', 'mixed', 'requires_series', 'ambiguous', 'cliffhanger', 'epic', 'na', 'hard', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Ilium'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'Ilium'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Ilium'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Ilium'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_filled', 0.4, 'ai_inferred' from books where title = 'Ilium'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Ilium'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Ilium'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.3, 'ai_inferred' from books where title = 'Ilium'
on conflict (book_id, field_name) do nothing;

-- Kushiel's Dart
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'frequent', 'explicit', 'understated', 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Kushiel''s Dart'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Kushiel''s Dart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Kushiel''s Dart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'infiltration_or_undercover_plot' from books where title = 'Kushiel''s Dart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'slow_burn_romance' from books where title = 'Kushiel''s Dart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'Kushiel''s Dart'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'central_theme', false from books where title = 'Kushiel''s Dart'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'dubious_consent', 'central_theme', false from books where title = 'Kushiel''s Dart'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'central_theme', false from books where title = 'Kushiel''s Dart'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Kushiel''s Dart'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Kushiel''s Dart'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Kushiel''s Dart'
on conflict (book_id, field_name) do nothing;

-- Legion
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'regional', 'moderate', 'gateway'
from books where title = 'Legion'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'Legion'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.4, 'ai_inferred' from books where title = 'Legion'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Legion'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Legion'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Legion'
on conflict (book_id, field_name) do nothing;

-- Leviathan
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'escapist', 'global', 'high', 'accessible'
from books where title = 'Leviathan'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'alternate_history' from books where title = 'Leviathan'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'steampunk' from books where title = 'Leviathan'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'secret_royalty' from books where title = 'Leviathan'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Leviathan'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Leviathan'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Leviathan'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Leviathan'
on conflict (book_id, field_name) do nothing;

-- Little Brother
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'heavy_handed', 'rare', 'low', null, 'occasional', 'moderate', 'moderate', 'exposition_dump', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'gateway'
from books where title = 'Little Brother'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Little Brother'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'infiltration_or_undercover_plot' from books where title = 'Little Brother'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cyberpunk' from books where title = 'Little Brother'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'modern_knowledge_as_power_source' from books where title = 'Little Brother'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Little Brother'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Little Brother'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Little Brother'
on conflict (book_id, field_name) do nothing;

-- Mortal Engines
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'ya', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'na', null, 'frequent', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'Mortal Engines'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'dystopia' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'lost_civilizations' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Mortal Engines'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Mortal Engines'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Mortal Engines'
on conflict (book_id, field_name) do nothing;

-- Odd Thomas
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'gut_punch', 'subtle', 'occasional', 'low', 'understated', 'occasional', 'graphic', 'light', null, 'self_contained', 'tragic', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'gateway'
from books where title = 'Odd Thomas'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'ghost_sight' from books where title = 'Odd Thomas'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Odd Thomas'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'Odd Thomas'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.5, 'ai_inferred' from books where title = 'Odd Thomas'
on conflict (book_id, trope_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'Odd Thomas'
on conflict (book_id, field_name) do nothing;

-- On Basilisk Station
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'graphic', 'dense', 'exposition_dump', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'On Basilisk Station'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'On Basilisk Station'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'On Basilisk Station'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'On Basilisk Station'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'telepathic_animal_bond' from books where title = 'On Basilisk Station'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'court_intrigue', 0.5, 'ai_inferred' from books where title = 'On Basilisk Station'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'On Basilisk Station'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'On Basilisk Station'
on conflict (book_id, field_name) do nothing;

-- Shards of Honour
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'brutal', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Shards of Honour'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'enemies_to_lovers' from books where title = 'Shards of Honour'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Shards of Honour'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'Shards of Honour'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'Shards of Honour'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'found_family', 0.4, 'ai_inferred' from books where title = 'Shards of Honour'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', true from books where title = 'Shards of Honour'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Shards of Honour'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Shards of Honour'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Shards of Honour'
on conflict (book_id, field_name) do nothing;

-- Soulless
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', 'mixed', 'rare', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'moderate', 'gateway'
from books where title = 'Soulless'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'vampires' from books where title = 'Soulless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'werewolves' from books where title = 'Soulless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'grumpy_sunshine' from books where title = 'Soulless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'steampunk' from books where title = 'Soulless'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'Soulless'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Soulless'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.4, 'ai_inferred' from books where title = 'Soulless'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.3, 'ai_inferred' from books where title = 'Soulless'
on conflict (book_id, field_name) do nothing;

-- The Amulet of Samarkand
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'dual', 'mixed', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'moderate', 'heavy', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'mixed', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'The Amulet of Samarkand'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'heist' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'corruption_arc' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'central_theme', false from books where title = 'The Amulet of Samarkand'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', false from books where title = 'The Amulet of Samarkand'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'The Amulet of Samarkand'
on conflict (book_id, field_name) do nothing;

-- The End of Eternity
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', 'melodramatic', 'rare', 'mild', 'dense', 'exposition_dump', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'sparse', 'accessible', 'cerebral', 'global', 'high', 'moderate'
from books where title = 'The End of Eternity'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'time_travel' from books where title = 'The End of Eternity'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'predictive_social_science' from books where title = 'The End of Eternity'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The End of Eternity'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'dystopia', 0.4, 'ai_inferred' from books where title = 'The End of Eternity'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'hidden_identity_romance', 0.4, 'ai_inferred' from books where title = 'The End of Eternity'
on conflict (book_id, trope_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'The End of Eternity'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'The End of Eternity'
on conflict (book_id, field_name) do nothing;

