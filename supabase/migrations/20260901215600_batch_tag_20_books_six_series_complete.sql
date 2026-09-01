-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA.
-- Completes SIX series:
-- - The Locked Tomb: 1/3 -> 3/3 (Harrow the Ninth, Nona the Ninth)
-- - Crescent City: 1/3 -> 3/3 (House of Sky and Breath, House of Flame
--   and Shadow)
-- - The Shadow and Bone Trilogy: 1/3 -> 3/3 (Siege and Storm, Ruin and
--   Rising)
-- - Robot (Asimov): 1/2 -> 2/2 (The Caves of Steel)
-- - The Dresden Files: 2/4 -> 4/4 (Fool Moon, Grave Peril)
-- - The Reckoners: 1/2 -> 2/2 (Firefight)
-- Also advances Ninth House, Wayfarers, Silo, Skyward, Secret Projects,
-- The Green Bone Saga, Gentleman Bastard, The Lunar Chronicles, The Heroes
-- of Olympus, and The Maze Runner (its finale, The Death Cure).
--
-- Skipped: The Farseer Trilogy omnibus (pure duplicate, as always) and
-- 'Monk and Robot' -- confirmed via direct query to be an omnibus of the
-- 2 already-individually-tagged Monk & Robot books (A Psalm for the
-- Wild-Built, A Prayer for the Crown-Shy), same reasoning as Farseer.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Fool Moon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Fool Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Fool Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Fool Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Fool Moon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Grave Peril'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Grave Peril' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Grave Peril' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Grave Peril' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Grave Peril' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Grave Peril' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Grave Peril' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'cerebral', 'intimate', 'moderate'
from books where title = 'Record of a Spaceborn Few'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'generation_ship' from books where title = 'Record of a Spaceborn Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Record of a Spaceborn Few' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'tragic', 'resolved', 'long', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'high'
from books where title = 'Shift'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Shift' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Shift' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Shift' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Shift' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Shift' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Shift' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Starsight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Starsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Starsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Starsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Starsight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Firefight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Firefight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Firefight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Firefight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Firefight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Firefight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'standard', 'dual', 'mixed', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'soft', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Harrow the Ninth'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Harrow the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Harrow the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Harrow the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Harrow the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'Harrow the Ninth' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Harrow the Ninth' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Hell Bent'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Hell Bent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Hell Bent' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Hell Bent' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'subtle', 'frequent', 'explicit', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'House of Flame and Shadow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'House of Flame and Shadow' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'House of Flame and Shadow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'House of Flame and Shadow' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'frequent', 'explicit', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'House of Sky and Breath'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'House of Sky and Breath' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'House of Sky and Breath' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'House of Sky and Breath' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'House of Sky and Breath' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'House of Sky and Breath' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'House of Sky and Breath' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'House of Sky and Breath' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Isles of the Emberdark'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Isles of the Emberdark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Isles of the Emberdark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Isles of the Emberdark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Isles of the Emberdark' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Jade War'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'crime_family_saga' from books where title = 'Jade War' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Jade War' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Jade War' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Jade War' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Jade War' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Jade War' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Jade War' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'standard', 'several', 'first', 'unreliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'soft', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Nona the Ninth'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'Nona the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Nona the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Nona the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Nona the Ninth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Nona the Ninth' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Nona the Ninth' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Red Seas Under Red Skies'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'renaissance_or_mercantile_setting' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Red Seas Under Red Skies' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Red Seas Under Red Skies' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Ruin and Rising'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Ruin and Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Ruin and Rising' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Ruin and Rising' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'high'
from books where title = 'Scarlet'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Scarlet' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Scarlet' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Scarlet' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Scarlet' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Scarlet' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Scarlet' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Siege and Storm'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Siege and Storm' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'moderate', 'gut_punch', 'subtle', 'occasional', 'na', 'frequent', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'life_threatening'
from books where title = 'The Blood Of Olympus'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Blood Of Olympus' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Blood Of Olympus' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Blood Of Olympus' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'moderate'
from books where title = 'The Caves of Steel'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Caves of Steel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Caves of Steel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'The Caves of Steel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Caves of Steel' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'The Death Cure'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Death Cure' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Death Cure' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Death Cure' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Death Cure' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Death Cure' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Death Cure' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Death Cure' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Death Cure' on conflict do nothing;

