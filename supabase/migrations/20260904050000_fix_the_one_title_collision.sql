-- Data-quality bug found while starting the next tagging batch: the catalog
-- has two different books both titled exactly "The One" -- Kiera Cass's
-- Selection #3, and John Marrs's unrelated adult sci-fi thriller about a
-- DNA soulmate-matching test. The previous batch's tagging script built its
-- title->book_id lookup as a plain dict keyed on normalized title, so the
-- second "The One" row silently overwrote the first in that dict -- Kiera
-- Cass's Book DNA (love_triangle, dystopia, YA, romance_driven, etc.) ended
-- up applied to John Marrs's book_id instead, and Cass's own book was left
-- completely untagged despite the script reporting it as tagged. A single
-- shared-title collision, not a wider pattern -- the other 19 titles in
-- that batch were checked and are unique.
--
-- Fixed by scoping every statement to title + author together (title alone
-- is provably ambiguous for this specific pair, but the pair is unique) --
-- portable across local/hosted like every other migration in this project,
-- no raw UUIDs. Removed the misapplied tropes/CWs/book_dna row from John
-- Marrs's book, then inserted correct, book-specific Book DNA for both
-- titles -- Marrs's book tagged with its own real content (DNA-match
-- thriller, ensemble POV, adult), Cass's book tagged with what was
-- originally intended for it.

delete from book_tropes
where book_id = (select id from books where title = 'The One' and author = 'John Marrs');
delete from book_content_warnings
where book_id = (select id from books where title = 'The One' and author = 'John Marrs');
delete from book_field_confidence
where book_id = (select id from books where title = 'The One' and author = 'John Marrs');
delete from book_dna
where book_id = (select id from books where title = 'The One' and author = 'John Marrs');

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'adult', 'standard', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven',
  'dark', 'light', 'gut_punch', 'heavy_handed',
  'occasional', 'moderate', 'occasional',
  'graphic', 'light', 'self_contained',
  'tragic', 'resolved', 'standard',
  'na', 'soft', 'sparse', 'accessible',
  'moderate', 'intimate', 'life_threatening', 'accessible'
from books where title = 'The One' and author = 'John Marrs'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t.trope_id
from books, unnest(array['twist_ending', 'soulmate_bond', 'villain_protagonist']) as t(trope_id)
where title = 'The One' and author = 'John Marrs'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'stalking', 'moderate', false from books where title = 'The One' and author = 'John Marrs'
on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The One' and author = 'John Marrs'
on conflict do nothing;

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select id, array['sci_fi'], 'ya', 'standard', 'single', 'first',
  'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven',
  'light', 'moderate', 'bittersweet', 'subtle',
  'frequent', 'low', 'occasional',
  'moderate', 'light', 'self_contained',
  'happy', 'resolved', 'standard',
  'na', 'soft', 'sparse', 'accessible',
  'escapist', 'intimate', 'high', 'gateway'
from books where title = 'The One' and author = 'Kiera Cass'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t.trope_id
from books, unnest(array['love_triangle', 'dystopia', 'underdog_rising', 'major_character_death']) as t(trope_id)
where title = 'The One' and author = 'Kiera Cass'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'central_theme', false from books where title = 'The One' and author = 'Kiera Cass'
on conflict do nothing;
