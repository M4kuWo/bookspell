-- Seventh batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batches 2-6
-- landed 2026-09-12 in 20260912100000_..._batch2.sql,
-- 20260912400000_..._batch3.sql, 20260912600000_..._batch4.sql,
-- 20260912800000_..._batch5.sql, 20260912900000_..._batch6.sql).
--
-- Root cause (unchanged): `status` defaults to 'ongoing' whenever
-- Hardcover's `is_completed` flag isn't explicitly true (including
-- missing data); `book_count` is Hardcover's raw per-series
-- edition/omnibus/box-set count, not a curated real-mainline-
-- installments count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/.
--
-- Batch selection: reconstructed the accurate 135-name "checked" list by
-- name straight from batches 1-6's own project-log.md entries (15 + 30 +
-- 17 + 38 + 18 + 17 = 135, verified against the live `series` table --
-- all 135 matched exactly one row before use), rather than trusting the
-- running-total number alone (this undercounted before, in batch 5).
-- Combined with the 14 still-unsettled flagged names carried from batch
-- 6 (Hogwarts Library, The Roald Dahl Classic Collection, The Riyria
-- Revelations (Omnibus), Robert Langdon, The Inheritance Games, Imperial
-- Radch (publication order), Enderverse:  Publication Order [DB's real
-- stored name, double space after the colon, confirmed via direct
-- query], The Shadow Series, Middle Earth, American Gods, Forward
-- Collection, Saga, Kingsbridge, Holly Gibney) -- 148 unique exclude
-- strings after dedup (the "Imperial Radch (publication order)" string
-- is shared between a batch-2 fix and a batch-5/6 flag, same collision
-- already known from batch 6).
--
-- Re-ran the ranking query excluding those 148 names. With the
-- catalog's continued growth, almost every top candidate again sits at
-- a flat 1-2 books currently linked in our own catalog. Worked the
-- batch-6-surfaced candidate tail (Revelation Space, Outlander, Legend,
-- Six of Crows, Legends & Lattes, The Founders Trilogy, Earthseed, Blood
-- and Ash, Ready Player One, Ana and Din Mysteries, The Roots of Chaos,
-- Oxford Time Travel, Elantris, Before the Coffee Gets Cold, Once Upon a
-- Broken Heart, Sword of Truth, Kate Daniels, Threshold), then continued
-- into 4 fresh names at the same "2 books linked" tier (Jurassic Park,
-- Letters of Enchantment, The Lot Lands, Hierarchy) since search budget
-- allowed it. Verified every single one via live web search before
-- writing anything, same standard as batches 1-6.
--
-- book_count convention (matching batches 1-6): count real PUBLISHED
-- mainline installments only -- not companion novellas/short-story
-- collections/retellings-of-already-counted-events, not unpublished
-- forthcoming books, regardless of whether an unpublished/companion
-- title already has its own row in our books/series tables, and
-- regardless of how many of the real total are currently linked in our
-- own catalog (book_count reflects the real-world series total, not our
-- own linkage count -- same convention as The Giver Quartet in batch 6).
--
-- Candidates checked this batch and confirmed ALREADY CORRECT (NOT in
-- this file): Ana and Din Mysteries (Robert Jackson Bennett, aka "Shadow
-- of the Leviathan" per Wikipedia -- a naming-vs-fan-label discrepancy
-- noted in passing, not fixed here, same shape as Enderverse being a
-- fan term) -- 'ongoing'/3 already correct (The Tainted Cup, A Drop of
-- Corruption, A Trade of Blood published August 2026; our catalog only
-- has the first 2 linked so far, book_count already reflects the real
-- total). Six of Crows (Leigh Bardugo) -- 'completed'/2 already correct
-- (Six of Crows, Crooked Kingdom; a "Six of Crows: A Darker Shore"
-- novella (2026) doesn't count as a third mainline book; no third novel
-- confirmed). Ready Player One (Ernest Cline) -- 'completed'/2 already
-- correct (Ready Player One, Ready Player Two; Cline has discussed an
-- unwritten prequel, "Ready Player Zero", not a numbered third book).
-- Earthseed (Octavia E. Butler) -- 'completed'/2 already correct
-- (Parable of the Sower, Parable of the Talents; the planned third book,
-- Parable of the Trickster, was never finished -- Butler died in 2006
-- with only false starts). Jurassic Park (Michael Crichton) --
-- 'completed'/2 already correct (Jurassic Park, The Lost World; no third
-- novel was ever written -- the film sequels are not book adaptations).
--
-- One data-quality issue flagged, NOT fixed here (a different bug class
-- from status/book_count, same "flag don't fix" treatment as prior
-- batches' LOTR/Farseer/Monk and Robot duplicate-book-row notes):
-- **Elantris** (Brandon Sanderson) -- the real novel "Elantris" (2005)
-- exists in our `books` table but has `series_id = NULL`, not linked to
-- its own "Elantris" series row at all. The series row instead only
-- has two Cosmere companion novellas linked at fractional positions
-- ("The Hope of Elantris" at 1.5, "The Emperor's Soul" at 1.75) --
-- exactly the "companion-grouping question, not a plain miscount"
-- shape flagged in docs/TODO.md's batch-7 pointer. Left completely
-- untouched (no status/book_count value written) since the real fix is
-- a `books.series_id` linkage correction, out of this task's scope --
-- added to the flagged-name list below so future batches' ranking
-- queries stop re-surfacing it as a plain value error.
--
-- One naming note, not a fix: **"Ana and Din Mysteries"** appears to be
-- a Goodreads-style informal label -- Wikipedia and the publisher both
-- use "Shadow of the Leviathan" as the real series name for Robert
-- Jackson Bennett's Ana Dolabra / Dinios Kol mysteries. Not renamed here
-- (status/book_count were already correct and renaming is a different
-- kind of change than this task covers), just noted for whoever next
-- touches this series row.

-- Revelation Space (Alastair Reynolds) -- the "Inhibitor Cycle" mainline
-- is 4 novels (Revelation Space, Redemption Ark, Absolution Gap,
-- Inhibitor Phase, 2000-2021); Chasm City (2001, our catalog's linked
-- "0.5" position) is a companion novel Reynolds himself has said "can be
-- read at any point," excluded per the standing companion-work
-- convention. Status 'ongoing' already correct -- no completion
-- statement found, and Reynolds returned to the mainline once already
-- after an 18-year gap (Absolution Gap 2003 -> Inhibitor Phase 2021), so
-- absence of a positive "more coming" signal isn't treated as a
-- completion signal either (same precedent as The Old Kingdom/Silo).
-- Was book_count=33.
update series set book_count = 4
where name = 'Revelation Space';

-- Outlander (Diana Gabaldon) -- 9 published mainline novels (Outlander
-- through Go Tell the Bees That I Am Gone, 1991-2021); a 10th book, "A
-- Blessing for a Warrior Going Out," is confirmed in progress but has no
-- release date and isn't published yet, so not counted per the
-- not-yet-published convention. Status 'ongoing' already correct. Was
-- book_count=44 (a raw Hardcover edition/format count).
update series set book_count = 9
where name = 'Outlander';

-- Legend (Marie Lu) -- confirmed a closed 4-book saga (Legend, Prodigy,
-- Champion, Rebel, 2011-2019) -- Rebel is officially the fourth and
-- final book (not a separate spin-off series despite the ~8-year
-- publication gap and shift to a new narrator), with Marie Lu on record
-- saying she found real closure writing it; a 2026 "Rebel: The Graphic
-- Novel" adaptation doesn't add a new prose installment. Was
-- 'ongoing'/9 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 4
where name = 'Legend';

-- The Founders Trilogy (Robert Jackson Bennett) -- a closed 3-book
-- trilogy (Foundryside, Shorefall, Locklands, 2018-2022) -- Locklands is
-- explicitly branded "the jaw-dropping conclusion" to the trilogy. Was
-- 'ongoing'/5 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'The Founders Trilogy';

-- Blood and Ash (Jennifer L. Armentrout) -- 6 published mainline novels
-- as of this migration (From Blood and Ash, A Kingdom of Flesh and
-- Fire, The Crown of Gilded Bones, The War of Two Queens, A Soul of Ash
-- and Blood, The Primal of Blood and Bone, 2020-2025); the confirmed
-- 7th and final book, The Throne of Bone and Ash, was pushed from
-- spring to fall 2026 and is not yet published as of this migration
-- (2026-09-13), so not counted per the not-yet-published convention.
-- Status 'ongoing' already correct. Was book_count=23 (a raw Hardcover
-- edition/format count).
update series set book_count = 6
where name = 'Blood and Ash';

-- The Roots of Chaos (Samantha Shannon) -- 3 published novels (The
-- Priory of the Orange Tree, A Day of Fallen Night, Among the Burning
-- Flowers, 2019-2025) -- Among the Burning Flowers is a genuine full
-- novel (288pp), not a novella, despite its shorter length relative to
-- Shannon's other books in the series. Status 'ongoing' already correct
-- -- no completion statement found, and no confirmed 4th book either.
-- Was book_count=2 (our own catalog hadn't yet linked the third book).
update series set book_count = 3
where name = 'The Roots of Chaos';

-- Legends & Lattes (Travis Baldree) -- 3 published novels (Legends &
-- Lattes, Bookshops & Bonedust, Brigands & Breadknives, 2022-2025).
-- Status 'ongoing' already correct -- Baldree's next book is confirmed
-- to be in a different (LitRPG) world, but he has explicitly left the
-- door open to returning to this one, and no completion statement was
-- found either way. Was book_count=2 (our own catalog hadn't yet linked
-- the third book).
update series set book_count = 3
where name = 'Legends & Lattes';

-- Oxford Time Travel (Connie Willis) -- 4 published mainline novels
-- (Doomsday Book, To Say Nothing of the Dog, Blackout, All Clear,
-- 1992-2010; Blackout/All Clear is one story split across two published
-- volumes, both counted); "Fire Watch" (1982) is a short story, excluded
-- per the standing collection-vs-novel convention. Status 'ongoing'
-- already correct -- a further book, "A Spanner in the Works," is
-- confirmed in development but not yet published. Was book_count=8 (a
-- raw Hardcover edition/format count).
update series set book_count = 4
where name = 'Oxford Time Travel';

-- Sword of Truth (Terry Goodkind) -- the core saga is 11 novels
-- (Wizard's First Rule through Confessor, 1994-2007), explicitly
-- concluded in Confessor; the 2 prequels, 1 direct sequel ("The Law of
-- Nines"), and the separate "Richard and Kahlan"/Nicci Chronicles
-- follow-up series are not part of this numbered 11-book core. Status
-- 'completed' already correct. Was book_count=85 (a raw Hardcover
-- edition/format count spanning omnibus and box-set editions).
update series set book_count = 11
where name = 'Sword of Truth';

-- Kate Daniels (Ilona Andrews) -- the main series is a closed 10-book
-- saga (Magic Bites through Magic Triumphs, 2007-2019) -- originally
-- planned as 7 books, extended to 10 while finishing the story; the
-- wider "Kate Daniels world" (novellas, spin-offs) runs to 18 titles but
-- isn't part of this numbered mainline count. Was 'ongoing'/29 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 10
where name = 'Kate Daniels';

-- Once Upon a Broken Heart (Stephanie Garber) -- a closed 3-book trilogy
-- (Once Upon a Broken Heart, The Ballad of Never After, A Curse for True
-- Love, 2021-2023); a companion novella, "The Mirror of Infinite
-- Endings" (2026), is excluded per the standing companion-work
-- convention. Status 'completed' already correct. Was book_count=8 (a
-- raw Hardcover edition/format count).
update series set book_count = 3
where name = 'Once Upon a Broken Heart';

-- Threshold (Peter Clines) -- identity resolved: this is "The Threshold
-- Universe," 4 mainline novels (14, The Fold, Dead Moon, Terminus,
-- 2012-2020); "Paradox Bound" is a separate story in Clines's wider
-- connected-universe of books, not a numbered Threshold entry. Status
-- 'ongoing' already correct (Wikipedia describes the series itself as
-- ongoing; no completion statement found). Note: the series row's
-- `books.author` values are contaminated with a translator
-- ("Jean-Pierre Pugi") and an audiobook narrator ("Ray Porter") --
-- already flagged in batch 6's project-log entry, not this task's fix
-- to make, left untouched. Was book_count=5.
update series set book_count = 4
where name = 'Threshold';

-- Before the Coffee Gets Cold (Toshikazu Kawaguchi) -- 6 published
-- mainline novels as of this migration (Before the Coffee Gets Cold,
-- Tales from the Cafe, Before Your Memory Fades, Before We Say Goodbye,
-- Before We Forget Kindness, Before I Knew I Loved You, 2015-2026 in
-- Japanese/English translation order -- Before I Knew I Loved You
-- published 2026-05-21/26, already out as of this migration). Status
-- 'ongoing' already correct -- an actively continuing series with no
-- completion announced. Was book_count=4 (our own catalog hadn't yet
-- linked the 5th/6th books).
update series set book_count = 6
where name = 'Before the Coffee Gets Cold';

-- Letters of Enchantment (Rebecca Ross) -- a closed 2-book duology
-- (Divine Rivals, Ruthless Vows, 2023-2024) -- Ross has said everything
-- wraps up in Ruthless Vows; "Wild Reverence" is a new story in the same
-- universe, not a numbered third book of this duology, excluded per the
-- standing companion-work convention. Status 'completed' already
-- correct. Was book_count=12 (a raw Hardcover edition/format count).
update series set book_count = 2
where name = 'Letters of Enchantment';

-- The Lot Lands (Jonathan French, aka the "Grey Bastards" trilogy) -- a
-- closed 3-book trilogy (The Grey Bastards, The True Bastards, The Free
-- Bastards, 2015-2020) -- The Free Bastards is explicitly the trilogy's
-- conclusion. book_count=3 was already correct; only status was wrong.
update series set status = 'completed'
where name = 'The Lot Lands';

-- Hierarchy (James Islington) -- 2 published novels (The Will of the
-- Many, The Strength of the Few, 2023-2025); the confirmed third and
-- final book, "The Justice of One," is in progress (~90,000 words of a
-- first draft as of late 2025) but has no release date and isn't
-- published yet -- fan speculation points to 2027/2028, not counted per
-- the not-yet-published convention. Status 'ongoing' already correct.
-- Was book_count=3 (our own catalog's 2 linked books plus 1 for the
-- unpublished third).
update series set book_count = 2
where name = 'Hierarchy';
