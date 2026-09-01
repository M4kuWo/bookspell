-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA. Mostly
-- standalone/series-opener sci-fi and fantasy titles.
--
-- Skipped as out of scope (no fantasy/sci-fi elements, same reasoning as
-- prior flags): Shogun (Clavell) -- realistic historical fiction, no
-- speculative content. Also skipped the two established omnibus
-- duplicates and previously-flagged out-of-scope titles.
--
-- Ringworld and Shards of Earth both use the multiple_alien_species
-- trope added 2026-08-31 -- genuine fits (Kzin/Puppeteer crew;
-- multiple established alien civilizations respectively).
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'standard', 'soft', 'na', 'lush', 'dense', 'cerebral', 'intimate', 'high'
from books where title = 'Perfume'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'villain_protagonist' from books where title = 'Perfume' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Perfume' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Perfume' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Perfume' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'unreliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Pines'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Pines' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Pines' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Pines' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Pines' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening'
from books where title = 'Powerless'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_identity_romance' from books where title = 'Powerless' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Powerless' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Powerless' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Powerless' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'Powerless' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Promise of Blood'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Promise of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Promise of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Promise of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Promise of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'renaissance_or_mercantile_setting' from books where title = 'Promise of Blood' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Promise of Blood' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'occasional', 'graphic', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'life_threatening'
from books where title = 'Quicksilver'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Quicksilver' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Quicksilver' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Quicksilver' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Quicksilver' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Quicksilver' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'global', 'high'
from books where title = 'Red Mars'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'Red Mars' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Red Mars' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Red Mars' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Red Mars' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Red Sister'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'Red Sister' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Red Sister' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Red Sister' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'Red Sister' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Red Sister' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Red Sister' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Red Sister' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'framing_device', 'fast', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'high'
from books where title = 'Redshirts'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Redshirts' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Redshirts' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'worldbuilding_driven', 'dark', 'none', 'tense', 'subtle', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Revelation Space'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Revelation Space' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Revelation Space' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Revelation Space' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Revelation Space' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Revelation Space' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Revelation Space' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'light', 'tense', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Ring Shout'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Ring Shout' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Ring Shout' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'central_theme', false from books where title = 'Ring Shout' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'central_theme', false from books where title = 'Ring Shout' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Ring Shout' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'light', 'light', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'high'
from books where title = 'Ringworld'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Ringworld' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Ringworld' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Ringworld' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Rivers of London'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Rivers of London' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Rivers of London' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Rivers of London' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'bittersweet', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Roadside Picnic'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Roadside Picnic' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Roadside Picnic' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Sabriel'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Sabriel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Sabriel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Sabriel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Sabriel' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'short', 'several', 'mixed', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'short', 'soft', 'soft', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Saga, Vol. 1'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Saga, Vol. 1' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Saga, Vol. 1' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Saga, Vol. 1' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Saga, Vol. 1' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Saga, Vol. 1' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Saga, Vol. 1' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Saga, Vol. 1' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'soft', 'moderate', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'Senlin Ascends'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'new_weird_setting' from books where title = 'Senlin Ascends' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Senlin Ascends' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'steampunk' from books where title = 'Senlin Ascends' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Senlin Ascends' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'trafficking', 'moderate', false from books where title = 'Senlin Ascends' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'bittersweet', 'heavy_handed', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Severance'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Severance' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Severance' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Severance' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Shards of Earth'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Shards of Earth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Shards of Earth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Shards of Earth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Shards of Earth' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Shards of Earth' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Shards of Earth' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'life_threatening'
from books where title = 'She Who Became the Sun'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'She Who Became the Sun' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'She Who Became the Sun' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'She Who Became the Sun' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'Ship of Magic'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'renaissance_or_mercantile_setting' from books where title = 'Ship of Magic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Ship of Magic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Ship of Magic' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'Ship of Magic' on conflict do nothing;

