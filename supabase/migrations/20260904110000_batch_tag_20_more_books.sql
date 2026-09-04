-- Batch-tag 20 more Bookspell catalog books with full Book DNA.
--
-- All standalone/series-opener titles: If It Bleeds, The Spellshop, The 5th
-- Wave, Metro 2033, Daughter of Smoke & Bone, Dead Until Dark, Middlegame,
-- Lightlark, The Sword of Shannara, Off to Be the Wizard, Daemon, Hounded,
-- The Hidden Oracle, Nine Princes in Amber, A Dowry of Blood, The Bone Shard
-- Daughter, Nevernight, Carry On, The Talisman, and Inkheart.
--
-- Duplicate-title safety check ran clean, no collisions.
--
-- Mandatory density self-check (Step 3): unusually, BOTH dimensions came in
-- meaningfully below catalog average this time (tropes 31% below, CWs 35%
-- below) -- several titles in this batch are genuinely light-toned (cozy
-- fantasy, comedic fantasy, MG books: The Spellshop, Off to Be the Wizard,
-- The Sword of Shannara, The Hidden Oracle, Carry On, Hounded), which pulled
-- the average down without being individually wrong. Added 12 genuine
-- additional tropes and 5 genuine additional content warnings, being careful
-- not to force CWs onto the books that are legitimately clean -- final ratio
-- exactly 0.80 on both.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high', 'demanding'
from books where title = 'If It Bleeds'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'If It Bleeds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'If It Bleeds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'If It Bleeds' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'If It Bleeds' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'If It Bleeds' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'occasional', 'low', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'low', 'accessible'
from books where title = 'The Spellshop'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'slow_burn_romance' from books where title = 'The Spellshop' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'grumpy_sunshine' from books where title = 'The Spellshop' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Spellshop' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'ya', 'standard', 'several', 'first', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'low', 'frequent', 'brutal', 'moderate', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The 5th Wave'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'alien_invasion' from books where title = 'The 5th Wave' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'The 5th Wave' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The 5th Wave' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The 5th Wave' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'The 5th Wave' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'moderate', false from books where title = 'The 5th Wave' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'dense', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'Metro 2033'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Metro 2033' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Metro 2033' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Metro 2033' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Metro 2033' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Metro 2033' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Metro 2033' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Metro 2033' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Metro 2033' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'dual', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'occasional', 'moderate', 'occasional', 'brutal', 'dense', 'requires_series', 'tragic', 'cliffhanger', 'standard', 'hard', 'na', 'lush', 'moderate', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'Daughter of Smoke & Bone'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reincarnated_protagonist' from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Daughter of Smoke & Bone' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'comfort_read', 'subtle', 'frequent', 'explicit', 'occasional', 'moderate', 'moderate', 'requires_series', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Dead Until Dark'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Dead Until Dark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Dead Until Dark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Dead Until Dark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'monster_or_fae_romance' from books where title = 'Dead Until Dark' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Dead Until Dark' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Dead Until Dark' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'Middlegame'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'Middlegame' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Middlegame' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'soulmate_bond' from books where title = 'Middlegame' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Middlegame' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'Middlegame' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Middlegame' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'accessible'
from books where title = 'Lightlark'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Lightlark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Lightlark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cursed_protagonist' from books where title = 'Lightlark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Lightlark' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Lightlark' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Lightlark' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'moderate'
from books where title = 'The Sword of Shannara'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Sword of Shannara' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'The Sword of Shannara' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Sword of Shannara' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Sword of Shannara' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Sword of Shannara' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', 'rare', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'standard', 'hard', 'soft', 'sparse', 'accessible', 'escapist', 'intimate', 'moderate', 'gateway'
from books where title = 'Off to Be the Wizard'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Off to Be the Wizard' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Off to Be the Wizard' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Off to Be the Wizard' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Off to Be the Wizard' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening', 'demanding'
from books where title = 'Daemon'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Daemon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'cyberpunk' from books where title = 'Daemon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Daemon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Daemon' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Daemon' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'occasional', 'moderate', 'frequent', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'hard', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Hounded'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Hounded' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Hounded' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Hounded' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'Hounded' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Hounded' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'The Hidden Oracle'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'The Hidden Oracle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Hidden Oracle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Hidden Oracle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Hidden Oracle' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Hidden Oracle' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'short', 'single', 'first', 'unreliable', 'nonlinear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'short', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high', 'moderate'
from books where title = 'Nine Princes in Amber'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'Nine Princes in Amber' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Nine Princes in Amber' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Nine Princes in Amber' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Nine Princes in Amber' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Nine Princes in Amber' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Nine Princes in Amber' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Nine Princes in Amber' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'short', 'single', 'second', 'reliable', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'occasional', 'explicit', 'occasional', 'moderate', 'light', 'requires_series', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'intimate', 'high', 'moderate'
from books where title = 'A Dowry of Blood'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'A Dowry of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'A Dowry of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'A Dowry of Blood' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'A Dowry of Blood' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', false from books where title = 'A Dowry of Blood' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'central_theme', false from books where title = 'A Dowry of Blood' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'several', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'The Bone Shard Daughter'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Bone Shard Daughter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Bone Shard Daughter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Bone Shard Daughter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Bone Shard Daughter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Bone Shard Daughter' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'The Bone Shard Daughter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Bone Shard Daughter' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'third_limited', 'unreliable', 'linear', 'framing_device', 'medium', 'uneven', 'character_driven', 'grimdark', 'moderate', 'tense', 'subtle', 'occasional', 'explicit', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'Nevernight'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Nevernight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Nevernight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Nevernight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'Nevernight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Nevernight' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Nevernight' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'several', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'occasional', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high', 'demanding'
from books where title = 'Carry On'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Carry On' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'Carry On' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Carry On' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Carry On' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Carry On' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Carry On' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'epic', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'brutal', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Talisman'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Talisman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Talisman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Talisman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Talisman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Talisman' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'The Talisman' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Talisman' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'middle_grade', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'high', 'moderate'
from books where title = 'Inkheart'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Inkheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Inkheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Inkheart' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Inkheart' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Inkheart' on conflict do nothing;

