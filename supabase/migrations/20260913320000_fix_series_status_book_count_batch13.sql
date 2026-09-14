-- series.status/book_count fix, batch 13 (CLDA persona).
-- Continues the P2 catalog-wide fix: `status` defaults to 'ongoing'
-- whenever Hardcover's `is_completed` isn't explicitly true; `book_count`
-- is Hardcover's raw edition/omnibus/box-set count, not a curated
-- mainline-installment count. Neither field is read by
-- scripts/recommend.py -- display-only bug in tools/catalog-review/.
-- Every value below verified via live WebFetch against a real
-- bibliography/publisher/Wikipedia source before writing (WebSearch
-- quota was already exhausted at the start of this session, same as
-- batch 12 -- WebFetch against real content, not a guess).

-- The Bound and the Broken (Ryan Cahill): book_count only, 10 -> 4.
-- Reopened from batch 12's "unresearched, no reachable source" flag --
-- found via the author's own site (ryancahillauthor.com/books), whose
-- "Published Books (In Order)" list gives exactly 4 mainline novels (Of
-- Blood and Fire, Of Darkness and Light, Of War and Ruin, Of Empires and
-- Dust); the 3 interstitial novellas (The Fall, The Exile, The Ice) are
-- excluded per the standing novella-exclusion convention. Book V is
-- listed under "Upcoming Books" (estimated 2026, still being written),
-- so status stays 'ongoing' (already correct).
update series set book_count = 4, updated_at = now()
where name = 'The Bound and the Broken';

-- Legacy of Orisha (Tomi Adeyemi): ongoing/8 -> completed/3. Children of
-- Blood and Bone (2018), Children of Virtue and Vengeance (2019),
-- Children of Anguish and Anarchy (June 2024) -- confirmed via Wikipedia
-- as a complete trilogy, the third book debuting at #1 on the NYT
-- bestseller list. "Awaken the Magic" is a companion journal, not a 4th
-- novel, excluded.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Legacy of Or' || chr(239) || 'sha';

-- The Singing Hills Cycle (Nghi Vo): book_count only, 8 -> 7. Wikipedia
-- lists 7 published novellas through "A Long and Speaking Silence" (May
-- 2026): The Empress of Salt and Fortune, When the Tiger Came Down the
-- Mountain, Into the Riverlands, Mammoths at the Gates, The Brides of
-- High Hill, A Mouthful of Dust, A Long and Speaking Silence. No
-- explicit "final book"/completion statement found (a second source,
-- Reactor/Tor.com's series page, wasn't reachable to corroborate) --
-- status left 'ongoing' on absence of evidence, per this task's
-- standing convention.
update series set book_count = 7, updated_at = now()
where name = 'The Singing Hills Cycle';

-- Wanderers (Chuck Wendig): book_count only, 8 -> 2. Wikipedia's
-- bibliography lists exactly 2 books (Wanderers 2019, Wayward 2022), no
-- third book announced -- status left 'ongoing' on absence of evidence.
update series set book_count = 2, updated_at = now()
where name = 'Wanderers';

-- Lightlark (Alex Aster): book_count only, 8 -> 5. Wikipedia lists 5
-- mainline novels (Lightlark, Nightbane, Skyshade, Grim and Oro,
-- Crowntide); the "Lightlark Holiday Novella" is a companion piece,
-- excluded. No completion statement found -- status left 'ongoing'.
update series set book_count = 5, updated_at = now()
where name = 'Lightlark';

-- The Checquy Files (Daniel O'Malley): book_count only, 8 -> 4. Wikipedia
-- confirms 4 full novels (The Rook 2012, Stiletto 2016, Blitz 2022,
-- Royal Gambit 2025) -- cross-checked via The Rook's own Wikipedia page,
-- which independently calls Blitz "the third novel of the series",
-- confirming it's a full entry, not a novella. No completion statement
-- found -- status left 'ongoing'.
update series set book_count = 4, updated_at = now()
where name = 'The Checquy Files';

-- Book of Ember (Jeanne DuPrau): ongoing/8 -> completed/4. Wikipedia
-- confirms the 4-book core series (The City of Ember 2003, The People of
-- Sparks 2004, The Prophet of Yonwood 2006, The Diamond of Darkhold
-- 2008) with no further mainline entries.
update series set status = 'completed', book_count = 4, updated_at = now()
where name = 'Book of Ember';

-- The Bridge Kingdom (Danielle L. Jensen): completed/8 -> ongoing/5, a
-- reversal in the same direction as batch 4's Locked Tomb case. The
-- author's own official series page (danielleljensen.com/bridge-kingdom-
-- series, fetched twice independently, consistent both times) lists 5
-- published full-length novels (The Bridge Kingdom, The Traitor Queen,
-- The Endless War, The Twisted Throne, The Tempest Blade) plus a 6th,
-- "The Inadequate Heir," explicitly marked PREORDER -- i.e. not yet
-- published as of this migration. Hardcover's data had apparently
-- marked the series complete and/or counted the unreleased 6th book.
update series set status = 'ongoing', book_count = 5, updated_at = now()
where name = 'The Bridge Kingdom';

-- The Library Trilogy (Mark Lawrence): ongoing/8 -> completed/3. The
-- Book That Wouldn't Burn (2023), The Book That Broke the World (2024),
-- The Book That Held Her Heart (2025) -- Wikipedia confirms all 3
-- planned installments published, trilogy complete.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'The Library Trilogy';

-- Metro (Dmitry Glukhovsky): ongoing/9 -> completed/3. Wikipedia
-- confirms Glukhovsky's own core trilogy (Metro 2033, Metro 2034, Metro
-- 2035) with 2035 explicitly described as "the final novel of the main
-- Metro trilogy." The much larger multi-author "Metro 2033 Universe"
-- spin-off novels by other writers are a separate body of work, not
-- counted here, same convention as every other shared-universe case
-- this task has handled.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Metro';

-- The Long Earth (Terry Pratchett & Stephen Baxter): ongoing/7 ->
-- completed/5. Wikipedia confirms 5 novels (The Long Earth 2012 through
-- The Long Cosmos 2016); Pratchett died in 2015 during the series but
-- the final book was completed and released in 2016, bringing the
-- collaboration to a conclusion.
update series set status = 'completed', book_count = 5, updated_at = now()
where name = 'The Long Earth';

-- Binti (Nnedi Okorafor): ongoing/7 -> completed/3. Wikipedia confirms a
-- complete trilogy: Binti (2015), Binti: Home (2017), Binti: The Night
-- Masquerade (2018).
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Binti';

-- Empire of the Vampire (Jay Kristoff): book_count only, 7 -> 3 (status
-- 'completed' already correct). Wikipedia confirms the trilogy concluded
-- with Empire of the Dawn (October 2025), the "third and final
-- installment."
update series set book_count = 3, updated_at = now()
where name = 'Empire of the Vampire';

-- The Books of Babel (Josiah Bancroft): book_count only, 7 -> 4 (status
-- 'completed' already correct). Wikipedia confirms 4 novels (Senlin
-- Ascends, Arm of the Sphinx, The Hod King, The Fall of Babel 2021),
-- explicitly called "the finale of the series."
update series set book_count = 4, updated_at = now()
where name = 'The Books of Babel';

-- Moties (Larry Niven & Jerry Pournelle): book_count only, 6 -> 3.
-- Wikipedia confirms 3 books (The Mote in God's Eye 1974, The Gripping
-- Hand 1993, and Outies 2010, an authorized sequel written by Jerry
-- Pournelle's daughter Jennifer). No completion statement found --
-- status left 'ongoing' on absence of evidence, same convention as
-- other deceased/inactive-author cases this task has handled (Old
-- Kingdom, Elric Saga).
update series set book_count = 3, updated_at = now()
where name = 'Moties';

-- Gone (Michael Grant): ongoing/7 -> completed/6. Wikipedia confirms the
-- main 6-book series (Gone, Hunger, Lies, Plague, Fear, Light,
-- 2008-2013) is complete; the separate "Monster Trilogy" (aka "Season
-- Two": Monster, Villain, Hero, 2017-2019) is an explicitly distinct
-- continuation, not part of this numbered sequence, same
-- shared-universe-vs-leaf-series convention this task has applied
-- throughout.
update series set status = 'completed', book_count = 6, updated_at = now()
where name = 'Gone';
