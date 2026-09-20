-- Catalog tagging batch 7: 20 books, full Book DNA (CLDA)
-- Self-screened pool from the round-4 expansion queue; partial-series
-- pool remains fully exhausted catalog-wide, so this batch is pure
-- own-merits tagging. See docs/project-log.md for full detail per book
-- (HIGH_RISK_FIELDS checks, author-contamination checks, vocabulary
-- gap notes, density self-check).

-- The Invisible Library
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'The Invisible Library';

insert into book_tropes (book_id, trope_id)
select id, 'portal_fantasy' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'dragons' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'fae_or_fairies' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'heist' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'secret_royalty' from books where title = 'The Invisible Library';
insert into book_tropes (book_id, trope_id)
select id, 'steampunk' from books where title = 'The Invisible Library';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'The Invisible Library';


-- The Killing Moon
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Killing Moon';

insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'The Killing Moon';
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Killing Moon';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Killing Moon';
insert into book_tropes (book_id, trope_id)
select id, 'mentor_death' from books where title = 'The Killing Moon';
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'The Killing Moon';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Killing Moon';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Killing Moon';


-- The Knight and the Moth
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'ambiguous', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'tense', 'subtle', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Knight and the Moth';

insert into book_tropes (book_id, trope_id)
select id, 'slow_burn_romance' from books where title = 'The Knight and the Moth';
insert into book_tropes (book_id, trope_id)
select id, 'animated_construct_companion' from books where title = 'The Knight and the Moth';
insert into book_tropes (book_id, trope_id)
select id, 'forced_proximity' from books where title = 'The Knight and the Moth';
insert into book_tropes (book_id, trope_id)
select id, 'long_journey' from books where title = 'The Knight and the Moth';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Knight and the Moth';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Knight and the Moth';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'The Knight and the Moth'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Knight and the Moth'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.4, 'ai_inferred' from books where title = 'The Knight and the Moth'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Knight and the Moth'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Knight and the Moth'
on conflict (book_id, field_name) do nothing;


-- The Library of the Unwritten
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'closed_door', null, 'occasional', 'moderate', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Library of the Unwritten';

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Library of the Unwritten';
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Library of the Unwritten';
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'The Library of the Unwritten';
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'The Library of the Unwritten';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Library of the Unwritten'
on conflict (book_id, field_name) do nothing;


-- The Lions of Al-Rassan
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'several', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'occasional', 'low', null, 'occasional', 'graphic', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'long', 'none', 'na', 'lush', 'dense', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'The Lions of Al-Rassan';

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Lions of Al-Rassan';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Lions of Al-Rassan';
insert into book_tropes (book_id, trope_id)
select id, 'medieval_european_setting' from books where title = 'The Lions of Al-Rassan';
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'The Lions of Al-Rassan';
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'The Lions of Al-Rassan';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Lions of Al-Rassan';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'moderate', false from books where title = 'The Lions of Al-Rassan';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Lions of Al-Rassan'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Lions of Al-Rassan'
on conflict (book_id, field_name) do nothing;


-- The Luminous Dead
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'ambiguous', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The Luminous Dead';

insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'The Luminous Dead';
insert into book_tropes (book_id, trope_id)
select id, 'sapphic_romance' from books where title = 'The Luminous Dead';
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The Luminous Dead';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'cosmic_horror', 0.4, 'ai_inferred' from books where title = 'The Luminous Dead';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Luminous Dead';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'The Luminous Dead';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Luminous Dead'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Luminous Dead'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Luminous Dead'
on conflict (book_id, field_name) do nothing;


-- The Mask of Mirrors
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'hard', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'demanding'
from books where title = 'The Mask of Mirrors';

insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Mask of Mirrors';
insert into book_tropes (book_id, trope_id)
select id, 'heist' from books where title = 'The Mask of Mirrors';
insert into book_tropes (book_id, trope_id)
select id, 'infiltration_or_undercover_plot' from books where title = 'The Mask of Mirrors';
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'The Mask of Mirrors';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'The Mask of Mirrors';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'central_theme', false from books where title = 'The Mask of Mirrors';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'moderate', false from books where title = 'The Mask of Mirrors';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'The Mask of Mirrors';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Mask of Mirrors'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Mask of Mirrors'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'The Mask of Mirrors'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Mask of Mirrors'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Mask of Mirrors'
on conflict (book_id, field_name) do nothing;


-- The Ninth Rain
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'rare', 'low', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'The Ninth Rain';

insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Ninth Rain';
insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'The Ninth Rain';
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Ninth Rain';
insert into book_tropes (book_id, trope_id)
select id, 'ancient_evil_awakens' from books where title = 'The Ninth Rain';
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Ninth Rain';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Ninth Rain';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Ninth Rain';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Ninth Rain';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'The Ninth Rain'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Ninth Rain'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Ninth Rain'
on conflict (book_id, field_name) do nothing;


-- The Paper Magician
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'new_adult', 'short', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'light', 'bittersweet', 'subtle', 'occasional', 'closed_door', null, 'rare', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'short', 'hard', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'accessible'
from books where title = 'The Paper Magician';

insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'The Paper Magician';
insert into book_tropes (book_id, trope_id)
select id, 'age_gap_romance' from books where title = 'The Paper Magician';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'The Paper Magician';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Paper Magician';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Paper Magician'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Paper Magician'
on conflict (book_id, field_name) do nothing;


-- The Prison Healer
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'occasional', 'closed_door', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'life_threatening', 'gateway'
from books where title = 'The Prison Healer';

insert into book_tropes (book_id, trope_id)
select id, 'love_triangle' from books where title = 'The Prison Healer';
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'The Prison Healer';
insert into book_tropes (book_id, trope_id)
select id, 'deadly_competition_or_trial' from books where title = 'The Prison Healer';
insert into book_tropes (book_id, trope_id)
select id, 'secret_royalty' from books where title = 'The Prison Healer';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Prison Healer';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Prison Healer';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Prison Healer'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'The Prison Healer'
on conflict (book_id, field_name) do nothing;


-- The Quantum Thief
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'mixed', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'regional', 'high', 'veteran_only'
from books where title = 'The Quantum Thief';

insert into book_tropes (book_id, trope_id)
select id, 'heist' from books where title = 'The Quantum Thief';
insert into book_tropes (book_id, trope_id)
select id, 'mind_uploading_or_digital_immortality' from books where title = 'The Quantum Thief';
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The Quantum Thief';
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'The Quantum Thief';
insert into book_tropes (book_id, trope_id)
select id, 'amnesia_driven_narrative' from books where title = 'The Quantum Thief';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'overall_pace', 0.5, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'The Quantum Thief'
on conflict (book_id, field_name) do nothing;


-- The Queen of the Tearling
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'The Queen of the Tearling';

insert into book_tropes (book_id, trope_id)
select id, 'secret_royalty' from books where title = 'The Queen of the Tearling';
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'The Queen of the Tearling';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Queen of the Tearling';
insert into book_tropes (book_id, trope_id)
select id, 'dark_lord_or_evil_overlord' from books where title = 'The Queen of the Tearling';
insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'The Queen of the Tearling';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'central_theme', false from books where title = 'The Queen of the Tearling';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'trafficking', 'moderate', false from books where title = 'The Queen of the Tearling';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Queen of the Tearling'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.4, 'ai_inferred' from books where title = 'The Queen of the Tearling'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Queen of the Tearling'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Queen of the Tearling'
on conflict (book_id, field_name) do nothing;


-- The Raven Scholar
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'rare', 'low', null, 'occasional', 'moderate', 'dense', null, 'requires_series', 'ambiguous', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Raven Scholar';

insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Raven Scholar';
insert into book_tropes (book_id, trope_id)
select id, 'deadly_competition_or_trial' from books where title = 'The Raven Scholar';
insert into book_tropes (book_id, trope_id)
select id, 'caste_or_faction_stratified_society' from books where title = 'The Raven Scholar';
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'The Raven Scholar';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.4, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.4, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.3, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.8, 'ai_inferred' from books where title = 'The Raven Scholar'
on conflict (book_id, field_name) do nothing;


-- The Raven Tower
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'mixed', 'ambiguous', 'nonlinear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'none', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', null, 'self_contained', 'ambiguous', 'cliffhanger', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'The Raven Tower';

insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'The Raven Tower';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Raven Tower';
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The Raven Tower';
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Raven Tower';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Raven Tower';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.6, 'ai_inferred' from books where title = 'The Raven Tower'
on conflict (book_id, field_name) do nothing;


-- The Reality Dysfunction
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'occasional', 'explicit', null, 'frequent', 'graphic', 'dense', null, 'requires_series', 'ambiguous', 'cliffhanger', 'epic', 'na', 'soft', 'lush', 'moderate', 'moderate', 'global', 'life_threatening', 'veteran_only'
from books where title = 'The Reality Dysfunction';

insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = 'The Reality Dysfunction';
insert into book_tropes (book_id, trope_id)
select id, 'first_contact' from books where title = 'The Reality Dysfunction';
insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = 'The Reality Dysfunction';
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Reality Dysfunction';
insert into book_tropes (book_id, trope_id)
select id, 'cybernetic_enhancement' from books where title = 'The Reality Dysfunction';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Reality Dysfunction';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Reality Dysfunction';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Reality Dysfunction'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Reality Dysfunction'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Reality Dysfunction'
on conflict (book_id, field_name) do nothing;


-- The Rise and Fall of D.O.D.O.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'adult', 'long', 'several', 'mixed', 'ambiguous', 'nonlinear', 'epistolary', 'medium', 'uneven', 'plot_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'rare', 'na', null, 'rare', 'mild', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'hard', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'The Rise and Fall of D.O.D.O.';

insert into book_tropes (book_id, trope_id)
select id, 'time_travel' from books where title = 'The Rise and Fall of D.O.D.O.';
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'The Rise and Fall of D.O.D.O.';
insert into book_tropes (book_id, trope_id)
select id, 'institutional_time_travel_bureaucracy' from books where title = 'The Rise and Fall of D.O.D.O.';
insert into book_tropes (book_id, trope_id)
select id, 'satirical_or_comedic_fantasy' from books where title = 'The Rise and Fall of D.O.D.O.';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_register', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'scifi_hardness', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrative_closure', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'form', 0.8, 'ai_inferred' from books where title = 'The Rise and Fall of D.O.D.O.'
on conflict (book_id, field_name) do nothing;


-- The River Has Roots
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'closed_door', null, 'rare', 'moderate', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'The River Has Roots';

insert into book_tropes (book_id, trope_id)
select id, 'fae_or_fairies' from books where title = 'The River Has Roots';
insert into book_tropes (book_id, trope_id)
select id, 'shapeshifters' from books where title = 'The River Has Roots';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'sapphic_romance', 0.5, 'ai_inferred' from books where title = 'The River Has Roots';
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'immortal_or_ageless_character', 0.5, 'ai_inferred' from books where title = 'The River Has Roots';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'stalking', 'moderate', false from books where title = 'The River Has Roots';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.4, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'form', 0.4, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.4, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The River Has Roots'
on conflict (book_id, field_name) do nothing;


-- The Strain
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'gut_punch', 'subtle', 'none', 'na', null, 'frequent', 'graphic', 'moderate', null, 'requires_series', 'ambiguous', 'cliffhanger', 'standard', 'none', 'soft', 'moderate', 'accessible', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Strain';

insert into book_tropes (book_id, trope_id)
select id, 'vampires' from books where title = 'The Strain';
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'The Strain';
insert into book_tropes (book_id, trope_id)
select id, 'sudden_apocalypse_event' from books where title = 'The Strain';
insert into book_tropes (book_id, trope_id)
select id, 'ancient_evil_awakens' from books where title = 'The Strain';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Strain';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Strain';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Strain'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Strain'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Strain'
on conflict (book_id, field_name) do nothing;


-- The Tommyknockers
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'epic', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', null, 'occasional', 'brutal', 'moderate', null, 'self_contained', 'tragic', 'resolved', 'epic', 'na', 'soft', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'The Tommyknockers';

insert into book_tropes (book_id, trope_id)
select id, 'ancient_evil_awakens' from books where title = 'The Tommyknockers';
insert into book_tropes (book_id, trope_id)
select id, 'hive_mind' from books where title = 'The Tommyknockers';
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'The Tommyknockers';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Tommyknockers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'moderate', false from books where title = 'The Tommyknockers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'The Tommyknockers';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Tommyknockers'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.4, 'ai_inferred' from books where title = 'The Tommyknockers'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.4, 'ai_inferred' from books where title = 'The Tommyknockers'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Tommyknockers'
on conflict (book_id, field_name) do nothing;


-- The Unbroken
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Unbroken';

insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'The Unbroken';
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Unbroken';
insert into book_tropes (book_id, trope_id)
select id, 'sapphic_romance' from books where title = 'The Unbroken';
insert into book_tropes (book_id, trope_id)
select id, 'forbidden_love' from books where title = 'The Unbroken';
insert into book_tropes (book_id, trope_id)
select id, 'morally_grey_protagonist' from books where title = 'The Unbroken';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'central_theme', false from books where title = 'The Unbroken';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Unbroken';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'moderate', false from books where title = 'The Unbroken';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.4, 'ai_inferred' from books where title = 'The Unbroken'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'The Unbroken'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 0.5, 'ai_inferred' from books where title = 'The Unbroken'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Unbroken'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Unbroken'
on conflict (book_id, field_name) do nothing;

