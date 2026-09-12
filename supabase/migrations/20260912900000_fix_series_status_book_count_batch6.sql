-- Sixth batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batches 2-5
-- landed 2026-09-12 in 20260912100000_..._batch2.sql,
-- 20260912400000_..._batch3.sql, 20260912600000_..._batch4.sql,
-- 20260912800000_..._batch5.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: re-ran the ranking query, excluding all 118 named
-- series checked (fixed or confirmed correct) across batches 1-5, plus
-- the 12 previously-flagged-but-not-settled names (Hogwarts Library,
-- The Roald Dahl Classic Collection, The Riyria Revelations (Omnibus),
-- Robert Langdon, The Inheritance Games, Imperial Radch (publication
-- order) [same duplicate-name row flagged batch 5], Enderverse:
-- Publication Order [DB's actual stored name has a double space after
-- the colon -- "Enderverse:  Publication Order" -- confirmed via direct
-- query; used the real string so the exclusion actually matches, not
-- "fixing" the stray space itself, which is a separate cosmetic data
-- issue out of this task's scope], The Shadow Series, Middle Earth,
-- American Gods, Forward Collection, Saga). Verified: 129 unique
-- excluded name strings for 130 nominal entries, since the Imperial
-- Radch duplicate-row name is shared between a batch-2 fix and the
-- batch-5 flag.
--
-- With the catalog's growth, almost every top candidate sits at a flat
-- 2-3 books currently linked in our own catalog -- worked down the
-- ranked list in order, verified via live web search before writing
-- anything, same standard as batches 1-5.
--
-- book_count convention (matching batches 1-5): count real PUBLISHED
-- mainline installments only -- not companion novellas/short-story
-- collections, not unpublished forthcoming books, regardless of
-- whether an unpublished/companion title already has its own row in
-- our books/series tables.
--
-- **Hit a real research wall this batch, stopped there rather than
-- pushing past it**: this session's live web-search budget ran out
-- (200/200 calls used) partway through verifying the ranked list --
-- landed on exactly 14 clean, fully-verified fixes plus 3 confirmed-
-- already-correct before that happened, close enough to the ~15 target
-- that stopping here (per this task's own "stop earlier if you hit a
-- research wall" instruction) was the right call rather than guessing
-- on the remaining unverified candidates. Batch 7 has a substantial,
-- already-ranked candidate list waiting (see docs/TODO.md).
--
-- Candidates checked this batch and confirmed ALREADY CORRECT (NOT in
-- this file): Skyward Flight (Brandon Sanderson & Janci Patterson) --
-- completed/3 (Sunreach, ReDawn, Evershore, the companion novella
-- trilogy set during Cytonic, collected in the 2022 "Skyward Flight"
-- omnibus) -- distinct from the main "Skyward" series (already fixed
-- batch 2), already matched our catalog's own 3 linked rows. The Age of
-- Madness (Joe Abercrombie) -- completed/3 (A Little Hatred, The
-- Trouble with Peace, The Wisdom of Crowds, 2019-2021), already
-- correct. The Giver (Lois Lowry, "The Giver Quartet") -- completed/4
-- (The Giver, Gathering Blue, Messenger, Son, 1993-2012), already
-- correct even though only 2 of the 4 are currently linked in our
-- catalog -- book_count reflects the real series total, not our own
-- catalog-linkage count, same convention as every prior batch (e.g.
-- batch 5's Sword of Truth-style cases).
--
-- Two judgment calls worth flagging (not decisions that need
-- re-litigating, just worth knowing):
-- - **Teixcalaan (Arkady Martine)** -- book_count fixed (4 -> 2), but
--   status deliberately LEFT 'ongoing' despite genuinely mixed
--   evidence: one source describes it as "book one in the Teixcalaan
--   trilogy" implying a third book, but the author has also referred to
--   it elsewhere as a completed duology. Rather than pick a side on
--   contradictory, unresolved evidence with no live search left to
--   settle it, left status untouched (matching the standing precedent
--   from The Old Kingdom/Silo of not flipping status without a clear
--   signal either way) -- worth a targeted re-check next time search
--   budget allows.
-- - **Crowns of Nyaxia (Carissa Broadbent)** -- book_count fixed (9 ->
--   5): a planned 6-book series (3 duologies), 5 of 6 mainline
--   installments published as of this migration, 1 more confirmed
--   coming (still ongoing, status already correct). The standalone
--   novella "Six Scorched Roses" and the standalone "Slaying the
--   Vampire Conqueror" are excluded from the mainline count, same
--   companion-work convention as every prior batch.
--
-- **New data-quality issue noticed in passing, NOT fixed here (out of
-- this task's scope, flagging for whoever owns author-field hygiene)**:
-- the "Threshold" series row's `books.author` values include "Jean-
-- Pierre Pugi" and "Ray Porter" alongside Peter Clines -- Pugi is
-- French-translation-adjacent and Porter is a well-known audiobook
-- narrator, both look like the same author-field-contamination pattern
-- CLAUDE.md's "Data quality / tagging" section already tracks (the
-- Sapkowski/David French translator case). Not this task's fix to make;
-- left "Threshold" itself unresearched/untouched for status/book_count
-- too, since its own identity was never actually pinned down (Peter
-- Clines has multiple same-title-adjacent series, and the contaminated
-- author field made this harder to resolve with the search budget
-- remaining) -- available for batch 7 with a clean start.
--
-- **Two new likely-out-of-scope names surfaced, not decided here**
-- (same shape as batch 4's Robert Langdon/The Inheritance Games flag):
-- **Kingsbridge** (Ken Follett) -- historical fiction (Pillars of the
-- Earth and its sequels), not sci-fi/fantasy. **Holly Gibney** (Stephen
-- King) -- the shared-universe audit's batch-6 entry already flagged
-- this sub-series as "worth a scope look, most of this sub-series is
-- crime/thriller rather than SFF" for a different task; surfacing it
-- again here since it also showed up in this task's own ranking query.
-- Both left completely untouched (not fixed, not deleted), added to
-- the flagged-name exclude list so they stop wasting future batches'
-- research time until the repo owner makes a scope call.
--
-- Candidates seen in the ranked list but NOT researched this batch
-- (search budget ran out before reaching them, no assumption made
-- either way -- available for batch 7): Revelation Space (Alastair
-- Reynolds), Outlander (Diana Gabaldon), Legend (Marie Lu), Six of
-- Crows (Leigh Bardugo), Legends & Lattes (Travis Baldree), The
-- Founders Trilogy (Robert Jackson Bennett), Earthseed (Octavia
-- Butler), Blood and Ash (Jennifer L. Armentrout), Ready Player One
-- (Ernest Cline), Ana and Din Mysteries (Robert Jackson Bennett), The
-- Roots of Chaos (Samantha Shannon), Oxford Time Travel (Connie
-- Willis), Elantris (Brandon Sanderson -- likely a companion-grouping
-- question like the already-flagged omnibus cases, worth checking
-- carefully rather than treating as a plain miscount), Before the
-- Coffee Gets Cold (Toshikazu Kawaguchi), Once Upon a Broken Heart
-- (Stephanie Garber -- book count genuinely unclear from available
-- sources, a companion novella/possible 4th-book title muddied it),
-- Sword of Truth (Terry Goodkind), Kate Daniels (Ilona Andrews) -- the
-- search budget ran out mid-query on these last two specifically.

-- Lock In (John Scalzi) -- 2 real novels (Lock In, Head On); "Unlocked:
-- An Oral History of Haden's Syndrome" is a prequel novella, excluded
-- per the standing companion-work convention. Status 'ongoing' left
-- unchanged -- no completion statement found either way. Was
-- book_count=3 (counting the novella).
update series set book_count = 2
where name = 'Lock In';

-- The Captive's War (James S.A. Corey) -- 2 published novels (The
-- Mercy of Gods 2024, The Faith of Beasts 2026) of a confirmed planned
-- trilogy; the third is not yet published, and "Livesuit" (2024) is a
-- companion novella, both excluded per convention. Status 'ongoing'
-- already correct. Was book_count=4.
update series set book_count = 2
where name = 'The Captive''s War';

-- Uglies (Scott Westerfeld) -- the original 4-book tetralogy (Uglies,
-- Pretties, Specials, Extras), 2005-2007, completed -- Westerfeld's
-- later "Impostors" books are a separate spin-off series, not more
-- Uglies installments. Was 'ongoing'/11 (a raw Hardcover
-- edition/format count).
update series set status = 'completed', book_count = 4
where name = 'Uglies';

-- Miss Peregrine's Peculiar Children (Ransom Riggs) -- 6 books across
-- two trilogies (Miss Peregrine's Home for Peculiar Children through
-- The Desolations of Devil's Acre), 2011-2021, completed. Was
-- 'ongoing'/10 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 6
where name = 'Miss Peregrine''s Peculiar Children';

-- The Vagrant (Peter Newman, aka the Deathless Trilogy) -- 3 books (The
-- Vagrant, The Malice, The Seven), 2015-2017, completed, no further
-- installment scheduled. Was 'ongoing'/10 (a raw Hardcover
-- edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Vagrant';

-- The Daevabad Trilogy (S.A. Chakraborty) -- 3 books (The City of
-- Brass, The Kingdom of Copper, The Empire of Gold), 2017-2020,
-- completed -- "The River of Silver" (2022) is a companion short-story
-- collection, excluded per the same collection-vs-novel convention used
-- for Earthsea Cycle/Book of the New Sun in prior batches. Was
-- 'ongoing'/5 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Daevabad Trilogy';

-- Emily Wilde (Heather Fawcett) -- 3 published books (Emily Wilde's
-- Encyclopaedia of Faeries, Map of the Otherlands, Compendium of Lost
-- Tales, 2023-2025); status 'ongoing' already correct -- a 4th book is
-- confirmed for January 2027 and a 5th is in progress (the author has
-- said the series grew from a planned trilogy to 5 books), but neither
-- is published yet, so not counted per the not-yet-published
-- convention. Was book_count=6.
update series set book_count = 3
where name = 'Emily Wilde';

-- Wayward Children (Seanan McGuire) -- 11 published novellas (Every
-- Heart a Doorway through Through Gates of Garnet and Gold,
-- 2016-2026); status 'ongoing' already correct -- an actively
-- continuing novella series with no completion announced. Was
-- book_count=35 (a raw Hardcover edition/format count, wildly inflated
-- relative to the real installment count).
update series set book_count = 11
where name = 'Wayward Children';

-- Commonwealth Saga (Peter F. Hamilton) -- 2 books (Pandora's Star,
-- Judas Unchained), 2004-2005, completed. Was 'ongoing'/9 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 2
where name = 'Commonwealth Saga';

-- Daemon (Daniel Suarez) -- 2 books (Daemon, Freedom(TM)), 2006-2009,
-- completed -- explicitly written and marketed as a concluding duology,
-- no further installment. Was 'ongoing'/5 (a raw Hardcover
-- edition/format count).
update series set status = 'completed', book_count = 2
where name = 'Daemon';

-- Bloodsworn Saga (John Gwynne) -- 3 books (The Shadow of the Gods, The
-- Hunger of the Gods, The Fury of the Gods), 2021-2024, completed. Was
-- 'ongoing'/6 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'Bloodsworn Saga';

-- Crowns of Nyaxia (Carissa Broadbent) -- a planned 6-book series (3
-- duologies: Nightborn, Shadowborn, Bloodborn), 5 of 6 mainline
-- installments published as of this migration (The Serpent and the
-- Wings of Night through The Lion and the Deathless Dark), 1 more
-- confirmed coming; status 'ongoing' already correct. The standalone
-- novella "Six Scorched Roses" and standalone "Slaying the Vampire
-- Conqueror" excluded per the companion-work convention. Was
-- book_count=9.
update series set book_count = 5
where name = 'Crowns of Nyaxia';

-- The Handmaid's Tale (Margaret Atwood) -- 2 books (The Handmaid's
-- Tale, The Testaments), 1985-2019, completed -- no third book written
-- or announced despite the TV adaptation's continued expansion. Was
-- 'ongoing'/10 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 2
where name = 'The Handmaid''s Tale';

-- Teixcalaan (Arkady Martine) -- 2 published books (A Memory Called
-- Empire, A Desolation Called Peace), 2019-2021; book_count fixed, but
-- status deliberately LEFT 'ongoing' -- evidence on whether a third book
-- exists is genuinely mixed (one source frames it as book one of a
-- trilogy, others describe the series as a completed duology) and
-- couldn't be resolved with this session's remaining search budget;
-- left as-is per the standing "don't flip status without a clear
-- signal" precedent rather than guess. Was book_count=4.
update series set book_count = 2
where name = 'Teixcalaan';
