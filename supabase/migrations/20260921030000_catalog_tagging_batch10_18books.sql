-- Catalog tagging batch 10 (round-5 pool): 18 books, full Book DNA (CLDA)
-- Prioritized partial-series completion per tag-catalog-batch/SKILL.md Step 2.
-- Completes: Discworld (41/41), Culture (10/10), Earthsea (5/5), The Selection
-- (4/4), Sun Eater (6/6), Murderbot Diaries (11/11), The Expanse (17/17),
-- Hitchhiker's Guide (7/7), Twilight Saga (6/6), Inheritance Cycle (5/5),
-- Artemis Fowl subset (4/4), The Folk of the Air (4/4).
-- Author-field contamination fixed inline (Hardcover cached_contributors
-- verified): 'Dust of Dreams' dropped narrator Michael Page; 'How the King
-- of Elfhame Learned to Hate Stories' dropped illustrator Rovina Cai.

-- author-field contamination fix (Hardcover cached_contributors verified)
update books set author = 'Steven Erikson' where title = 'Dust of Dreams';

-- author-field contamination fix (Hardcover cached_contributors verified)
update books set author = 'Holly Black' where title = 'How the King of Elfhame Learned to Hate Stories';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'moderate', 'accessible'
from books where title = 'The Last Continent';

insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Last Continent';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Last Continent';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Last Continent';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Last Continent';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'few', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'The Shepherd''s Crown';

insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Shepherd''s Crown';
insert into book_tropes (book_id, trope_id) select id, 'mentor_death' from books where title = 'The Shepherd''s Crown';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Shepherd''s Crown';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Shepherd''s Crown';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Shepherd''s Crown';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'The Shepherd''s Crown';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'na', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'Side Jobs: Stories from The Dresden Files';

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Side Jobs: Stories from The Dresden Files';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Side Jobs: Stories from The Dresden Files';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'brief', false from books where title = 'Side Jobs: Stories from The Dresden Files';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'worldbuilding_driven', 'grimdark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Dust of Dreams';

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Dust of Dreams';
insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Dust of Dreams';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Dust of Dreams';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Dust of Dreams';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Dust of Dreams';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_limited', 'ambiguous', 'linear', 'framing_device', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Inversions';

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Inversions';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Inversions';
insert into book_tropes (book_id, trope_id) select id, 'infiltration_or_undercover_plot' from books where title = 'Inversions';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Inversions';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Inversions';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Inversions';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Inversions' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'worldbuilding_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'soft', 'lush', 'moderate', 'cerebral', 'global', 'moderate', 'demanding'
from books where title = 'The Hydrogen Sonata';

insert into book_tropes (book_id, trope_id) select id, 'post_scarcity_utopia' from books where title = 'The Hydrogen Sonata';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Hydrogen Sonata';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'The Hydrogen Sonata';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'The Hydrogen Sonata';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Hydrogen Sonata';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', true from books where title = 'The Hydrogen Sonata';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'moderate', 'mixed', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'intimate', 'moderate', 'demanding'
from books where title = 'The State of the Art';

insert into book_tropes (book_id, trope_id) select id, 'post_scarcity_utopia' from books where title = 'The State of the Art';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'The State of the Art';
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The State of the Art';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The State of the Art';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.2, 'ai_inferred' from books where title = 'The State of the Art' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', null, 'rare', 'mild', 'moderate', 'exposition_dump', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'cosmic', 'high', 'accessible'
from books where title = 'And Another Thing...';

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'And Another Thing...';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'And Another Thing...';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'And Another Thing...';
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'And Another Thing...';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'subtle', 'rare', 'low', null, 'frequent', 'graphic', 'moderate', 'woven', 'requires_series', 'tragic', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Short Second Life of Bree Tanner';

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'The Short Second Life of Bree Tanner';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'The Short Second Life of Bree Tanner';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Short Second Life of Bree Tanner';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'The Short Second Life of Bree Tanner';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'long', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'long', 'hard', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Murtagh';

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Murtagh';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Murtagh';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Murtagh';
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Murtagh';
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Murtagh';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Murtagh';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Murtagh';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Murtagh' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'moderate', 'none', 'bittersweet', 'moderate', 'none', 'na', null, 'rare', 'mild', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'moderate', 'veteran_only'
from books where title = 'The Other Wind';

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'The Other Wind';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Other Wind';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Other Wind';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Other Wind';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy','sci_fi'], 'middle_grade', 'short', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'mild', 'moderate', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'short', 'soft', 'soft', 'sparse', 'accessible', 'moderate', 'global', 'high', 'accessible'
from books where title = 'The Eternity Code';

insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'The Eternity Code';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Eternity Code';
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Eternity Code';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Eternity Code';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'light', 'light', 'comfort_read', 'subtle', 'occasional', 'closed_door', null, 'rare', 'mild', 'light', null, 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'The Heir';

insert into book_tropes (book_id, trope_id) select id, 'royal_suitor_selection_competition' from books where title = 'The Heir';
insert into book_tropes (book_id, trope_id) select id, 'reverse_harem_or_why_choose' from books where title = 'The Heir';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Heir';
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Heir';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'The Heir';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'first', 'unreliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'occasional', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'lush', 'dense', 'cerebral', 'regional', 'high', 'veteran_only'
from books where title = 'Ashes of Man';

insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Ashes of Man';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Ashes of Man';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Ashes of Man';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Ashes of Man';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Ashes of Man';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Ashes of Man';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'brief', false from books where title = 'Ashes of Man';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Ashes of Man';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Ashes of Man' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', null, 'frequent', 'brutal', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'veteran_only'
from books where title = 'Disquiet Gods';

insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Disquiet Gods';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Disquiet Gods';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Disquiet Gods';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Disquiet Gods';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Disquiet Gods';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Disquiet Gods';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Disquiet Gods';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Disquiet Gods';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Disquiet Gods';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Disquiet Gods' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'occasional', 'low', null, 'rare', 'mild', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'moderate', 'moderate'
from books where title = 'How the King of Elfhame Learned to Hate Stories';

insert into book_tropes (book_id, trope_id) select id, 'fae_courts' from books where title = 'How the King of Elfhame Learned to Hate Stories';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'How the King of Elfhame Learned to Hate Stories';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'How the King of Elfhame Learned to Hate Stories';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'How the King of Elfhame Learned to Hate Stories';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'How the King of Elfhame Learned to Hate Stories';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'How the King of Elfhame Learned to Hate Stories';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'requires_series', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy';

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy';
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Rapport: Friendship, Solidarity, Communion, Empathy' on conflict (book_id, field_name) do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'demanding'
from books where title = 'The Sins of Our Fathers';

insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Sins of Our Fathers';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Sins of Our Fathers';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Sins of Our Fathers';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Sins of Our Fathers';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Sins of Our Fathers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'brief', false from books where title = 'The Sins of Our Fathers';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Sins of Our Fathers' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Sins of Our Fathers' on conflict (book_id, field_name) do nothing;
