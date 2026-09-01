-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA.
-- Completes:
-- - The Heroes of Olympus: 2/5 -> 5/5 (The House Of Hades, The Mark of
--   Athena, The Son of Neptune)
-- - The Maze Runner: 2/3 -> 3/3 (The Scorch Trials)
-- - Old Man's War: 1/2 -> 2/2 (The Ghost Brigades)
-- - Jurassic Park: 1/2 -> 2/2 (The Lost World)
-- - The Culture: 1/2 -> 2/2 (The Player of Games)
-- - The Folk of the Air: 1/3 -> 3/3 (The Wicked King, The Queen of Nothing)
-- - Hierarchy: 1/2 -> 2/2 (The Strength of the Few)
-- - Earthsea Cycle: 1/2 -> 2/2 (The Tombs of Atuan)
-- - Arc of a Scythe: 1/2 -> 2/2 (Thunderhead)
-- Advances The Poppy War and Secret Projects, plus 8 standalone/series-
-- opener titles.
--
-- Skipped: The Farseer Trilogy omnibus, 'Monk and Robot' omnibus (both
-- established duplicates), and 'A Farewell to Arms' (Hemingway) -- no
-- fantasy or sci-fi elements, same reasoning as the other out-of-scope
-- books flagged in earlier batches.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'standard', 'single', 'first', 'unreliable', 'linear', 'embedded_system_text', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'high'
from books where title = 'The Frugal Wizard''s Handbook for Surviving Medieval England'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Frugal Wizard''s Handbook for Surviving Medieval England' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'The Frugal Wizard''s Handbook for Surviving Medieval England' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'The Frugal Wizard''s Handbook for Surviving Medieval England' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Frugal Wizard''s Handbook for Surviving Medieval England' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'na', 'frequent', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'life_threatening'
from books where title = 'The House Of Hades'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The House Of Hades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The House Of Hades' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The House Of Hades' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high'
from books where title = 'The Mark of Athena'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Mark of Athena' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Mark of Athena' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Mark of Athena' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Mark of Athena' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Mark of Athena' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Mark of Athena' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high'
from books where title = 'The Son of Neptune'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Son of Neptune' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'The Scorch Trials'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Scorch Trials' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Scorch Trials' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Scorch Trials' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Scorch Trials' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Scorch Trials' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Scorch Trials' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Scorch Trials' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'life_threatening'
from books where title = 'The Dragon Republic'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Dragon Republic' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'The Dragon Republic' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'The Dragon Republic' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'The Ghost Brigades'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mutual_human_alien_war' from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Ghost Brigades' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', 'frequent', 'graphic', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'The Lost World'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'The Lost World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The Lost World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'The Lost World' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'moderate', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'regional', 'high'
from books where title = 'The Player of Games'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'The Player of Games' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'The Player of Games' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Player of Games' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Player of Games' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'The Player of Games' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'The Queen of Nothing'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'fae_courts' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Queen of Nothing' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'The Strength of the Few'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The Strength of the Few' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Strength of the Few' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high'
from books where title = 'The Tombs of Atuan'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Tombs of Atuan' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'The Tombs of Atuan' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'The Tombs of Atuan' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Tombs of Atuan' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Tombs of Atuan' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Tombs of Atuan' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'The Wicked King'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'fae_courts' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Wicked King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Wicked King' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Thunderhead'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Thunderhead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Thunderhead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Thunderhead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Thunderhead' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Thunderhead' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'bittersweet', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'moderate'
from books where title = 'A Canticle for Leibowitz'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'A Canticle for Leibowitz' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'A Canticle for Leibowitz' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'A Canticle for Leibowitz' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'A Fire Upon the Deep'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'A Fire Upon the Deep' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_uprising_or_rebellion' from books where title = 'A Fire Upon the Deep' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'A Fire Upon the Deep' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'A Fire Upon the Deep' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'A Fire Upon the Deep' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'A Fire Upon the Deep' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'A Knight of the Seven Kingdoms'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Knight of the Seven Kingdoms' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'grimdark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'A Little Hatred'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Little Hatred' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'A Little Hatred' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'A Little Hatred' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'anti_hero' from books where title = 'A Little Hatred' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'A Little Hatred' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'A Little Hatred' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'A Little Hatred' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'A Master of Djinn'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'steampunk' from books where title = 'A Master of Djinn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'A Master of Djinn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'A Master of Djinn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Master of Djinn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Master of Djinn' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'A Master of Djinn' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'A Master of Djinn' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'unreliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'grimdark', 'moderate', 'gut_punch', 'heavy_handed', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'A Scanner Darkly'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'A Scanner Darkly' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'A Scanner Darkly' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'central_theme', false from books where title = 'A Scanner Darkly' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'A Scanner Darkly' on conflict do nothing;

