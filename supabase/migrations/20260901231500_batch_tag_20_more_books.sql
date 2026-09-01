-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA.
--
-- Includes 'The Invisible Man' (H.G. Wells, 1897) -- a genuine sci-fi
-- classic, distinct from Ralph Ellison's 'Invisible Man' (already flagged
-- out of scope as realistic literary fiction in a prior batch).
--
-- Borderline genre calls included with a book_field_confidence flag:
-- The Glass Hotel (Emily St. John Mandel) -- subtle, ambiguous ghost
-- element; genre confidence flagged at 0.5.
--
-- Skipped as out of scope (no fantasy/sci-fi elements): The Glass Castle
-- (Jeannette Walls, memoir) and The Godfather (Mario Puzo, realistic crime
-- fiction). Also skipped the established omnibus duplicates and all
-- previously-flagged out-of-scope titles reappearing in this pull.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'dual', 'mixed', 'reliable', 'nonlinear', 'framing_device', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'The Empress of Salt and Fortune'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high'
from books where title = 'The Familiar'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Familiar' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Familiar' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'renaissance_or_mercantile_setting' from books where title = 'The Familiar' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Familiar' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'The Familiar' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high'
from books where title = 'The First Fifteen Lives of Harry August'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'The First Fifteen Lives of Harry August' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reincarnated_protagonist' from books where title = 'The First Fifteen Lives of Harry August' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The First Fifteen Lives of Harry August' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening'
from books where title = 'The Girl with All the Gifts'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Girl with All the Gifts' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'The Girl with All the Gifts' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Girl with All the Gifts' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Girl with All the Gifts' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Girl with All the Gifts' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Girl with All the Gifts' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'light', 'self_contained', 'ambiguous', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'moderate'
from books where title = 'The Glass Hotel'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'The Glass Hotel' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'The Glass Hotel' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre', 0.5, 'ai_inferred' from books where title = 'The Glass Hotel' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'comfort_read', 'moderate', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'The Goblin Emperor'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Goblin Emperor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Goblin Emperor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Goblin Emperor' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Goblin Emperor' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'global', 'high'
from books where title = 'The Grace of Kings'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Grace of Kings' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Grace of Kings' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'tragic', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'The Green Mile'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Green Mile' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'central_theme', false from books where title = 'The Green Mile' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'The Green Mile' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_sexual_abuse', 'moderate', false from books where title = 'The Green Mile' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'epic', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'high'
from books where title = 'The Host'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'The Host' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Host' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'The Host' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Host' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'unreliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'explicit', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'The Hundred Thousand Kingdoms'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'intimate', 'high'
from books where title = 'The Invisible Man'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'villain_protagonist' from books where title = 'The Invisible Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'The Invisible Man' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Invisible Man' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'The Knife of Never Letting Go'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'moderate', false from books where title = 'The Knife of Never Letting Go' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'moderate'
from books where title = 'The Lathe of Heaven'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Lathe of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'The Lathe of Heaven' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'grimdark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'The Library at Mount Char'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Library at Mount Char' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Library at Mount Char' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'frequent', 'brutal', 'light', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'The Long Walk'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Long Walk' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Long Walk' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Long Walk' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Long Walk' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'rare', 'graphic', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high'
from books where title = 'The Lovely Bones'
on conflict (book_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', false from books where title = 'The Lovely Bones' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'The Lovely Bones' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_sexual_abuse', 'central_theme', false from books where title = 'The Lovely Bones' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'occasional', 'explicit', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'The Magicians'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Magicians' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Magicians' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'The Magicians' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Magicians' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'The Magicians' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Magicians' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'unreliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'heavy', 'bittersweet', 'heavy_handed', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'cosmic', 'high'
from books where title = 'The Master and Margarita'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Master and Margarita' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Master and Margarita' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Master and Margarita' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Master and Margarita' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'dark', 'none', 'bittersweet', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'The Memory Police'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Memory Police' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Memory Police' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening'
from books where title = 'The Mercy of Gods'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'The Mercy of Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'The Mercy of Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Mercy of Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Mercy of Gods' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Mercy of Gods' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Mercy of Gods' on conflict do nothing;

