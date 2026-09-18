-- Backfill the remaining book_dna.audiobook_length rows that
-- 20260913090000_backfill_audiobook_length_from_editions.sql
-- deliberately left null: books with more than one 'standard'-edition
-- audiobook_editions runtime (different narrators/publishers), where
-- that migration didn't want to guess which edition's runtime should
-- count as "the" canonical length.
--
-- Re-checked 2026-09-18: of the books currently in this state (14, not
-- the 18 from 2026-09-13 -- the catalog/tagging state has moved since
-- then), EVERY one resolves to the SAME docs/schema/book-dna.schema.yaml
-- bucket (short <8h, standard 8-15h, long 15-25h, epic 25h+) regardless
-- of which standard edition's runtime is used -- verified programmatically,
-- not eyeballed. This is genuinely mechanical, not a per-book judgment
-- call: no case here actually straddles a bucket boundary, so there is
-- no "which edition is canonical" question to answer. Title-scoped
-- (never a raw UUID), all 14 titles confirmed unique in `books` first.

-- A Wizard of Earthsea: runtimes [360, 420, 438] minutes (6.00h, 7.00h, 7.30h) -> all 'short'
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'A Wizard of Earthsea')
  and audiobook_length is null;
-- Assassin's Apprentice: runtimes [995, 1039] minutes (16.58h, 17.32h) -> all 'long'
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'Assassin''s Apprentice')
  and audiobook_length is null;
-- Foundation: runtimes [517, 536] minutes (8.62h, 8.93h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Foundation')
  and audiobook_length is null;
-- Frankenstein: runtimes [515, 534] minutes (8.58h, 8.90h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Frankenstein')
  and audiobook_length is null;
-- Harry Potter and the Chamber of Secrets: runtimes [580, 583] minutes (9.67h, 9.72h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Harry Potter and the Chamber of Secrets')
  and audiobook_length is null;
-- Harry Potter and the Goblet of Fire: runtimes [1214, 1236] minutes (20.23h, 20.60h) -> all 'long'
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'Harry Potter and the Goblet of Fire')
  and audiobook_length is null;
-- Harry Potter and the Order of the Phoenix: runtimes [1599, 1745] minutes (26.65h, 29.08h) -> all 'epic'
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'Harry Potter and the Order of the Phoenix')
  and audiobook_length is null;
-- Neuromancer: runtimes [513, 632] minutes (8.55h, 10.53h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Neuromancer')
  and audiobook_length is null;
-- Slaughterhouse-Five: runtimes [313, 360] minutes (5.22h, 6.00h) -> all 'short'
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'Slaughterhouse-Five')
  and audiobook_length is null;
-- The Eye of the World: runtimes [1794, 1975] minutes (29.90h, 32.92h) -> all 'epic'
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'The Eye of the World')
  and audiobook_length is null;
-- The Left Hand of Darkness: runtimes [580, 607] minutes (9.67h, 10.12h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Left Hand of Darkness')
  and audiobook_length is null;
-- The Return of the King: runtimes [1099, 1312] minutes (18.32h, 21.87h) -> all 'long'
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'The Return of the King')
  and audiobook_length is null;
-- The Three-Body Problem: runtimes [806, 833, 887] minutes (13.43h, 13.88h, 14.78h) -> all 'standard'
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Three-Body Problem')
  and audiobook_length is null;
-- The Will of the Many: runtimes [1694, 1723] minutes (28.23h, 28.72h) -> all 'epic'
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'The Will of the Many')
  and audiobook_length is null;
