-- Catalog tagging batch: 20 books, CLDA round-4-continued (self-screened)
-- Tagged by CLDA per .claude/skills/tag-catalog-batch/SKILL.md.
-- 3 author-field contamination fixes verified via Hardcover's cached_contributors
-- GraphQL API before applying: Redwall (Gary Chalk = Illustrator, not co-author),
-- Remote Control (Adjoa Andoh = Narrator), Sunreach (Suzy Jackson = Narrator, unlike
-- Sanderson/Patterson who are genuine co-authors on this and ReDawn/Evershore).
-- romance_tone/worldbuilding_delivery left null catalog-wide this batch: this
-- session's WebSearch budget was already exhausted (shared with a sibling batch)
-- before real scene-level presentation evidence could be gathered for either field,
-- so per the skill's evidence standard, both are left null rather than pattern-
-- matched from genre/author reputation.

-- Author-field contamination fixes (verified via Hardcover cached_contributors)
update books set author = 'Brian Jacques'
  where title = 'Redwall' and author = 'Brian Jacques, Gary Chalk';

update books set author = 'Nnedi Okorafor'
  where title = 'Remote Control' and author = 'Nnedi Okorafor, Adjoa Andoh';

update books set author = 'Brandon Sanderson, Janci Patterson'
  where title = 'Sunreach' and author = 'Brandon Sanderson, Janci Patterson, Suzy Jackson';

-- Nexus
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'Nexus';

insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Nexus';
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Nexus';
insert into book_tropes (book_id, trope_id)
select id, 'infiltration_or_undercover_plot' from books where title = 'Nexus';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'hive_mind', 0.5, 'ai_inferred' from books where title = 'Nexus';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'cybernetic_enhancement', 0.5, 'ai_inferred' from books where title = 'Nexus';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Nexus';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'Nexus';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Nexus'
on conflict (book_id, field_name) do nothing;


-- Of Blood and Fire
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'rare', 'low', null, 'occasional', 'moderate', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'Of Blood and Fire';

insert into book_tropes (book_id, trope_id)
select id, 'dragons' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'chosen_one' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'prophecy' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'ancient_evil_awakens' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'immortal_or_ageless_character', 0.5, 'ai_inferred' from books where title = 'Of Blood and Fire';
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Of Blood and Fire';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Of Blood and Fire';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Of Blood and Fire'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Of Blood and Fire'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'Of Blood and Fire'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Of Blood and Fire'
on conflict (book_id, field_name) do nothing;


-- Ordinary Monsters
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Ordinary Monsters';

insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Ordinary Monsters';
insert into book_tropes (book_id, trope_id)
select id, 'government_experimentation_on_the_gifted' from books where title = 'Ordinary Monsters';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Ordinary Monsters';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'immortal_or_ageless_character', 0.5, 'ai_inferred' from books where title = 'Ordinary Monsters';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'underdog_rising', 0.5, 'ai_inferred' from books where title = 'Ordinary Monsters';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'central_theme', false from books where title = 'Ordinary Monsters';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Ordinary Monsters';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Ordinary Monsters';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Ordinary Monsters'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Ordinary Monsters'
on conflict (book_id, field_name) do nothing;


-- Permutation City
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'none', 'tense', 'moderate', 'rare', 'low', null, 'rare', 'mild', 'dense', null, 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'hard', 'sparse', 'dense', 'cerebral', 'cosmic', 'moderate', 'veteran_only'
from books where title = 'Permutation City';

insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'Permutation City';
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Permutation City';
insert into book_tropes (book_id, trope_id)
select id, 'self_replicating_consciousness' from books where title = 'Permutation City';
insert into book_tropes (book_id, trope_id)
select id, 'virtual_reality_or_simulated_world' from books where title = 'Permutation City';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.6, 'ai_inferred' from books where title = 'Permutation City'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Permutation City'
on conflict (book_id, field_name) do nothing;


-- ReDawn
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'gateway'
from books where title = 'ReDawn';

insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'ReDawn';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_alien_species' from books where title = 'ReDawn';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'court_intrigue', 0.5, 'ai_inferred' from books where title = 'ReDawn';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'ReDawn';


-- Redwall
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'standard', 'few', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'none', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'gateway'
from books where title = 'Redwall';

insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'black_and_white_morality' from books where title = 'Redwall';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Redwall';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Redwall';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Redwall'
on conflict (book_id, field_name) do nothing;


-- Remote Control
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi','fantasy'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Remote Control';

insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Remote Control';
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Remote Control';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'found_family', 0.5, 'ai_inferred' from books where title = 'Remote Control';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', false from books where title = 'Remote Control';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'age_category', 0.5, 'ai_inferred' from books where title = 'Remote Control'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pace_shape', 0.5, 'ai_inferred' from books where title = 'Remote Control'
on conflict (book_id, field_name) do nothing;


-- Rosewater
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high', 'moderate'
from books where title = 'Rosewater';

insert into book_tropes (book_id, trope_id)
select id, 'alien_invasion' from books where title = 'Rosewater';
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'Rosewater';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'government_experimentation_on_the_gifted', 0.5, 'ai_inferred' from books where title = 'Rosewater';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Rosewater';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'moderate', false from books where title = 'Rosewater';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Rosewater'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Rosewater'
on conflict (book_id, field_name) do nothing;


-- Salvation
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'several', 'third_limited', 'ambiguous', 'multi_timeline', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'na', 'hard', 'lush', 'moderate', 'moderate', 'global', 'high', 'demanding'
from books where title = 'Salvation';

insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'Salvation';
insert into book_tropes (book_id, trope_id)
select id, 'first_contact' from books where title = 'Salvation';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Salvation';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'infiltration_or_undercover_plot', 0.5, 'ai_inferred' from books where title = 'Salvation';
insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'Salvation';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Salvation';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Salvation'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'form', 0.5, 'ai_inferred' from books where title = 'Salvation'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Salvation'
on conflict (book_id, field_name) do nothing;


-- Shadow of the Hegemon
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'global', 'high', 'moderate'
from books where title = 'Shadow of the Hegemon';

insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Shadow of the Hegemon';
insert into book_tropes (book_id, trope_id)
select id, 'child_soldiers_in_warfare' from books where title = 'Shadow of the Hegemon';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Shadow of the Hegemon';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Shadow of the Hegemon';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', false from books where title = 'Shadow of the Hegemon';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Shadow of the Hegemon';


-- Shadow Puppets
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'closed_door', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'global', 'high', 'moderate'
from books where title = 'Shadow Puppets';

insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Shadow Puppets';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Shadow Puppets';
insert into book_tropes (book_id, trope_id)
select id, 'dark_lord_or_evil_overlord' from books where title = 'Shadow Puppets';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Shadow Puppets';


-- Sharp Ends
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'dark', 'heavy', 'tense', 'subtle', 'rare', 'low', null, 'frequent', 'brutal', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Sharp Ends';

insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'Sharp Ends';
insert into book_tropes (book_id, trope_id)
select id, 'anti_hero' from books where title = 'Sharp Ends';
insert into book_tropes (book_id, trope_id)
select id, 'heist' from books where title = 'Sharp Ends';
insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Sharp Ends';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Sharp Ends';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'monster_hunter_for_hire', 0.5, 'ai_inferred' from books where title = 'Sharp Ends';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Sharp Ends';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Sharp Ends';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Sharp Ends'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Sharp Ends'
on conflict (book_id, field_name) do nothing;


-- Six Crimson Cranes
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'closed_door', null, 'rare', 'mild', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening', 'accessible'
from books where title = 'Six Crimson Cranes';

insert into book_tropes (book_id, trope_id)
select id, 'mythological_retelling' from books where title = 'Six Crimson Cranes';
insert into book_tropes (book_id, trope_id)
select id, 'arranged_marriage' from books where title = 'Six Crimson Cranes';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'Six Crimson Cranes';
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Six Crimson Cranes';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Six Crimson Cranes'
on conflict (book_id, field_name) do nothing;


-- Sleeping Beauties
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', null, 'frequent', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'moderate'
from books where title = 'Sleeping Beauties';

insert into book_tropes (book_id, trope_id)
select id, 'sudden_apocalypse_event' from books where title = 'Sleeping Beauties';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'immortal_or_ageless_character', 0.5, 'ai_inferred' from books where title = 'Sleeping Beauties';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'found_family', 0.5, 'ai_inferred' from books where title = 'Sleeping Beauties';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'corruption_arc', 0.5, 'ai_inferred' from books where title = 'Sleeping Beauties';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'central_theme', false from books where title = 'Sleeping Beauties';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'Sleeping Beauties';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Sleeping Beauties';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'message_intensity', 0.5, 'ai_inferred' from books where title = 'Sleeping Beauties'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'Sleeping Beauties'
on conflict (book_id, field_name) do nothing;


-- Someone You Can Build a Nest In
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'heavy', 'bittersweet', 'moderate', 'occasional', 'moderate', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Someone You Can Build a Nest In';

insert into book_tropes (book_id, trope_id)
select id, 'monster_or_fae_romance' from books where title = 'Someone You Can Build a Nest In';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Someone You Can Build a Nest In';
insert into book_tropes (book_id, trope_id)
select id, 'enemies_to_lovers' from books where title = 'Someone You Can Build a Nest In';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'Someone You Can Build a Nest In';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'Someone You Can Build a Nest In';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'Someone You Can Build a Nest In';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Someone You Can Build a Nest In'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Someone You Can Build a Nest In'
on conflict (book_id, field_name) do nothing;


-- Sufficiently Advanced Magic
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'long', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'light', 'comfort_read', 'subtle', 'rare', 'low', null, 'occasional', 'moderate', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'hard', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Sufficiently Advanced Magic';

insert into book_tropes (book_id, trope_id)
select id, 'litrpg_or_progression_fantasy' from books where title = 'Sufficiently Advanced Magic';
insert into book_tropes (book_id, trope_id)
select id, 'magic_school' from books where title = 'Sufficiently Advanced Magic';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Sufficiently Advanced Magic';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'Sufficiently Advanced Magic';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Sufficiently Advanced Magic'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'age_category', 0.5, 'ai_inferred' from books where title = 'Sufficiently Advanced Magic'
on conflict (book_id, field_name) do nothing;


-- Sunreach
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'closed_door', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'gateway'
from books where title = 'Sunreach';

insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'Sunreach';
insert into book_tropes (book_id, trope_id)
select id, 'infiltration_or_undercover_plot' from books where title = 'Sunreach';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Sunreach';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Sunreach';


-- Swordheart
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Swordheart';

insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'Swordheart';
insert into book_tropes (book_id, trope_id)
select id, 'grumpy_sunshine' from books where title = 'Swordheart';
insert into book_tropes (book_id, trope_id)
select id, 'slow_burn_romance' from books where title = 'Swordheart';
insert into book_tropes (book_id, trope_id)
select id, 'magically_binding_bargain' from books where title = 'Swordheart';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'brief', false from books where title = 'Swordheart';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Swordheart'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Swordheart'
on conflict (book_id, field_name) do nothing;


-- The Atrocity Archives
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi','fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'heavy', 'tense', 'subtle', 'rare', 'low', null, 'occasional', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'hard', 'moderate', 'moderate', 'cerebral', 'cosmic', 'life_threatening', 'moderate'
from books where title = 'The Atrocity Archives';

insert into book_tropes (book_id, trope_id)
select id, 'cosmic_horror' from books where title = 'The Atrocity Archives';
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'The Atrocity Archives';
insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_scifi' from books where title = 'The Atrocity Archives';
insert into book_tropes (book_id, trope_id)
select id, 'parallel_universe_or_multiverse' from books where title = 'The Atrocity Archives';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Atrocity Archives';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Atrocity Archives';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Atrocity Archives'
on conflict (book_id, field_name) do nothing;


-- The Bone Ships
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Bone Ships';

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Bone Ships';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'The Bone Ships';
insert into book_tropes (book_id, trope_id)
select id, 'redemption_arc' from books where title = 'The Bone Ships';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Bone Ships';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'dragons', 0.5, 'ai_inferred' from books where title = 'The Bone Ships';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Bone Ships';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Bone Ships'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'The Bone Ships'
on conflict (book_id, field_name) do nothing;

