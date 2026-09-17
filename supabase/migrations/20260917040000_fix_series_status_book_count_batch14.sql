-- series.status/book_count fix, batch 14 (CLDO persona).
-- Continues the P2 catalog-wide fix: `status` defaults to 'ongoing'
-- whenever Hardcover's `is_completed` isn't explicitly true; `book_count`
-- is Hardcover's raw edition/omnibus/box-set count, not a curated
-- mainline-installment count. Neither field is read by
-- scripts/recommend.py -- display-only bug in tools/catalog-review/.
-- Every value below verified via live WebSearch/WebFetch against a real
-- bibliography/publisher/author-own-site/Wikipedia source before writing.
--
-- Candidate selection: re-ranked by our own catalog's book_count
-- descending, excluding all names already checked across batches 1-13
-- (fixed names re-derived directly from executing every prior batch's
-- migration file with `returning name` in a rolled-back transaction --
-- more reliable than the prose-summary reconstruction batch 13 used,
-- since it can't miss a name hidden behind string concatenation like
-- Legacy of Orisha's `chr(239)` escape -- plus the 64 previously-flagged
-- names given in docs/TODO.md's "Next (batch 14)" pointer). Worked down
-- the doc's own named "unresearched candidate tail" first (The Band,
-- The Crimson Moth, Matched, Inheritance Trilogy, The Last Unicorn,
-- Hundred Kingdoms, Fae & Alchemy, Elements of Cadence -- note: Todd
-- Family/Life After Life and Elements of Cadence were NOT reached this
-- batch, left for batch 15), then continued into newly-surfaced
-- candidates (Black Company, Firefall, A Targaryen History, John Dies
-- at the End, Xenogenesis, Chronicles of Osreth).

-- The Chronicles of the Black Company (Glen Cook): completed/10 ->
-- ongoing/12. Wikipedia confirms 11 novels through Port of Shadows
-- (2018), plus Lies Weeping (Nov 2025) opening a new confirmed
-- multi-volume continuation ("A Pitiless Rain" -- They Cry due Nov
-- 2026, at least 3 more volumes after that per the author's own
-- publishing plan). This is a direct narrative continuation, not a
-- companion/spinoff, so it counts -- the series is very much still
-- being actively written, not a completed classic.
update series set status = 'ongoing', book_count = 12, updated_at = now()
where name = 'The Chronicles of the Black Company';

-- Hundred Kingdoms (Alexandra Christo): ongoing/7 -> completed/2.
-- Confirmed via the publisher's own catalog and Goodreads: 2 standalone
-- novels in the same world (To Kill a Kingdom 2018, Princess of Souls
-- 2022) -- no third book announced, no evidence of ongoing work since
-- 2022, treated as complete on the same absence-of-further-work basis
-- prior batches have used.
update series set status = 'completed', book_count = 2, updated_at = now()
where name = 'Hundred Kingdoms';

-- Matched (Ally Condie): ongoing/7 -> completed/3. Wikipedia confirms
-- the classic completed trilogy (Matched 2010, Crossed 2011, Reached
-- 2012) -- no further books.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Matched';

-- The Band (Nicholas Eames, Kings of the Wyld): ongoing/7 ->
-- completed/3. Confirmed a finished trilogy: Kings of the Wyld (2017),
-- Bloody Rose (2018), Outlaw Empire (2023) -- no further books
-- announced.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'The Band';

-- The Last Unicorn (Peter S. Beagle): ongoing/7 -> completed/1. The
-- 1968 novel is a genuinely self-contained, long-finished work; its
-- only "sequels" are the novellas "Two Hearts" (2004) and "Sooz"
-- (2023, collected together as "The Way Home") -- companion novella
-- material, not counted, same convention as Powder Mage's "Forsworn"/
-- Arc of a Scythe's "Gleanings".
update series set status = 'completed', book_count = 1, updated_at = now()
where name = 'The Last Unicorn';

-- The Chronicles of Osreth (Katherine Addison): ongoing/7 ->
-- completed/4. The umbrella series over The Goblin Emperor (2014) plus
-- the Cemeteries of Amalo trilogy (The Witness for the Dead 2021, The
-- Grief of Stones 2022, The Tomb of Dragons 2025) -- 4 mainline novels.
-- The Tomb of Dragons is explicitly confirmed as the trilogy's closing
-- volume. "Lora Selezh" and "The Orb of Cairado" are companion
-- novellas, not counted, same convention as above.
update series set status = 'completed', book_count = 4, updated_at = now()
where name = 'The Chronicles of Osreth';

-- Fae & Alchemy (Callie Hart): book_count only, 7 -> 2. A planned
-- trilogy (Quicksilver 2024, Brimstone 2025, an unannounced-title third
-- book not yet published as of this batch, expected 2026-2027 per
-- conflicting retailer estimates) -- book_count reflects PUBLISHED
-- installments only, per this project's standing convention (see A
-- Song of Ice and Fire/Red Rising Saga in batch 1). Status was already
-- correctly 'ongoing'.
update series set book_count = 2, updated_at = now()
where name = 'Fae & Alchemy';

-- Inheritance Trilogy (N.K. Jemisin): ongoing/7 -> completed/3. The
-- classic completed trilogy (The Hundred Thousand Kingdoms 2010, The
-- Broken Kingdoms 2010, The Kingdom of Gods 2011) -- "The Awakened
-- Kingdom" is a companion novella, not counted.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Inheritance Trilogy';

-- The Crimson Moth (Kristen Ciccarelli): ongoing/7 -> completed/2. The
-- author's own site explicitly labels this a completed duology
-- (Heartless Hunter, Rebel Witch) with no further books announced --
-- a third-book "Dark Descent" listing found on Goodreads is not
-- corroborated by the author's own site or any publisher source, so
-- not trusted here.
update series set status = 'completed', book_count = 2, updated_at = now()
where name = 'The Crimson Moth';

-- A Targaryen History (George R.R. Martin): book_count only, 6 -> 1.
-- Confirmed only "Fire & Blood" (2018) has actually been published;
-- the second volume (working title "Blood & Fire") remains unwritten/
-- in progress as of the most recent update found. Status was already
-- correctly 'ongoing'.
update series set book_count = 1, updated_at = now()
where name = 'A Targaryen History';

-- John Dies at the End (David Wong / Jason Pargin): book_count only,
-- 6 -> 5. Confirmed 5 published novels (John Dies at the End 2007,
-- This Book Is Full of Spiders 2012, What the Hell Did I Just Read
-- 2017, If This Book Exists You're in the Wrong Universe 2022, There
-- Are No Giant Crabs in This Novel of Giant Crabs 2026). Status was
-- already correctly 'ongoing'.
update series set book_count = 5, updated_at = now()
where name = 'John Dies at the End';

-- Xenogenesis (Octavia Butler): ongoing/6 -> completed/3. The classic
-- completed trilogy (Dawn 1987, Adulthood Rites 1988, Imago 1989),
-- later republished under the omnibus title "Lilith's Brood" -- Butler
-- died in 2006 with no further installments.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Xenogenesis';

-- Firefall (Peter Watts): book_count only, 6 -> 2. Wikipedia identifies
-- exactly 2 novels (Blindsight 2006, Echopraxia 2014) as "comprising
-- the Firefall series"; "The Colonel" (2014) is a Tor.com Original
-- novella under 40 pages, a bridge story, not counted, same companion-
-- novella convention as above. Status left 'ongoing' on absence of a
-- completion statement (no confirmed third novel, but also no
-- confirmed end), same convention batch 13 used for The Singing Hills
-- Cycle.
update series set book_count = 2, updated_at = now()
where name = 'Firefall';

-- Author-field contamination caught during this batch's research (not
-- a series.status/book_count fix, but the standing CLAUDE.md policy on
-- author contamination applies the moment it's found, not just at
-- ingestion time): "To Kill a Kingdom" (Hundred Kingdoms #1, fixed
-- above) had its audiobook narrators (Jacob York, Stephanie Willis --
-- confirmed via AudioFile Magazine's own review byline and the
-- Audible/Amazon audiobook listings) merged into the author field.
-- "The Last Unicorn" (fixed above) had Patrick Rothfuss listed as a
-- co-author -- he wrote only a new introduction to a later reissue
-- (confirmed via the Penguin Random House listing's own title:
-- "...with a new introduction by Patrick Rothfuss"), never co-authored
-- the novel.
update books set author = 'Alexandra Christo', updated_at = now()
where title = 'To Kill a Kingdom';

update books set author = 'Peter S. Beagle', updated_at = now()
where title = 'The Last Unicorn';
