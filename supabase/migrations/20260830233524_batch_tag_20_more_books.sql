-- Batch-tag 20 more untagged Bookspell catalog books with full Book DNA
-- (previous batches: 20260830221511 through 20260830231854). Almost
-- entirely standalone/series-opener sci-fi and fantasy titles -- the
-- backlog is now mostly individual books rather than partial series.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).
--
-- Skipped again: 'The Farseer Trilogy' omnibus (duplicate content). Also
-- skipped 'The Da Vinci Code' (Dan Brown) alongside the already-flagged
-- 'If We Were Villains' -- a conspiracy thriller with no fantasy or sci-fi
-- elements, doesn't honestly satisfy book_dna's genre constraint. Both are
-- catalog-scope questions for the owner, confirmed out of scope for now
-- rather than force-tagged.

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi', 'fantasy'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'subtle', 'frequent', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'na', 'soft', 'lush', 'moderate', 'moderate', 'intimate', 'life_threatening'
from books where title = 'Outlander'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Outlander' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Outlander' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'soulmate_bond' from books where title = 'Outlander' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'marriage_of_convenience' from books where title = 'Outlander' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Outlander' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', false from books where title = 'Outlander' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Outlander' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Outlander' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'life_threatening'
from books where title = 'Red Queen'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Red Queen' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Red Queen' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Red Queen' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Red Queen' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'Red Queen' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'Red Queen' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'worldbuilding_driven', 'light', 'light', 'tense', 'subtle', 'none', 'na', 'rare', 'mild', 'dense', 'requires_series', 'ambiguous', 'resolved', 'standard', 'na', 'hard', 'sparse', 'moderate', 'cerebral', 'cosmic', 'moderate'
from books where title = 'Rendezvous with Rama'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Rendezvous with Rama' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Rendezvous with Rama' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'generation_ship' from books where title = 'Rendezvous with Rama' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Scythe'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Scythe' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Scythe' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Scythe' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Scythe' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Scythe' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Seveneves'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Seveneves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'generation_ship' from books where title = 'Seveneves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Seveneves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'Seveneves' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Seveneves' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'lush', 'moderate', 'escapist', 'regional', 'high'
from books where title = 'Shatter Me'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Shatter Me' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Shatter Me' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Shatter Me' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Shatter Me' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Shatter Me' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Shatter Me' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Shatter Me' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Skyward'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Skyward' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Skyward' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Skyward' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Skyward' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Skyward' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Skyward' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'rare', 'low', 'rare', 'mild', 'dense', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'intimate', 'high'
from books where title = 'Solaris'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Solaris' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Solaris' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Solaris' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Stardust'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Stardust' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Stardust' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Stardust' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Stardust' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Stardust' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Stardust' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'hard', 'sparse', 'moderate', 'cerebral', 'global', 'life_threatening'
from books where title = 'Starship Troopers'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Starship Troopers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mutual_human_alien_war' from books where title = 'Starship Troopers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cybernetic_enhancement' from books where title = 'Starship Troopers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Starship Troopers' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Starship Troopers' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'moderate'
from books where title = 'Starter Villain'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Starter Villain' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Starter Villain' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Steelheart'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Steelheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Steelheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Steelheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Steelheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Steelheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Steelheart' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'Steelheart' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'mixed', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'hard', 'sparse', 'dense', 'cerebral', 'intimate', 'moderate'
from books where title = 'Stories of Your Life and Others'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Stories of Your Life and Others' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Stories of Your Life and Others' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Storm Front'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Storm Front' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Storm Front' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'moderate', 'bittersweet', 'heavy_handed', 'frequent', 'explicit', 'occasional', 'moderate', 'dense', 'self_contained', 'tragic', 'resolved', 'epic', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'high'
from books where title = 'Stranger in a Strange Land'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Stranger in a Strange Land' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'Stranger in a Strange Land' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Stranger in a Strange Land' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening'
from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'The 7 1/2 Deaths of Evelyn Hardcastle' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'The Atlas Six'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'The Atlas Six' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Atlas Six' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Atlas Six' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Atlas Six' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Atlas Six' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Atlas Six' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'The Black Prism'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The Black Prism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Black Prism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Black Prism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Black Prism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Black Prism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Black Prism' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'The Black Prism' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'The Black Prism' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'short', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high'
from books where title = 'The Emperor''s Soul'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'The Emperor''s Soul' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Emperor''s Soul' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high'
from books where title = 'The Graveyard Book'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Graveyard Book' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Graveyard Book' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Graveyard Book' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Graveyard Book' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Graveyard Book' on conflict do nothing;

