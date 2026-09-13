-- Tagging batch 3, 2026-09-13 (CLDO session, following .claude/skills/tag-catalog-batch)
-- 18 books tagged, prioritizing partial series completion (Step 2 query).
-- 3 NEW permanent-skip candidates found, not tagged:
--   - Monk and Robot (Becky Chambers) -- confirmed omnibus (2 novellas bound
--     together), same schema gap as the other known duplicates.
--   - Villains Duology (V.E. Schwab) -- confirmed omnibus (boxed set + poster).
--   - Heir of Novron (Michael J. Sullivan) -- confirmed omnibus (946pp, combines
--     Wintertide + Percepliquis, the last 2 Riyria Revelations novels).
-- Author-field contamination flagged, not fixed (out of scope): Rocannon's World
--     ('..., Stefan Rudnicki') and Blackflame ('Travis Baldree, ...') both credit
--     the AUDIOBOOK NARRATOR as a second author -- same recurring pattern.

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'understated', 'frequent', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'demanding'
from books where title = 'Demon in White';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Demon in White';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Demon in White';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Demon in White';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Demon in White';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Demon in White';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Demon in White';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Demon in White';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'demanding'
from books where title = 'Kingdoms of Death';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Kingdoms of Death';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Kingdoms of Death';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Kingdoms of Death';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Kingdoms of Death';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Kingdoms of Death';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Kingdoms of Death';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'several', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'gut_punch', 'moderate', 'occasional', 'low', 'melodramatic', 'occasional', 'graphic', 'moderate', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'King''s Cage';
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'King''s Cage';
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'King''s Cage';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'King''s Cage';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'King''s Cage';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'King''s Cage';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'King''s Cage';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'King''s Cage';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'King''s Cage';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'short', 'single', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'worldbuilding_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', null, 'none', 'na', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'low', 'gateway'
from books where title = 'Quidditch Through the Ages';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Quidditch Through the Ages';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.3, 'ai_inferred' from books where title = 'Quidditch Through the Ages';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'none', 'bittersweet', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'lush', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'Rocannon''s World';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Rocannon''s World';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Rocannon''s World';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Rocannon''s World';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Rocannon''s World';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Rocannon''s World';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'occasional', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'The Golden Enclaves';
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Golden Enclaves';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Golden Enclaves';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Golden Enclaves';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Golden Enclaves';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'The Golden Enclaves';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'The Golden Enclaves';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'The Lost Colony';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Lost Colony';
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'The Lost Colony';
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'The Lost Colony';
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Lost Colony';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Mad Ship';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Mad Ship';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Mad Ship';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Mad Ship';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Mad Ship';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Mad Ship';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'The Mad Ship';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Mad Ship';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Mad Ship';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'long', 'hard', 'na', 'lush', 'dense', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'The Magician''s Land';
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Magician''s Land';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Magician''s Land';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Magician''s Land';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Magician''s Land';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Magician''s Land';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'worldbuilding_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'occasional', 'brutal', 'moderate', 'woven', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'lush', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'The Word for World Is Forest';
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Word for World Is Forest';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'The Word for World Is Forest';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Word for World Is Forest';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Word for World Is Forest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'The Word for World Is Forest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Word for World Is Forest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'The Word for World Is Forest';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'cerebral', 'global', 'moderate', 'moderate'
from books where title = '2010: Odyssey Two';
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = '2010: Odyssey Two';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = '2010: Odyssey Two';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = '2010: Odyssey Two';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'A Deepness in the Sky';
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'A Deepness in the Sky';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'A Deepness in the Sky';
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'A Deepness in the Sky';
insert into book_tropes (book_id, trope_id) select id, 'cryosleep' from books where title = 'A Deepness in the Sky';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'A Deepness in the Sky';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'A Deepness in the Sky';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'new_adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'melodramatic', 'occasional', 'graphic', 'moderate', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'demanding'
from books where title = 'A Kingdom of Flesh and Fire';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'A Kingdom of Flesh and Fire';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'A Kingdom of Flesh and Fire';
insert into book_tropes (book_id, trope_id) select id, 'fated_mates' from books where title = 'A Kingdom of Flesh and Fire';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Kingdom of Flesh and Fire';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'A Kingdom of Flesh and Fire';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'A Kingdom of Flesh and Fire';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'A Kingdom of Flesh and Fire';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'gut_punch', 'moderate', 'occasional', 'low', 'understated', 'frequent', 'brutal', 'moderate', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'A Torch Against the Night';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'A Torch Against the Night';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'A Torch Against the Night';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'A Torch Against the Night';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'A Torch Against the Night';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'A Torch Against the Night';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'A Torch Against the Night';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'A Torch Against the Night';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'A Torch Against the Night';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'A Torch Against the Night';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'closed_door', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Abhorsen';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Abhorsen';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Abhorsen';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Abhorsen';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Assassin''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Assassin''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Assassin''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Assassin''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Assassin''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Assassin''s Fate';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Assassin''s Fate';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Assassin''s Fate';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', 'understated', 'frequent', 'brutal', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'Beyond the Shadows';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Beyond the Shadows';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Beyond the Shadows';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Beyond the Shadows';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Beyond the Shadows';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Beyond the Shadows';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Beyond the Shadows';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Beyond the Shadows';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Beyond the Shadows';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'standard', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'Blackflame';
insert into book_tropes (book_id, trope_id) select id, 'litrpg_or_progression_fantasy' from books where title = 'Blackflame';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Blackflame';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Blackflame';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Blackflame';

