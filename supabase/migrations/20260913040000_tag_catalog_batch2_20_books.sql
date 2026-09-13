-- Tagging batch 2, 2026-09-13 (CLDO session, following .claude/skills/tag-catalog-batch)
-- 20 books tagged, prioritizing partial series completion (Step 2 query).
-- Foundation Trilogy / Red God / Winds of Winter still permanently skipped (reappear
-- every query since they never get a book_dna row -- not re-litigated here).
-- 2 NEW permanent-skip candidates found in this batch, not tagged:
--   - The Doors of Stone (Patrick Rothfuss) -- unpublished, same as Winds of Winter.
--   - The Farseer Trilogy (Robin Hobb) -- confirmed omnibus duplicate, same schema
--     gap as Foundation/Villains/Monk and Robot (already documented).
-- Author-field contamination flagged, not fixed (out of scope): The Redemption of
--     Time's author field 'Baoshu, Ken Liu' -- Ken Liu is the English translator
--     only, not a co-author (Baoshu is the sole author, a pen name for Li Jun).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'mixed', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'lush', 'dense', 'cerebral', 'intimate', 'high', 'demanding'
from books where title = 'Burning Chrome';
insert into book_tropes (book_id, trope_id) select id, 'cyberpunk' from books where title = 'Burning Chrome';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Burning Chrome';
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Burning Chrome';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Burning Chrome';
insert into book_tropes (book_id, trope_id) select id, 'villain_protagonist' from books where title = 'Burning Chrome';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Burning Chrome';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'medium', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'cosmic', 'moderate', 'demanding'
from books where title = 'Excession';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Excession';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Excession';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'Excession';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Excession';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'lush', 'dense', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Look to Windward';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Look to Windward';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Look to Windward';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Look to Windward';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Look to Windward';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'Look to Windward';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Look to Windward';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'Matter';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Matter';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Matter';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Matter';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Matter';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Matter';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'Surface Detail';
insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Surface Detail';
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'Surface Detail';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Surface Detail';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Surface Detail';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'Surface Detail';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Surface Detail';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Surface Detail';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'front_loaded', 'character_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'House of Chains';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'House of Chains';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'House of Chains';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'House of Chains';
insert into book_tropes (book_id, trope_id) select id, 'berserker_rage' from books where title = 'House of Chains';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'House of Chains';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'House of Chains';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'House of Chains';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'House of Chains';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'grimdark', 'moderate', 'tense', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'veteran_only'
from books where title = 'Midnight Tides';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Midnight Tides';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Midnight Tides';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Midnight Tides';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Midnight Tides';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Midnight Tides';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Midnight Tides';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Midnight Tides';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Midnight Tides';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Reaper''s Gale';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Reaper''s Gale';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Reaper''s Gale';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Reaper''s Gale';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Reaper''s Gale';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Reaper''s Gale';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Reaper''s Gale';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Reaper''s Gale';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'veteran_only'
from books where title = 'The Bonehunters';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Bonehunters';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Bonehunters';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Bonehunters';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'The Bonehunters';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Bonehunters';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Bonehunters';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Bonehunters';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'veteran_only'
from books where title = 'Toll the Hounds';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Toll the Hounds';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Toll the Hounds';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Toll the Hounds';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Toll the Hounds';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Toll the Hounds';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Toll the Hounds';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'veteran_only'
from books where title = 'The Crippled God';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Crippled God';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Crippled God';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Crippled God';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Crippled God';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Crippled God';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'The Crippled God';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Crippled God';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'high', 'moderate'
from books where title = 'Mitosis: A Reckoners Story';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Mitosis: A Reckoners Story';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Mitosis: A Reckoners Story';
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'Mitosis: A Reckoners Story';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'moderate', 'comfort_read', 'moderate', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'Provenance';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Provenance';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Provenance';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Provenance';
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'Provenance';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.4, 'ai_inferred' from books where title = 'Provenance';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'closed_door', 'understated', 'rare', 'moderate', 'dense', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Translation State';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Translation State';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Translation State';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Translation State';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Translation State';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.3, 'ai_inferred' from books where title = 'Translation State';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Translation State';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'cerebral', 'global', 'high', 'moderate'
from books where title = 'Robots and Empire';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Robots and Empire';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Robots and Empire';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Robots and Empire';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Robots and Empire';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'light', 'tense', 'moderate', 'occasional', 'low', 'understated', 'none', 'na', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'cerebral', 'regional', 'moderate', 'moderate'
from books where title = 'The Robots of Dawn';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Robots of Dawn';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Robots of Dawn';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Robots of Dawn';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Robots of Dawn';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Robots of Dawn';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'rare', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'dense', 'cerebral', 'intimate', 'high', 'demanding'
from books where title = 'Tehanu';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Tehanu';
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Tehanu';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Tehanu';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Tehanu';
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Tehanu';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'Tehanu';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Tehanu';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Tehanu';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'gut_punch', 'moderate', 'rare', 'closed_door', 'understated', 'frequent', 'graphic', 'moderate', 'woven', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Kill Order';
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'The Kill Order';
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Kill Order';
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Kill Order';
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'The Kill Order';
insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'The Kill Order';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Kill Order';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Kill Order';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Kill Order';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'The Kill Order';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'frequent', 'moderate', 'melodramatic', 'occasional', 'moderate', 'moderate', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'soft', 'soft', 'lush', 'moderate', 'escapist', 'regional', 'high', 'demanding'
from books where title = 'Restore Me';
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Restore Me';
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Restore Me';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Restore Me';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Restore Me';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Restore Me';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Restore Me';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Restore Me';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'high', 'veteran_only'
from books where title = 'The Redemption of Time';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'The Redemption of Time';
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Redemption of Time';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Redemption of Time';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Redemption of Time';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Redemption of Time';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.4, 'ai_inferred' from books where title = 'The Redemption of Time';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'The Redemption of Time';

