-- Batch-tag 21 untagged Bookspell catalog books with full Book DNA,
-- resuming after the round-2 catalog expansion (299 new books, most
-- still untagged) and the schema updates from the other laptop's
-- session: narrator_reliability gained an 'ambiguous' value, and
-- magic_system_hardness/etc. are tagged per-book based on what THAT
-- book reveals to the reader, not omniscient series knowledge -- applied
-- here to Wheel of Time (soft in book 1, hard from The Great Hunt
-- onward, per the existing convention; every WoT book in this batch is
-- past that point, so all are magic_system_hardness: hard).
--
-- Completes THREE series in one batch:
-- - The Wheel of Time: 6/15 -> 15/15 (all 9 remaining books, incl. the
--   New Spring prequel)
-- - The Expanse: 8/9 -> 9/9 (Leviathan Falls, series finale)
-- - Throne of Glass: 5/8 -> 6/8 (Kingdom of Ash, series finale)
-- Also advances Discworld (5/14 -> 13/14, 8 books across the Watch,
-- Death, and Rincewind subseries), Murderbot (7/8 -> 8/8, complete), and
-- Hitchhiker's Guide (Mostly Harmless).
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'accessible', 'moderate', 'cosmic', 'life_threatening'
from books where title = 'Leviathan Falls'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Leviathan Falls' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Leviathan Falls' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Leviathan Falls' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'moderate'
from books where title = 'Home: Habitat, Range, Niche, Territory'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Home: Habitat, Range, Niche, Territory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'android_or_replicant_rights' from books where title = 'Home: Habitat, Range, Niche, Territory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Home: Habitat, Range, Niche, Territory' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'brief', false from books where title = 'Home: Habitat, Range, Niche, Territory' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'frequent', 'explicit', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening'
from books where title = 'Kingdom of Ash'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Kingdom of Ash' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Kingdom of Ash' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Kingdom of Ash' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'closed_door', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'New Spring'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'New Spring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'New Spring' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'New Spring' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Lord of Chaos'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Lord of Chaos' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Lord of Chaos' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Lord of Chaos' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high'
from books where title = 'The Path of Daggers'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Path of Daggers' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Path of Daggers' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'The Path of Daggers' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Winter''s Heart'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Winter''s Heart' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Winter''s Heart' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Winter''s Heart' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'rare', 'mild', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high'
from books where title = 'Crossroads of Twilight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Crossroads of Twilight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Crossroads of Twilight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Crossroads of Twilight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Crossroads of Twilight' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Crossroads of Twilight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Knife of Dreams'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'Knife of Dreams' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Knife of Dreams' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Knife of Dreams' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'The Gathering Storm'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Gathering Storm' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'The Gathering Storm' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Gathering Storm' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'tense', 'moderate', 'occasional', 'closed_door', 'frequent', 'graphic', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening'
from books where title = 'Towers of Midnight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'Towers of Midnight' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Towers of Midnight' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Towers of Midnight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'closed_door', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'cosmic', 'life_threatening'
from books where title = 'A Memory of Light'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'sanderlanche' from books where title = 'A Memory of Light' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'A Memory of Light' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'A Memory of Light' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'high'
from books where title = 'Going Postal'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Going Postal' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Going Postal' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Going Postal' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Going Postal' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Going Postal' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'moderate'
from books where title = 'Hogfather'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Hogfather' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Hogfather' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Hogfather' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Men at Arms'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Men at Arms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Men at Arms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Men at Arms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Men at Arms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'Men at Arms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Men at Arms' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'short', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'cosmic', 'life_threatening'
from books where title = 'Mostly Harmless'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Mostly Harmless' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Mostly Harmless' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Mostly Harmless' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_omniscient', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Night Watch'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Night Watch' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Night Watch' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Night Watch' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Night Watch' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Night Watch' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Night Watch' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Night Watch' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'moderate'
from books where title = 'Pyramids'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Pyramids' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Pyramids' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Pyramids' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Pyramids' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Pyramids' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'moderate', 'rare', 'low', 'occasional', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'moderate'
from books where title = 'Reaper Man'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Reaper Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Reaper Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Reaper Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Reaper Man' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'cerebral', 'regional', 'moderate'
from books where title = 'Small Gods'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Small Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Small Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Small Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Small Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Small Gods' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'Small Gods' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'global', 'high'
from books where title = 'Sourcery'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'Sourcery' on conflict do nothing;

