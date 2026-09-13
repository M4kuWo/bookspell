-- series.status/book_count fix, batch 11 (CLDA).
-- Root cause (unchanged since batch 1): series.status defaults to 'ongoing'
-- whenever Hardcover's is_completed flag isn't explicitly true, and
-- series.book_count is Hardcover's raw edition/omnibus/box-set count, not a
-- curated count of real mainline installments. Neither field is read by
-- scripts/recommend.py -- display-only bug in tools/catalog-review/.
--
-- Candidates selected by re-running the ranking query (Hardcover raw
-- book_count descending, per batches 8-10's finding that "books currently
-- linked in our own catalog" has saturated at 1 for every remaining
-- series), excluding all 204 names checked across batches 1-10 plus the 52
-- still-unsettled flagged names (256 total, 255 unique after the known
-- Imperial Radch collision). Every fix below verified via live web search
-- before writing, same standard as batches 1-10. Session's web-search
-- budget ran out (200/200) after these 13 -- stopped cleanly per this
-- task's own "stop at a research wall" precedent (same shape as batch 6),
-- rather than guessing the remainder.

-- Daughter of Smoke & Bone (Laini Taylor): wrongly 'ongoing' with a raw
-- Hardcover count of 14. Real closed trilogy: Daughter of Smoke & Bone,
-- Days of Blood & Starlight, Dreams of Gods & Monsters (2011-2014).
update series set status = 'completed', book_count = 3
where name = 'Daughter of Smoke & Bone';

-- Serpent & Dove (Shelby Mahurin): status 'completed' already correct.
-- book_count was a raw Hardcover count (13); real trilogy is 3 books
-- (Serpent & Dove, Blood & Honey, Gods & Monsters, 2019-2021).
update series set book_count = 3
where name = 'Serpent & Dove';

-- Rama (Arthur C. Clarke / Gentry Lee): status 'completed' already correct.
-- book_count 12 was a raw Hardcover count across Gentry Lee's later solo
-- spin-off work; the real Clarke/Lee "Rama" tetralogy is 4 books
-- (Rendezvous with Rama, Rama II, The Garden of Rama, Rama Revealed,
-- 1973-1993). Lee's solo prequel novels are a separate body of work in the
-- same universe, not numbered Rama entries.
update series set book_count = 4
where name = 'Rama';

-- Mortal Engines Quartet (Philip Reeve): wrongly 'ongoing' with a raw count
-- of 12. Real closed quartet: Mortal Engines, Predator's Gold, Infernal
-- Devices, A Darkling Plain (2001-2006); the Fever Crumb prequel trilogy
-- and 2026's standalone "Bridge of Storms" are separate books, not part of
-- this named quartet.
update series set status = 'completed', book_count = 4
where name = 'Mortal Engines Quartet';

-- Innkeeper Chronicles (Ilona Andrews): status 'ongoing' already correct --
-- the series is on hiatus ("finished for now") with at least one more book
-- planned but no confirmed title/date, so left 'ongoing' per the standing
-- "don't flip on absence of evidence" convention. book_count was a raw
-- Hardcover count (12); real total is 5 mainline novels (Clean Sweep
-- through Sweep of the Heart, 2013-2022) -- "Sweep with Me" is a novella,
-- excluded per the standing companion-work convention.
update series set book_count = 5
where name = 'Innkeeper Chronicles';

-- Chaos Walking (Patrick Ness): wrongly 'ongoing' with a raw count of 12.
-- Real closed trilogy: The Knife of Never Letting Go, The Ask and the
-- Answer, Monsters of Men (2008-2010). "The Wide, Wide Sea" and other
-- linked titles are short stories/companions, not numbered mainline books.
update series set status = 'completed', book_count = 3
where name = 'Chaos Walking';

-- The Baroque Cycle (8 volume) (Neal Stephenson): wrongly 'ongoing' with a
-- raw count of 12. This row's own name specifies the 8-volume split
-- edition (vs. the original 3-volume publication of Quicksilver/The
-- Confusion/The System of the World); Stephenson finished writing in 2004
-- with no further installments.
update series set status = 'completed', book_count = 8
where name = 'The Baroque Cycle (8 volume)';

-- Unwind Dystology (Neal Shusterman): wrongly 'ongoing' with a raw count of
-- 11. Real closed 5-book series: Unwind, UnWholly, UnSouled, UnDivided,
-- UnBound (2007-2015).
update series set status = 'completed', book_count = 5
where name = 'Unwind Dystology';

-- Star Wars: Thrawn (Timothy Zahn's 2017-2019 "Imperial Trilogy", a
-- distinct row from the already-fixed "Star Wars: The Thrawn Trilogy"
-- 1990s books): wrongly 'ongoing' with a raw count of 11. Real closed
-- trilogy: Thrawn, Thrawn: Alliances, Thrawn: Treason (2017-2019).
update series set status = 'completed', book_count = 3
where name = 'Star Wars: Thrawn';

-- The Memoirs of Lady Trent (Marie Brennan): wrongly 'ongoing' with a raw
-- count of 11. Real closed 5-book series (A Natural History of Dragons
-- through Within the Sanctuary of Wings, 2013-2017).
update series set status = 'completed', book_count = 5
where name = 'The Memoirs of Lady Trent';

-- The Dark Star Trilogy (Marlon James): status 'ongoing' already correct --
-- only 2 of the planned 3 books are published (Black Leopard, Red Wolf
-- 2019; Moon Witch, Spider King 2022); "White Wing, Dark Star" is
-- confirmed in development but no specific 2026 (or later) publication
-- date was found, so not counted as published yet. book_count was a raw
-- Hardcover count (11).
update series set book_count = 2
where name = 'The Dark Star Trilogy';

-- Lorien Legacies (Pittacus Lore): wrongly 'ongoing' with a raw count of
-- 11. Real closed main 7-book series (I Am Number Four through United As
-- One, 2010-2016); "Lorien Legacies Reborn" is a separate 3-book sequel
-- series, and "The Lost Files" are companion novellas -- neither counted.
update series set status = 'completed', book_count = 7
where name = 'Lorien Legacies';

-- Delirium (Lauren Oliver): wrongly 'ongoing' with a raw count of 10. Real
-- closed trilogy: Delirium, Pandemonium, Requiem (2011-2013); "Delirium
-- Stories" is a companion novella collection, excluded per the standing
-- collection-vs-novel convention.
update series set status = 'completed', book_count = 3
where name = 'Delirium';
