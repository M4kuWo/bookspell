-- Third batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batch 2 landed
-- 2026-09-12 in 20260912100000_..._batch2.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: re-ran the same ranking query as batches 1-2 (our
-- own catalog's book-count-per-series, the only available profile
-- proxy), excluding the 50 already-checked names from both prior
-- batches. The catalog grew significantly since batch 2 (a 378-book/
-- 118-series ingestion round landed 2026-09-12), so most new-series
-- rows only have 3-4 books currently linked in our own catalog --
-- worked the resulting ties in the order the query returned them, not
-- a meaningful ranking distinction at that tie level. 17 needed a real
-- fix (see per-series comments below), verified via live web search
-- before writing anything, same standard as batches 1-2.
--
-- book_count convention (matching batches 1-2 / the 2026-09-08
-- precedent): count real PUBLISHED mainline installments only -- not
-- companion novellas/short-story collections, not unpublished
-- forthcoming books, regardless of whether an unpublished/companion
-- title already has its own row in our books/series tables.
--
-- Candidates checked this batch and confirmed already correct (NOT in
-- this file): none this round -- every top candidate by the ranking
-- query turned out to need at least a book_count fix. Candidates seen
-- in the ranked list but NOT researched (left for batch 4, no
-- assumption made either way): The First Law, His Dark Materials,
-- Book of the Ancestor, The Broken Empire, Divergent, The Folk of the
-- Air, The Green Bone Saga, Skyward Flight, The Shadow and Bone
-- Trilogy, The Poppy War, Silo, Monk and Robot, Time Master, Children
-- of Time, The Locked Tomb, MaddAddam, Southern Reach, The Hunger
-- Games, The Inheritance Games, He Who Fights with Monsters (book_count
-- currently NULL), Hogwarts Library, The Roald Dahl Classic Collection
-- (both non-traditional "series" -- a companion-book grouping rather
-- than a numbered continuing story, worth a policy look before
-- treating like an ordinary series), and The Riyria Revelations
-- (Omnibus) (a different, already-flagged design question -- whether
-- an omnibus row should carry its own book_count at all -- not a
-- plain status/count miscount, left for that separate decision).
-- 'Saga' (the out-of-scope graphic novel series) also seen in the
-- ranked list, deliberately left untouched per existing policy.

-- Takeshi Kovacs (Richard K. Morgan) -- 3 books (Altered Carbon, Broken
-- Angels, Woken Furies), 2002-2005, completed; Morgan never continued
-- Kovacs's own numbered trilogy (Thin Air, 2018, is set in the same
-- universe but follows a different protagonist, not a 4th Kovacs
-- novel). Was 'ongoing'/4.
update series set status = 'completed', book_count = 3
where name = 'Takeshi Kovacs';

-- Wayward Pines (Blake Crouch) -- 3 books (Pines, Wayward, The Last
-- Town), 2012-2014, completed; status was already correct. Was
-- book_count=5.
update series set book_count = 3
where name = 'Wayward Pines';

-- The Old Kingdom (Garth Nix) -- 6 novels (Sabriel, Lirael, Abhorsen,
-- Clariel, Goldenhand, Terciel and Elinor), 1995-2021; status left
-- 'ongoing' -- no explicit "series complete" statement found, and Nix
-- has kept returning to this world periodically (Terciel and Elinor
-- was itself a 2021 return after a 2016 prior entry), so no evidence
-- supports flipping to 'completed'. Was book_count=13 (a raw Hardcover
-- edition/format count; the companion novella "The Creature in the
-- Case" and other short fiction not counted, matching convention).
update series set book_count = 6
where name = 'The Old Kingdom';

-- Cradle (Will Wight) -- 12 main novels (Unsouled through Waybound),
-- 2016-2023, completed with Waybound as the confirmed final book of
-- Lindon's core story; status was already correct. "Threshold: Stories
-- from Cradle" is a short-story collection set in the same world, not
-- counted as a 13th mainline book. Was book_count=19 (a raw Hardcover
-- edition/format count).
update series set book_count = 12
where name = 'Cradle';

-- All Souls (Deborah Harkness) -- 5 published novels (A Discovery of
-- Witches, Shadow of Night, The Book of Life, Time's Convert, The
-- Black Bird Oracle), 2011-2024; status left 'ongoing' -- a 6th book,
-- "The Falcon and the Rose," is confirmed announced (title revealed,
-- no publication date yet), so 'ongoing' is correct and not yet
-- counted since it isn't published. Was book_count=17 (a raw Hardcover
-- edition/format count; the companion guide "The World of All Souls"
-- also not counted).
update series set book_count = 5
where name = 'All Souls';

-- The Selection (Kiera Cass) -- 5 core novels (The Selection, The
-- Elite, The One, The Heir, The Crown), 2012-2016, completed; "Happily
-- Ever After" is a bonus novella/companion collection, not counted.
-- Was 'ongoing'/23 -- wrong on both axes.
update series set status = 'completed', book_count = 5
where name = 'The Selection';

-- Red Queen (Victoria Aveyard) -- 4 main novels (Red Queen, Glass
-- Sword, King's Cage, War Storm), 2015-2018, completed; prequel
-- novella compilation and the companion "Broken Throne" not counted.
-- Was 'ongoing'/11.
update series set status = 'completed', book_count = 4
where name = 'Red Queen';

-- The Scholomance (Naomi Novik) -- 3 books (A Deadly Education, The
-- Last Graduate, The Golden Enclaves), 2020-2022, completed ("the
-- triumphant conclusion to the ... trilogy" per the publisher). Was
-- 'ongoing'/5.
update series set status = 'completed', book_count = 3
where name = 'The Scholomance';

-- Themis Files (Sylvain Neuvel) -- 3 books (Sleeping Giants, Waking
-- Gods, Only Human), 2016-2018, completed ("a fitting, satisfying end"
-- per reviews of the final book, no further entries since). Free
-- bonus web chapters ("The Lost Files") not counted. Was 'ongoing'/8.
update series set status = 'completed', book_count = 3
where name = 'Themis Files';

-- The Interdependency (John Scalzi) -- 3 books (The Collapsing Empire,
-- The Consuming Fire, The Last Emperox), 2017-2020, completed --
-- Scalzi has stated this was his first intentionally-written trilogy
-- and it concluded with The Last Emperox. Was 'ongoing'/4.
update series set status = 'completed', book_count = 3
where name = 'The Interdependency';

-- The Infernal Devices (Cassandra Clare) -- 3 books (Clockwork Angel,
-- Clockwork Prince, Clockwork Princess), 2010-2013, completed. Was
-- 'ongoing'/14 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Infernal Devices';

-- Fitz and the Fool (Robin Hobb) -- 3 books (Fool's Assassin, Fool's
-- Quest, Assassin's Fate), 2014-2017, completed -- Assassin's Fate is
-- confirmed as the conclusion both of this trilogy and of Hobb's
-- entire Realm of the Elderlings saga. Was 'ongoing'/7.
update series set status = 'completed', book_count = 3
where name = 'Fitz and the Fool';

-- The Liveship Traders (Robin Hobb) -- 3 books (Ship of Magic, The
-- Mad Ship, Ship of Destiny), 1998-2000, completed; status was already
-- correct. Was book_count=5.
update series set book_count = 3
where name = 'The Liveship Traders';

-- Star Wars: The Thrawn Trilogy (Timothy Zahn) -- 3 books (Heir to the
-- Empire, Dark Force Rising, The Last Command), 1991-1993, completed
-- (this specific, original Legends-continuity trilogy; distinct from
-- Zahn's separate later "Star Wars: Thrawn" Canon-continuity series,
-- which is a different catalog series row and an already-flagged,
-- separate universe-linking question -- not touched here). Was
-- 'ongoing'/20 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'Star Wars: The Thrawn Trilogy';

-- The Magicians (Lev Grossman) -- 3 books (The Magicians, The
-- Magician King, The Magician's Land), 2009-2014, completed ("brings
-- the Magicians trilogy to a magnificent conclusion"). Was
-- 'ongoing'/6.
update series set status = 'completed', book_count = 3
where name = 'The Magicians';

-- Villains (V.E. Schwab) -- 2 published books (Vicious 2013, Vengeful
-- 2018); status left 'ongoing' -- a confirmed third and final book,
-- Victorious, has a cover reveal and a 2026-10-06 release date (still
-- in the future as of this migration), so 'ongoing' is correct and
-- Victorious isn't counted yet per the not-yet-published convention.
-- Was book_count=7 (a raw Hardcover edition/format count).
update series set book_count = 2
where name = 'Villains';

-- A Series of Unfortunate Events (Lemony Snicket) -- 13 books (The Bad
-- Beginning through The End), 1999-2006, completed; status was
-- already correct. Was book_count=39 (a raw Hardcover edition/format
-- count -- this series has an unusually large number of box-set/
-- individual reprint editions).
update series set book_count = 13
where name = 'A Series of Unfortunate Events';
