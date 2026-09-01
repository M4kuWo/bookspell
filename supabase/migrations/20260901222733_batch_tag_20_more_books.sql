-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA. Mostly
-- standalone/series-opener sci-fi and fantasy titles.
--
-- Skipped as out of scope (no fantasy/sci-fi elements): Deception Point,
-- Digital Fortress (both Dan Brown techno-thrillers, same reasoning as
-- The Da Vinci Code), and Earthlings (Murata) -- its 'alien' framing is
-- the protagonist's trauma-coping delusion, not an actual sci-fi premise.
-- Also skipped Cosmos (Sagan) -- nonfiction popular science, not a novel;
-- Book DNA's narrative fields don't conceptually apply. Plus the two
-- established omnibus duplicates and previously-flagged out-of-scope
-- titles (A Farewell to Arms, Aristotle and Dante, Around the World in
-- Eighty Days, Atlas Shrugged, Atmosphere, Beartown, Butcher & Blackbird,
-- If We Were Villains).
--
-- Genre judgment call flagged: Gravity's Rainbow tagged sci_fi with a
-- confidence flag (0.5) -- it's fundamentally postmodern literary fiction,
-- but its psychic-conditioning/reality-distortion content is genuinely
-- speculative enough to include, similar to the earlier Infinite Jest call.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'multi_timeline', 'framing_device', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Cloud Cuckoo Land'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'generation_ship' from books where title = 'Cloud Cuckoo Land' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'Cloud Cuckoo Land' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Cloud Cuckoo Land' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'worldbuilding_driven', 'light', 'light', 'tense', 'heavy_handed', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'moderate'
from books where title = 'Contact'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Contact' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Contact' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Daughter of the Moon Goddess'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'none', 'tense', 'heavy_handed', 'occasional', 'moderate', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Dawn '
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Dawn ' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Dawn ' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Dawn ' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'central_theme', false from books where title = 'Dawn ' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Dawn ' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'moderate'
from books where title = 'Dirk Gently''s Holistic Detective Agency'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Dirk Gently''s Holistic Detective Agency' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Dirk Gently''s Holistic Detective Agency' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Dirk Gently''s Holistic Detective Agency' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Dirk Gently''s Holistic Detective Agency' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'unreliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'character_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Empire of the Vampire'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Empire of the Vampire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Empire of the Vampire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Empire of the Vampire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Empire of the Vampire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Empire of the Vampire' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'Empire of the Vampire' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Empire of the Vampire' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Ender''s Shadow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Ender''s Shadow' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'Ender''s Shadow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Ender''s Shadow' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high'
from books where title = 'Every Heart a Doorway'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Every Heart a Doorway' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Every Heart a Doorway' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Every Heart a Doorway' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Every Heart a Doorway' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'unreliable', 'linear', 'framing_device', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'global', 'high'
from books where title = 'Fire & Blood'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Fire & Blood' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'incest', 'central_theme', false from books where title = 'Fire & Blood' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'Fire & Blood' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'Fool''s Errand'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'Fool''s Errand' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Fool''s Errand' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Fool''s Errand' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Fool''s Errand' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Fool''s Errand' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'Fool''s Errand' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'several', 'first', 'reliable', 'nonlinear', 'epistolary', 'medium', 'uneven', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'light', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'Frankenstein: The 1818 Text'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Frankenstein: The 1818 Text' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Frankenstein: The 1818 Text' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Frankenstein: The 1818 Text' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Furies of Calderon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Furies of Calderon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Furies of Calderon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Furies of Calderon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Furies of Calderon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high'
from books where title = 'Gallant'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Gallant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Gallant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Gallant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Gallant' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Graceling'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Graceling' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Graceling' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Graceling' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Graceling' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Graceling' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'unreliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'dark', 'heavy', 'gut_punch', 'heavy_handed', 'frequent', 'explicit', 'occasional', 'graphic', 'dense', 'self_contained', 'ambiguous', 'resolved', 'epic', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'moderate'
from books where title = 'Gravity''s Rainbow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Gravity''s Rainbow' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Gravity''s Rainbow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Gravity''s Rainbow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_sexual_abuse', 'moderate', true from books where title = 'Gravity''s Rainbow' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre', 0.5, 'ai_inferred' from books where title = 'Gravity''s Rainbow' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'long', 'dual', 'first', 'ambiguous', 'multi_timeline', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'bittersweet', 'subtle', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'soft', 'moderate', 'dense', 'cerebral', 'cosmic', 'high'
from books where title = 'Hard-Boiled Wonderland and the End of the World'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'cyberpunk' from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'high'
from books where title = 'Heir to the Empire'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Heir to the Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Heir to the Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Heir to the Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Heir to the Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Heir to the Empire' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'His Majesty''s Dragon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'His Majesty''s Dragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'His Majesty''s Dragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'His Majesty''s Dragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'His Majesty''s Dragon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'How High We Go in the Dark'
on conflict (book_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'How High We Go in the Dark' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'How High We Go in the Dark' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening'
from books where title = 'I Have No Mouth and I Must Scream'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_uprising_or_rebellion' from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;

