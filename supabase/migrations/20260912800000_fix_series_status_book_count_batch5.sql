-- Fifth batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batches 2-4
-- landed 2026-09-12 in 20260912100000_..._batch2.sql,
-- 20260912400000_..._batch3.sql, 20260912600000_..._batch4.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: re-ran the ranking query (our own catalog's
-- book-count-per-series, the only available profile proxy), excluding
-- all 100 named series checked (fixed or confirmed correct) across
-- batches 1-4, plus the 5 previously-flagged-but-not-settled names
-- (Hogwarts Library, The Roald Dahl Classic Collection, The Riyria
-- Revelations (Omnibus), Robert Langdon, The Inheritance Games). NOTE:
-- batch 4's own "next batch" pointer undercounted this to "84" (67 +
-- only its own 17 fixes, omitting its 21 confirmed-already-correct
-- names) in both docs/TODO.md and docs/project-log.md -- this batch
-- used the accurate 100-name total instead (verified by re-reading
-- batch 1-4's project-log entries directly for every name) and is
-- correcting the running count going forward; see docs/TODO.md's
-- updated entry.
--
-- 15 needed a real fix, 3 more checked and confirmed already correct,
-- 6 new names flagged as a different bug class (not status/book_count
-- -- duplicate/umbrella series-row issues or multi-author-anthology
-- scope questions, see docs/project-log.md's dated entry for detail),
-- 1 (Saga) skipped per existing out-of-scope-graphic-novel policy.
-- Verified via live web search before writing anything, same standard
-- as batches 1-4.
--
-- book_count convention (matching batches 1-4): count real PUBLISHED
-- mainline installments only -- not companion novellas/short-story
-- collections, not unpublished forthcoming books, regardless of
-- whether an unpublished/companion title already has its own row in
-- our books/series tables.
--
-- Candidates checked this batch and confirmed ALREADY CORRECT (NOT in
-- this file): The Dresden Files (18, ongoing -- Jim Butcher has
-- published 18 novels as of "Twelve Months" (Jan 2026); the series is
-- openly planned for 25 total, so 'ongoing' is correct and 18 matches
-- our catalog's own count), The Vampire Chronicles (13, completed --
-- Anne Rice's 13 novels from Interview with the Vampire (1976) through
-- Blood Communion (2018), her de facto final book; she died in 2021),
-- The Faithful and the Fallen (4, completed -- John Gwynne's Malice,
-- Valour, Ruin, Wrath, a closed quartet).
--
-- Flagged as a DIFFERENT bug class (not fixed here -- not simple
-- status/book_count errors, need a separate look): Imperial Radch
-- (publication order) -- all 5 real books (Ancillary Justice through
-- Translation State) are linked to this duplicate-named series row,
-- while the "Imperial Radch" row batch 2 already fixed the
-- status/book_count on now has ZERO books linked -- a duplicate-series
-- -row problem, not a value-correctness one. Enderverse: Publication
-- Order / The Shadow Series -- Ender's Shadow and Shadow of the Giant
-- sit under the former (a cross-saga reading-order umbrella) while
-- Shadow of the Hegemon and Shadow Puppets sit under the latter (the
-- real leaf sub-series these 4 books all belong to), splitting one
-- 5-book saga (the "Shadow" quintet) across two series rows -- violates
-- CLAUDE.md's "series_id always points at a leaf series" convention.
-- Middle Earth -- holds only an omnibus ("The Hobbit & The Lord of the
-- Rings") and "The Silmarillion", not a real leaf series in the normal
-- sense -- same pattern as the already-flagged Hogwarts
-- Library/Roald Dahl Classic Collection. American Gods -- groups Neil
-- Gaiman's "American Gods" with "Anansi Boys", a loosely-connected
-- companion novel in the same mythology/universe with a different
-- protagonist, not a numbered direct sequel -- a scope/grouping
-- question in the same family as the omnibus flags above. Forward
-- Collection -- a one-time 2019 anthology of 6 unrelated standalone
-- novellas by 6 different authors (Jemisin, Weir, Roth, Crouch,
-- Towles, Tremblay), not a normal single-author mainline series --
-- whether/how "book_count" even applies to a multi-author anthology
-- brand is a policy question, not a value to just correct to 6.
--
-- 'Saga' (out-of-scope graphic novel) also seen again in the ranked
-- list, deliberately left untouched per existing policy -- not
-- previously added to the running exclude list, so it will keep
-- resurfacing in every batch's ranking query until it is; added to
-- docs/TODO.md's exclude list now to stop that waste.
--
-- Candidates seen in the ranked list but NOT researched (left for
-- batch 6, no assumption made either way): Legend (Marie Lu), Emily
-- Wilde (Heather Fawcett), Legends & Lattes (Travis Baldree), Oxford
-- Time Travel (Connie Willis), Uglies (Scott Westerfeld), Wayward
-- Children (Seanan McGuire), Outlander (Diana Gabaldon), Holly Gibney
-- (Stephen King -- also worth a scope look, most of this sub-series is
-- crime/thriller rather than SFF), The Captive's War (James S. A.
-- Corey).

-- The Rain Wild Chronicles (Robin Hobb) -- 4 books (Dragon Keeper,
-- Dragon Haven, City of Dragons, Blood of Dragons), 2010-2013,
-- completed. Was 'ongoing'/20 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 4
where name = 'The Rain Wild Chronicles';

-- Space Odyssey (Arthur C. Clarke) -- 4 books (2001: A Space Odyssey,
-- 2010: Odyssey Two, 2061: Odyssey Three, 3001: The Final Odyssey),
-- 1968-1997, completed -- Clarke died in 2008. Was 'ongoing'/12 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 4
where name = 'Space Odyssey';

-- Dirk Gently (Douglas Adams) -- 2 completed novels (Dirk Gently's
-- Holistic Detective Agency, The Long Dark Tea-Time of the Soul),
-- 1987-1988. "The Salmon of Doubt" (2002) was published posthumously
-- from Adams' unfinished manuscript and other writings after his 2001
-- death -- an incomplete draft, not a finished third novel, excluded
-- per the same "real published mainline installments" convention used
-- to exclude every other unfinished/companion work in batches 1-4. Was
-- 'ongoing'/8 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 2
where name = 'Dirk Gently';

-- The Book of the New Sun (Gene Wolfe) -- 4 books (The Shadow of the
-- Torturer, The Claw of the Conciliator, The Sword of the Lictor, The
-- Citadel of the Autarch), 1980-1983, completed -- Wolfe died in 2019.
-- "The Urth of the New Sun" (1987) is a separate sequel published 4
-- years later, not part of the named tetralogy itself (sources
-- explicitly describe it as "not an integral part of The Book of the
-- New Sun"); excluded, matching how batches 1-4 have consistently kept
-- a series' book_count scoped to its own named title rather than the
-- wider universe (e.g. The Riftwar Saga below, or batch 1's Ender's
-- Saga vs. the wider Enderverse). Status was already correct. Was
-- book_count=21 (a raw Hardcover edition/format count, also inflated by
-- a "Shadow & Claw" omnibus edition sitting in our own books table
-- alongside the individual volumes -- a books-table duplicate-row
-- question like the ones already flagged in batch 4, not fixed here).
update series set book_count = 4
where name = 'The Book of the New Sun';

-- The Final Architecture (Adrian Tchaikovsky) -- 3 books (Shards of
-- Earth, Eyes of the Void, Lords of Uncreation), 2021-2023, completed.
-- Was 'ongoing'/5.
update series set status = 'completed', book_count = 3
where name = 'The Final Architecture';

-- An Ember in the Ashes (Sabaa Tahir) -- 4 books (An Ember in the
-- Ashes, A Torch Against the Night, A Reaper at the Gates, A Sky Beyond
-- the Storm), 2015-2020, completed. Was 'ongoing'/7 (a raw Hardcover
-- edition/format count).
update series set status = 'completed', book_count = 4
where name = 'An Ember in the Ashes';

-- The Kane Chronicles (Rick Riordan) -- 3 books (The Red Pyramid, The
-- Throne of Fire, The Serpent's Shadow), 2010-2012, completed --
-- companion guides (Survival Guide, Brooklyn House Magician's Manual)
-- not counted. Was 'ongoing'/12 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Kane Chronicles';

-- Zones of Thought (Vernor Vinge) -- 3 novels (A Fire Upon the Deep, A
-- Deepness in the Sky, The Children of the Sky), 1992-2011, completed
-- -- Vinge died in 2024 with no further installment; "The Blabber" is a
-- linked short story, not a novel, excluded. Was 'ongoing'/22 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'Zones of Thought';

-- The Atlas (Olivie Blake) -- 3 books (The Atlas Six, The Atlas
-- Paradox, The Atlas Complex), 2020-2024, completed; status was already
-- correct. Was book_count=4.
update series set book_count = 3
where name = 'The Atlas';

-- King of Scars (Leigh Bardugo) -- 2 books (King of Scars, Rule of
-- Wolves), 2019-2021, completed -- confirmed a closed duology, no
-- further installment announced (the same world continues in the
-- separate Ninth House/Alex Stern series, not as a King of Scars
-- sequel). Was 'ongoing'/3.
update series set status = 'completed', book_count = 2
where name = 'King of Scars';

-- Ninth House (Leigh Bardugo) -- 2 published books (Ninth House, Hell
-- Bent); status 'ongoing' was already correct -- "Dead Beat" (book 3,
-- the trilogy's confirmed conclusion) is scheduled for 2026-09-15, i.e.
-- NOT YET PUBLISHED as of this migration (2026-09-12), so it is not
-- counted yet, matching the same not-yet-released standard batch 4
-- applied to The Locked Tomb. Was book_count=3 (counting the unreleased
-- book).
update series set book_count = 2
where name = 'Ninth House';

-- Caraval (Stephanie Garber) -- 3 books (Caraval, Legendary, Finale),
-- 2017-2019, completed. Was 'ongoing'/6 (a raw Hardcover edition/format
-- count).
update series set status = 'completed', book_count = 3
where name = 'Caraval';

-- The Riftwar Saga (Raymond E. Feist) -- 3 books (Magician, Silverthorn,
-- A Darkness at Sethanon), 1982-1986, completed; status was already
-- correct. The wider "Riftwar Cycle" (Krondor's sequels, Empire
-- trilogy, Serpentwar, etc.) is a separate set of related series, not
-- additional Riftwar Saga installments -- not counted here, same
-- narrow-to-the-named-title convention as The Book of the New Sun
-- above. Was book_count=8 (a raw Hardcover edition/format count).
update series set book_count = 3
where name = 'The Riftwar Saga';

-- The Shepherd King (Rachel Gillig) -- 2 books (One Dark Window, Two
-- Twisted Crowns), 2022-2023, completed -- confirmed a deliberately
-- closed duology (Gillig has stated a preference for writing duologies
-- specifically), no third book. Status was already correct. Was
-- book_count=3.
update series set book_count = 2
where name = 'The Shepherd King';

-- Cerulean Chronicles (TJ Klune) -- 2 published books (The House in the
-- Cerulean Sea, Somewhere Beyond the Sea), 2020-2024; status corrected
-- to 'ongoing' -- a third book is confirmed in development (referenced
-- across multiple retailer/publisher listings as forthcoming, expected
-- 2026) but has no confirmed title or firm release date yet, so it is
-- not counted, only used to justify keeping 'ongoing' rather than
-- 'completed'. Was 'completed'/1 -- both fields wrong (book_count was
-- wrong even against our own catalog's already-linked 2 books).
update series set status = 'ongoing', book_count = 2
where name = 'Cerulean Chronicles';
