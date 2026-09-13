-- Catalog tagging batch (CLDA session, 2026-09-13): 17 books tagged,
-- partial-series-first per tag-catalog-batch skill Step 2. Completes
-- 9 partial series to full tagged status: MaddAddam, Themis Files,
-- Once Upon a Broken Heart, The Captive's War, Bloodsworn Saga, Wayward
-- Pines, Dirk Gently, The Kane Chronicles, The Vampire Chronicles,
-- Oxford Time Travel (also The Roald Dahl Classic Collection grouping,
-- A Series of Unfortunate Events subset). See docs/project-log.md for
-- full per-book reasoning (romance_tone/worldbuilding_delivery evidence,
-- HIGH_RISK_FIELDS verification via web research, vocabulary gap checks).

-- Author-field contamination fix (3 cases, verified against Hardcover's
-- own `contributions` GraphQL data before fixing, per CLAUDE.md's mandatory
-- standard -- all three are illustrator credits, not co-authors):
--   The BFG (hardcover_id 103126): Roald Dahl (Author) + Quentin Blake (Illustrator)
--   The Witches (hardcover_id 39482): Roald Dahl (Author) + Quentin Blake (illustrator)
--   The Reptile Room (hardcover_id 33577): Lemony Snicket (Author) + Brett Helquist (Illustrator)
update books set author = 'Roald Dahl' where title = 'The BFG';
update books set author = 'Roald Dahl' where title = 'The Witches';
update books set author = 'Lemony Snicket' where title = 'The Reptile Room';

-- The Year of the Flood
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Year of the Flood'),
  array['sci_fi'],
  'adult',
  'standard',
  'dual',
  'mixed',
  'reliable',
  'nonlinear',
  'standard_prose',
  'medium',
  'consistent',
  'character_driven',
  'dark',
  'light',
  'gut_punch',
  'moderate',
  'occasional',
  'moderate',
  null,
  'frequent',
  'graphic',
  'dense',
  null,
  'requires_series',
  'ambiguous',
  'cliffhanger',
  'standard',
  'na',
  'hard',
  'moderate',
  'moderate',
  'cerebral',
  'global',
  'life_threatening',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Year of the Flood'), 'dystopia'),
  ((select id from books where title = 'The Year of the Flood'), 'post_apocalyptic'),
  ((select id from books where title = 'The Year of the Flood'), 'sudden_apocalypse_event'),
  ((select id from books where title = 'The Year of the Flood'), 'found_family'),
  ((select id from books where title = 'The Year of the Flood'), 'survivalist_ingenuity')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Year of the Flood'), 'pandemic_or_epidemic', 'central_theme', false),
  ((select id from books where title = 'The Year of the Flood'), 'sexual_assault', 'central_theme', false),
  ((select id from books where title = 'The Year of the Flood'), 'slavery', 'moderate', false),
  ((select id from books where title = 'The Year of the Flood'), 'animal_harm', 'moderate', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'The Year of the Flood'), 'humor_level', 0.5, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- MaddAddam
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'MaddAddam'),
  array['sci_fi'],
  'adult',
  'standard',
  'few',
  'mixed',
  'reliable',
  'nonlinear',
  'framing_device',
  'medium',
  'uneven',
  'character_driven',
  'dark',
  'moderate',
  'bittersweet',
  'moderate',
  'occasional',
  'moderate',
  'understated',
  'frequent',
  'graphic',
  'dense',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'moderate',
  'moderate',
  'cerebral',
  'global',
  'life_threatening',
  'demanding'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'MaddAddam'), 'dystopia'),
  ((select id from books where title = 'MaddAddam'), 'post_apocalyptic'),
  ((select id from books where title = 'MaddAddam'), 'found_family'),
  ((select id from books where title = 'MaddAddam'), 'survivalist_ingenuity'),
  ((select id from books where title = 'MaddAddam'), 'species_divergence')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'MaddAddam'), 'war_trauma', 'central_theme', false),
  ((select id from books where title = 'MaddAddam'), 'sexual_assault', 'moderate', false),
  ((select id from books where title = 'MaddAddam'), 'kidnapping_or_captivity', 'moderate', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'MaddAddam'), 'romance_tone', 0.6, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- Waking Gods
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'Waking Gods'),
  array['sci_fi'],
  'adult',
  'standard',
  'ensemble',
  'mixed',
  'reliable',
  'linear',
  'epistolary',
  'fast',
  'consistent',
  'plot_driven',
  'dark',
  'light',
  'tense',
  'subtle',
  'none',
  'na',
  null,
  'frequent',
  'graphic',
  'moderate',
  null,
  'requires_series',
  'ambiguous',
  'cliffhanger',
  'standard',
  'na',
  'hard',
  'sparse',
  'accessible',
  'moderate',
  'global',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'Waking Gods'), 'mecha_or_giant_robots'),
  ((select id from books where title = 'Waking Gods'), 'alien_invasion'),
  ((select id from books where title = 'Waking Gods'), 'war_story'),
  ((select id from books where title = 'Waking Gods'), 'powerful_artifact_macguffin')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'Waking Gods'), 'war_trauma', 'central_theme', false)
on conflict do nothing;

-- Only Human
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'Only Human'),
  array['sci_fi'],
  'adult',
  'standard',
  'several',
  'mixed',
  'reliable',
  'nonlinear',
  'epistolary',
  'medium',
  'uneven',
  'character_driven',
  'moderate',
  'light',
  'bittersweet',
  'moderate',
  'rare',
  'low',
  null,
  'occasional',
  'moderate',
  'dense',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'hard',
  'sparse',
  'accessible',
  'moderate',
  'global',
  'high',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'Only Human'), 'mecha_or_giant_robots'),
  ((select id from books where title = 'Only Human'), 'first_contact'),
  ((select id from books where title = 'Only Human'), 'found_family'),
  ((select id from books where title = 'Only Human'), 'coming_of_age')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'Only Human'), 'war_trauma', 'moderate', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'Only Human'), 'drive', 0.5, 'ai_inferred'),
  ((select id from books where title = 'Only Human'), 'pov_count', 0.5, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- The Ballad of Never After
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Ballad of Never After'),
  array['fantasy'],
  'ya',
  'standard',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'consistent',
  'romance_driven',
  'moderate',
  'light',
  'tense',
  'subtle',
  'occasional',
  'low',
  'mixed',
  'occasional',
  'moderate',
  'moderate',
  null,
  'requires_series',
  'bittersweet',
  'cliffhanger',
  'standard',
  'soft',
  'na',
  'moderate',
  'accessible',
  'escapist',
  'intimate',
  'high',
  'gateway'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Ballad of Never After'), 'enemies_to_lovers'),
  ((select id from books where title = 'The Ballad of Never After'), 'slow_burn_romance'),
  ((select id from books where title = 'The Ballad of Never After'), 'magically_binding_bargain'),
  ((select id from books where title = 'The Ballad of Never After'), 'epic_quest'),
  ((select id from books where title = 'The Ballad of Never After'), 'mythological_retelling')
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'The Ballad of Never After'), 'romance_tone', 0.2, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- The Faith of Beasts
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Faith of Beasts'),
  array['sci_fi'],
  'adult',
  'standard',
  'several',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'consistent',
  'plot_driven',
  'dark',
  'light',
  'tense',
  'moderate',
  'none',
  'na',
  null,
  'frequent',
  'graphic',
  'dense',
  null,
  'requires_series',
  'ambiguous',
  'cliffhanger',
  'standard',
  'na',
  'hard',
  'moderate',
  'moderate',
  'moderate',
  'global',
  'life_threatening',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Faith of Beasts'), 'multiple_alien_species'),
  ((select id from books where title = 'The Faith of Beasts'), 'space_opera'),
  ((select id from books where title = 'The Faith of Beasts'), 'war_story'),
  ((select id from books where title = 'The Faith of Beasts'), 'infiltration_or_undercover_plot'),
  ((select id from books where title = 'The Faith of Beasts'), 'court_intrigue')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Faith of Beasts'), 'slavery', 'central_theme', false),
  ((select id from books where title = 'The Faith of Beasts'), 'war_trauma', 'moderate', false),
  ((select id from books where title = 'The Faith of Beasts'), 'colonization_themes', 'moderate', false)
on conflict do nothing;

-- The Hunger of the Gods
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Hunger of the Gods'),
  array['fantasy'],
  'adult',
  'long',
  'several',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'slow_burn_to_fast_finish',
  'plot_driven',
  'dark',
  'light',
  'tense',
  'subtle',
  'rare',
  'low',
  null,
  'frequent',
  'brutal',
  'dense',
  null,
  'requires_series',
  'bittersweet',
  'cliffhanger',
  'long',
  'soft',
  'na',
  'moderate',
  'moderate',
  'moderate',
  'regional',
  'life_threatening',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Hunger of the Gods'), 'ancient_evil_awakens'),
  ((select id from books where title = 'The Hunger of the Gods'), 'war_story'),
  ((select id from books where title = 'The Hunger of the Gods'), 'revenge'),
  ((select id from books where title = 'The Hunger of the Gods'), 'mythological_pantheon_as_characters'),
  ((select id from books where title = 'The Hunger of the Gods'), 'multiple_fantasy_species')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Hunger of the Gods'), 'kidnapping_or_captivity', 'moderate', false),
  ((select id from books where title = 'The Hunger of the Gods'), 'war_trauma', 'central_theme', false),
  ((select id from books where title = 'The Hunger of the Gods'), 'slavery', 'moderate', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'The Hunger of the Gods'), 'stakes_scope', 0.5, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- Wayward Pines - Revolta
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'Wayward Pines - Revolta'),
  array['sci_fi'],
  'adult',
  'standard',
  'single',
  'third_limited',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'slow_burn_to_fast_finish',
  'plot_driven',
  'dark',
  'none',
  'tense',
  'subtle',
  'rare',
  'low',
  null,
  'frequent',
  'graphic',
  'dense',
  null,
  'requires_series',
  'ambiguous',
  'cliffhanger',
  'standard',
  'na',
  'soft',
  'sparse',
  'accessible',
  'moderate',
  'regional',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'Wayward Pines - Revolta'), 'dystopia'),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'post_apocalyptic'),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'twist_ending'),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'survivalist_ingenuity'),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'noir_detective_structure')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'Wayward Pines - Revolta'), 'body_horror', 'central_theme', false),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'mental_illness_depiction', 'moderate', false),
  ((select id from books where title = 'Wayward Pines - Revolta'), 'kidnapping_or_captivity', 'central_theme', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'Wayward Pines - Revolta'), 'pov_count', 0.5, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- The Last Town
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Last Town'),
  array['sci_fi'],
  'adult',
  'standard',
  'several',
  'third_limited',
  'reliable',
  'nonlinear',
  'standard_prose',
  'fast',
  'front_loaded',
  'plot_driven',
  'dark',
  'none',
  'gut_punch',
  'subtle',
  'rare',
  'low',
  null,
  'frequent',
  'brutal',
  'dense',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'standard',
  'na',
  'soft',
  'sparse',
  'accessible',
  'moderate',
  'regional',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Last Town'), 'post_apocalyptic'),
  ((select id from books where title = 'The Last Town'), 'dystopia'),
  ((select id from books where title = 'The Last Town'), 'survivalist_ingenuity'),
  ((select id from books where title = 'The Last Town'), 'last_minute_rescue'),
  ((select id from books where title = 'The Last Town'), 'war_story')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Last Town'), 'body_horror', 'central_theme', false),
  ((select id from books where title = 'The Last Town'), 'war_trauma', 'central_theme', false),
  ((select id from books where title = 'The Last Town'), 'kidnapping_or_captivity', 'moderate', false)
on conflict do nothing;

-- The Long Dark Tea-Time of the Soul
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Long Dark Tea-Time of the Soul'),
  array['fantasy'],
  'adult',
  'standard',
  'several',
  'third_omniscient',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'uneven',
  'plot_driven',
  'moderate',
  'heavy',
  'comfort_read',
  'moderate',
  'none',
  'na',
  null,
  'occasional',
  'moderate',
  'moderate',
  null,
  'self_contained',
  'happy',
  'resolved',
  'standard',
  'soft',
  'na',
  'moderate',
  'moderate',
  'moderate',
  'global',
  'high',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Long Dark Tea-Time of the Soul'), 'mythological_pantheon_as_characters'),
  ((select id from books where title = 'The Long Dark Tea-Time of the Soul'), 'satirical_or_comedic_fantasy'),
  ((select id from books where title = 'The Long Dark Tea-Time of the Soul'), 'noir_detective_structure'),
  ((select id from books where title = 'The Long Dark Tea-Time of the Soul'), 'twist_ending'),
  ((select id from books where title = 'The Long Dark Tea-Time of the Soul'), 'found_family')
on conflict do nothing;

-- The Reptile Room
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Reptile Room'),
  array['fantasy'],
  'middle_grade',
  'short',
  'ensemble',
  'third_omniscient',
  'reliable',
  'linear',
  'framing_device',
  'medium',
  'consistent',
  'plot_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'subtle',
  'none',
  'na',
  null,
  'rare',
  'mild',
  'light',
  null,
  'requires_series',
  'tragic',
  'resolved',
  'short',
  'na',
  'na',
  'sparse',
  'moderate',
  'moderate',
  'intimate',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Reptile Room'), 'found_family'),
  ((select id from books where title = 'The Reptile Room'), 'black_and_white_morality'),
  ((select id from books where title = 'The Reptile Room'), 'hidden_talent_prodigy'),
  ((select id from books where title = 'The Reptile Room'), 'major_character_death'),
  ((select id from books where title = 'The Reptile Room'), 'wise_mentor')
on conflict do nothing;

-- The Wide Window
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Wide Window'),
  array['fantasy'],
  'middle_grade',
  'short',
  'ensemble',
  'third_omniscient',
  'reliable',
  'linear',
  'framing_device',
  'medium',
  'consistent',
  'plot_driven',
  'moderate',
  'moderate',
  'bittersweet',
  'subtle',
  'none',
  'na',
  null,
  'rare',
  'mild',
  'light',
  null,
  'requires_series',
  'tragic',
  'resolved',
  'short',
  'na',
  'na',
  'sparse',
  'moderate',
  'moderate',
  'intimate',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Wide Window'), 'found_family'),
  ((select id from books where title = 'The Wide Window'), 'black_and_white_morality'),
  ((select id from books where title = 'The Wide Window'), 'major_character_death'),
  ((select id from books where title = 'The Wide Window'), 'survivalist_ingenuity'),
  ((select id from books where title = 'The Wide Window'), 'twist_ending')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Wide Window'), 'suicide', 'moderate', true)
on conflict do nothing;

-- The Throne of Fire
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Throne of Fire'),
  array['fantasy'],
  'ya',
  'standard',
  'dual',
  'first',
  'reliable',
  'linear',
  'framing_device',
  'fast',
  'consistent',
  'plot_driven',
  'moderate',
  'moderate',
  'tense',
  'subtle',
  'rare',
  'low',
  null,
  'occasional',
  'mild',
  'dense',
  null,
  'requires_series',
  'bittersweet',
  'cliffhanger',
  'standard',
  'hard',
  'na',
  'sparse',
  'accessible',
  'moderate',
  'global',
  'high',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Throne of Fire'), 'mythological_pantheon_as_characters'),
  ((select id from books where title = 'The Throne of Fire'), 'epic_quest'),
  ((select id from books where title = 'The Throne of Fire'), 'prophecy'),
  ((select id from books where title = 'The Throne of Fire'), 'secret_royalty'),
  ((select id from books where title = 'The Throne of Fire'), 'found_family')
on conflict do nothing;

-- The Vampire Lestat
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Vampire Lestat'),
  array['fantasy'],
  'adult',
  'long',
  'single',
  'first',
  'unreliable',
  'nonlinear',
  'framing_device',
  'slow',
  'consistent',
  'character_driven',
  'dark',
  'light',
  'gut_punch',
  'moderate',
  'occasional',
  'moderate',
  'melodramatic',
  'frequent',
  'graphic',
  'moderate',
  null,
  'requires_series',
  'bittersweet',
  'cliffhanger',
  'long',
  'na',
  'na',
  'lush',
  'dense',
  'cerebral',
  'regional',
  'high',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Vampire Lestat'), 'vampires'),
  ((select id from books where title = 'The Vampire Lestat'), 'immortal_or_ageless_character'),
  ((select id from books where title = 'The Vampire Lestat'), 'cursed_protagonist'),
  ((select id from books where title = 'The Vampire Lestat'), 'morally_grey_protagonist'),
  ((select id from books where title = 'The Vampire Lestat'), 'major_character_death'),
  ((select id from books where title = 'The Vampire Lestat'), 'retrospective_memoir_narration')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Vampire Lestat'), 'war_trauma', 'moderate', false),
  ((select id from books where title = 'The Vampire Lestat'), 'suicide', 'moderate', false)
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'The Vampire Lestat'), 'narrator_reliability', 0.6, 'ai_inferred'),
  ((select id from books where title = 'The Vampire Lestat'), 'romance_tone', 0.6, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- To Say Nothing of the Dog
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'To Say Nothing of the Dog'),
  array['sci_fi'],
  'adult',
  'long',
  'single',
  'first',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'uneven',
  'balanced',
  'light',
  'heavy',
  'comfort_read',
  'subtle',
  'occasional',
  'closed_door',
  'understated',
  'none',
  'na',
  'moderate',
  null,
  'self_contained',
  'happy',
  'resolved',
  'long',
  'na',
  'hard',
  'moderate',
  'moderate',
  'moderate',
  'regional',
  'moderate',
  'moderate'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'To Say Nothing of the Dog'), 'time_travel'),
  ((select id from books where title = 'To Say Nothing of the Dog'), 'satirical_or_comedic_scifi'),
  ((select id from books where title = 'To Say Nothing of the Dog'), 'institutional_time_travel_bureaucracy'),
  ((select id from books where title = 'To Say Nothing of the Dog'), 'slow_burn_romance')
on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
values
  ((select id from books where title = 'To Say Nothing of the Dog'), 'romance_tone', 0.6, 'ai_inferred')
on conflict (book_id, field_name) do nothing;

-- The BFG
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The BFG'),
  array['fantasy'],
  'middle_grade',
  'short',
  'single',
  'third_omniscient',
  'reliable',
  'linear',
  'standard_prose',
  'fast',
  'consistent',
  'plot_driven',
  'moderate',
  'heavy',
  'comfort_read',
  'subtle',
  'none',
  'na',
  null,
  'rare',
  'mild',
  'light',
  null,
  'self_contained',
  'happy',
  'resolved',
  'short',
  'soft',
  'na',
  'moderate',
  'accessible',
  'escapist',
  'regional',
  'moderate',
  'gateway'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The BFG'), 'found_family'),
  ((select id from books where title = 'The BFG'), 'underdog_rising'),
  ((select id from books where title = 'The BFG'), 'black_and_white_morality'),
  ((select id from books where title = 'The BFG'), 'reluctant_hero')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The BFG'), 'child_death', 'brief', false)
on conflict do nothing;

-- The Witches
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
) values (
  (select id from books where title = 'The Witches'),
  array['fantasy'],
  'middle_grade',
  'short',
  'single',
  'first',
  'reliable',
  'linear',
  'standard_prose',
  'medium',
  'consistent',
  'character_driven',
  'dark',
  'moderate',
  'bittersweet',
  'subtle',
  'none',
  'na',
  null,
  'occasional',
  'moderate',
  'light',
  null,
  'self_contained',
  'bittersweet',
  'resolved',
  'short',
  'soft',
  'na',
  'moderate',
  'accessible',
  'moderate',
  'global',
  'life_threatening',
  'accessible'
)
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
values
  ((select id from books where title = 'The Witches'), 'found_family'),
  ((select id from books where title = 'The Witches'), 'shapeshifters'),
  ((select id from books where title = 'The Witches'), 'black_and_white_morality'),
  ((select id from books where title = 'The Witches'), 'underdog_rising')
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
values
  ((select id from books where title = 'The Witches'), 'child_death', 'central_theme', false),
  ((select id from books where title = 'The Witches'), 'body_horror', 'moderate', false)
on conflict do nothing;
