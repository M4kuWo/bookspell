-- Catalog tagging batch: 18 untagged standalone books
-- (Heinlein, PKD, Zamyatin, Vonnegut, Bester, Wells, Kay, Morgenstern,
-- Harrow x2, Bradbury, Ken Liu, Crichton, King x3, Alderman, KSR)
-- Tagged per .claude/skills/tag-catalog-batch/SKILL.md Step 3. Every nullable
-- book_dna column filled in per the skill's silent-partial-insert warning.
-- Idempotent (on conflict do nothing), title+author-scoped throughout.

-- ============ The Moon Is a Harsh Mistress (Robert A. Heinlein) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'moderate', 'bittersweet', 'heavy_handed', 'rare', 'closed_door', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'moderate'
from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'rebellion_against_empire', 'ai_inferred' from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'ai_consciousness', 'ai_inferred' from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'court_intrigue', 'ai_inferred', 0.6 from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Moon Is a Harsh Mistress' and author = 'Robert A. Heinlein'
on conflict (book_id, warning_id) do nothing;


-- ============ Ubik (Philip K. Dick) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'rare', 'moderate', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'veteran_only'
from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'twist_ending', 'ai_inferred' from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'twist_filled', 'ai_inferred' from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'mind_uploading_or_digital_immortality', 'ai_inferred', 0.6 from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'cosmic_horror', 'ai_inferred', 0.6 from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Ubik' and author = 'Philip K. Dick'
on conflict (book_id, warning_id) do nothing;


-- ============ We (Yevgeny Zamyatin) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'unreliable', 'linear', 'epistolary', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'tense', 'heavy_handed', 'occasional', 'moderate', 'occasional', 'graphic', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'dystopia', 'ai_inferred' from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'rebellion_against_empire', 'ai_inferred' from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'hive_mind', 'ai_inferred', 0.6 from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'forbidden_love', 'ai_inferred' from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.6, 'ai_inferred' from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, field_name) do nothing;


-- ============ The Sirens of Titan (Kurt Vonnegut) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'moderate', 'heavy', 'bittersweet', 'heavy_handed', 'rare', 'closed_door', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'cerebral', 'cosmic', 'high', 'accessible'
from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'satirical_or_comedic_scifi', 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'chosen_one', 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'long_journey', 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, field_name) do nothing;


-- ============ The Stars My Destination (Alfred Bester) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'brutal', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'accessible'
from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'revenge', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'anti_hero', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'underdog_rising', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'redemption_arc', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'space_opera', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'twist_ending', 'ai_inferred' from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Stars My Destination' and author = 'Alfred Bester'
on conflict (book_id, warning_id) do nothing;


-- ============ The Island of Doctor Moreau (H. G. Wells) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'ambiguous', 'linear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'occasional', 'graphic', 'light', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'uplift', 'ai_inferred', 0.5 from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'dark_lord_or_evil_overlord', 'ai_inferred' from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'central_theme', false from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, warning_id) do nothing;


-- ============ Tigana (Guy Gavriel Kay) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'lush', 'moderate', 'cerebral', 'regional', 'life_threatening', 'veteran_only'
from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'rebellion_against_empire', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'court_intrigue', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'revenge', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'hidden_identity_romance', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'epic_quest', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'morally_grey_protagonist', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'infiltration_or_undercover_plot', 'ai_inferred' from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'central_theme', false from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Tigana' and author = 'Guy Gavriel Kay'
on conflict (book_id, warning_id) do nothing;


-- ============ The Starless Sea (Erin Morgenstern) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'mixed', 'reliable', 'multi_timeline', 'framing_device', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'low', 'rare', 'moderate', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'portal_fantasy', 'ai_inferred' from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'soulmate_bond', 'ai_inferred' from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'mythological_pantheon_as_characters', 'ai_inferred' from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'twist_ending', 'ai_inferred', 0.5 from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'hidden_identity_romance', 'ai_inferred', 0.6 from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Starless Sea' and author = 'Erin Morgenstern'
on conflict (book_id, warning_id) do nothing;


-- ============ The Ten Thousand Doors of January (Alix E. Harrow) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'mixed', 'reliable', 'multi_timeline', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'occasional', 'low', 'rare', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'portal_fantasy', 'ai_inferred' from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'coming_of_age', 'ai_inferred' from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'retrospective_memoir_narration', 'ai_inferred', 0.6 from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'epic_quest', 'ai_inferred' from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'colonization_themes', 'central_theme', false from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'moderate', false from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'emotional_abuse', 'moderate', false from books where title = 'The Ten Thousand Doors of January' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;


-- ============ The Once and Future Witches (Alix E. Harrow) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'occasional', 'low', 'occasional', 'graphic', 'moderate', 'self_contained', 'happy', 'resolved', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'sapphic_romance', 'ai_inferred' from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'revenge', 'ai_inferred', 0.6 from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'underdog_rising', 'ai_inferred' from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'moderate', false from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', false from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'The Once and Future Witches' and author = 'Alix E. Harrow'
on conflict (book_id, warning_id) do nothing;


-- ============ The Illustrated Man (Ray Bradbury) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'ensemble', 'mixed', 'reliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'balanced', 'dark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'soft', 'lush', 'moderate', 'cerebral', 'global', 'high', 'moderate'
from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'post_apocalyptic', 'ai_inferred' from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'twist_ending', 'ai_inferred' from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'twist_filled', 'ai_inferred' from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'satirical_or_comedic_scifi', 'ai_inferred', 0.6 from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'dying_earth', 'ai_inferred', 0.6 from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Illustrated Man' and author = 'Ray Bradbury'
on conflict (book_id, warning_id) do nothing;


-- ============ The Paper Menagerie and Other Stories (Ken Liu) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi','fantasy'], 'adult', 'standard', 'ensemble', 'mixed', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'closed_door', 'occasional', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'hard', 'moderate', 'moderate', 'cerebral', 'global', 'high', 'moderate'
from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'shapeshifters', 'ai_inferred' from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'steampunk', 'ai_inferred' from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'generation_ship', 'ai_inferred' from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'dying_earth', 'ai_inferred' from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'mythological_pantheon_as_characters', 'ai_inferred', 0.6 from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'central_theme', false from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'central_theme', false from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'moderate', false from books where title = 'The Paper Menagerie and Other Stories' and author = 'Ken Liu'
on conflict (book_id, warning_id) do nothing;


-- ============ Timeline (Michael Crichton) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', 'frequent', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'hard', 'sparse', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'last_minute_rescue', 'ai_inferred' from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'court_intrigue', 'ai_inferred' from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, warning_id) do nothing;


-- ============ Under the Dome (Stephen King) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'occasional', 'moderate', 'frequent', 'brutal', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'dark_lord_or_evil_overlord', 'ai_inferred' from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'first_contact', 'ai_inferred', 0.6 from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'black_and_white_morality', 'ai_inferred', 0.6 from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'revenge', 'ai_inferred', 0.6 from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'central_theme', false from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'suicide', 'moderate', false from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'moderate', false from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'substance_abuse', 'moderate', false from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'moderate', false from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'overall_pace', 0.5, 'ai_inferred' from books where title = 'Under the Dome' and author = 'Stephen King'
on conflict (book_id, field_name) do nothing;


-- ============ The Running Man (Richard Bachman, Stephen King) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'none', 'na', 'frequent', 'brutal', 'moderate', 'self_contained', 'tragic', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'dystopia', 'ai_inferred' from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'deadly_competition_or_trial', 'ai_inferred' from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'anti_hero', 'ai_inferred' from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'central_theme', false from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'The Running Man' and author = 'Richard Bachman, Stephen King'
on conflict (book_id, warning_id) do nothing;


-- ============ The Mist (Stephen King) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'none', 'na', 'frequent', 'graphic', 'light', 'self_contained', 'ambiguous', 'cliffhanger', 'short', 'na', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'The Mist' and author = 'Stephen King'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Mist' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'parallel_universe_or_multiverse', 'ai_inferred' from books where title = 'The Mist' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'black_and_white_morality', 'ai_inferred', 0.6 from books where title = 'The Mist' and author = 'Stephen King'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Mist' and author = 'Stephen King'
on conflict (book_id, warning_id) do nothing;


-- ============ The Power (Naomi Alderman) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening', 'moderate'
from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'dystopia', 'ai_inferred' from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'revenge', 'ai_inferred' from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'corruption_arc', 'ai_inferred' from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'central_theme', false from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, warning_id) do nothing;


-- ============ The Ministry for the Future (Kim Stanley Robinson) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'long', 'ensemble', 'mixed', 'reliable', 'linear', 'framing_device', 'slow', 'uneven', 'worldbuilding_driven', 'dark', 'light', 'bittersweet', 'heavy_handed', 'none', 'na', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'The Ministry for the Future' and author = 'Kim Stanley Robinson'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'war_story', 'ai_inferred' from books where title = 'The Ministry for the Future' and author = 'Kim Stanley Robinson'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Ministry for the Future' and author = 'Kim Stanley Robinson'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'sudden_apocalypse_event', 'ai_inferred', 0.6 from books where title = 'The Ministry for the Future' and author = 'Kim Stanley Robinson'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Ministry for the Future' and author = 'Kim Stanley Robinson'
on conflict (book_id, warning_id) do nothing;

