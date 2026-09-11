-- First batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item, approach decided 2026-09-11: manually
-- verify+fix the most-viewed/highest-profile series first, real
-- publication status via search, same standard as the 5 series already
-- fixed 2026-09-08).
--
-- Root cause (documented 2026-09-08, unchanged): `status` defaults to
-- 'ongoing' whenever Hardcover's `is_completed` flag isn't explicitly
-- true; `book_count` is Hardcover's raw per-series edition/omnibus/
-- box-set count, not a curated mainline-installment number.
--
-- Batch selection: the 14 highest-profile 'ongoing'-status series by
-- our own catalog's book count (excluding the 5 already fixed
-- 2026-09-08), each individually verified via live search against
-- real-world publication status before any value was written here --
-- no guessing. One candidate checked (A Court of Thorns and Roses) was
-- already correct and needed no fix, so isn't in this file.
--
-- book_count convention (matching the 2026-09-08 precedent): count
-- real PUBLISHED mainline installments only -- not companion novellas/
-- short-story collections (Powder Mage's "Forsworn", Arc of a Scythe's
-- "Gleanings"), not unpublished forthcoming books (A Song of Ice and
-- Fire's The Winds of Winter, Red Rising Saga's Red God, The Kingkiller
-- Chronicle's The Doors of Stone -- all confirmed still unpublished as
-- of 2026-09-11), regardless of whether that unpublished/companion
-- title already has its own row in our `books`/`series` tables.

-- The Demon Cycle (Peter V. Brett) -- 5 novels, series completed 2017
-- with The Core. Was 'ongoing'/47 (47 clearly a raw Hardcover
-- edition/format count, not a book count).
update series set status = 'completed', book_count = 5
where name = 'The Demon Cycle';

-- Powder Mage (Brian McClellan) -- Promise of Blood/The Crimson
-- Campaign/The Autumn Republic, a completed trilogy (2013-2015);
-- "Forsworn" is a companion novella, not counted. Was 'ongoing'/35.
-- Note: this is distinct from McClellan's separate sequel trilogy
-- "Gods of Blood and Powder" (Sins of Empire and after), which is a
-- different series entirely, not this row.
update series set status = 'completed', book_count = 3
where name = 'Powder Mage';

-- Bobiverse (Dennis E. Taylor) -- still ongoing; 6th book "The Infinite
-- Extent" published 2026-09-10 (confirmed via search), not yet in our
-- catalog. Book 7 confirmed planned as the last in the main timeline,
-- not yet published. Was book_count=5 (matching our catalog's current
-- 5 tagged books, not the real published count).
update series set book_count = 6
where name = 'Bobiverse';

-- Red Rising Saga (Pierce Brown) -- 6 published (Red Rising through
-- Light Bringer); the 7th and final book "Red God" confirmed still
-- unfinished as of March 2026 (author's own statement), missed its
-- intended 2026 release. Was book_count=7 (prematurely counting the
-- unpublished final book).
update series set book_count = 6
where name = 'Red Rising Saga';

-- The Murderbot Diaries (Martha Wells) -- 8 main-numbered
-- novellas/novels published through Platform Decay (2026-05), matching
-- our own catalog's current 8 main-position rows exactly (0.5/4.5
-- entries are separate short stories, not counted). Was book_count=7.
update series set book_count = 8
where name = 'The Murderbot Diaries';

-- The Lunar Chronicles (Marissa Meyer) -- Cinder/Scarlet/Cress/Winter,
-- a completed 4-book series; companion material (Fairest, Stars Above,
-- graphic novels) not counted. Was 'ongoing'/17.
update series set status = 'completed', book_count = 4
where name = 'The Lunar Chronicles';

-- The Licanius Trilogy (James Islington) -- 3 books, completed 2019.
-- Was 'ongoing'/4.
update series set status = 'completed', book_count = 3
where name = 'The Licanius Trilogy';

-- The Red Queen's War (Mark Lawrence) -- 3 books, completed. Was
-- 'ongoing'/8.
update series set status = 'completed', book_count = 3
where name = 'The Red Queen''s War';

-- Arc of a Scythe (Neal Shusterman) -- Scythe/Thunderhead/The Toll, a
-- completed trilogy; "Gleanings" is a companion short-story
-- collection, not counted. Was 'ongoing'/6.
update series set status = 'completed', book_count = 3
where name = 'Arc of a Scythe';

-- A Song of Ice and Fire (George R.R. Martin) -- 5 published (A Game
-- of Thrones through A Dance with Dragons); The Winds of Winter
-- confirmed still unpublished. Was book_count=7.
update series set book_count = 5
where name = 'A Song of Ice and Fire';

-- Ender's Saga (Orson Scott Card) -- the original 4-book "Ender
-- Quartet" (Ender's Game/Speaker for the Dead/Xenocide/Children of the
-- Mind), published 1985-1996, a completed, self-contained set distinct
-- from the later-added "Ender Quintet" (which adds Ender in Exile, a
-- different book not in this catalog series). book_count already
-- correct at 4; only status was wrong.
update series set status = 'completed'
where name = 'Ender''s Saga';

-- The Kingkiller Chronicle (Patrick Rothfuss) -- 2 published (The Name
-- of the Wind, The Wise Man's Fear); The Doors of Stone confirmed still
-- unpublished as of August 2026 (no confirmed release date). "The Slow
-- Regard of Silent Things" is a companion novella, not counted. Was
-- book_count=3 (prematurely counting the unpublished third book).
update series set book_count = 2
where name = 'The Kingkiller Chronicle';

-- Crescent City (Sarah J. Maas) -- 3 published; a 4th confirmed
-- happening but with no announced date. Was book_count=20 (clearly a
-- raw Hardcover edition/format count).
update series set book_count = 3
where name = 'Crescent City';

-- Dungeon Crawler Carl (Matt Dinniman) -- 8 published through "A
-- Parade of Horribles" (2026), matching our own catalog's current 8
-- rows exactly; 2 more confirmed planned to complete the series. Was
-- book_count=12.
update series set book_count = 8
where name = 'Dungeon Crawler Carl';
