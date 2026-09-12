-- Eighth batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batches 2-7
-- landed 2026-09-12/13 in 20260912100000_..._batch2.sql,
-- 20260912400000_..._batch3.sql, 20260912600000_..._batch4.sql,
-- 20260912800000_..._batch5.sql, 20260912900000_..._batch6.sql,
-- 20260913100000_..._batch7.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: reconstructed the accurate 156-name "checked" list
-- by name straight from batches 1-7's own project-log.md entries
-- (15 + 30 + 17 + 38 + 18 + 17 + 21 = 156, verified against the live
-- `series` table -- all 156 matched exactly one row before use, with one
-- naming correction: batch 4's "Mistborn Era Two" is actually stored as
-- "Mistborn Era Two (Wax and Wayne)" -- the shorter form matched zero
-- rows, same class of naming-drift bug as the already-known Enderverse
-- double-space case), rather than trusting the running-total number
-- alone. Combined with the 15 still-unsettled flagged names carried from
-- batch 7 (Hogwarts Library, The Roald Dahl Classic Collection, The
-- Riyria Revelations (Omnibus), Robert Langdon, The Inheritance Games,
-- Imperial Radch (publication order), Enderverse:  Publication Order
-- [double space, DB's real stored name], The Shadow Series, Middle
-- Earth, American Gods, Forward Collection, Saga, Kingsbridge, Holly
-- Gibney, Elantris) -- 171 unique exclude strings after dedup.
--
-- Re-ran the ranking query excluding those 171 names. Unlike batches
-- 1-7, the "count(b.id)" ranking is now almost completely flat: every
-- remaining series has exactly 1 book currently linked in our own
-- catalog (the catalog has grown enough that this proxy has basically
-- saturated). With no more meaningful primary ranking signal, used
-- `book_count` (Hardcover's raw count) descending as a secondary sort
-- to surface series most likely to be established multi-book franchises
-- with a badly inflated raw count, and worked down that list, verifying
-- every single one via live web search before writing anything, same
-- standard as batches 1-7.
--
-- book_count convention (matching batches 1-7): count real PUBLISHED
-- mainline installments only -- not companion novellas/short-story
-- collections/prequels/spin-off series, not unpublished forthcoming
-- books, regardless of whether an unpublished/companion title already
-- has its own row in our books/series tables.
--
-- One naming/bookkeeping correction folded in (not a value fix, just
-- exclude-list hygiene like batch 6's Enderverse catch): the exclude
-- list above uses "Mistborn Era Two (Wax and Wayne)", the DB's actual
-- stored name for the series batch 4 fixed as "Mistborn Era Two" --
-- confirmed via `select name from series where name ilike '%mistborn
-- era two%'`.
--
-- 17 series needed a real fix this batch, detailed inline below.
-- 0 candidates checked this batch turned out already correct.
--
-- Five new names flagged as likely out-of-scope, not this task's call
-- (same shape as batch 4's Robert Langdon/The Inheritance Games and
-- batch 6's Kingsbridge/Holly Gibney flags -- surfaced by the ranking
-- query with real catalog rows, but not sci-fi/fantasy, or not prose):
-- **The Walking Dead** and **Watchmen** are both graphic novels/comics
-- (confirmed via the linked book title/author: "The Walking Dead, Vol.
-- 1: Days Gone Bye" by Kirkman/Moore; "Watchmen" by Alan Moore) --
-- out of v1 scope per the existing comics/graphic-novel policy
-- (docs/TODO.md's "Catalog scope & series hierarchy" section, the same
-- policy that removed Saga/Sandman). **The Divine Comedy** (Dante) and
-- **Asian Saga: Chronological Order** (James Clavell -- Shogun, Tai-Pan,
-- etc., historical fiction) are not sci-fi/fantasy, likely the same kind
-- of Hardcover genre-search false positive as Robert Langdon/Inheritance
-- Games. **Blindness** (Jose Saramago) is dystopian literary fiction,
-- not marketed or shelved as genre SFF despite the speculative premise
-- -- same false-positive shape. None of these five touched here --
-- surfaced, not decided, added to the flagged-name list below.
--
-- Two new duplicate/non-leaf-series-row issues flagged, NOT fixed here
-- (a different bug class from status/book_count, same "flag don't fix"
-- treatment as prior batches): **The Legend of Drizzt** and **The Dark
-- Elf Trilogy** are the exact duplicate-series-row problem already
-- named (but not yet fixed) in the shared-universe audit's batch-6
-- summary ("Salvatore's Dark Elf Trilogy/Legend of Drizzt duplicate-
-- series rows") -- Salvatore's real Drizzt bibliography spans 30+ novels
-- across many named sub-series, and any single accurate book_count
-- requires first resolving which rows are real leaf series vs.
-- duplicates/umbrellas, out of this task's scope. **The Mistborn Saga**
-- and **Mistborn** are a parent/umbrella-series pair for the exact
-- pattern docs/TODO.md's "Catalog scope & series hierarchy" section
-- already describes and batch 4 already fixed correctly for this same
-- book (Mistborn Era One / Mistborn Era Two are the real leaf series);
-- "Mistborn" itself correctly has 0 books linked (consistent with the
-- leaf-series convention), but "The Mistborn Saga" has 1 book
-- incorrectly linked to the umbrella row instead of to Era One or Era
-- Two -- a `books.series_id` linkage bug, the same shape as batch 7's
-- Elantris flag, not a status/book_count value error. Both added to the
-- flagged-name list below.
--
-- Three candidates seen in the ranked list but deliberately left
-- UNRESEARCHED this batch (not flagged as a different bug class, just
-- not reached/settled -- available as batch 9's first candidates):
-- **Shannara (Chronological Order)** (Terry Brooks -- a genuinely large,
-- multi-sub-series bibliography on the scale of Wheel of Time/Horus
-- Heresy; needs careful sub-series-by-sub-series verification, not a
-- quick single-search answer). **World of the Five Gods (Publication)**
-- (Bujold -- sources disagree on the exact novel count, 3 vs. 4,
-- depending on how "The Physicians of Vilnoc"-adjacent material is
-- classified against the 11 separately-published Penric novellas;
-- genuinely mixed evidence, didn't want to guess). **Capitaine Nemo**
-- (the one linked book is Verne's "Twenty Thousand Leagues Under the
-- Sea"; Nemo also appears in "The Mysterious Island", but no source
-- found establishing this as an officially branded 2-book series rather
-- than an informal cataloging grouping of "books featuring Captain
-- Nemo" -- needs more digging before writing a number). Also seen but
-- not reached: Rivers of London and Vorkosigan Saga (Publication
-- Order), both real ongoing series where the exact core-novel-vs-
-- novella split needs more careful per-title verification than this
-- batch's search budget allowed for cleanly.
--
-- One judgment call worth flagging for visibility (not a decision that
-- needs re-litigating): **Gormenghast**'s book_count is set to 4, not
-- the commonly-cited "trilogy" of 3 -- "Titus Awakes" (2011) is
-- explicitly published and marketed as "Gormenghast, Volume 4" /
-- "The Lost Book of Gormenghast", completed by Peake's widow Maeve
-- Gilmore from his notes and fragments after his death, not merely a
-- separate companion work. Counted per this batch's "real published
-- mainline installment" convention since it carries the official
-- volume-4 numbering, unlike the companion-novella exclusions elsewhere
-- in this file.

-- The Chronicles of Amber (Roger Zelazny) -- 10 published novels: the
-- 5-book Corwin cycle (Nine Princes in Amber, The Guns of Avalon, Sign
-- of the Unicorn, The Hand of Oberon, The Courts of Chaos, 1970-1978)
-- plus the 5-book Merlin cycle (Trumps of Doom, Blood of Amber, Sign of
-- Chaos, Knight of Shadows, Prince of Chaos, 1985-1991). Status
-- 'completed' already correct (Zelazny died in 1995 with no further
-- volumes). Was book_count=111 (a raw Hardcover edition/omnibus count).
update series set book_count = 10
where name = 'The Chronicles of Amber';

-- Sookie Stackhouse (Charlaine Harris) -- a closed 13-book series
-- (Dead Until Dark through Dead Ever After, 2001-2013); a coda ("After
-- Dead") and a companion guide are not numbered novels, excluded per
-- the standing companion-work convention. Was 'ongoing'/42 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 13
where name = 'Sookie Stackhouse';

-- Dragonlance: Chronicles (Margaret Weis & Tracy Hickman) -- a closed
-- 3-book trilogy (Dragons of Autumn Twilight, Dragons of Winter Night,
-- Dragons of Spring Dawning, 1984-1985); the separate "Dragonlance
-- Legends" trilogy that follows is a different named series, not part
-- of this one's count. Was 'ongoing'/39 (a raw Hardcover edition/format
-- count spanning the much larger wider Dragonlance line).
update series set status = 'completed', book_count = 3
where name = 'Dragonlance: Chronicles';

-- Redwall (Brian Jacques) -- a closed 22-book series (Redwall through
-- The Rogue Crew, 1986-2011) -- The Rogue Crew was released posthumously
-- after Jacques's 2011 death, completing the series as planned. Was
-- 'ongoing'/38 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 22
where name = 'Redwall';

-- The Chronicles of Prydain (Lloyd Alexander) -- a closed 5-book series
-- (The Book of Three, The Black Cauldron, The Castle of Llyr, Taran
-- Wanderer, The High King, 1964-1968); "The Foundling and Other Tales of
-- Prydain" is a short-story collection of prequels, excluded per the
-- standing collection/prequel convention. Was 'ongoing'/27 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 5
where name = 'The Chronicles of Prydain';

-- The Queen of the Tearling (Erika Johansen) -- a closed 3-book trilogy
-- (The Queen of the Tearling, The Invasion of the Tearling, The Fate of
-- the Tearling, 2014-2016); "The Beginning of Everything" is a
-- companion novella, excluded per the standing companion-work
-- convention. Was 'ongoing'/27 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Queen of the Tearling';

-- The Belgariad (David Eddings) -- a closed 5-book series (Pawn of
-- Prophecy, Queen of Sorcery, Magician's Gambit, Castle of Wizardry,
-- Enchanters' End Game, 1982-1984); "The Malloreon" is a separate,
-- distinctly-named 5-book sequel series with its own catalog row, not
-- part of this count. Was 'ongoing'/19 (a raw Hardcover edition/format
-- count).
update series set status = 'completed', book_count = 5
where name = 'The Belgariad';

-- Temeraire (Naomi Novik) -- a closed 9-book series (His Majesty's
-- Dragon through League of Dragons, 2006-2016). Was 'ongoing'/21 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 9
where name = 'Temeraire';

-- Odd Thomas (Dean Koontz) -- a closed 7-book main series (Odd Thomas
-- through Saint Odd, 2003-2015) -- "Odd Interlude" is a novella and
-- several graphic novels/short stories exist in the wider universe,
-- excluded per the standing companion-work convention; Saint Odd is
-- explicitly the series finale. Was 'ongoing'/22 (a raw Hardcover
-- edition/format count).
update series set status = 'completed', book_count = 7
where name = 'Odd Thomas';

-- Gormenghast (Mervyn Peake) -- 4 published novels: Titus Groan (1946),
-- Gormenghast (1950), Titus Alone (1959), and Titus Awakes (2011) --
-- the last completed by Peake's widow Maeve Gilmore from his own notes
-- and fragments after his death, and explicitly published/marketed as
-- "Gormenghast, Volume 4" / "The Lost Book of Gormenghast", not a loose
-- companion work (see header note on this judgment call). Status
-- 'completed' -- both contributing authors are deceased. Was
-- 'ongoing'/18 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 4
where name = 'Gormenghast';

-- The Iron Druid Chronicles (Kevin Hearne) -- a closed 9-book main
-- series (Hounded through Scourged, 2011-2018), explicitly wrapped up
-- with Scourged as the finale; "Ink & Sigil" launches a separate
-- spin-off trilogy with a different protagonist in the same universe,
-- not a numbered Iron Druid entry, excluded per the standing spin-off
-- convention. Was 'ongoing'/31 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 9
where name = 'The Iron Druid Chronicles';

-- The Prince of Nothing (R. Scott Bakker) -- a closed 3-book trilogy
-- (The Darkness That Comes Before, The Warrior-Prophet, The Thousandfold
-- Thought, 2003-2006); the sequel tetralogy "The Aspect-Emperor" is a
-- separate named series, not part of this count. Was 'ongoing'/17 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Prince of Nothing';

-- Honor Harrington (David Weber) -- 14 published mainline novels (On
-- Basilisk Station through Uncompromising Honor, 1993-2018); the wider
-- Honorverse's many spin-off sub-series (Saganami Island, Wages of Sin,
-- Manticore Ascendant, anthologies, etc.) are separately-named series,
-- not part of this numbered count. Status 'ongoing' already correct --
-- Weber has stated on the record that he plans at least several more
-- core Honor Harrington novels, and a next book has been informally
-- estimated (no confirmed date). Was book_count=44 (a raw Hardcover
-- edition/format count).
update series set book_count = 14
where name = 'Honor Harrington';

-- Pern (Anne McCaffrey, later co-written/solo-written by Todd
-- McCaffrey) -- 24 published novels as of this migration (per
-- Wikipedia's bibliography); "The Chronicles of Pern: First Fall" and
-- "A Gift of Dragons" are short-story collections, excluded per the
-- standing collection convention. Status 'ongoing' already correct --
-- no completion statement found for the series as a whole (Anne
-- McCaffrey died in 2011; Todd McCaffrey has continued writing Pern
-- novels since), same "absence of a completion statement isn't itself
-- a completion signal" precedent as The Old Kingdom/Silo/Revelation
-- Space. Was book_count=58 (a raw Hardcover edition/format count).
update series set book_count = 24
where name = 'Pern';

-- Bartimaeus (Jonathan Stroud) -- a closed 3-book trilogy (The Amulet of
-- Samarkand, The Golem's Eye, Ptolemy's Gate, 2003-2005); "The Ring of
-- Solomon" is an explicitly-billed prequel, excluded per the standing
-- prequel convention. Was 'ongoing'/7 (a raw Hardcover edition/format
-- count).
update series set status = 'completed', book_count = 3
where name = 'Bartimaeus';

-- Newsflesh (Mira Grant) -- a closed 3-book trilogy (Feed, Deadline,
-- Blackout, 2010-2012), explicitly billed by the author as a trilogy;
-- "Feedback" (2016) is a parallel/companion novel in the same universe
-- with different protagonists, excluded per the standing companion-work
-- convention. Was 'ongoing'/13 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'Newsflesh';

-- Parasol Protectorate (Gail Carriger) -- a closed 5-book series
-- (Soulless through Timeless, 2009-2012). Was 'ongoing'/13 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 5
where name = 'Parasol Protectorate';
