-- Batch-tag 20 more untagged Bookspell catalog books with full Book DNA,
-- continuing the partial-series-first priority (previous batches:
-- 20260830221511, 20260830223533). Advances Throne of Glass, Twilight,
-- Discworld, Divergent, First Law, Farseer Trilogy, Foundation, The Witcher,
-- Wheel of Time, Ready Player One, Ender's Saga, His Dark Materials.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).
--
-- Includes two omnibus editions tagged deliberately (unlike the skipped
-- Farseer Trilogy omnibus, which is pure redundant duplicate content of 3
-- already-tagged individual books): 'The Ultimate Hitchhiker's Guide' is
-- the only catalog entry containing Mostly Harmless content, and 'The
-- Complete Chronicles of Narnia' is the only entry for 6 of the 7 Narnia
-- books -- both carry real, otherwise-uncataloged signal. Tagged as
-- aggregate representations of their full contents, with lower-confidence
-- flags on tone fields that vary across the individual entries.
--
-- See book_field_confidence rows below for fields flagged as genuinely
-- uncertain.

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'bittersweet', 'moderate', 'occasional', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'cosmic', 'moderate'
from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'darkness', 0.5, 'ai_inferred' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_register', 0.5, 'ai_inferred' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'The Ultimate Hitchhiker''s Guide: Five Complete Novels and One Story' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Heir of Fire'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Heir of Fire' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'self_harm', 'moderate', false from books where title = 'Heir of Fire' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Heir of Fire' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'front_loaded', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'closed_door', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high'
from books where title = 'New Moon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'New Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'soulmate_bond' from books where title = 'New Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'New Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'New Moon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'New Moon' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'self_harm', 'moderate', false from books where title = 'New Moon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'New Moon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Queen of Shadows'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Queen of Shadows' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Queen of Shadows' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Queen of Shadows' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'moderate'
from books where title = 'Guards! Guards!'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Guards! Guards!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Guards! Guards!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Guards! Guards!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Guards! Guards!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Guards! Guards!' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'frequent', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Insurgent'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Insurgent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Insurgent' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Insurgent' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Insurgent' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Insurgent' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'moderate', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Last Argument of Kings'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Last Argument of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Last Argument of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Last Argument of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'berserker_rage' from books where title = 'Last Argument of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'anti_hero' from books where title = 'Last Argument of Kings' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Last Argument of Kings' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Last Argument of Kings' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'occasional', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'moderate'
from books where title = 'Mort'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Mort' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Mort' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Mort' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Mort' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'framing_device', 'slow', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'tragic', 'cliffhanger', 'epic', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Royal Assassin'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'Royal Assassin' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Royal Assassin' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Royal Assassin' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Royal Assassin' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Royal Assassin' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Royal Assassin' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Royal Assassin' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'sparse', 'moderate', 'cerebral', 'global', 'moderate'
from books where title = 'Second Foundation'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Second Foundation' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Second Foundation' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Second Foundation' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Second Foundation' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high'
from books where title = 'Sword of Destiny'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Sword of Destiny' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Sword of Destiny' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'Sword of Destiny' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Sword of Destiny' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Sword of Destiny' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high'
from books where title = 'The Dragon Reborn'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Dragon Reborn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Dragon Reborn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Dragon Reborn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Dragon Reborn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Dragon Reborn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Dragon Reborn' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Dragon Reborn' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'balanced', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'closed_door', 'frequent', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'The Fires of Heaven'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Fires of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Fires of Heaven' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Fires of Heaven' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high'
from books where title = 'The Great Hunt'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Great Hunt' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Great Hunt' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'cosmic', 'moderate'
from books where title = 'The Light Fantastic'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Light Fantastic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Light Fantastic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Light Fantastic' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'frequent', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high'
from books where title = 'The Shadow Rising'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Shadow Rising' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Shadow Rising' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Shadow Rising' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'long', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'high'
from books where title = 'Ready Player Two'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Ready Player Two' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Ready Player Two' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Ready Player Two' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'Ready Player Two' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'rare', 'low', 'rare', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'high'
from books where title = 'Speaker for the Dead'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Speaker for the Dead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Speaker for the Dead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Speaker for the Dead' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'Speaker for the Dead' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'Speaker for the Dead' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'bittersweet', 'heavy_handed', 'rare', 'closed_door', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high'
from books where title = 'The Amber Spyglass'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Amber Spyglass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Amber Spyglass' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Amber Spyglass' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'epic', 'ensemble', 'third_omniscient', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'light', 'comfort_read', 'heavy_handed', 'none', 'na', 'occasional', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'cosmic', 'high'
from books where title = 'The Complete Chronicles of Narnia'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'darkness', 0.5, 'ai_inferred' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'message_intensity', 0.5, 'ai_inferred' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;

