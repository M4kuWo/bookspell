-- Catalog tagging batch 5 (CLDO session, 2026-09-13)
-- 20 books tagged, prioritizing partial-series completion per tag-catalog-batch/SKILL.md Step 2.
-- Also fixes an author-field contamination case found while tagging (Judas Unchained:
-- Spanish translator Marta Garcia Martinez was pulled into books.author alongside
-- Peter F. Hamilton -- confirmed via web search, she translated "La estrella de Pandora"
-- into Spanish, not a co-author).

-- === Author contamination fix ===
update books set author = 'Peter F. Hamilton'
where title = 'Judas Unchained' and author = 'Peter F. Hamilton, Marta García Martínez';

-- === 1. The Golden Fool (Robin Hobb, Tawny Man #2) -- completes Tawny Man ===
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
select id, array['fantasy'], 'adult', 'long', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven',
  'dark', 'light', 'bittersweet', 'moderate',
  'rare', 'closed_door', null,
  'occasional', 'moderate', 'dense',
  'woven', 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  'soft', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'high', 'demanding'
from books where title = 'The Golden Fool';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['court_intrigue','found_family','wise_mentor','prophecy','retrospective_memoir_narration','immortal_or_ageless_character']) t
where title = 'The Golden Fool';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Golden Fool';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'The Golden Fool';

-- === 2. The Last Command (Timothy Zahn, Thrawn Trilogy #3) -- completes Thrawn Trilogy ===
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
select id, array['sci_fi','fantasy'], 'adult', 'standard', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'rare', 'closed_door', null,
  'frequent', 'moderate', 'dense',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  'soft', 'soft', 'sparse', 'accessible',
  'escapist', 'global', 'high', 'accessible'
from books where title = 'The Last Command';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['space_opera','war_story','court_intrigue','villain_turns_ally']) t
where title = 'The Last Command';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Last Command';

-- === 3. Woken Furies (Richard K. Morgan, Takeshi Kovacs #3) -- completes Takeshi Kovacs ===
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
select id, array['sci_fi'], 'adult', 'long', 'single', 'first',
  'reliable', 'nonlinear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'grimdark', 'light', 'tense', 'moderate',
  'occasional', 'explicit', null,
  'frequent', 'brutal', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  'na', 'hard', 'moderate', 'moderate',
  'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Woken Furies';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['revenge','cybernetic_enhancement','mind_uploading_or_digital_immortality','noir_detective_structure','anti_hero']) t
where title = 'Woken Furies';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('torture','central_theme'), ('sexual_assault','moderate'), ('war_trauma','moderate')) as x(w, s)
where title = 'Woken Furies';

-- === 4. Hollow City (Ransom Riggs, Miss Peregrine's #2) -- completes Miss Peregrine's (in catalog) ===
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
select id, array['fantasy'], 'ya', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'occasional', 'closed_door', 'understated',
  'occasional', 'moderate', 'moderate',
  'woven', 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'regional', 'life_threatening', 'accessible'
from books where title = 'Hollow City';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['time_loop','found_family','portal_fantasy','long_journey','coming_of_age','ancient_evil_awakens']) t
where title = 'Hollow City';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('war_trauma','moderate'), ('body_horror','moderate')) as x(w, s)
where title = 'Hollow City';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, 0.6, 'ai_inferred' from books, unnest(array['romance_tone','worldbuilding_delivery']) f
where title = 'Hollow City';

-- === 5. Judas Unchained (Peter F. Hamilton, Commonwealth Saga #2) -- completes Commonwealth Saga ===
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
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'occasional', 'explicit', null,
  'frequent', 'graphic', 'dense',
  null, 'self_contained',
  'happy', 'resolved', 'epic',
  'na', 'hard', 'lush', 'moderate',
  'moderate', 'global', 'high', 'demanding'
from books where title = 'Judas Unchained';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['space_opera','first_contact','ai_consciousness','multiple_alien_species','war_story']) t
where title = 'Judas Unchained';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('war_trauma','moderate'), ('genocide','moderate')) as x(w, s)
where title = 'Judas Unchained';

-- === 6. Legendary (Stephanie Garber, Caraval #2) -- completes Caraval (in catalog) ===
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
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'light', 'tense', 'subtle',
  'occasional', 'low', 'melodramatic',
  'rare', 'mild', 'moderate',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  'soft', 'na', 'lush', 'moderate',
  'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Legendary';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['found_family','hidden_identity_romance','forbidden_love','twist_ending','epic_quest']) t
where title = 'Legendary';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('emotional_abuse','moderate'), ('kidnapping_or_captivity','moderate')) as x(w, s)
where title = 'Legendary';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Legendary';

-- === 7. Pretties (Scott Westerfeld, Uglies #2) -- completes Uglies (in catalog) ===
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
select id, array['sci_fi'], 'ya', 'standard', 'single', 'third_limited',
  'unreliable', 'linear', 'standard_prose', 'medium', 'uneven', 'balanced',
  'moderate', 'light', 'tense', 'heavy_handed',
  'occasional', 'low', null,
  'rare', 'mild', 'moderate',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  'na', 'soft', 'sparse', 'accessible',
  'moderate', 'regional', 'high', 'accessible'
from books where title = 'Pretties';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['dystopia','coming_of_age','underdog_rising','twist_ending']) t
where title = 'Pretties';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('body_horror','moderate'), ('classism','moderate')) as x(w, s)
where title = 'Pretties';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'Pretties';

-- === 8. Prodigy (Marie Lu, Legend #2) -- completes Legend (in catalog) ===
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
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced',
  'moderate', 'light', 'gut_punch', 'moderate',
  'occasional', 'low', 'mixed',
  'frequent', 'moderate', 'moderate',
  null, 'requires_series',
  'tragic', 'cliffhanger', 'standard',
  'na', 'soft', 'sparse', 'accessible',
  'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Prodigy';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['dystopia','rebellion_against_empire','hidden_talent_prodigy','major_character_death','court_intrigue']) t
where title = 'Prodigy';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('war_trauma','moderate'), ('classism','moderate')) as x(w, s)
where title = 'Prodigy';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Prodigy';

-- === 9. Rule of Wolves (Leigh Bardugo, King of Scars #2) -- completes King of Scars ===
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
select id, array['fantasy'], 'ya', 'long', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'dark', 'moderate', 'tense', 'moderate',
  'occasional', 'low', 'understated',
  'frequent', 'graphic', 'dense',
  null, 'self_contained',
  'bittersweet', 'resolved', 'long',
  'hard', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Rule of Wolves';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['court_intrigue','war_story','found_family','slow_burn_romance','immortal_or_ageless_character']) t
where title = 'Rule of Wolves';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('war_trauma','moderate'), ('torture','moderate')) as x(w, s)
where title = 'Rule of Wolves';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Rule of Wolves';

-- === 10. Shadow & Claw (Gene Wolfe, Book of the New Sun #1) -- completes Book of the New Sun (2-omnibus catalog rep) ===
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
select id, array['sci_fi','fantasy'], 'adult', 'epic', 'single', 'first',
  'unreliable', 'nonlinear', 'framing_device', 'slow', 'uneven', 'character_driven',
  'dark', 'none', 'bittersweet', 'subtle',
  'rare', 'low', null,
  'occasional', 'graphic', 'dense',
  null, 'requires_series',
  'ambiguous', 'cliffhanger', 'epic',
  'soft', 'soft', 'lush', 'dense',
  'cerebral', 'regional', 'high', 'veteran_only'
from books where title = 'Shadow & Claw';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['retrospective_memoir_narration','dying_earth','twist_filled','lost_civilizations','epic_quest','long_journey']) t
where title = 'Shadow & Claw';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('torture','central_theme'), ('sexual_assault','moderate'), ('body_horror','moderate')) as x(w, s)
where title = 'Shadow & Claw';

-- === 11. Shadow of Night (Deborah Harkness, All Souls #2) -- toward All Souls completion ===
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
select id, array['fantasy'], 'adult', 'epic', 'single', 'mixed',
  'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'romance_driven',
  'moderate', 'light', 'bittersweet', 'subtle',
  'frequent', 'moderate', 'understated',
  'rare', 'mild', 'dense',
  null, 'requires_series',
  'happy', 'resolved', 'epic',
  'soft', 'na', 'lush', 'moderate',
  'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'Shadow of Night';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['time_travel','forbidden_love','found_family','vampires','immortal_or_ageless_character']) t
where title = 'Shadow of Night';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('religious_trauma_or_cults','moderate'), ('sexism_or_misogyny_depicted','moderate')) as x(w, s)
where title = 'Shadow of Night';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Shadow of Night';

-- === 12. The Book of Life (Deborah Harkness, All Souls #3) -- completes All Souls ===
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
select id, array['fantasy'], 'adult', 'long', 'single', 'mixed',
  'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced',
  'moderate', 'light', 'bittersweet', 'subtle',
  'frequent', 'moderate', 'understated',
  'occasional', 'moderate', 'dense',
  null, 'self_contained',
  'happy', 'resolved', 'long',
  'soft', 'na', 'lush', 'moderate',
  'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Book of Life';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['found_family','vampires','immortal_or_ageless_character','court_intrigue','prophecy','war_story']) t
where title = 'The Book of Life';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('religious_trauma_or_cults','moderate'), ('war_trauma','moderate')) as x(w, s)
where title = 'The Book of Life';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'The Book of Life';

-- === 13. Shadow of the Giant (Orson Scott Card, Enderverse: Publication Order #9) -- completes catalog series row ===
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
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'moderate', 'light', 'tense', 'moderate',
  'rare', 'closed_door', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'bittersweet', 'resolved', 'standard',
  'na', 'hard', 'sparse', 'accessible',
  'cerebral', 'global', 'life_threatening', 'moderate'
from books where title = 'Shadow of the Giant';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['child_soldiers_in_warfare','hidden_talent_prodigy','war_story','court_intrigue','morally_grey_protagonist']) t
where title = 'Shadow of the Giant';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('war_trauma','central_theme'), ('child_abuse','moderate')) as x(w, s)
where title = 'Shadow of the Giant';

-- === 14. Shorefall (Robert Jackson Bennett, Founders Trilogy #2) -- completes Founders Trilogy (in catalog) ===
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
select id, array['fantasy'], 'adult', 'long', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven',
  'dark', 'light', 'tense', 'moderate',
  'rare', 'closed_door', null,
  'occasional', 'graphic', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'long',
  'hard', 'na', 'moderate', 'moderate',
  'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Shorefall';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['heist','ancient_evil_awakens','found_family','immortal_or_ageless_character','court_intrigue']) t
where title = 'Shorefall';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('slavery','central_theme'), ('classism','moderate')) as x(w, s)
where title = 'Shorefall';

-- === 15. Silverthorn (Raymond E. Feist, Riftwar Saga #2) -- completes Riftwar Saga (in catalog) ===
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
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'rare', 'closed_door', null,
  'occasional', 'moderate', 'moderate',
  null, 'self_contained',
  'happy', 'resolved', 'standard',
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'regional', 'high', 'accessible'
from books where title = 'Silverthorn';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['epic_quest','court_intrigue','wise_mentor','powerful_artifact_macguffin','long_journey','last_minute_rescue']) t
where title = 'Silverthorn';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Silverthorn';

-- === 16. Stone of Tears (Terry Goodkind, Sword of Truth #2) -- completes catalog series row ===
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
select id, array['fantasy'], 'adult', 'epic', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'grimdark', 'light', 'gut_punch', 'heavy_handed',
  'frequent', 'moderate', 'melodramatic',
  'frequent', 'brutal', 'dense',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'epic',
  'soft', 'na', 'lush', 'moderate',
  'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'Stone of Tears';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['chosen_one','epic_quest','prophecy','war_story','revenge']) t
where title = 'Stone of Tears';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('torture','central_theme'), ('dubious_consent','moderate'), ('war_trauma','moderate')) as x(w, s)
where title = 'Stone of Tears';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Stone of Tears';

-- === 17. Tales from the Cafe (Toshikazu Kawaguchi, Before the Coffee Gets Cold #2) -- completes catalog series row ===
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
select id, array['fantasy'], 'adult', 'short', 'ensemble', 'third_limited',
  'reliable', 'nonlinear', 'standard_prose', 'slow', 'consistent', 'character_driven',
  'light', 'light', 'bittersweet', 'moderate',
  'none', 'na', null,
  'none', 'na', 'light',
  null, 'self_contained',
  'bittersweet', 'resolved', 'short',
  'hard', 'na', 'sparse', 'accessible',
  'moderate', 'intimate', 'low', 'gateway'
from books where title = 'Tales from the Cafe';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['time_travel','found_family']) t
where title = 'Tales from the Cafe';

-- === 18. The Ashes and the Star-Cursed King (Carissa Broadbent, Crowns of Nyaxia #2) -- completes Crowns of Nyaxia ===
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
select id, array['fantasy'], 'adult', 'long', 'dual', 'first',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'romance_driven',
  'dark', 'light', 'gut_punch', 'subtle',
  'frequent', 'explicit', 'understated',
  'frequent', 'graphic', 'moderate',
  null, 'requires_series',
  'tragic', 'cliffhanger', 'long',
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Ashes and the Star-Cursed King';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['enemies_to_lovers','vampires','court_intrigue','forced_proximity','monster_or_fae_romance']) t
where title = 'The Ashes and the Star-Cursed King';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('sexual_assault','moderate'), ('torture','moderate'), ('domestic_abuse','moderate')) as x(w, s)
where title = 'The Ashes and the Star-Cursed King';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'The Ashes and the Star-Cursed King';

-- === 19. Heir of Novron (Michael J. Sullivan, The Riyria Revelations (Omnibus) #3) -- completes catalog series row ===
-- Note: confirmed via live query that this is NOT a duplicate of Theft of Swords/Rise of Empire --
-- it's the 3rd of a legitimate 3-omnibus representation of the 6-book Riyria Revelations
-- (same pattern as Book of the New Sun's Shadow&Claw/Sword&Citadel 2-omnibus split), unlike
-- the genuine duplicates skipped this batch (see project-log.md). Flagging the discrepancy
-- from a prior session's note that called this a confirmed duplicate -- current live data
-- does not support that; treated as a real, distinct, untagged book.
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
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'moderate', 'moderate', 'tense', 'subtle',
  'rare', 'closed_door', null,
  'occasional', 'moderate', 'dense',
  null, 'self_contained',
  'happy', 'resolved', 'epic',
  'soft', 'na', 'moderate', 'accessible',
  'escapist', 'regional', 'high', 'accessible'
from books where title = 'Heir of Novron';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['heist','court_intrigue','chosen_one','found_family','prophecy']) t
where title = 'Heir of Novron';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Heir of Novron';

-- === 20. The Atlas Paradox (Olivie Blake, The Atlas #2) -- completes The Atlas (in catalog) ===
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
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited',
  'reliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'character_driven',
  'dark', 'light', 'tense', 'moderate',
  'occasional', 'low', 'understated',
  'occasional', 'moderate', 'moderate',
  null, 'requires_series',
  'ambiguous', 'cliffhanger', 'standard',
  'hard', 'na', 'lush', 'dense',
  'cerebral', 'regional', 'high', 'demanding'
from books where title = 'The Atlas Paradox';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['dark_academia_setting','magic_school','morally_grey_protagonist','corruption_arc','twist_ending']) t
where title = 'The Atlas Paradox';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('kidnapping_or_captivity','central_theme'), ('mental_illness_depiction','moderate')) as x(w, s)
where title = 'The Atlas Paradox';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'The Atlas Paradox';
