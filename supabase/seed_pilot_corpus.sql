-- Seed: 30-book pilot corpus loaded as a smoke test of the schema against real data.
-- Source: docs/pilot/tagged-books.yaml. No series/universe/page-count/ISBN data —
-- that's real bibliographic sourcing work for step 03, not part of this smoke test.
begin;

-- The Three-Body Problem
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Three-Body Problem', 'Liu Cixin') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'third_limited', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'none', 'tense', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'ambiguous', 'cliffhanger', 'na', 'hard');
  insert into book_tropes (book_id, trope_id) values (book_id, 'first_contact');
  insert into book_tropes (book_id, trope_id) values (book_id, 'alien_invasion');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dying_earth');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_filled');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'suicide', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'moderate', false);
end $$;

-- The Golden Compass
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Golden Compass', 'Philip Pullman') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'dark', 'light', 'gut_punch', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'portal_fantasy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'parallel_universe_or_multiverse');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'hidden_talent_prodigy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_ending');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_abuse', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_death', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'brief', false);
end $$;

-- Bird Box
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Bird Box', 'Josh Malerman') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'third_limited', 'reliable', 'multi_timeline', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'gut_punch', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'ambiguous', 'resolved', 'none', 'na');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'suicide', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'mental_illness_depiction', 'moderate', false);
end $$;

-- The Black Company
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Black Company', 'Glen Cook') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'first', 'reliable', 'linear', 'framing_device', 'fast', 'uneven', 'balanced', 'grimdark', 'moderate', 'tense', 'none', 'na', 'frequent', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dark_lord_or_evil_overlord');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'central_theme', false);
end $$;

-- Ender's Game
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Ender''s Game', 'Orson Scott Card') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'chosen_one');
  insert into book_tropes (book_id, trope_id) values (book_id, 'hidden_talent_prodigy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_ending');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'child_soldiers_in_warfare');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'bullying', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'genocide', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'moderate', false);
end $$;

-- Perdido Street Station
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Perdido Street Station', 'China Miéville') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy,sci_fi}', 'multiple', 'third_limited', 'unreliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'worldbuilding_driven', 'dark', 'light', 'gut_punch', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'soft', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_ending');
  insert into book_tropes (book_id, trope_id) values (book_id, 'multiple_fantasy_species');
  insert into book_tropes (book_id, trope_id) values (book_id, 'steampunk');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ancient_evil_awakens');
  insert into book_tropes (book_id, trope_id) values (book_id, 'new_weird_setting');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'sexual_assault', 'moderate', true);
end $$;

-- Assassin's Apprentice
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Assassin''s Apprentice', 'Robin Hobb') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'first', 'reliable', 'linear', 'framing_device', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'rare', 'na', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'hard', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'underdog_rising');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'wise_mentor');
  insert into book_tropes (book_id, trope_id) values (book_id, 'court_intrigue');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'telepathic_animal_bond');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_abuse', 'brief', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'animal_harm', 'moderate', false);
end $$;

-- The Forever War
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Forever War', 'Joe Haldeman') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'dark', 'light', 'bittersweet', 'occasional', 'moderate', 'frequent', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'na', 'hard');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'first_contact');
  insert into book_tropes (book_id, trope_id) values (book_id, 'reluctant_hero');
  insert into book_tropes (book_id, trope_id) values (book_id, 'relativistic_time_dilation');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'mental_illness_depiction', 'moderate', false);
end $$;

-- The Lies of Locke Lamora
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Lies of Locke Lamora', 'Scott Lynch') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'third_limited', 'reliable', 'multi_timeline', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'balanced', 'grimdark', 'heavy', 'gut_punch', 'none', 'na', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'heist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_filled');
  insert into book_tropes (book_id, trope_id) values (book_id, 'major_character_death');
  insert into book_tropes (book_id, trope_id) values (book_id, 'court_intrigue');
  insert into book_tropes (book_id, trope_id) values (book_id, 'renaissance_or_mercantile_setting');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'moderate', false);
end $$;

-- The Fifth Season
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Fifth Season', 'N.K. Jemisin') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'mixed', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'none', 'gut_punch', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'requires_series', 'ambiguous', 'cliffhanger', 'hard', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_ending');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'major_character_death');
  insert into book_tropes (book_id, trope_id) values (book_id, 'sanderlanche');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_death', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'racism_depicted', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'slavery', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'domestic_abuse', 'moderate', false);
end $$;

-- We Are Legion (We Are Bob)
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('We Are Legion (We Are Bob)', 'Dennis E. Taylor') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'none', 'na', 'occasional', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ai_consciousness');
  insert into book_tropes (book_id, trope_id) values (book_id, 'mind_uploading_or_digital_immortality');
  insert into book_tropes (book_id, trope_id) values (book_id, 'first_contact');
  insert into book_tropes (book_id, trope_id) values (book_id, 'terraforming_or_space_colonization');
  insert into book_tropes (book_id, trope_id) values (book_id, 'self_replicating_consciousness');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'brief', false);
end $$;

-- The Time Machine
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Time Machine', 'H.G. Wells') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'first', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'none', 'na', 'occasional', 'mild', 'moderate', 'self_contained', 'ambiguous', 'cliffhanger', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'time_travel');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dying_earth');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dystopia');
  insert into book_tropes (book_id, trope_id) values (book_id, 'species_divergence');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'brief', false);
end $$;

-- Kings of Paradise
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Kings of Paradise', 'Richard Nell') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'light', 'gut_punch', 'occasional', 'moderate', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'underdog_rising');
  insert into book_tropes (book_id, trope_id) values (book_id, 'reluctant_hero');
  insert into book_tropes (book_id, trope_id) values (book_id, 'non_european_inspired_setting');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'bullying', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'ableism_depicted', 'moderate', false);
end $$;

-- Interview with the Vampire
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Interview with the Vampire', 'Anne Rice') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'first', 'reliable', 'multi_timeline', 'framing_device', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'bittersweet', 'rare', 'low', 'frequent', 'graphic', 'moderate', 'requires_series', 'tragic', 'cliffhanger', 'na', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'immortal_or_ageless_character');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'vampires');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_abuse', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'substance_abuse', 'brief', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'suicide', 'moderate', false);
end $$;

-- Neuromancer
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Neuromancer', 'William Gibson') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'ambiguous', 'resolved', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'cyberpunk');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ai_consciousness');
  insert into book_tropes (book_id, trope_id) values (book_id, 'cybernetic_enhancement');
  insert into book_tropes (book_id, trope_id) values (book_id, 'virtual_reality_or_simulated_world');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'substance_abuse', 'central_theme', false);
end $$;

-- The Eye of the World
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Eye of the World', 'Robert Jordan') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'rare', 'closed_door', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'chosen_one');
  insert into book_tropes (book_id, trope_id) values (book_id, 'prophecy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'epic_quest');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ancient_evil_awakens');
  insert into book_tropes (book_id, trope_id) values (book_id, 'wise_mentor');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'reluctant_hero');
  insert into book_tropes (book_id, trope_id) values (book_id, 'hidden_talent_prodigy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'medieval_european_setting');
end $$;

-- The Road
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Road', 'Cormac McCarthy') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'grimdark', 'none', 'gut_punch', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'bittersweet', 'resolved', 'na', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'post_apocalyptic');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_death', 'brief', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'suicide', 'brief', false);
end $$;

-- The Poppy War
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Poppy War', 'R.F. Kuang') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'light', 'gut_punch', 'rare', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'tragic', 'cliffhanger', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'magic_school');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dark_academia_setting');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'non_european_inspired_setting');
  insert into book_tropes (book_id, trope_id) values (book_id, 'underdog_rising');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'genocide', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'substance_abuse', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'self_harm', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'sexual_assault', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'bullying', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'colonization_themes', 'central_theme', false);
end $$;

-- Old Man's War
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Old Man''s War', 'John Scalzi') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'balanced', 'moderate', 'heavy', 'bittersweet', 'rare', 'low', 'frequent', 'graphic', 'moderate', 'self_contained', 'happy', 'resolved', 'na', 'hard');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'cybernetic_enhancement');
  insert into book_tropes (book_id, trope_id) values (book_id, 'terraforming_or_space_colonization');
  insert into book_tropes (book_id, trope_id) values (book_id, 'aging_reversal_or_rejuvenation');
  insert into book_tropes (book_id, trope_id) values (book_id, 'mutual_human_alien_war');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'brief', false);
end $$;

-- The Man in the High Castle
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Man in the High Castle', 'Philip K. Dick') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'third_limited', 'reliable', 'linear', 'framing_device', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'rare', 'closed_door', 'rare', 'moderate', 'dense', 'self_contained', 'ambiguous', 'resolved', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'parallel_universe_or_multiverse');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dystopia');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'racism_depicted', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'hate_speech_depicted', 'moderate', false);
end $$;

-- Circe
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Circe', 'Madeline Miller') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'none', 'bittersweet', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'immortal_or_ageless_character');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'mythological_retelling');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'sexual_assault', 'moderate', false);
end $$;

-- Leviathan Wakes
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Leviathan Wakes', 'James S.A. Corey') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'na', 'hard');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'found_family');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'noir_detective_structure');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'body_horror', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'brief', false);
end $$;

-- Prince of Thorns
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Prince of Thorns', 'Mark Lawrence') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'grimdark', 'light', 'gut_punch', 'none', 'na', 'frequent', 'brutal', 'moderate', 'requires_series', 'ambiguous', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'villain_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'cursed_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'major_character_death');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_abuse', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'sexual_assault', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_death', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'brief', false);
end $$;

-- A Wizard of Earthsea
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('A Wizard of Earthsea', 'Ursula K. Le Guin') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'moderate', 'none', 'bittersweet', 'none', 'na', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'hidden_talent_prodigy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'wise_mentor');
  insert into book_tropes (book_id, trope_id) values (book_id, 'epic_quest');
  insert into book_tropes (book_id, trope_id) values (book_id, 'shadow_self_confrontation');
end $$;

-- Dark Matter
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Dark Matter', 'Blake Crouch') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'moderate', 'none', 'tense', 'occasional', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'parallel_universe_or_multiverse');
  insert into book_tropes (book_id, trope_id) values (book_id, 'twist_filled');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'kidnapping_or_captivity', 'central_theme', false);
end $$;

-- The Gunslinger
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Gunslinger', 'Stephen King') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy,sci_fi}', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'ambiguous', 'resolved', 'soft', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dying_earth');
  insert into book_tropes (book_id, trope_id) values (book_id, 'post_apocalyptic');
  insert into book_tropes (book_id, trope_id) values (book_id, 'anti_hero');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'epic_quest');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'child_death', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'religious_trauma_or_cults', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'substance_abuse', 'brief', false);
end $$;

-- The Hitchhiker's Guide to the Galaxy
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{sci_fi}', 'multiple', 'third_omniscient', 'reliable', 'linear', 'framing_device', 'fast', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'none', 'na', 'rare', 'mild', 'moderate', 'requires_series', 'ambiguous', 'cliffhanger', 'na', 'soft');
  insert into book_tropes (book_id, trope_id) values (book_id, 'satirical_or_comedic_scifi');
end $$;

-- Malice
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('Malice', 'John Gwynne') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'tragic', 'cliffhanger', 'soft', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'chosen_one');
  insert into book_tropes (book_id, trope_id) values (book_id, 'prophecy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'epic_quest');
  insert into book_tropes (book_id, trope_id) values (book_id, 'dark_lord_or_evil_overlord');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ancient_evil_awakens');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'slavery', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'torture', 'brief', false);
end $$;

-- He Who Fights with Monsters
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('He Who Fights with Monsters', 'Shirtaloon') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'balanced', 'moderate', 'heavy', 'comfort_read', 'rare', 'low', 'frequent', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'hard', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'reincarnated_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'underdog_rising');
  insert into book_tropes (book_id, trope_id) values (book_id, 'anti_hero');
  insert into book_tropes (book_id, trope_id) values (book_id, 'litrpg_or_progression_fantasy');
end $$;

-- The Way of Kings
do $$
declare
  book_id uuid;
begin
  insert into books (title, author) values ('The Way of Kings', 'Brandon Sanderson') returning id into book_id;
  insert into book_dna (book_id, genre, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness) values (book_id, '{fantasy}', 'multiple', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'hard', 'na');
  insert into book_tropes (book_id, trope_id) values (book_id, 'sanderlanche');
  insert into book_tropes (book_id, trope_id) values (book_id, 'epic_quest');
  insert into book_tropes (book_id, trope_id) values (book_id, 'war_story');
  insert into book_tropes (book_id, trope_id) values (book_id, 'morally_grey_protagonist');
  insert into book_tropes (book_id, trope_id) values (book_id, 'redemption_arc');
  insert into book_tropes (book_id, trope_id) values (book_id, 'prophecy');
  insert into book_tropes (book_id, trope_id) values (book_id, 'court_intrigue');
  insert into book_tropes (book_id, trope_id) values (book_id, 'major_character_death');
  insert into book_tropes (book_id, trope_id) values (book_id, 'ancient_evil_awakens');
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'slavery', 'central_theme', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'suicide', 'brief', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'substance_abuse', 'moderate', false);
  insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (book_id, 'war_trauma', 'moderate', false);
end $$;

commit;
