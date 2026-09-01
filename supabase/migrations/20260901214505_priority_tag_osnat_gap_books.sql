-- Priority out-of-queue batch, ahead of the skill's usual partial-series
-- prioritization: tags the 7 books ingested in
-- 20260901213000ish (targeted ingestion, run against hosted this session)
-- plus 4 of the 5 already-in-catalog titles flagged in the 2026-09-01
-- project-log handoff note -- all from external rater Osnat's disliked-
-- books list, added specifically to fix a real negative-signal gap in the
-- scoring engine's held-out test (her tagged ratings are almost all
-- positive because her actual dislikes weren't in the catalog). 'Sweep of
-- the Heart' (the 5th handoff title) isn't in the catalog yet -- needs
-- ingesting separately before it can be tagged.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Magic Bites'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Magic Bites' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Magic Bites' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Magic Bites' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Magic Bites' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Magic Bites' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Magic Bites' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'moderate', 'tense', 'subtle', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Magic Burns'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Magic Burns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Magic Burns' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Magic Burns' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'short', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high'
from books where title = 'A Questionable Client'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'A Questionable Client' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'A Questionable Client' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'A Questionable Client' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Daughter of No Worlds'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_identity_romance' from books where title = 'Daughter of No Worlds' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Daughter of No Worlds' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Daughter of No Worlds' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'When the Moon Hatched'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'When the Moon Hatched' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'When the Moon Hatched' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'When the Moon Hatched' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'When the Moon Hatched' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'slow_burn_romance' from books where title = 'When the Moon Hatched' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'epistolary', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'closed_door', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Ruthless Vows'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Ruthless Vows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'slow_burn_romance' from books where title = 'Ruthless Vows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Ruthless Vows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Ruthless Vows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Ruthless Vows' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Ruthless Vows' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'moderate'
from books where title = 'The Assassin and the Healer'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Assassin and the Healer' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Assassin and the Healer' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'The Assassin and the Healer' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'epistolary', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'closed_door', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Divine Rivals'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Divine Rivals' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Divine Rivals' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'slow_burn_romance' from books where title = 'Divine Rivals' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Divine Rivals' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Divine Rivals' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'From Blood and Ash'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'From Blood and Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'From Blood and Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'From Blood and Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'From Blood and Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'From Blood and Ash' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fated_mates' from books where title = 'From Blood and Ash' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'From Blood and Ash' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'frequent', 'explicit', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'The Serpent and the Wings of Night'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Serpent and the Wings of Night' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'moderate', 'tense', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'cerebral', 'global', 'high'
from books where title = 'An Absolutely Remarkable Thing'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'An Absolutely Remarkable Thing' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'An Absolutely Remarkable Thing' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'An Absolutely Remarkable Thing' on conflict do nothing;

