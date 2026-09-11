-- Second batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_fix_series_status_book_count_batch1.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: re-ran the same ranking query as batch 1 (our own
-- catalog's book-count-per-series, the only available profile proxy),
-- excluding the 19 already-fixed + 1 already-correct series from
-- batch 1. Worked down the resulting ~181-series pool by that ranking
-- and verified each via live web search before writing anything --
-- no guessing, same standard as batch 1. 14 needed a real fix (see
-- per-series comments below); several high-ranking candidates checked
-- along the way turned out already correct and are NOT in this file:
-- Discworld, The Expanse, The Wheel of Time, Throne of Glass, Foundation,
-- Harry Potter, The Chronicles of Narnia (Publication Order), The Dark
-- Tower, Dune, The Mortal Instruments, Stormlight Archive Era One,
-- Robot, Mistborn Era One, The Maze Runner, Hainish Cycle, The
-- Hitchhiker's Guide to the Galaxy.
--
-- book_count convention (matching batch 1 / the 2026-09-08 precedent):
-- count real PUBLISHED mainline installments only -- not companion
-- novellas/short-story collections, not unpublished forthcoming books,
-- regardless of whether an unpublished/companion title already has its
-- own row in our books/series tables.

-- Malazan Book of the Fallen (Steven Erikson) -- 10 novels (Gardens of
-- the Moon through The Crippled God), published 1999-2011, completed;
-- status was already correct. Was book_count=34, clearly a raw
-- Hardcover edition/format count (real count includes Esslemont's
-- separate Malazan Empire novels, translations, omnibuses, etc.).
update series set book_count = 10
where name = 'Malazan Book of the Fallen';

-- The Culture (Iain M. Banks) -- 10 works (Consider Phlebas, The Player
-- of Games, Use of Weapons, The State of the Art, Excession, Inversions,
-- Look to Windward, Matter, Surface Detail, The Hydrogen Sonata),
-- 1987-2012, completed (Banks died 2013); status was already correct.
-- Was book_count=17.
update series set book_count = 10
where name = 'The Culture';

-- Lightbringer (Brent Weeks) -- 5 books (The Black Prism through The
-- Burning White), completed 2019; status was already correct. Was
-- book_count=13 (a raw Hardcover edition/format count).
update series set book_count = 5
where name = 'Lightbringer';

-- The Heroes of Olympus (Rick Riordan) -- 5 books (The Lost Hero
-- through The Blood of Olympus), 2010-2014, completed; status was
-- already correct. Was book_count=9.
update series set book_count = 5
where name = 'The Heroes of Olympus';

-- Skyward (Brandon Sanderson) -- 4 main novels (Skyward, Starsight,
-- Cytonic, Defiant), completed 2023; status was already correct. Was
-- book_count=15 (novellas Sunreach/ReDawn/Evershore/Nightfarer are
-- companion material, not counted, same convention as elsewhere).
update series set book_count = 4
where name = 'Skyward';

-- The Reckoners (Brandon Sanderson) -- 3 books (Steelheart, Firefight,
-- Calamity), completed 2016; "Mitosis" is a companion novelette, not
-- counted. Was 'ongoing'/7.
update series set status = 'completed', book_count = 3
where name = 'The Reckoners';

-- Mars Trilogy (Kim Stanley Robinson) -- 3 books (Red Mars, Green Mars,
-- Blue Mars), completed 1996; status was already correct. Was
-- book_count=10 (a raw Hardcover edition/format count; "The Martians"
-- short-story collection not counted).
update series set book_count = 3
where name = 'Mars Trilogy';

-- The Sun Eater (Christopher Ruocchio) -- 7 main novels (Empire of
-- Silence through Shadows Upon Time, 2018-2025); Shadows Upon Time
-- confirmed via search as the 7th and final novel, completing Hadrian
-- Marlowe's main saga (side material in the universe may continue, but
-- the main numbered sequence is done). Was 'ongoing'/17.
update series set status = 'completed', book_count = 7
where name = 'The Sun Eater';

-- Imperial Radch (publication order) (Ann Leckie) -- 6 books (Ancillary
-- Justice, Ancillary Sword, Ancillary Mercy, Provenance, Translation
-- State, Radiant Star [May 2026]), all set in the same Goodreads-
-- grouped series; status already correctly 'ongoing' (Leckie has kept
-- adding standalones to this universe periodically with no announced
-- end). Was book_count=9.
update series set book_count = 6
where name = 'Imperial Radch (publication order)';

-- Percy Jackson and the Olympians (Rick Riordan) -- 7 published books:
-- the original pentalogy (The Lightning Thief through The Last
-- Olympian) plus The Chalice of the Gods (2023) and Wrath of the Triple
-- Goddess (2024), both officially numbered/branded entries in this same
-- series (the "Senior Year Adventures" sub-arc), not a separate series.
-- A third Senior Year book is confirmed planned (Riordan has publicly
-- committed to finishing the trilogy) but not yet released as of
-- 2026-09-12, so not counted. Was 'completed'/5 -- wrong on both axes:
-- status was stale (the series kept growing past the original 5) and
-- book_count undercounted even the currently-published total.
update series set status = 'ongoing', book_count = 7
where name = 'Percy Jackson and the Olympians';

-- Shatter Me (Tahereh Mafi) -- 6 core novels (Shatter Me through
-- Imagine Me, 2011-2020), completed; status was already correct.
-- "Shatter Me: The New Republic" (Watch Me/Release Me/Escape Me,
-- 2025-2026) confirmed via search as a separate spin-off series (new
-- protagonists, set 10 years later), not a continuation of this one --
-- companion novellas (Destroy Me, Fracture Me, etc.) also not counted.
-- Was book_count=23 (a raw Hardcover edition/format count).
update series set book_count = 6
where name = 'Shatter Me';

-- The Witcher (Andrzej Sapkowski) -- 9 published books (2 short-story
-- collections + Season of Storms + the 5-book saga + Crossroads of
-- Ravens, English translation 2025-09-30); status corrected to
-- 'ongoing' -- Sapkowski publicly reaffirmed in a 2025-06 interview
-- that he intends to keep writing Witcher books ("unlike George R.R.
-- Martin, when I say I'll write something, I will"), a real, recent,
-- on-the-record commitment, not the vaguer 2023 statement alone. Was
-- 'completed'/8 (Crossroads of Ravens not yet reflected).
update series set status = 'ongoing', book_count = 9
where name = 'The Witcher';

-- Old Man's War (John Scalzi) -- 7 published books (Old Man's War
-- through The Shattering Peace, 2025); status left as 'completed' --
-- deliberately NOT changed to 'ongoing' despite The Shattering Peace's
-- open-ended plot threads, because the only evidence found for a book 8
-- is Scalzi's own conditional "I might write another if people like
-- this one," not a confirmed commitment (contrast the Witcher and
-- Percy Jackson cases above, both of which have an on-the-record
-- commitment). Flagged in the batch report rather than guessed. Was
-- book_count=6.
update series set book_count = 7
where name = 'Old Man''s War';

-- The Twilight Saga (Stephenie Meyer) -- 5 books: Twilight, New Moon,
-- Eclipse, Breaking Dawn, and Midnight Sun (2020, officially published
-- and numbered as Saga #5, unlike the Kingkiller/Hitchhiker's-Guide
-- precedent of a different author's unofficial continuation not being
-- counted); completed. "The Short Second Life of Bree Tanner" is a
-- companion novella, not counted. Was book_count=4.
update series set book_count = 5
where name = 'The Twilight Saga';
