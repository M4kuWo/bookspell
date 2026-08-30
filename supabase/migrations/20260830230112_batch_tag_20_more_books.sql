-- Batch-tag 20 more untagged Bookspell catalog books with full Book DNA,
-- continuing the partial-series-first priority (previous batches:
-- 20260830221511, 20260830223533, 20260830225358). Completes His Dark
-- Materials; advances Hainish Cycle, The Dark Tower, Hyperion Cantos, The
-- Broken Earth; tags 13 standalone/series-opener sci-fi and fantasy books.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).
--
-- Skipped again: 'The Farseer Trilogy' omnibus -- pure duplicate content of
-- the 3 individually-tagged Farseer books (all 3 now tagged as of this batch).
--
-- See book_field_confidence rows below for fields flagged as genuinely
-- uncertain (Cloud Atlas's unusual nested multi-form structure).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high'
from books where title = 'The Subtle Knife'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Subtle Knife' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Subtle Knife' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Subtle Knife' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Subtle Knife' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'The Subtle Knife' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Subtle Knife' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Subtle Knife' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'moderate'
from books where title = 'The Dispossessed'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Dispossessed' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'The Dispossessed' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'The Dispossessed' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy', 'sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'soft', 'moderate', 'moderate', 'moderate', 'cosmic', 'life_threatening'
from books where title = 'The Drawing of the Three'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Drawing of the Three' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Drawing of the Three' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Drawing of the Three' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Drawing of the Three' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'The Drawing of the Three' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'central_theme', false from books where title = 'The Drawing of the Three' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Drawing of the Three' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'mixed', 'reliable', 'nonlinear', 'framing_device', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'hard', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'The Fall of Hyperion'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_uprising_or_rebellion' from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Fall of Hyperion' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Fall of Hyperion' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'The Fall of Hyperion' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'The Fall of Hyperion' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'mixed', 'unreliable', 'multi_timeline', 'standard_prose', 'medium', 'uneven', 'character_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening'
from books where title = 'The Obelisk Gate'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Obelisk Gate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Obelisk Gate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Obelisk Gate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Obelisk Gate' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Obelisk Gate' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'The Obelisk Gate' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'The Obelisk Gate' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'mixed', 'unreliable', 'multi_timeline', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening'
from books where title = 'The Stone Sky'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Stone Sky' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'The Stone Sky' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'The Stone Sky' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'subtle', 'occasional', 'explicit', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'intimate', 'high'
from books where title = '1Q84'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = '1Q84' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'soulmate_bond' from books where title = '1Q84' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = '1Q84' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', false from books where title = '1Q84' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = '1Q84' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_sexual_abuse', 'moderate', false from books where title = '1Q84' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = '1Q84' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'none', 'tense', 'moderate', 'none', 'na', 'rare', 'moderate', 'dense', 'requires_series', 'ambiguous', 'resolved', 'short', 'na', 'hard', 'sparse', 'moderate', 'cerebral', 'cosmic', 'moderate'
from books where title = '2001: A Space Odyssey'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = '2001: A Space Odyssey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_uprising_or_rebellion' from books where title = '2001: A Space Odyssey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = '2001: A Space Odyssey' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening'
from books where title = 'A Deadly Education'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'A Deadly Education' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'A Deadly Education' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'A Deadly Education' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'A Deadly Education' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Deadly Education' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Deadly Education' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'dual', 'mixed', 'reliable', 'linear', 'standard_prose', 'slow', 'front_loaded', 'character_driven', 'moderate', 'light', 'comfort_read', 'subtle', 'frequent', 'moderate', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'A Discovery of Witches'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'A Discovery of Witches' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'A Discovery of Witches' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'soulmate_bond' from books where title = 'A Discovery of Witches' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Discovery of Witches' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'A Discovery of Witches' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'age_gap_romance' from books where title = 'A Discovery of Witches' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'A Memory Called Empire'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Memory Called Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'A Memory Called Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'A Memory Called Empire' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'A Memory Called Empire' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'light', 'light', 'comfort_read', 'moderate', 'none', 'na', 'none', 'na', 'moderate', 'requires_series', 'happy', 'resolved', 'short', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'low'
from books where title = 'A Psalm for the Wild-Built'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'A Psalm for the Wild-Built' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Psalm for the Wild-Built' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'light', 'tense', 'moderate', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Altered Carbon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'cyberpunk' from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mind_uploading_or_digital_immortality' from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Altered Carbon' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Altered Carbon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Altered Carbon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'high'
from books where title = 'Ancillary Justice'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Ancillary Justice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Ancillary Justice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Ancillary Justice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Ancillary Justice' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'short', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'short', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'moderate'
from books where title = 'Artemis Fowl'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Artemis Fowl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'villain_protagonist' from books where title = 'Artemis Fowl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Artemis Fowl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Artemis Fowl' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'none', 'tense', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'ambiguous', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening'
from books where title = 'Blindsight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Blindsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Blindsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Blindsight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Blindsight' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Blindsight' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Blindsight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'Blood Over Bright Haven'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Blood Over Bright Haven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Blood Over Bright Haven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Blood Over Bright Haven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Blood Over Bright Haven' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Blood Over Bright Haven' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'Blood Over Bright Haven' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'cosmic', 'moderate'
from books where title = 'Childhood''s End'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Childhood''s End' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'Childhood''s End' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Childhood''s End' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'high'
from books where title = 'Cinder'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Cinder' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Cinder' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Cinder' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_identity_romance' from books where title = 'Cinder' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Cinder' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Cinder' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'mixed', 'unreliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'balanced', 'dark', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'high'
from books where title = 'Cloud Atlas'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'reincarnated_protagonist' from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Cloud Atlas' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Cloud Atlas' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'form', 0.5, 'ai_inferred' from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Cloud Atlas' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Cloud Atlas' on conflict do nothing;

