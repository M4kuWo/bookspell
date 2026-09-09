-- Catalog tagging batch 2: 15 untagged standalone books
-- (Turton, Erlick, Nayler, Ende, Poston, Hendrix, Jimenez, Cutter, Young,
-- Mandanna, Chambers, Klune, Crouch, Hart, McAllister)
-- Tagged per .claude/skills/tag-catalog-batch/SKILL.md Step 3. Every nullable
-- book_dna column filled in per the skill's silent-partial-insert warning.
-- Idempotent (on conflict do nothing), title+author-scoped throughout.

-- Author-field contamination fixes, caught during this batch's mandatory
-- author-verification check (CLAUDE.md's data-quality section) -- same
-- scoped-UPDATE pattern as 20260909040000_fix_white_night_author_contamination.sql.
-- The Measure's audiobook narrator (Julia Whelan, confirmed via Audible/Amazon
-- listing) had been pulled into the author field alongside the real author.
update books set author = 'Nikki Erlick'
where title = 'The Measure' and author = 'Nikki Erlick, Julia Whelan';

-- The Neverending Story's author field carried both the English translator
-- (Ralph Manheim) and the original German edition's calligrapher/illustrator
-- (Roswitha Quadflieg, who gave the book its two-color red/green typesetting
-- and chapter-opening artwork) -- neither is an author of the work itself.
update books set author = 'Michael Ende'
where title = 'The Neverending Story' and author = 'Michael Ende, Ralph Manheim, Roswitha Quadflieg';

-- ============ The Last Murder at the End of the World (Stuart Turton) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'post_apocalyptic', 'ai_inferred' from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'ai_consciousness', 'ai_inferred' from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'dystopia', 'ai_inferred' from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'noir_detective_structure', 'ai_inferred' from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'twist_ending', 'ai_inferred', 0.6 from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'last_minute_rescue', 'ai_inferred', 0.4 from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'brief', false from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'The Last Murder at the End of the World' and author = 'Stuart Turton'
on conflict (book_id, field_name) do nothing;


-- ============ The Measure (Nikki Erlick) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'none', 'na', 'moderate', 'accessible', 'moderate', 'global', 'moderate', 'accessible'
from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'found_family', 'ai_inferred', 0.5 from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'major_character_death', 'ai_inferred' from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'underdog_rising', 'ai_inferred', 0.5 from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'twist_ending', 'ai_inferred', 0.4 from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'central_theme', false from books where title = 'The Measure' and author = 'Nikki Erlick'
on conflict (book_id, warning_id) do nothing;


-- ============ The Mountain in the Sea (Ray Nayler) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'worldbuilding_driven', 'moderate', 'none', 'tense', 'moderate', 'none', 'na', 'occasional', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'moderate', 'dense', 'cerebral', 'global', 'high', 'veteran_only'
from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'ai_consciousness', 'ai_inferred' from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'android_or_replicant_rights', 'ai_inferred' from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'uplift', 'ai_inferred', 0.5 from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'first_contact', 'ai_inferred', 0.6 from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'hive_mind', 'ai_inferred', 0.4 from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'central_theme', false from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'trafficking', 'moderate', false from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.6, 'ai_inferred' from books where title = 'The Mountain in the Sea' and author = 'Ray Nayler'
on conflict (book_id, field_name) do nothing;


-- ============ The Neverending Story (Michael Ende) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'middle_grade', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'framing_device', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'global', 'high', 'accessible'
from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'portal_fantasy', 'ai_inferred' from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'chosen_one', 'ai_inferred', 0.6 from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'coming_of_age', 'ai_inferred' from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'epic_quest', 'ai_inferred' from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'long_journey', 'ai_inferred' from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'mythological_pantheon_as_characters', 'ai_inferred', 0.5 from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, trope_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'age_category', 0.5, 'ai_inferred' from books where title = 'The Neverending Story' and author = 'Michael Ende'
on conflict (book_id, field_name) do nothing;


-- ============ The Seven Year Slip (Ashley Poston) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'light', 'moderate', 'bittersweet', 'subtle', 'occasional', 'moderate', 'none', 'na', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'low', 'gateway'
from books where title = 'The Seven Year Slip' and author = 'Ashley Poston'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'The Seven Year Slip' and author = 'Ashley Poston'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'slow_burn_romance', 'ai_inferred', 0.6 from books where title = 'The Seven Year Slip' and author = 'Ashley Poston'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'found_family', 'ai_inferred', 0.5 from books where title = 'The Seven Year Slip' and author = 'Ashley Poston'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'grumpy_sunshine', 'ai_inferred', 0.5 from books where title = 'The Seven Year Slip' and author = 'Ashley Poston'
on conflict (book_id, trope_id) do nothing;


-- ============ The Southern Book Club's Guide to Slaying Vampires (Grady Hendrix) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'moderate', 'gut_punch', 'heavy_handed', 'rare', 'low', 'frequent', 'brutal', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'vampires', 'ai_inferred' from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'underdog_rising', 'ai_inferred', 0.5 from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'black_and_white_morality', 'ai_inferred', 0.5 from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'survivalist_ingenuity', 'ai_inferred', 0.5 from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'revenge', 'ai_inferred', 0.4 from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'central_theme', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'moderate', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'central_theme', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'moderate', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'suicide', 'moderate', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'brief', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'The Southern Book Club''s Guide to Slaying Vampires' and author = 'Grady Hendrix'
on conflict (book_id, warning_id) do nothing;


-- ============ The Spear Cuts Through Water (Simon Jimenez) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'several', 'mixed', 'reliable', 'nonlinear', 'framing_device', 'slow', 'uneven', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'frequent', 'graphic', 'dense', 'self_contained', 'bittersweet', 'resolved', 'long', 'soft', 'na', 'lush', 'dense', 'cerebral', 'global', 'life_threatening', 'veteran_only'
from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'mythological_pantheon_as_characters', 'ai_inferred', 0.6 from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'epic_quest', 'ai_inferred' from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'revenge', 'ai_inferred', 0.5 from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'forbidden_love', 'ai_inferred' from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'mlm_romance', 'ai_inferred' from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Spear Cuts Through Water' and author = 'Simon Jimenez'
on conflict (book_id, field_name) do nothing;


-- ============ The Troop (Nick Cutter) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'several', 'third_omniscient', 'reliable', 'nonlinear', 'framing_device', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'subtle', 'none', 'na', 'frequent', 'brutal', 'light', 'self_contained', 'tragic', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'survivalist_ingenuity', 'ai_inferred' from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'coming_of_age', 'ai_inferred', 0.5 from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'black_and_white_morality', 'ai_inferred', 0.4 from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'twist_ending', 'ai_inferred', 0.4 from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'central_theme', false from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', false from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'moderate', false from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'suicide', 'moderate', false from books where title = 'The Troop' and author = 'Nick Cutter'
on conflict (book_id, warning_id) do nothing;


-- ============ The Unmaking of June Farrow (Adrienne Young) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'ambiguous', 'multi_timeline', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'rare', 'mild', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'hidden_identity_romance', 'ai_inferred', 0.5 from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'forbidden_love', 'ai_inferred', 0.5 from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'amnesia_driven_narrative', 'ai_inferred', 0.5 from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'underdog_rising', 'ai_inferred', 0.4 from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'mental_illness_depiction', 'central_theme', false from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Unmaking of June Farrow' and author = 'Adrienne Young'
on conflict (book_id, field_name) do nothing;


-- ============ The Very Secret Society of Irregular Witches (Sangu Mandanna) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'occasional', 'low', 'rare', 'mild', 'light', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'low', 'gateway'
from books where title = 'The Very Secret Society of Irregular Witches' and author = 'Sangu Mandanna'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'The Very Secret Society of Irregular Witches' and author = 'Sangu Mandanna'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'slow_burn_romance', 'ai_inferred', 0.6 from books where title = 'The Very Secret Society of Irregular Witches' and author = 'Sangu Mandanna'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'grumpy_sunshine', 'ai_inferred', 0.5 from books where title = 'The Very Secret Society of Irregular Witches' and author = 'Sangu Mandanna'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'underdog_rising', 'ai_inferred', 0.4 from books where title = 'The Very Secret Society of Irregular Witches' and author = 'Sangu Mandanna'
on conflict (book_id, trope_id) do nothing;


-- ============ To Be Taught, If Fortunate (Becky Chambers) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'epistolary', 'slow', 'consistent', 'character_driven', 'light', 'light', 'bittersweet', 'moderate', 'none', 'na', 'none', 'na', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'hard', 'moderate', 'moderate', 'cerebral', 'intimate', 'moderate', 'moderate'
from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'relativistic_time_dilation', 'ai_inferred' from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'cryosleep', 'ai_inferred' from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'survivalist_ingenuity', 'ai_inferred', 0.5 from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id, trope_id) do nothing;


-- ============ Under the Whispering Door (TJ Klune) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'occasional', 'closed_door', 'none', 'na', 'moderate', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'found_family', 'ai_inferred' from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'mlm_romance', 'ai_inferred' from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'grumpy_sunshine', 'ai_inferred', 0.5 from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'shadow_self_confrontation', 'ai_inferred', 0.5 from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'suicide', 'moderate', false from books where title = 'Under the Whispering Door' and author = 'TJ Klune'
on conflict (book_id, warning_id) do nothing;


-- ============ Upgrade (Blake Crouch) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'heavy_handed', 'none', 'na', 'frequent', 'graphic', 'moderate', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'hard', 'sparse', 'accessible', 'cerebral', 'global', 'life_threatening', 'accessible'
from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'cybernetic_enhancement', 'ai_inferred' from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'post_apocalyptic', 'ai_inferred', 0.5 from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'species_divergence', 'ai_inferred', 0.5 from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'survivalist_ingenuity', 'ai_inferred', 0.5 from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'corruption_arc', 'ai_inferred', 0.4 from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'Upgrade' and author = 'Blake Crouch'
on conflict (book_id, warning_id) do nothing;


-- ============ Weyward (Emilia Hart) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'mixed', 'reliable', 'multi_timeline', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'none', 'bittersweet', 'moderate', 'rare', 'low', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'multi_generational_saga', 'ai_inferred' from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'telepathic_animal_bond', 'ai_inferred', 0.6 from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'underdog_rising', 'ai_inferred', 0.5 from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'found_family', 'ai_inferred', 0.4 from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'coming_of_age', 'ai_inferred', 0.4 from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'central_theme', false from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'stalking', 'moderate', false from books where title = 'Weyward' and author = 'Emilia Hart'
on conflict (book_id, warning_id) do nothing;


-- ============ Wrong Place Wrong Time (Gillian McAllister) ============
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'nonlinear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'none', 'tense', 'moderate', 'none', 'na', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'sparse', 'accessible', 'moderate', 'intimate', 'life_threatening', 'gateway'
from books where title = 'Wrong Place Wrong Time' and author = 'Gillian McAllister'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'Wrong Place Wrong Time' and author = 'Gillian McAllister'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'noir_detective_structure', 'ai_inferred', 0.5 from books where title = 'Wrong Place Wrong Time' and author = 'Gillian McAllister'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source, confidence)
select id, 'twist_ending', 'ai_inferred', 0.5 from books where title = 'Wrong Place Wrong Time' and author = 'Gillian McAllister'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'domestic_abuse', 'moderate', false from books where title = 'Wrong Place Wrong Time' and author = 'Gillian McAllister'
on conflict (book_id, warning_id) do nothing;

