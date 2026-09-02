-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA.
--
-- Mostly Discworld: 17 novels spanning the Rincewind, Witches, Death, and
-- City Watch sub-series, prioritized because 14 other Discworld books were
-- already tagged (partial-series-first priority). Plus 3 Expanse novellas
-- (The Butcher of Anderson Station, Gods of Risk, Drive), same logic.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'moderate'
from books where title = 'Eric'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Eric' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Eric' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Eric' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Eric' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Eric' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'moderate'
from books where title = 'Moving Pictures'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Moving Pictures' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Moving Pictures' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Moving Pictures' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', 'rare', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'moderate'
from books where title = 'Witches Abroad'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Witches Abroad' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Witches Abroad' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Witches Abroad' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Witches Abroad' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'heavy', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Lords and Ladies'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Lords and Ladies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Lords and Ladies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Lords and Ladies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Lords and Ladies' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Lords and Ladies' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'heavy', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Soul Music'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Soul Music' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Soul Music' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Soul Music' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Soul Music' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'moderate'
from books where title = 'Interesting Times'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Interesting Times' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Interesting Times' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Interesting Times' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Interesting Times' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'Interesting Times' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'moderate'
from books where title = 'Maskerade'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Maskerade' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Maskerade' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Maskerade' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Maskerade' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Feet of Clay'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Feet of Clay' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Feet of Clay' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Feet of Clay' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Feet of Clay' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Jingo'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Jingo' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Jingo' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Jingo' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Jingo' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'moderate', false from books where title = 'Jingo' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Jingo' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'Carpe Jugulum'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Carpe Jugulum' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Carpe Jugulum' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Carpe Jugulum' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Carpe Jugulum' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Carpe Jugulum' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'The Fifth Elephant'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Fifth Elephant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Fifth Elephant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Fifth Elephant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'The Fifth Elephant' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'The Fifth Elephant' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'The Truth'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Truth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Truth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Truth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Truth' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'brief', false from books where title = 'The Truth' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high'
from books where title = 'Thief Of Time'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Thief Of Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Thief Of Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Thief Of Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Thief Of Time' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', 'rare', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high'
from books where title = 'The Wee Free Men'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'The Wee Free Men' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Wee Free Men' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Wee Free Men' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Wee Free Men' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Wee Free Men' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Wee Free Men' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'tense', 'heavy_handed', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Monstrous Regiment'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Monstrous Regiment' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Monstrous Regiment' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Monstrous Regiment' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Monstrous Regiment' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Monstrous Regiment' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Monstrous Regiment' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'moderate', 'tense', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'Thud!'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Thud!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Thud!' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Thud!' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Thud!' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'moderate'
from books where title = 'Making Money'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Making Money' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Making Money' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Making Money' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Making Money' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'The Butcher of Anderson Station'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'The Butcher of Anderson Station' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Butcher of Anderson Station' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'The Butcher of Anderson Station' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Butcher of Anderson Station' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Butcher of Anderson Station' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'The Butcher of Anderson Station' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'moderate', 'intimate', 'high'
from books where title = 'Gods of Risk'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Gods of Risk' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Gods of Risk' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'central_theme', false from books where title = 'Gods of Risk' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'Drive'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Drive' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Drive' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Drive' on conflict do nothing;

