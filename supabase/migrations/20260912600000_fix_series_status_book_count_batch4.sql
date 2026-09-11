-- Fourth batch of the series.status/book_count catalog-wide fix
-- (docs/TODO.md's P2 item; root cause documented 2026-09-08, batch 1
-- landed 2026-09-11 in 20260911190000_..._batch1.sql, batch 2 and
-- batch 3 landed 2026-09-12 in 20260912100000_..._batch2.sql and
-- 20260912400000_..._batch3.sql).
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
-- all 67 names checked across batches 1-3 plus the 3 flagged-but-not-
-- fixed names (Hogwarts Library, The Roald Dahl Classic Collection,
-- The Riyria Revelations (Omnibus)) carried over from batch 3. Worked
-- down the resulting list (mostly 3-4-book ties, same flat-tie
-- situation batch 3 hit) in ranked order. 17 needed a real fix, 21 more
-- checked and confirmed already correct, 2 flagged as likely out-of-
-- scope (not fixed, not this task's call), 1 (Saga) skipped per
-- existing out-of-scope-graphic-novel policy. Verified via live web
-- search before writing anything, same standard as batches 1-3.
--
-- book_count convention (matching batches 1-3): count real PUBLISHED
-- mainline installments only -- not companion novellas/short-story
-- collections, not unpublished forthcoming books, regardless of
-- whether an unpublished/companion title already has its own row in
-- our books/series tables.
--
-- Candidates checked this batch and confirmed ALREADY CORRECT (NOT in
-- this file): Wayfarers (4, completed -- Becky Chambers' quartet, no
-- announced 5th), Remembrance of Earth's Past (3, completed -- Liu
-- Cixin's own trilogy; "The Redemption of Time" is a fan-authorized
-- sequel by a different author, Baoshu, not counted), Sprawl (3,
-- completed -- Gibson's Neuromancer/Count Zero/Mona Lisa Overdrive;
-- "Burning Chrome" is a linked short-story collection, not a 4th
-- novel), Mistborn Era Two/Wax and Wayne (4, completed -- The Lost
-- Metal confirmed as this era's finale), Hyperion Cantos (4,
-- completed), The Inheritance Cycle (4, completed -- Murtagh (2023) is
-- explicitly marketed as a standalone/duology-starter in the same
-- world, not book 5 of the Cycle), The Lord of the Rings (3,
-- completed), The Farseer Trilogy (3, completed), Divergent (3,
-- completed), The Poppy War (3, completed), The Broken Empire (3,
-- completed), The Broken Earth (3, completed), The Shadow and Bone
-- Trilogy (3, completed), The Folk of the Air (3, completed), Book of
-- the Ice (3, completed -- ingested/tagged just prior to this batch),
-- His Dark Materials (3, completed), Book of the Ancestor (3,
-- completed), The Green Bone Saga (3, completed), The First Law (3,
-- completed), The Hunger Games (5, ongoing -- The Hunger Games,
-- Catching Fire, Mockingjay, The Ballad of Songbirds and Snakes,
-- Sunrise on the Reaping all published; Collins hasn't ruled out more),
-- Silo (3, completed -- Hugh Howey has mentioned a possible future
-- trilogy extending the universe in interviews/AMAs, but no confirmed
-- title or date exists yet, so per the Old Kingdom precedent
-- (absence of a completion statement is not itself evidence of an
-- upcoming book) this does not meet the bar to flip away from
-- 'completed').
--
-- Flagged as likely OUT OF SCOPE for this catalog (not fixed here --
-- not this task's call, surfacing for the repo owner): Robert Langdon
-- (Dan Brown) and The Inheritance Games (Jennifer Lynn Barnes) both
-- turned up in the ranking query with real catalog rows, but neither
-- series is sci-fi/fantasy -- Langdon is a techno-thriller/mystery
-- series, Inheritance Games a contemporary YA mystery. Likely the same
-- kind of Hardcover genre-search false positive as the
-- Shogun/Screwtape removals (see
-- 20260909100000_remove_out_of_scope_shogun_screwtape.sql). Left
-- untouched (status/book_count not fixed) pending a scope decision --
-- do not force-tag or delete without repo owner confirmation per
-- CLAUDE.md's catalog-scope policy.
--
-- 'Saga' (out-of-scope graphic novel) also seen in the ranked list,
-- deliberately left untouched per existing policy.
--
-- Candidates seen in the ranked list but NOT researched (left for
-- batch 5, no assumption made either way): King of Scars, Ninth House,
-- The Captive's War, The Kane Chronicles, An Ember in the Ashes, The
-- Rain Wild Chronicles, The Atlas, Earthseed.
--
-- Two data-integrity observations noticed in passing (NOT this task's
-- fix -- a different bug class from status/book_count, flagging for
-- visibility only): "The Lord of the Rings" and "The Farseer Trilogy"
-- each have a duplicate row in `books` where the omnibus/series-titled
-- edition (e.g. a book literally titled "The Lord of the Rings", or
-- "The Farseer Trilogy") sits alongside the individual volumes at the
-- same `position_in_series`. Same pattern briefly seen on "Monk and
-- Robot" below. Not touched here -- a `books`-table duplicate-row
-- question, not a `series.status`/`book_count` one.

-- Shades of Magic (V.E. Schwab) -- 3 books (A Darker Shade of Magic, A
-- Gathering of Shadows, A Conjuring of Light), 2015-2017, completed.
-- "Threads of Power" (starting with The Fragile Threads of Power,
-- 2023) is a separate sequel trilogy in the same universe/world, its
-- own catalog series row, not a continuation of this one. Was
-- 'ongoing'/5.
update series set status = 'completed', book_count = 3
where name = 'Shades of Magic';

-- Night Angel (Brent Weeks) -- 3 books (The Way of Shadows, Shadow's
-- Edge, Beyond the Shadows), 2008-2009, completed. "Night Angel
-- Nemesis" (2024) and its upcoming sequel are explicitly a new,
-- separate series ("The Kylar Chronicles") set in the same world, not
-- a direct continuation/4th book of this original trilogy. Was
-- 'ongoing'/20 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'Night Angel';

-- Gentleman Bastard (Scott Lynch) -- 3 published books (The Lies of
-- Locke Lamora, Red Seas Under Red Skies, The Republic of Thieves),
-- 2006-2013; status left 'ongoing' -- Lynch gave a substantial update
-- in a July 2026 interview confirming he's actively revising "The
-- Thorn of Emberlain" (book 4), still no release date. Was
-- book_count=7 (a raw Hardcover edition/format count).
update series set book_count = 3
where name = 'Gentleman Bastard';

-- Covenant of Steel (Anthony Ryan) -- 3 books (The Pariah, The Martyr,
-- The Traitor), 2021-2023, completed -- The Traitor confirmed as the
-- trilogy's conclusion. Was 'ongoing'/3 -- book_count was already
-- correct, only status was wrong.
update series set status = 'completed'
where name = 'Covenant of Steel';

-- The Locked Tomb (Tamsyn Muir) -- 3 published books (Gideon the
-- Ninth, Harrow the Ninth, Nona the Ninth), 2019-2022; status
-- corrected from 'completed' back to 'ongoing' -- "Alecto the Ninth"
-- (the planned 4th and final book) has NOT been published as of this
-- migration (2026-09-12): no confirmed release date from
-- Tor/Macmillan/Muir, only an unconfirmed retailer-listing date of
-- 2026-10-12 that postdates today. Was 'completed'/4 -- both fields
-- wrong (this looks like Hardcover data prematurely marking the series
-- complete/counting an unreleased book, the mirror image of the usual
-- ongoing-by-default bug).
update series set status = 'ongoing', book_count = 3
where name = 'The Locked Tomb';

-- Southern Reach (Jeff VanderMeer) -- 4 published books (Annihilation,
-- Authority, Acceptance, Absolution), 2014-2024, completed --
-- Absolution (2024) is explicitly marketed as "the final word" /"last
-- installment" of the series. Was 'ongoing'/4 -- book_count was
-- already correct, only status was wrong.
update series set status = 'completed'
where name = 'Southern Reach';

-- MaddAddam (Margaret Atwood) -- 3 books (Oryx and Crake, The Year of
-- the Flood, MaddAddam), 2003-2013, completed. Was 'ongoing'/7 (a raw
-- Hardcover edition/format count).
update series set status = 'completed', book_count = 3
where name = 'MaddAddam';

-- Artemis Fowl (Eoin Colfer) -- 8 books (Artemis Fowl through The Last
-- Guardian), 2001-2012, completed -- The Last Guardian confirmed as
-- the original 8-book series' final book. "The Fowl Twins" is a
-- separate spin-off trilogy with different lead characters, not
-- counted. Was 'ongoing'/17 (a raw Hardcover edition/format count).
update series set status = 'completed', book_count = 8
where name = 'Artemis Fowl';

-- Monk and Robot (Becky Chambers) -- 2 books (A Psalm for the
-- Wild-Built, A Prayer for the Crown-Shy), 2021-2022, completed --
-- confirmed as a deliberately closed 2-book duology, no more planned.
-- Was 'ongoing'/4. (Same duplicate-omnibus-row pattern as LOTR/Farseer
-- noted above was seen here too -- a "Monk and Robot" titled row
-- alongside "A Psalm for the Wild-Built" at position 1 -- not touched,
-- separate bug class.)
update series set status = 'completed', book_count = 2
where name = 'Monk and Robot';

-- Time Master (Louise Cooper) -- 3 books (The Initiate, The Outcast,
-- The Master), 1985-1986, completed. The "Chaos Gate" (sequel) and
-- "Star Shadow" (prequel) trilogies are separate, related series in
-- the same universe, not additional Time Master installments -- not
-- counted here. Was 'ongoing'/10 (a raw Hardcover edition/format
-- count).
update series set status = 'completed', book_count = 3
where name = 'Time Master';

-- Ash and Sand (Richard Nell) -- 3 books (Kings of Paradise, Kings of
-- Ash, Kings of Heaven), 2018-2020, completed. Was 'ongoing'/2 -- both
-- fields wrong.
update series set status = 'completed', book_count = 3
where name = 'Ash and Sand';

-- Children of Time (Adrian Tchaikovsky) -- 4 published books (Children
-- of Time, Children of Ruin, Children of Memory, Children of Strife),
-- 2015-2026 (Children of Strife released March 2026); status left
-- 'ongoing' -- no statement that the series is now closed at 4, and
-- Tchaikovsky has already extended it once from the original trilogy
-- shape. Was book_count=3 (catalog only has the original 3 books
-- linked yet -- a separate catalog-completeness/ingestion gap, not
-- fixed here).
update series set book_count = 4
where name = 'Children of Time';

-- The Tawny Man (Robin Hobb) -- 3 books (Fool's Errand, The Golden
-- Fool, Fool's Fate), 2001-2003, completed -- the third Realm of the
-- Elderlings sub-trilogy, closed with Fool's Fate. Was 'ongoing'/4.
update series set status = 'completed', book_count = 3
where name = 'The Tawny Man';

-- He Who Fights with Monsters (Shirtaloon/Travis Deverell) -- 12
-- published books as of this migration (book 13 confirmed for
-- 2026-10-06, not yet published); status 'ongoing' was already
-- correct. Was book_count=NULL.
update series set book_count = 12
where name = 'He Who Fights with Monsters';

-- Earthsea Cycle (Ursula K. Le Guin) -- 5 mainline novels (A Wizard of
-- Earthsea, The Tombs of Atuan, The Farthest Shore, Tehanu, The Other
-- Wind), 1968-2001, completed; status was already correct. "Tales from
-- Earthsea" (2001) is a short-story collection, excluded per the
-- established book_count convention even though Le Guin's own
-- publisher groups it with "The Books of Earthsea" branding. Was
-- book_count=6 (counting the story collection as a 6th book,
-- inconsistent with how batches 1-3 have treated every other
-- collection-vs-mainline case, e.g. Cradle's "Threshold" or All
-- Souls' "The World of All Souls").
update series set book_count = 5
where name = 'Earthsea Cycle';

-- Secret Projects (Brandon Sanderson) -- 5 published books (Tress of
-- the Emerald Sea, The Frugal Wizard's Handbook for Surviving Medieval
-- England, Yumi and the Nightmare Painter, The Sunlit Man, Isles of
-- the Emberdark), 2023-2025; status left 'ongoing' -- this was
-- announced and delivered as a 4-book Kickstarter set, then a 5th was
-- added in 2024 with no statement that 5 is final, and Sanderson's
-- history here already includes one unannounced expansion, so per the
-- Old Kingdom/Silo precedent absence of a completion statement isn't
-- treated as evidence of closure. Was book_count=6 (a raw Hardcover
-- edition/format count).
update series set book_count = 5
where name = 'Secret Projects';

-- The Empyrean (Rebecca Yarros) -- 3 published books (Fourth Wing,
-- Iron Flame, Onyx Storm), 2023-2025; status 'ongoing' was already
-- correct -- Yarros has confirmed this is a planned 5-book series (the
-- ending is reportedly already plotted), with book 4 still being
-- written as of March 2026 and no release date yet. Was book_count=5
-- (the planned total, not the published count -- same category of
-- mistake batches 1-3 already fixed on The Empyrean's peers, e.g.
-- Villains/All Souls keeping an unpublished confirmed book out of the
-- count).
update series set book_count = 3
where name = 'The Empyrean';
