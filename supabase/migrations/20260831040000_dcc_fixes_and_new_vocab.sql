-- External reader feedback (2026-08-31), second round:
--
-- 1. Dungeon Crawler Carl was tagged person = 'third_limited' but the book is
--    narrated in first person by Carl throughout -- one of the series'
--    defining stylistic features (his sarcastic first-person voice). Clear
--    factual error, fixed directly.
--
-- 2. Dungeon Crawler Carl was tagged narrator_reliability = 'reliable', but
--    the reader reports it's genuinely left up to interpretation. Rather than
--    force a binary reliable/unreliable choice, add 'ambiguous' as a third
--    value (see book-dna.schema.yaml for the definition distinguishing it
--    from 'unreliable') and retag this book with it.
--
-- 3. Add multiple_alien_species trope (sci-fi analog to
--    multiple_fantasy_species) -- confirmed no existing trope covers "several
--    distinct alien species/civilizations coexisting in the setting" and
--    Empire of Silence is a clear example. Apply it there.

alter table book_dna drop constraint book_dna_narrator_reliability_check;
alter table book_dna add constraint book_dna_narrator_reliability_check
  check (narrator_reliability in ('reliable', 'unreliable', 'ambiguous'));

update book_dna set person = 'first', narrator_reliability = 'ambiguous'
where book_id = (select id from books where title = 'Dungeon Crawler Carl');

insert into tropes (id, group_name, spoiler) values
  ('multiple_alien_species', 'scifi_specific', false);

insert into book_tropes (book_id, trope_id)
values ((select id from books where title = 'Empire of Silence'), 'multiple_alien_species');
