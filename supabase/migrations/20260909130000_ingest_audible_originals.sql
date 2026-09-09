-- Ingests the 3 confirmed Sub-task B (Audible Originals) candidates --
-- audio-only full-cast dramas with no print/ebook counterpart at all,
-- see .claude/skills/tag-audiobook-editions/SKILL.md and docs/TODO.md's
-- Sub-task B entry for the discovery/scope-decision history. Both open
-- scope questions (Zero G's age category, The Left Right Game's genre
-- fit + print-origin ambiguity) were resolved by the repo owner
-- 2026-09-09 -- both are IN.
--
-- Researched each via web search (cast, runtime, plot, series status)
-- rather than relying on memory, same standard as any other tagging
-- work. Several fields flagged via book_field_confidence where the
-- source material (audio drama press coverage, not a reviewed novel)
-- left genuine ambiguity -- these are less-documented works than a
-- typical novel, so more flagged uncertainty than usual is expected,
-- not a shortcut.
--
-- books.work_type = 'audio_original' (not 'novel'/'novella') per the
-- 20260907140000 migration. book_length/page_count left NULL -- no
-- print form exists. form = 'script_or_stage_play' for all three --
-- full-cast dramatized scripts, not literary prose, so prose_density/
-- prose_complexity are also left NULL as inapplicable.

-- The Salvation (Justin Lockey, 2023) -- 8-part time-travel sci-fi thriller
insert into books (title, author, work_type, publication_year)
select 'The Salvation', 'Justin Lockey', 'audio_original', 2023
where not exists (select 1 from books where title = 'The Salvation' and author = 'Justin Lockey');

insert into book_dna (
  book_id, genre, age_category, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'single', 'third_limited', 'reliable', 'nonlinear', 'script_or_stage_play', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'light', 'self_contained', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.4, 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrative_closure', 0.5, 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'audiobook_length', 0.5, 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'time_travel', 'ai_inferred' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity)
select id, 'war_trauma', 'moderate' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity)
select id, 'mental_illness_depiction', 'moderate' from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, warning_id) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, release_status, parts_released, parts_total, source_url, last_verified_date)
select id, 'dramatized_full_cast', array['Ariyon Bakare','Rose Leslie','Olafur Olafsson','Toby Jones'], 'Audible Originals', 'fully_released', 8, 8, 'https://www.audible.com/pd/The-Salvation-Podcast/B0CK8RZ2GR', current_date
from books where title = 'The Salvation' and author = 'Justin Lockey'
on conflict (book_id, source_url) do nothing;

-- Zero G (Dan Wells, 2018) -- middle-grade sci-fi caper, The Zero Chronicles #1 of 3
insert into books (title, author, work_type, publication_year, audiobook_duration_minutes)
select 'Zero G', 'Dan Wells', 'audio_original', 2018, 248
where not exists (select 1 from books where title = 'Zero G' and author = 'Dan Wells');

insert into book_dna (
  book_id, genre, age_category, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'middle_grade', 'single', 'third_limited', 'reliable', 'linear', 'script_or_stage_play', 'fast', 'consistent', 'plot_driven', 'light', 'moderate', 'tense', 'subtle', 'none', 'na', 'occasional', 'mild', 'moderate', 'requires_series', 'happy', 'resolved', 'short', 'na', 'soft', 'escapist', 'regional', 'high', 'gateway'
from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_register', 0.5, 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'genre_accessibility', 0.5, 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'cryosleep', 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'terraforming_or_space_colonization', 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'generation_ship', 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'survivalist_ingenuity', 0.6, 'ai_inferred' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity)
select id, 'kidnapping_or_captivity', 'moderate' from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, warning_id) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, release_status, parts_released, parts_total, source_url, last_verified_date)
select id, 'dramatized_full_cast', array['Emily Woo Zeller','Margaret Ying Drake','Betsy Hogg','Josh Hurley','Jonathan Davis','Jennifer Van Dyck','Chelsea Spack','Charlie Thurston','David Shih','Eunice Wong','Eddy Lee','Allyson Johnson','Polly Lee'], 'Audible Originals', 248, 'fully_released', 1, 1, 'https://www.audible.com/pd/Zero-G-Audiobook/B07K4VYQ5X', current_date
from books where title = 'Zero G' and author = 'Dan Wells'
on conflict (book_id, source_url) do nothing;

-- The Left Right Game (Jack Anderson/QCode/Legion M, 2020) -- sci-fi horror, alternate-reality mechanism
insert into books (title, author, work_type, publication_year)
select 'The Left Right Game', 'Jack Anderson', 'audio_original', 2020
where not exists (select 1 from books where title = 'The Left Right Game' and author = 'Jack Anderson');

insert into book_dna (
  book_id, genre, age_category, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'single', 'third_limited', 'ambiguous', 'nonlinear', 'script_or_stage_play', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'none', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'soft', 'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pace_shape', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'violence_intensity', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrative_closure', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'audiobook_length', 0.5, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'parallel_universe_or_multiverse', 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'cosmic_horror', 0.6, 'ai_inferred' from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, trope_id) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, release_status, parts_released, parts_total, source_url, last_verified_date)
select id, 'dramatized_full_cast', array['Tessa Thompson','W. Earl Brown','Aml Ameen','Dayo Okeniyi','Inanna Sarkis'], 'QCODE', 'fully_released', 10, 10, 'https://www.audible.com/podcast/The-Left-Right-Game/B08K593D3Y', current_date
from books where title = 'The Left Right Game' and author = 'Jack Anderson'
on conflict (book_id, source_url) do nothing;
