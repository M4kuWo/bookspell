-- Batch-tag 20 more Bookspell catalog books with full Book DNA.
--
-- All standalone titles: How to Sell a Haunted House, How to Stop Time,
-- Lincoln in the Bardo, My Best Friend's Exorcism, Needful Things, Nothing
-- to See Here, Prey, Slewfoot, Some Desperate Glory, Starling House, Swan
-- Song, The Book Eaters, The Book of Doors, The Buffalo Hunter Hunter, The
-- Cartographers, The Everlasting, The Fisherman, The Gods Themselves, The
-- Gone World, and The Humans.
--
-- Judgment calls of note: Nothing to See Here included under the
-- magical-realism precedent (unexplained combustion, never explained or
-- treated as literal fantasy magic, same bar Lincoln in the Bardo's afterlife
-- narration and The Cartographers' magic map clear). The Everlasting was
-- marked drive='romance_driven' (lower confidence, flagged) -- unlike
-- Alchemised two batches ago, this one's own marketing and reviews foreground
-- the Owen/Una romance as the emotional core rather than a love story
-- embedded in a larger non-romance plot, so it reads differently under the
-- same judgment test. Swan Song tagged genre=[fantasy, sci_fi] -- post-nuclear
-- apocalypse with a psychic protagonist and a shapeshifting supernatural
-- antagonist, genuinely both. The Buffalo Hunter Hunter, The Gone World, and
-- The Everlasting all had real POV/person/reliability uncertainty verified
-- against plot summaries rather than assumed, and flagged via
-- book_field_confidence rather than guessed silently.
--
-- Duplicate-title safety check ran clean against this batch's target set (the
-- catalog's only existing duplicate, ('The One', 2), is the already-fixed pair
-- from the 2026-09-04 title-collision bug, not a new collision).
--
-- Mandatory density self-check (Step 3): first-pass trope density came in at
-- only 0.65x catalog average -- most of this batch is contemporary
-- horror/speculative-fiction standalones that are naturally trope-light
-- compared to the epic-fantasy-heavy catalog average. Added 21 genuine
-- additional tropes across 11 of the 20 books (never padded onto books that
-- didn't have more to genuinely say) before finishing -- final ratio 0.85x.
-- CW ratio was fine throughout at 1.34x, no topup needed there.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'none', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'How to Sell a Haunted House'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'How to Sell a Haunted House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'How to Sell a Haunted House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'How to Sell a Haunted House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'How to Sell a Haunted House' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'How to Sell a Haunted House' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pregnancy_loss', 'moderate', true from books where title = 'How to Sell a Haunted House' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'How to Sell a Haunted House' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'low', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'How to Stop Time'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'How to Stop Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'How to Stop Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'How to Stop Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'How to Stop Time' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'How to Stop Time' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'brief', false from books where title = 'How to Stop Time' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.7, 'ai_inferred' from books where title = 'How to Stop Time' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'ensemble', 'mixed', 'unreliable', 'linear', 'framing_device', 'slow', 'consistent', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'none', 'na', 'sparse', 'dense', 'cerebral', 'intimate', 'high', 'veteran_only'
from books where title = 'Lincoln in the Bardo'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Lincoln in the Bardo' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'Lincoln in the Bardo' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Lincoln in the Bardo' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Lincoln in the Bardo' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Lincoln in the Bardo' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Lincoln in the Bardo' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'form', 0.55, 'ai_inferred' from books where title = 'Lincoln in the Bardo' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.75, 'ai_inferred' from books where title = 'Lincoln in the Bardo' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'none', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'life_threatening', 'gateway'
from books where title = 'My Best Friend''s Exorcism'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'eating_disorder', 'moderate', false from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'brief', false from books where title = 'My Best Friend''s Exorcism' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Needful Things'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Needful Things' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Needful Things' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Needful Things' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Needful Things' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Needful Things' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'moderate', false from books where title = 'Needful Things' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'none', 'na', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Nothing to See Here'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Nothing to See Here' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Nothing to See Here' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Nothing to See Here' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Nothing to See Here' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Nothing to See Here' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Nothing to See Here' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'Nothing to See Here' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', 'frequent', 'graphic', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Prey'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Prey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Prey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Prey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Prey' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Prey' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'Prey' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Prey' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'Slewfoot: A Tale of Bewitchery'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Slewfoot: A Tale of Bewitchery' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening', 'demanding'
from books where title = 'Some Desperate Glory'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Some Desperate Glory' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', true from books where title = 'Some Desperate Glory' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'moderate', false from books where title = 'Some Desperate Glory' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.55, 'ai_inferred' from books where title = 'Some Desperate Glory' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'Starling House'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Starling House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Starling House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Starling House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Starling House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Starling House' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'Starling House' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'Starling House' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy', 'sci_fi'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'Swan Song'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Swan Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Swan Song' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Swan Song' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Swan Song' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre', 0.6, 'ai_inferred' from books where title = 'Swan Song' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'rare', 'low', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'The Book Eaters'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Book Eaters' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', false from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'The Book Eaters' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Book Eaters' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'The Book of Doors'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Book of Doors' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Book of Doors' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Book of Doors' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'The Book of Doors' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Book of Doors' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'The Book of Doors' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.6, 'ai_inferred' from books where title = 'The Book of Doors' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'few', 'mixed', 'unreliable', 'multi_timeline', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'intimate', 'life_threatening', 'demanding'
from books where title = 'The Buffalo Hunter Hunter'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'central_theme', false from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.55, 'ai_inferred' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.55, 'ai_inferred' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'The Buffalo Hunter Hunter' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'few', 'mixed', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'rare', 'mild', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'The Cartographers'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Cartographers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Cartographers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Cartographers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Cartographers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Cartographers' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'The Cartographers' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy', 'sci_fi'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'soft', 'lush', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Everlasting'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_identity_romance' from books where title = 'The Everlasting' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Everlasting' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.55, 'ai_inferred' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Everlasting' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'The Everlasting' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'first', 'reliable', 'nonlinear', 'framing_device', 'slow', 'front_loaded', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', 'occasional', 'graphic', 'moderate', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'na', 'lush', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'The Fisherman'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Fisherman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'new_weird_setting' from books where title = 'The Fisherman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Fisherman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Fisherman' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'The Fisherman' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'The Fisherman' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Fisherman' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.55, 'ai_inferred' from books where title = 'The Fisherman' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'moderate', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'cosmic', 'high', 'veteran_only'
from books where title = 'The Gods Themselves'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Gods Themselves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'The Gods Themselves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Gods Themselves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'The Gods Themselves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Gods Themselves' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'single', 'mixed', 'ambiguous', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'ambiguous', 'resolved', 'long', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'life_threatening', 'demanding'
from books where title = 'The Gone World'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Gone World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'The Gone World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'The Gone World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Gone World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'The Gone World' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'The Gone World' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', true from books where title = 'The Gone World' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.55, 'ai_inferred' from books where title = 'The Gone World' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Gone World' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'heavy', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'The Humans'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Humans' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Humans' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Humans' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_identity_romance' from books where title = 'The Humans' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Humans' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Humans' on conflict do nothing;

