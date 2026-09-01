-- Batch-tag 20 untagged Bookspell catalog books with full Book DNA. Mostly
-- standalone/series-opener sci-fi and fantasy titles.
--
-- Skipped as out of scope (no fantasy/sci-fi elements, same reasoning as
-- prior flags): Aristotle and Dante Discover the Secrets of the Universe,
-- Around the World in Eighty Days, Atlas Shrugged, Atmosphere: A Love
-- Story, Beartown, Butcher & Blackbird. Also skipped The Farseer Trilogy
-- and Monk and Robot omnibi (established duplicates).
--
-- Judgment calls worth noting: 'Blindness' (Saramago) tagged in-scope as
-- sci_fi -- its mass-blindness epidemic is genuinely unexplained/
-- speculative (unlike Camus's The Plague, previously excluded, which
-- depicts a realistic, medically-explicable outbreak). 'A Short Stay in
-- Hell' has no tropes -- its infinite-library-afterlife premise genuinely
-- doesn't map onto any vocabulary trope, left honestly empty rather than
-- forced.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy', 'sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high'
from books where title = 'A Short Stay in Hell'
on conflict (book_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'A Short Stay in Hell' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'A Short Stay in Hell' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'middle_grade', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'low'
from books where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'An Ember in the Ashes'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'An Ember in the Ashes' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'An Ember in the Ashes' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'An Ember in the Ashes' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'high'
from books where title = 'Anathem'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Anathem' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Anathem' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Anathem' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy', 'sci_fi'], 'adult', 'long', 'ensemble', 'mixed', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'hard', 'soft', 'moderate', 'moderate', 'cerebral', 'cosmic', 'moderate'
from books where title = 'Arcanum Unbounded: The Cosmere Collection'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Arcanum Unbounded: The Cosmere Collection' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Arcanum Unbounded: The Cosmere Collection' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Arcanum Unbounded: The Cosmere Collection' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'low', 'frequent', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'life_threatening'
from books where title = 'Armada'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'Armada' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Armada' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Armada' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Armada' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'new_adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', 'occasional', 'mild', 'light', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'moderate'
from books where title = 'Assistant to the Villain'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Assistant to the Villain' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Assistant to the Villain' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Assistant to the Villain' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Assistant to the Villain' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'grimdark', 'moderate', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Best Served Cold'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Best Served Cold' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Best Served Cold' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Best Served Cold' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'anti_hero' from books where title = 'Best Served Cold' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Best Served Cold' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Best Served Cold' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Best Served Cold' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'long', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'frequent', 'brutal', 'dense', 'self_contained', 'tragic', 'resolved', 'long', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening'
from books where title = 'Between Two Fires'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Between Two Fires' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'Between Two Fires' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Between Two Fires' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening'
from books where title = 'Binti'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'Binti' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Binti' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Binti' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Binti' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'moderate', false from books where title = 'Binti' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high'
from books where title = 'Black Sun'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Black Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Black Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Black Sun' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Black Sun' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Black Sun' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Black Sun' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'worldbuilding_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening'
from books where title = 'Blindness'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Blindness' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Blindness' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Blindness' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', false from books where title = 'Blindness' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'central_theme', false from books where title = 'Blindness' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Blindness' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_omniscient', 'unreliable', 'linear', 'framing_device', 'medium', 'uneven', 'character_driven', 'dark', 'heavy', 'bittersweet', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'light', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'sparse', 'moderate', 'cerebral', 'intimate', 'moderate'
from books where title = 'Breakfast of Champions'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Breakfast of Champions' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'Breakfast of Champions' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Breakfast of Champions' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'frequent', 'explicit', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high'
from books where title = 'Bride'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Bride' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Bride' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'marriage_of_convenience' from books where title = 'Bride' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Bride' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Bride' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'unreliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high'
from books where title = 'Caraval'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Caraval' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Caraval' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Caraval' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Caraval' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'framing_device', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'tense', 'subtle', 'rare', 'closed_door', 'rare', 'moderate', 'light', 'self_contained', 'tragic', 'resolved', 'short', 'soft', 'na', 'moderate', 'dense', 'moderate', 'intimate', 'life_threatening'
from books where title = 'Carmilla'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Carmilla' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'Carmilla' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening'
from books where title = 'Chain-Gang All-Stars'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Chain-Gang All-Stars' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Chain-Gang All-Stars' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'central_theme', false from books where title = 'Chain-Gang All-Stars' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'Chain-Gang All-Stars' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Chain-Gang All-Stars' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'long', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'heavy_handed', 'occasional', 'low', 'frequent', 'graphic', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening'
from books where title = 'Children of Blood and Bone'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Children of Blood and Bone' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'central_theme', false from books where title = 'Children of Blood and Bone' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Children of Blood and Bone' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'regional', 'high'
from books where title = 'City of Stairs'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'City of Stairs' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'City of Stairs' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'City of Stairs' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'City of Stairs' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'City of Stairs' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'City of Stairs' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes)
select id, array['fantasy'], 'ya', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'low', 'frequent', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high'
from books where title = 'Clockwork Angel'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'steampunk' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Clockwork Angel' on conflict do nothing;

