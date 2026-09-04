-- Batch-tag 20 more Bookspell catalog books with full Book DNA.
--
-- All standalone/series-opener titles: Elder Race, The Rithmatist, The Last
-- Unicorn, Watership Down, Blood Song, The Curse of Chalion, The Sparrow, The
-- Aeronaut's Windlass, 1984 / Animal Farm, A Monster Calls, A Sorceress Comes
-- to Call, A Wizard's Guide to Defensive Baking, Alchemised, Ariadne, Battle
-- Royale, Bury Our Bones in the Midnight Soil, Cell, Dead Silence, Flatland,
-- and House of Suns.
--
-- Two titles from the same prioritized-untagged pull were skipped and left
-- flagged rather than tagged: Shogun (James Clavell) is historical fiction with
-- no sci-fi/fantasy content -- out of v1 catalog scope, should be confirmed for
-- deletion with the repo owner. Nimona (ND Stevenson) is a graphic novel --
-- out of scope per the 2026-09-04 graphic-novel scope decision, should be
-- deleted the same way Saga/Sandman were.
--
-- Judgment calls of note: Elder Race and Blood Song both use person='mixed'
-- (alternating first/third across POVs), confirmed against plot summaries
-- rather than assumed. Alchemised's drive was deliberately set to
-- character_driven, not romance_driven, despite fanfic-romance origins --
-- the author's own framing and story summary ('fundamentally about war,
-- power, survival') pass the romance_driven judgment test in the negative.
-- Nothing to See Here was considered but not included this batch (deferred,
-- not rejected) pending a closer look at whether its unexplained-fire premise
-- clears the magical-realism bar the same way Lincoln in the Bardo's afterlife
-- narration did.
--
-- Duplicate-title safety check ran clean against this batch's target set (the
-- catalog's only existing duplicate, ('The One', 2), is the already-fixed pair
-- from the 2026-09-04 title-collision bug, not a new collision).
--
-- Mandatory density self-check (Step 3): trope ratio came in at 0.85x catalog
-- average and CW ratio at 1.35x -- both clear the 0.8x floor without any topup
-- needed this time.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi', 'fantasy'], 'adult', 'short', 'dual', 'mixed', 'ambiguous', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'soft', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'Elder Race'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Elder Race' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Elder Race' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'generation_ship' from books where title = 'Elder Race' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Elder Race' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Elder Race' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Elder Race' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.75, 'ai_inferred' from books where title = 'Elder Race' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.7, 'ai_inferred' from books where title = 'Elder Race' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'hard', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'The Rithmatist'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'The Rithmatist' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Rithmatist' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'The Rithmatist' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'sanderlanche' from books where title = 'The Rithmatist' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Rithmatist' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Rithmatist' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.6, 'ai_inferred' from books where title = 'The Rithmatist' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'short', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'closed_door', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'The Last Unicorn'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Last Unicorn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Last Unicorn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Last Unicorn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Last Unicorn' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'The Last Unicorn' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'The Last Unicorn' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'balanced', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'none', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'demanding'
from books where title = 'Watership Down'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Watership Down' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Watership Down' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'central_theme', false from books where title = 'Watership Down' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Watership Down' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'age_category', 0.6, 'ai_inferred' from books where title = 'Watership Down' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.65, 'ai_inferred' from books where title = 'Watership Down' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'dual', 'mixed', 'ambiguous', 'nonlinear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'closed_door', 'frequent', 'brutal', 'dense', 'requires_series', 'bittersweet', 'cliffhanger', 'epic', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Blood Song'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Blood Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Blood Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Blood Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Blood Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Blood Song' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Blood Song' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Blood Song' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'Blood Song' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Blood Song' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'Blood Song' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.75, 'ai_inferred' from books where title = 'Blood Song' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'closed_door', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'long', 'soft', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'The Curse of Chalion'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Curse of Chalion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Curse of Chalion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Curse of Chalion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Curse of Chalion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Curse of Chalion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Curse of Chalion' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Curse of Chalion' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.7, 'ai_inferred' from books where title = 'The Curse of Chalion' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'light', 'gut_punch', 'moderate', 'rare', 'na', 'occasional', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'long', 'na', 'soft', 'lush', 'dense', 'cerebral', 'intimate', 'life_threatening', 'demanding'
from books where title = 'The Sparrow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'first_contact' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'The Sparrow' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', true from books where title = 'The Sparrow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', true from books where title = 'The Sparrow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Sparrow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', true from books where title = 'The Sparrow' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'message_intensity', 0.6, 'ai_inferred' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'The Sparrow' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_frequency', 0.7, 'ai_inferred' from books where title = 'The Sparrow' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'rare', 'closed_door', 'frequent', 'moderate', 'dense', 'requires_series', 'happy', 'resolved', 'epic', 'hard', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'moderate'
from books where title = 'The Aeronaut''s Windlass'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'steampunk' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.7, 'ai_inferred' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.6, 'ai_inferred' from books where title = 'The Aeronaut''s Windlass' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi', 'fantasy'], 'adult', 'long', 'single', 'mixed', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'grimdark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'brutal', 'dense', 'self_contained', 'tragic', 'resolved', 'long', 'none', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening', 'moderate'
from books where title = '1984 / Animal Farm'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'corruption_arc' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = '1984 / Animal Farm' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', true from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'moderate', false from books where title = '1984 / Animal Farm' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.55, 'ai_inferred' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.6, 'ai_inferred' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.6, 'ai_inferred' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = '1984 / Animal Farm' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'form', 0.6, 'ai_inferred' from books where title = '1984 / Animal Farm' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'short', 'single', 'third_limited', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', 'rare', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'A Monster Calls'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'A Monster Calls' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'central_theme', false from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'A Monster Calls' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'age_category', 0.6, 'ai_inferred' from books where title = 'A Monster Calls' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.65, 'ai_inferred' from books where title = 'A Monster Calls' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'rare', 'closed_door', 'occasional', 'moderate', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'A Sorceress Comes to Call'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'A Sorceress Comes to Call' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Sorceress Comes to Call' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Sorceress Comes to Call' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'A Sorceress Comes to Call' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'central_theme', false from books where title = 'A Sorceress Comes to Call' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'A Sorceress Comes to Call' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'A Sorceress Comes to Call' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'darkness', 0.6, 'ai_inferred' from books where title = 'A Sorceress Comes to Call' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'heavy', 'comfort_read', 'subtle', 'none', 'na', 'rare', 'mild', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'gateway'
from books where title = 'A Wizard''s Guide to Defensive Baking'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Wizard''s Guide to Defensive Baking' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'A Wizard''s Guide to Defensive Baking' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'A Wizard''s Guide to Defensive Baking' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Wizard''s Guide to Defensive Baking' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre_accessibility', 0.6, 'ai_inferred' from books where title = 'A Wizard''s Guide to Defensive Baking' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'single', 'third_limited', 'ambiguous', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'frequent', 'moderate', 'frequent', 'brutal', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Alchemised'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'Alchemised' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Alchemised' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Alchemised' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Alchemised' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Alchemised' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', false from books where title = 'Alchemised' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'Alchemised' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Alchemised' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'central_theme', false from books where title = 'Alchemised' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Alchemised' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Alchemised' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Alchemised' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'Alchemised' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.65, 'ai_inferred' from books where title = 'Alchemised' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'moderate', 'self_contained', 'tragic', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'high', 'moderate'
from books where title = 'Ariadne'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Ariadne' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'Ariadne' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'Ariadne' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Ariadne' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', true from books where title = 'Ariadne' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Ariadne' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Ariadne' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'light', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Battle Royale'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Battle Royale' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'Battle Royale' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Battle Royale' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Battle Royale' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Battle Royale' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Battle Royale' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Battle Royale' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'Battle Royale' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre', 0.65, 'ai_inferred' from books where title = 'Battle Royale' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['fantasy'], 'adult', 'epic', 'few', 'third_limited', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'high', 'moderate'
from books where title = 'Bury Our Bones in the Midnight Soil'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', false from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'Bury Our Bones in the Midnight Soil' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'grimdark', 'none', 'tense', 'moderate', 'none', 'na', 'frequent', 'brutal', 'light', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'escapist', 'global', 'life_threatening', 'gateway'
from books where title = 'Cell'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Cell' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Cell' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Cell' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Cell' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Cell' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Cell' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'Cell' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre', 0.6, 'ai_inferred' from books where title = 'Cell' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.7, 'ai_inferred' from books where title = 'Cell' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'ambiguous', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'tense', 'subtle', 'rare', 'low', 'occasional', 'graphic', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'Dead Silence'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'Dead Silence' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Dead Silence' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Dead Silence' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'last_minute_rescue' from books where title = 'Dead Silence' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Dead Silence' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Dead Silence' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'brief', false from books where title = 'Dead Silence' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.55, 'ai_inferred' from books where title = 'Dead Silence' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'light', 'moderate', 'comfort_read', 'heavy_handed', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'high', 'veteran_only'
from books where title = 'Flatland: A Romance of Many Dimensions'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'parallel_universe_or_multiverse' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'central_theme', false from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.55, 'ai_inferred' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.6, 'ai_inferred' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'genre_accessibility', 0.6, 'ai_inferred' from books where title = 'Flatland: A Romance of Many Dimensions' on conflict do nothing;

insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'epic', 'dual', 'first', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'cosmic', 'high', 'demanding'
from books where title = 'House of Suns'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'House of Suns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'House of Suns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'relativistic_time_dilation' from books where title = 'House of Suns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'House of Suns' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'House of Suns' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', true from books where title = 'House of Suns' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'House of Suns' on conflict do nothing;

