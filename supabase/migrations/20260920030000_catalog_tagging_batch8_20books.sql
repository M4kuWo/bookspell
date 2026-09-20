-- Catalog tagging batch 8 (CLDA session, 2026-09-20): 20 more books tagged
-- from the round-4 expansion pool, own-merits (partial-series completion
-- pool still fully exhausted catalog-wide): This Woven Kingdom, Three
-- Parts Dead, Titus Groan, Trail of Lightning, Trigger Warning: Short
-- Fictions and Disturbances, Vampire Academy, Vita Nostra, Wanderers,
-- Warcross, When Among Crows, When the Moon Hits Your Eye, When Women
-- Were Dragons, Winter's Orbit, Witchcraft for Wayward Girls, The
-- Historian, The Cabin at the End of the World, The Last House on
-- Needless Street, Water Moon, What You Are Looking for Is in the
-- Library, The Bone Clocks.
--
-- Author-field contamination fixed at tagging time via Hardcover's
-- cached_contributors data (not fixed here -- books.author itself is
-- untouched by this migration, flagged for a separate authorship-fix
-- migration): The Historian (Justine Eyre/Paul Michael are audiobook
-- narrators), When the Moon Hits Your Eye (Wil Wheaton is the narrator),
-- What You Are Looking for Is in the Library (Alison Watts is the
-- translator, Rohan Eason the illustrator), and Titus Groan (Anthony
-- Burgess wrote the foreword to one edition, not a co-author) -- the
-- last one not among the pre-flagged three, caught by this session's own
-- routine multi-name author check.
--
-- romance_tone/worldbuilding_delivery left null throughout except Vita
-- Nostra's worldbuilding_delivery (woven, confidence 0.5) -- the
-- "confusing because nothing is explained" pattern already documented
-- for Gideon the Ninth/Gardens of the Moon (docs/schema/book-dna.md).
-- Every other book's romance/worldbuilding presentation evidence wasn't
-- solid enough to clear this project's strict evidence bar, so left null
-- per standing policy rather than guessed from genre reputation.
--
-- Density self-check (fresh catalog average at time of tagging: 5.34
-- tropes/book, 1.70 CWs/book, 1099 tagged books): this batch landed at
-- 4.30 tropes/book (86/20, ~19.5% below) and 1.35 CWs/book (27/20,
-- ~20.6% below) -- both close to but within this skill's ~20% tolerance,
-- not a rushing/fatigue signal. The batch's own genre mix explains most
-- of the gap: a short-story collection (Trigger Warning) and two
-- deliberately gentle, light-worldbuilding magical-realism books (Water
-- Moon, What You Are Looking for Is in the Library) legitimately carry
-- fewer tropes/CWs than the catalog average -- confirmed against the
-- catalog's own precedent for this exact subgenre (Before the Coffee
-- Gets Cold: 2 tropes, 0 content warnings), not padded or under-tagged.
--
-- New single-occurrence vocabulary gap flagged (added to
-- docs/schema/book-dna.md's tracker, not added as new vocabulary yet):
-- Titus Groan/Gormenghast's castle-bound society governed by an
-- exhaustive, unbroken book of ceremonial ritual observance dictating
-- daily life -- distinct from generic court_intrigue (political scheming)
-- or caste_or_faction_stratified_society (formal caste sorting, not
-- ritual-observance-as-law). One occurrence only; watch for a second.
--
-- All other open tracker gaps checked against this batch, no second
-- occurrences found (incl. magical_archive_guardian checked directly
-- against "What You Are Looking for Is in the Library" and correctly
-- excluded -- Komachi is not fleeing/expelled from an official
-- institution, she runs a normal, current community-center library).

-- ===== This Woven Kingdom =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'long', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'This Woven Kingdom';
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'This Woven Kingdom';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'This Woven Kingdom';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'This Woven Kingdom' on conflict (book_id, field_name) do nothing;
-- ===== Three Parts Dead =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'rare', 'low', null, 'occasional', 'moderate', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'moderate', 'cerebral', 'regional', 'high', 'demanding'
from books where title = 'Three Parts Dead';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Three Parts Dead';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Three Parts Dead';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Three Parts Dead';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Three Parts Dead';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Three Parts Dead';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Three Parts Dead' on conflict (book_id, field_name) do nothing;
-- ===== Titus Groan =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_omniscient', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'worldbuilding_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'none', 'na', null, 'rare', 'mild', 'dense', null, 'requires_series', 'ambiguous', 'resolved', 'long', 'none', 'na', 'lush', 'dense', 'cerebral', 'intimate', 'moderate', 'veteran_only'
from books where title = 'Titus Groan';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Titus Groan';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Titus Groan';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Titus Groan';
insert into book_tropes (book_id, trope_id) select id, 'villain_protagonist' from books where title = 'Titus Groan';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Titus Groan';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'Titus Groan';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Titus Groan' on conflict (book_id, field_name) do nothing;
-- ===== Trail of Lightning =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'occasional', 'moderate', null, 'frequent', 'graphic', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'Trail of Lightning';
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Trail of Lightning';
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Trail of Lightning';
insert into book_tropes (book_id, trope_id) select id, 'monster_hunter_for_hire' from books where title = 'Trail of Lightning';
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Trail of Lightning';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Trail of Lightning';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Trail of Lightning';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Trail of Lightning';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.5, 'ai_inferred' from books where title = 'Trail of Lightning' on conflict (book_id, field_name) do nothing;
-- ===== Trigger Warning: Short Fictions and Disturbances =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'adult', 'standard', 'several', 'mixed', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'rare', 'low', null, 'occasional', 'moderate', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'soft', 'moderate', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'Trigger Warning: Short Fictions and Disturbances';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'Trigger Warning: Short Fictions and Disturbances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Trigger Warning: Short Fictions and Disturbances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.5, 'ai_inferred' from books where title = 'Trigger Warning: Short Fictions and Disturbances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Trigger Warning: Short Fictions and Disturbances' on conflict (book_id, field_name) do nothing;
-- ===== Vampire Academy =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'gateway'
from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'age_gap_romance' from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Vampire Academy';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Vampire Academy';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'Vampire Academy';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'self_harm', 'moderate', true from books where title = 'Vampire Academy';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Vampire Academy' on conflict (book_id, field_name) do nothing;
-- ===== Vita Nostra =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'rare', 'low', null, 'rare', 'moderate', 'dense', 'woven', 'requires_series', 'ambiguous', 'resolved', 'standard', 'soft', 'na', 'moderate', 'dense', 'cerebral', 'intimate', 'high', 'veteran_only'
from books where title = 'Vita Nostra';
insert into book_tropes (book_id, trope_id) select id, 'dark_academia_setting' from books where title = 'Vita Nostra';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Vita Nostra';
insert into book_tropes (book_id, trope_id) select id, 'cosmic_horror' from books where title = 'Vita Nostra';
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'Vita Nostra';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'central_theme', false from books where title = 'Vita Nostra';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Vita Nostra';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'age_category', 0.6, 'ai_inferred' from books where title = 'Vita Nostra' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Vita Nostra' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.5, 'ai_inferred' from books where title = 'Vita Nostra' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Vita Nostra' on conflict (book_id, field_name) do nothing;
-- ===== Wanderers =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'epic', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', null, 'frequent', 'graphic', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'Wanderers';
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Wanderers';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Wanderers';
insert into book_tropes (book_id, trope_id) select id, 'predictive_social_science' from books where title = 'Wanderers';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Wanderers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Wanderers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Wanderers';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'moderate', false from books where title = 'Wanderers';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.5, 'ai_inferred' from books where title = 'Wanderers' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'Wanderers' on conflict (book_id, field_name) do nothing;
-- ===== Warcross =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'soft', 'moderate', 'accessible', 'escapist', 'global', 'high', 'gateway'
from books where title = 'Warcross';
insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Warcross';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Warcross';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Warcross';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Warcross';
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Warcross';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Warcross';
-- ===== When Among Crows =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'short', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'rare', 'low', null, 'frequent', 'graphic', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'When Among Crows';
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'When Among Crows';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'When Among Crows';
insert into book_tropes (book_id, trope_id) select id, 'monster_hunter_for_hire' from books where title = 'When Among Crows';
insert into book_tropes (book_id, trope_id) select id, 'magically_binding_bargain' from books where title = 'When Among Crows';
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'When Among Crows';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'When Among Crows' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'When Among Crows' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'When Among Crows' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_frequency', 0.4, 'ai_inferred' from books where title = 'When Among Crows' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'When Among Crows' on conflict (book_id, field_name) do nothing;
-- ===== When the Moon Hits Your Eye =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'light', 'heavy', 'bittersweet', 'moderate', 'rare', 'low', null, 'rare', 'mild', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'global', 'moderate', 'accessible'
from books where title = 'When the Moon Hits Your Eye';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'When the Moon Hits Your Eye';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'When the Moon Hits Your Eye';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'When the Moon Hits Your Eye' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'When the Moon Hits Your Eye' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'overall_pace', 0.5, 'ai_inferred' from books where title = 'When the Moon Hits Your Eye' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'When the Moon Hits Your Eye' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.5, 'ai_inferred' from books where title = 'When the Moon Hits Your Eye' on conflict (book_id, field_name) do nothing;
-- ===== When Women Were Dragons =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'framing_device', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'rare', 'low', null, 'rare', 'mild', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'none', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'moderate', 'moderate'
from books where title = 'When Women Were Dragons';
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'When Women Were Dragons';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'When Women Were Dragons';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'When Women Were Dragons';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'When Women Were Dragons';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'When Women Were Dragons';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'When Women Were Dragons';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'form', 0.5, 'ai_inferred' from books where title = 'When Women Were Dragons' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'When Women Were Dragons' on conflict (book_id, field_name) do nothing;
-- ===== Winter's Orbit =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'occasional', 'moderate', null, 'rare', 'mild', 'moderate', null, 'self_contained', 'happy', 'resolved', 'standard', 'na', 'soft', 'moderate', 'accessible', 'escapist', 'global', 'high', 'accessible'
from books where title = 'Winter''s Orbit';
insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'Winter''s Orbit';
insert into book_tropes (book_id, trope_id) select id, 'marriage_of_convenience' from books where title = 'Winter''s Orbit';
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Winter''s Orbit';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Winter''s Orbit';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Winter''s Orbit';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'central_theme', true from books where title = 'Winter''s Orbit';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Winter''s Orbit' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.6, 'ai_inferred' from books where title = 'Winter''s Orbit' on conflict (book_id, field_name) do nothing;
-- ===== Witchcraft for Wayward Girls =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'rare', 'low', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Witchcraft for Wayward Girls';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Witchcraft for Wayward Girls';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Witchcraft for Wayward Girls';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Witchcraft for Wayward Girls';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'abortion', 'central_theme', false from books where title = 'Witchcraft for Wayward Girls';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Witchcraft for Wayward Girls';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Witchcraft for Wayward Girls';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Witchcraft for Wayward Girls' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Witchcraft for Wayward Girls' on conflict (book_id, field_name) do nothing;
-- ===== The Historian =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'epic', 'few', 'first', 'reliable', 'multi_timeline', 'framing_device', 'slow', 'consistent', 'plot_driven', 'moderate', 'none', 'tense', 'subtle', 'rare', 'low', null, 'rare', 'moderate', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'The Historian';
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'The Historian';
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'The Historian';
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Historian';
insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'The Historian';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Historian';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Historian';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Historian';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Historian' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'The Historian' on conflict (book_id, field_name) do nothing;
-- ===== The Cabin at the End of the World =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'ambiguous', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'frequent', 'brutal', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'standard', 'none', 'na', 'moderate', 'moderate', 'cerebral', 'global', 'life_threatening', 'moderate'
from books where title = 'The Cabin at the End of the World';
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'The Cabin at the End of the World';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Cabin at the End of the World';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Cabin at the End of the World';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'central_theme', false from books where title = 'The Cabin at the End of the World';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'The Cabin at the End of the World' on conflict (book_id, field_name) do nothing;
-- ===== The Last House on Needless Street =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'mixed', 'unreliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'none', 'gut_punch', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'light', null, 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'na', 'moderate', 'moderate', 'cerebral', 'intimate', 'life_threatening', 'moderate'
from books where title = 'The Last House on Needless Street';
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'The Last House on Needless Street';
insert into book_tropes (book_id, trope_id) select id, 'twist_filled' from books where title = 'The Last House on Needless Street';
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Last House on Needless Street';
insert into book_tropes (book_id, trope_id) select id, 'shadow_self_confrontation' from books where title = 'The Last House on Needless Street';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', true from books where title = 'The Last House on Needless Street';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', true from books where title = 'The Last House on Needless Street';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'The Last House on Needless Street' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'The Last House on Needless Street' on conflict (book_id, field_name) do nothing;
-- ===== Water Moon =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'light', 'bittersweet', 'subtle', 'occasional', 'low', null, 'none', 'na', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Water Moon';
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'Water Moon';
insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Water Moon';
insert into book_tropes (book_id, trope_id) select id, 'slow_burn_romance' from books where title = 'Water Moon';
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Water Moon';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Water Moon' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Water Moon' on conflict (book_id, field_name) do nothing;
-- ===== What You Are Looking for Is in the Library =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'light', 'light', 'comfort_read', 'moderate', 'none', 'na', null, 'none', 'na', 'light', null, 'self_contained', 'happy', 'resolved', 'standard', 'none', 'na', 'sparse', 'accessible', 'moderate', 'intimate', 'low', 'accessible'
from books where title = 'What You Are Looking for Is in the Library';
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'What You Are Looking for Is in the Library';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.5, 'ai_inferred' from books where title = 'What You Are Looking for Is in the Library' on conflict (book_id, field_name) do nothing;
-- ===== The Bone Clocks =====
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy','sci_fi'], 'adult', 'epic', 'several', 'first', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'balanced', 'dark', 'light', 'bittersweet', 'moderate', 'rare', 'low', null, 'occasional', 'moderate', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'epic', 'soft', 'soft', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'The Bone Clocks';
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Bone Clocks';
insert into book_tropes (book_id, trope_id) select id, 'reincarnated_protagonist' from books where title = 'The Bone Clocks';
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Bone Clocks';
insert into book_tropes (book_id, trope_id) select id, 'multi_generational_saga' from books where title = 'The Bone Clocks';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Bone Clocks';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Bone Clocks';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'The Bone Clocks';
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Bone Clocks' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Bone Clocks' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Bone Clocks' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.5, 'ai_inferred' from books where title = 'The Bone Clocks' on conflict (book_id, field_name) do nothing;
