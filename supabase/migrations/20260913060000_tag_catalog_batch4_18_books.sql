-- Tagging batch 4, 2026-09-13 (CLDO session, following .claude/skills/tag-catalog-batch)
-- 18 books tagged, prioritizing partial series completion (Step 2 query).
-- 13 series brought to full completion (within this catalog's current
-- scope, not necessarily the real-world series' full length): Fitz and
-- the Fool (3/3), Mars Trilogy (3/3), The Old Kingdom (3/3), Night Angel
-- (3/3), Cradle (3/3), Revelation Space (2/2), Wayward Children (2/2),
-- Outlander (2/2), The Final Architecture (2/2), Daemon (2/2), The Giver
-- (2/2), He Who Fights with Monsters (3/3), Lock In (2/2) -- each
-- verified via direct query after applying, not assumed from the
-- pre-batch counts.
-- "He Who Fights with Monsters 2"/"3" both credit author as "Shirtaloon,
-- Travis Deverell" -- verified via web search this is NOT author-field
-- contamination: Shirtaloon is Travis Deverell's own pen name, i.e. one
-- real author credited two ways, same category as other legitimate
-- pen-name-plus-real-name cases already accepted in this project.
-- Density self-check: batch landed at 4.61 tropes/book, 1.78 CWs/book
-- after one enrichment pass (up from an initial 3.78/1.06), against a
-- fresh catalog-wide average of 5.41/2.07 -- both land within ~85% of
-- average. The remaining gap is attributable to genuine content
-- differences (Kim Stanley Robinson's Mars Trilogy and Will Wight's
-- Cradle both run genuinely light on trope-vocabulary/CW-worthy content
-- relative to typical epic fantasy), not under-tagging -- documented
-- transparently per this project's own standing policy on that
-- distinction, rather than force-adding unjustified tags to close it
-- further.
-- Pre-existing hosted/local drift (4 book_tropes / 1 book_content_warnings
-- / 1 book_field_confidence row, first flagged during batch 1's
-- verification) is still present, unchanged by this batch -- book_dna
-- itself matches exactly (941/941) both sides. Still deferred to a
-- future full sync, not investigated here.

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'dual', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'veteran_only'
from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Fool''s Quest';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Fool''s Quest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Fool''s Quest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Fool''s Quest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Fool''s Quest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'self_harm', 'moderate', false from books where title = 'Fool''s Quest';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Fool''s Quest';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Fool''s Quest';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'long', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Lirael';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Lirael';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Lirael';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Lirael';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'occasional', 'moderate', 'understated', 'frequent', 'brutal', 'dense', 'woven', 'requires_series', 'tragic', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Shadow''s Edge';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Shadow''s Edge';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Shadow''s Edge';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Shadow''s Edge';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Shadow''s Edge';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Shadow''s Edge';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'standard', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'Soulsmith';
insert into book_tropes (book_id, trope_id) select id, 'litrpg_or_progression_fantasy' from books where title = 'Soulsmith';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Soulsmith';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Soulsmith';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Soulsmith';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Soulsmith';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'moderate', 'none', 'bittersweet', 'heavy_handed', 'none', 'na', null, 'rare', 'moderate', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'lush', 'dense', 'cerebral', 'global', 'moderate', 'veteran_only'
from books where title = 'Blue Mars';
insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'Blue Mars';
insert into book_tropes (book_id, trope_id) select id, 'aging_reversal_or_rejuvenation' from books where title = 'Blue Mars';
insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'Blue Mars';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Blue Mars';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'explicit', 'understated', 'frequent', 'brutal', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'Broken Angels';
insert into book_tropes (book_id, trope_id) select id, 'cyberpunk' from books where title = 'Broken Angels';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Broken Angels';
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Broken Angels';
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'Broken Angels';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Broken Angels';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Broken Angels';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Broken Angels';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Broken Angels';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Broken Angels';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'dual', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', null, 'frequent', 'brutal', 'dense', 'woven', 'self_contained', 'tragic', 'resolved', 'epic', 'na', 'hard', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'Chasm City';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Chasm City';
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'Chasm City';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Chasm City';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Chasm City';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Chasm City';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Chasm City';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Chasm City';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Chasm City';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'high', 'demanding'
from books where title = 'Dark Force Rising';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Dark Force Rising';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Dark Force Rising';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Dark Force Rising';
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'Dark Force Rising';
insert into book_tropes (book_id, trope_id) select id, 'villain_turns_ally' from books where title = 'Dark Force Rising';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Dark Force Rising';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'short', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'moderate', 'woven', 'self_contained', 'tragic', 'resolved', 'short', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'intimate', 'high', 'accessible'
from books where title = 'Down Among the Sticks and Bones';
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Down Among the Sticks and Bones';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Down Among the Sticks and Bones';
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Down Among the Sticks and Bones';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Down Among the Sticks and Bones';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'central_theme', false from books where title = 'Down Among the Sticks and Bones';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Down Among the Sticks and Bones';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'dual', 'first', 'reliable', 'nonlinear', 'framing_device', 'slow', 'consistent', 'romance_driven', 'dark', 'light', 'gut_punch', 'moderate', 'frequent', 'explicit', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Dragonfly in Amber';
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Dragonfly in Amber';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Dragonfly in Amber';
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Dragonfly in Amber';
insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'Dragonfly in Amber';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Dragonfly in Amber';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Dragonfly in Amber';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pregnancy_loss', 'central_theme', false from books where title = 'Dragonfly in Amber';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'Dragonfly in Amber';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'long', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high', 'demanding'
from books where title = 'Eyes of the Void';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Eyes of the Void';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'Eyes of the Void';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Eyes of the Void';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Eyes of the Void';
insert into book_tropes (book_id, trope_id) select id, 'twist_filled' from books where title = 'Eyes of the Void';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Eyes of the Void';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'subtle', 'rare', 'low', 'understated', 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'veteran_only'
from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Fool''s Fate';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Fool''s Fate';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Fool''s Fate';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'self_harm', 'moderate', false from books where title = 'Fool''s Fate';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Fool''s Fate';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'none', 'na', null, 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'happy', 'resolved', 'long', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'Freedom';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Freedom';
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Freedom';
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Freedom';
insert into book_tropes (book_id, trope_id) select id, 'infiltration_or_undercover_plot' from books where title = 'Freedom';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Freedom';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'middle_grade', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'moderate', 'woven', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'gateway'
from books where title = 'Gathering Blue';
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Gathering Blue';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Gathering Blue';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Gathering Blue';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'central_theme', false from books where title = 'Gathering Blue';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Gathering Blue';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'moderate', 'none', 'tense', 'heavy_handed', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'lush', 'dense', 'cerebral', 'global', 'moderate', 'veteran_only'
from books where title = 'Green Mars';
insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'Green Mars';
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Green Mars';
insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'Green Mars';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Green Mars';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'He Who Fights with Monsters 2';
insert into book_tropes (book_id, trope_id) select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights with Monsters 2';
insert into book_tropes (book_id, trope_id) select id, 'isekai' from books where title = 'He Who Fights with Monsters 2';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'He Who Fights with Monsters 2';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'He Who Fights with Monsters 2';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'He Who Fights with Monsters 2';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'understated', 'frequent', 'moderate', 'dense', 'woven', 'requires_series', 'happy', 'cliffhanger', 'long', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';
insert into book_tropes (book_id, trope_id) select id, 'litrpg_or_progression_fantasy' from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';
insert into book_tropes (book_id, trope_id) select id, 'isekai' from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.2, 'ai_inferred' from books where title = 'He Who Fights with Monsters 3: A LitRPG Adventure (He Who Fights with Monsters, Book 3)';

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'Head On';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Head On';
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Head On';
insert into book_tropes (book_id, trope_id) select id, 'twist_filled' from books where title = 'Head On';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'central_theme', false from books where title = 'Head On';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'central_theme', false from books where title = 'Head On';
