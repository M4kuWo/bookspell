-- PRIORITY BATCH (tag-catalog-batch skill, Step 0): tag the 25 books the repo
-- owner (Mathias) named and rated from memory, ingested via
-- 20260903170000_targeted_ingestion_mathias_priority_list.sql. Prioritized ahead
-- of the normal partial-series query because it unlocks real, already-collected
-- enjoyment signal (data/ratings/mathias.json) immediately.
--
-- Also the first batch tagged since genre_accessibility was added
-- (20260903000000_add_genre_accessibility_field.sql) -- computed per the formula
-- in book-dna.md, adjusted for premise familiarity where warranted (e.g. Valor's
-- angel/demon cosmic war and The Wandering Inn's isekai/LitRPG premise both
-- adjusted down a tier from their raw craft-field score).
--
-- Includes the trilogy-closing books for 5 different partial series (Ash and
-- Sand, Licanius, Covenant of Steel, The Vagrant, Red Queen's War, Time Master),
-- moving all of them to full completion for Series DNA purposes.
--
-- Mandatory density self-check (Step 3): initial pass came out with trope
-- density 29% below the catalog average (CW density matched exactly). Went back
-- and added 17 genuine, individually-justified additional tropes across the
-- thinner books (not padding -- e.g. underdog_rising across the Covenant of
-- Steel and Lot Lands trilogies' shared outcast-rising arcs, immortal_or_ageless_
-- character for several books' ancient antagonists) before finishing. Final:
-- batch tropes/book 4.76 vs catalog 5.77 (0.83 ratio); CWs/book 1.72, exactly
-- matching the catalog average of 1.72.
--
-- The Initiate/The Outcast/The Master (Louise Cooper, Time Master trilogy, 1985-86)
-- are obscure enough that several fields carry a book_field_confidence flag
-- rather than a confident guess, per the skill's 'don't be confidently wrong'
-- policy -- basic tone/structure is well-attested but specific plot-mechanical
-- details (exact POV count, romance heat level, stakes framing) are not.
--
-- 'The Liar's Key' (Mark Lawrence) is stored with a Unicode right single quote
-- (U+2019), not an ASCII apostrophe -- matched exactly here, not mojibake.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'Kings of Ash'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Kings of Ash' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Kings of Ash' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Kings of Ash' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'Kings of Heaven'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Kings of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Kings of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Kings of Heaven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Kings of Heaven' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Kings of Heaven' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Kings of Heaven' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Kings of Heaven' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'life_threatening', 'moderate'
from books where title = 'Valor'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Valor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Valor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Valor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Valor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Valor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Valor' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Valor' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'moderate', 'tense', 'moderate', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Grey Bastards'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The Grey Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Grey Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Grey Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Grey Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Grey Bastards' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Grey Bastards' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Grey Bastards' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'grimdark', 'moderate', 'tense', 'moderate', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The True Bastards'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The True Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The True Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The True Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The True Bastards' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The True Bastards' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The True Bastards' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The True Bastards' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'The True Bastards' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'An Echo of Things to Come'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'An Echo of Things to Come' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'An Echo of Things to Come' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'An Echo of Things to Come' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'An Echo of Things to Come' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'An Echo of Things to Come' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'An Echo of Things to Come' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'An Echo of Things to Come' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'veteran_only'
from books where title = 'The Light of All That Falls'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'The Light of All That Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Light of All That Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Light of All That Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Light of All That Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Light of All That Falls' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Light of All That Falls' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Light of All That Falls' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Pariah'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Pariah' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Pariah' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Pariah' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Pariah' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Pariah' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Pariah' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'The Pariah' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Pariah' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Martyr'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Martyr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Martyr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Martyr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Martyr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Martyr' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Martyr' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Martyr' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Martyr' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'The Traitor'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Traitor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Traitor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Traitor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Traitor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Traitor' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Traitor' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Traitor' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'brutal', 'dense', 'requires_series', 'tragic', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'Aching God'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Aching God' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Aching God' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Aching God' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Aching God' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Aching God' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Aching God' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'none', 'na', 'occasional', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'sparse', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Vagrant'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Vagrant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Vagrant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Vagrant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Vagrant' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Vagrant' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Vagrant' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'sparse', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Malice'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Malice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Malice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Malice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Malice' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Malice' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Malice' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'The Justice of Kings'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Justice of Kings' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Justice of Kings' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Justice of Kings' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'escapist', 'intimate', 'moderate', 'accessible'
from books where title = 'I''m Afraid You''ve Got Dragons'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'I''m Afraid You''ve Got Dragons' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'I''m Afraid You''ve Got Dragons' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'I''m Afraid You''ve Got Dragons' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'I''m Afraid You''ve Got Dragons' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_frequency', 0.6, 'ai_inferred' from books where title = 'I''m Afraid You''ve Got Dragons' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'hard', 'na', 'lush', 'accessible', 'moderate', 'intimate', 'moderate', 'moderate'
from books where title = 'The Wandering Inn'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'isekai' from books where title = 'The Wandering Inn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'litrpg_or_progression_fantasy' from books where title = 'The Wandering Inn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Wandering Inn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Wandering Inn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Wandering Inn' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'The Wandering Inn' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'dark', 'heavy', 'tense', 'subtle', 'occasional', 'moderate', 'frequent', 'brutal', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Prince of Fools'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Prince of Fools' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Prince of Fools' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Prince of Fools' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Prince of Fools' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'anti_hero' from books where title = 'Prince of Fools' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Prince of Fools' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'heavy', 'tense', 'subtle', 'occasional', 'moderate', 'frequent', 'brutal', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Liar’s Key'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Liar’s Key' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Liar’s Key' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Liar’s Key' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Liar’s Key' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Liar’s Key' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Liar’s Key' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'bittersweet', 'subtle', 'occasional', 'moderate', 'frequent', 'brutal', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Wheel of Osheim'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Wheel of Osheim' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Wheel of Osheim' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Wheel of Osheim' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Wheel of Osheim' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Wheel of Osheim' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Wheel of Osheim' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'grimdark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Blackwing'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Blackwing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Blackwing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Blackwing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'Blackwing' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Blackwing' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Blackwing' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Blackwing' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'Firestarter'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Firestarter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Firestarter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Firestarter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Firestarter' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Firestarter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Firestarter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'Firestarter' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'high', 'moderate'
from books where title = 'The Initiate'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Initiate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Initiate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Initiate' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Initiate' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Initiate' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Initiate' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Initiate' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Initiate' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'high', 'moderate'
from books where title = 'The Outcast'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Outcast' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Outcast' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Outcast' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Outcast' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Outcast' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Outcast' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Outcast' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Outcast' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'high', 'moderate'
from books where title = 'The Master'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Master' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Master' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Master' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Master' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Master' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Master' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Master' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Master' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Master' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'moderate', 'light', 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'One Word Kill'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'One Word Kill' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'One Word Kill' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'One Word Kill' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'One Word Kill' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'central_theme', false from books where title = 'One Word Kill' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'One Word Kill' on conflict do nothing;

