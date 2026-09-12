-- Tagging batch, 2026-09-13 (CLDO session, following .claude/skills/tag-catalog-batch)
-- 18 books tagged, prioritizing partial series completion (Step 2 query).
-- 3 candidates from the priority list explicitly SKIPPED, not tagged:
--   - The Foundation Trilogy (Isaac Asimov) -- confirmed omnibus (752pp vs
--     ~250-300pp for a single Foundation novel; synopsis describes the full
--     trilogy's arc), same schema gap as the other known omnibus duplicates
--     (book-dna.md's 'omnibus/compilation editions' backlog entry).
--   - The Winds of Winter (George R.R. Martin) -- unpublished, existing
--     permanent-skip precedent (see docs/TODO.md).
--   - Red God (Pierce Brown) -- NOT YET PUBLISHED. Caught by verifying rather
--     than pattern-matching 'next book in a series I know': Brown was still
--     actively writing it as of a March 2026 interview, no confirmed release
--     date. Catalog row has no publication_year/synopsis, consistent with a
--     speculative Hardcover pre-listing. Left untagged, same as Winds of Winter.
-- Author-field note, not fixed here (out of this batch's scope, flagging per
-- CLAUDE.md convention): 3 books (A Hat Full of Sky, The Last Hero, Wintersmith)
-- carry 'Terry Pratchett, Paul Kidby' as author -- Kidby is Pratchett's cover
-- illustrator, not a co-author. Same contamination pattern already documented
-- catalog-wide; not touched here since fixing it isn't this batch's job.

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'mentor_death' from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'A Hat Full of Sky';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Hat Full of Sky';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'closed_door', 'understated', 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'I Shall Wear Midnight';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'I Shall Wear Midnight';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'I Shall Wear Midnight';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'I Shall Wear Midnight';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'I Shall Wear Midnight';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'I Shall Wear Midnight';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', false from books where title = 'I Shall Wear Midnight';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pregnancy_loss', 'moderate', false from books where title = 'I Shall Wear Midnight';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'brief', false from books where title = 'I Shall Wear Midnight';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'I Shall Wear Midnight';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'Raising Steam';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Raising Steam';
insert into book_tropes (book_id, trope_id) select id, 'steampunk' from books where title = 'Raising Steam';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Raising Steam';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Raising Steam';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Raising Steam';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Snuff';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Snuff';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Snuff';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Snuff';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Snuff';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Snuff';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'Snuff';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Snuff';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Snuff';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'short', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'gateway'
from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Amazing Maurice and His Educated Rodents';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'moderate', false from books where title = 'The Amazing Maurice and His Educated Rodents';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'global', 'moderate', 'accessible'
from books where title = 'The Last Hero';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Last Hero';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Last Hero';
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Last Hero';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Last Hero';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Last Hero';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'occasional', 'closed_door', 'understated', 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Unseen Academicals';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Unseen Academicals';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Unseen Academicals';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Unseen Academicals';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Unseen Academicals';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'Unseen Academicals';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Unseen Academicals';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Unseen Academicals';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'rare', 'closed_door', 'understated', 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Wintersmith';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Wintersmith';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Wintersmith';
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'Wintersmith';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Wintersmith';
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Wintersmith';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Wintersmith';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'understated', 'frequent', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'global', 'life_threatening', 'demanding'
from books where title = 'Cold Days';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Cold Days';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Cold Days';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Cold Days';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Cold Days';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Cold Days';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Cold Days';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Cold Days';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'global', 'life_threatening', 'demanding'
from books where title = 'Peace Talks';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Peace Talks';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Peace Talks';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Peace Talks';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Peace Talks';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Peace Talks';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'rare', 'low', null, 'frequent', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'demanding'
from books where title = 'Turn Coat';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Turn Coat';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Turn Coat';
insert into book_tropes (book_id, trope_id) select id, 'infiltration_or_undercover_plot' from books where title = 'Turn Coat';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Turn Coat';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Turn Coat';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'brief', false from books where title = 'Turn Coat';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'subtle', 'frequent', 'moderate', 'melodramatic', 'frequent', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'global', 'life_threatening', 'demanding'
from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'City of Heavenly Fire';
insert into book_tropes (book_id, trope_id) select id, 'mlm_romance' from books where title = 'City of Heavenly Fire';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'City of Heavenly Fire';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'City of Heavenly Fire';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'rare', 'closed_door', 'understated', 'occasional', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'moderate', 'gateway'
from books where title = 'The Chalice of the Gods';
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Chalice of the Gods';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Chalice of the Gods';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Chalice of the Gods';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Chalice of the Gods';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'The Chalice of the Gods';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'closed_door', 'understated', 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'moderate', 'moderate'
from books where title = 'Ender in Exile';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Ender in Exile';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Ender in Exile';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Ender in Exile';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Ender in Exile';
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Ender in Exile';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Ender in Exile';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Ender in Exile';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Ender in Exile';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'frequent', 'low', 'melodramatic', 'rare', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'epic', 'soft', 'na', 'lush', 'accessible', 'escapist', 'intimate', 'high', 'moderate'
from books where title = 'Midnight Sun';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Midnight Sun';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Midnight Sun';
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Midnight Sun';
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'Midnight Sun';
insert into book_tropes (book_id, trope_id) select id, 'insta_love' from books where title = 'Midnight Sun';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'central_theme', false from books where title = 'Midnight Sun';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Midnight Sun';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'moderate', 'demanding'
from books where title = 'The End of All Things';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The End of All Things';
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The End of All Things';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The End of All Things';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The End of All Things';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The End of All Things';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'moderate', 'demanding'
from books where title = 'The Human Division';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Human Division';
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Human Division';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'The Human Division';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Human Division';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Human Division';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Auberon';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Auberon';
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Auberon';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Auberon';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.4, 'ai_inferred' from books where title = 'Auberon';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'Auberon';

