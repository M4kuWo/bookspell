-- Batch 12 of the series.status/book_count catalog-wide fix (see docs/TODO.md
-- "series.status/book_count is systemically wrong catalog-wide" and
-- docs/project-log.md's per-batch entries for the full running history).
--
-- Root cause (unchanged since batch 1): series.status defaults to 'ongoing'
-- whenever Hardcover's is_completed flag isn't explicitly true; book_count is
-- Hardcover's raw edition/omnibus/box-set count, not a curated
-- mainline-installment count. Neither field is read by scripts/recommend.py --
-- display-only bug in tools/catalog-review/, no scoring impact.
--
-- Candidate pool for this batch: the "count(b.id) currently linked" ranking
-- signal remains saturated at 1 book/series catalog-wide (per batches 8-11's
-- finding), so candidates were ranked by Hardcover's raw book_count
-- descending, starting with batch 11's own unresearched tail (all still
-- checked-in this batch) then continuing into the fresh ranked list. Every
-- value below was verified via live web search (WebFetch against Wikipedia
-- and related sources; the WebSearch tool itself started this session
-- already at its 200/200 budget, exhausted by batch 11) before being
-- written -- no guessing.
--
-- 16 series needed a real fix (status+book_count or book_count-only):
--
-- The Celestial Kingdom (Sue Lynn Tan): ongoing/10 -> completed/2. A real
-- duology (Daughter of the Moon Goddess, Heart of the Sun Warrior) --
-- "Tales of the Celestial Kingdom" is a companion novella collection, not a
-- third mainline novel; no further books announced.
update series set status = 'completed', book_count = 2, updated_at = now()
where name = 'The Celestial Kingdom';

-- Craft Sequence (Publication Order) (Max Gladstone): ongoing/10 ->
-- completed/6. The original 6-book run (Three Parts Dead through The Ruin
-- of Angels) is complete; "The Craft Wars" (Dead Country, Wicked Problems,
-- Dead Hand Rule) is a separate follow-up series in the same universe, same
-- shape as Star Wars: Thrawn vs. Star Wars: The Thrawn Trilogy.
update series set status = 'completed', book_count = 6, updated_at = now()
where name = 'Craft Sequence (Publication Order)';

-- Raven's Shadow (Anthony Ryan): ongoing/10 -> completed/3 (Blood Song,
-- Tower Lord, Queen of Fire). "Raven's Blade" (The Wolf's Call, The Black
-- Song) is a distinct continuation series in the same universe, not more
-- Raven's Shadow books.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Raven''s Shadow';

-- The Raven Cycle (Maggie Stiefvater): ongoing/10 -> completed/4 (The Raven
-- Boys, The Dream Thieves, Blue Lily Lily Blue, The Raven King). The Dreamer
-- Trilogy is a separate sequel series, not part of this one.
update series set status = 'completed', book_count = 4, updated_at = now()
where name = 'The Raven Cycle';

-- Song of the Lioness (Tamora Pierce): ongoing/9 -> completed/4, a closed
-- quartet (1983-1988). Pierce's later Tortall series ("The Immortals" etc.)
-- are separate series, not more Song of the Lioness books.
update series set status = 'completed', book_count = 4, updated_at = now()
where name = 'Song of the Lioness';

-- Stephen Fry's Great Mythology: book_count only, 9 -> 4 (Mythos, Heroes,
-- Troy, Odyssey). Status stays 'ongoing' -- no completion statement found for
-- this tetralogy, absence of evidence isn't itself a completion signal.
update series set book_count = 4, updated_at = now()
where name = 'Stephen Fry''s Great Mythology';

-- Alcatraz vs. the Evil Librarians (Brandon Sanderson): book_count only,
-- 9 -> 6 (Alcatraz vs. the Evil Librarians, ...Scrivener's Bones, ...Knights
-- of Crystallia, ...Shattered Lens, ...the Dark Talent, Bastille vs. the
-- Evil Librarians). Status 'completed' left as-is (no source found
-- explicitly contradicting it, and the shift to a new lead character/title
-- in book 6 is consistent with a deliberate series closer).
update series set book_count = 6, updated_at = now()
where name = 'Alcatraz vs. the Evil Librarians';

-- Ringworld (Larry Niven): book_count only, 9 -> 4 (Ringworld, The Ringworld
-- Engineers, The Ringworld Throne, Ringworld's Children). "Fleet of Worlds"
-- (co-written with Edward M. Lerner) is a separate Known Space prequel/
-- sequel series, not more mainline Ringworld books.
update series set book_count = 4, updated_at = now()
where name = 'Ringworld';

-- Avalon (Chronological Order) (Marion Zimmer Bradley / Diana L. Paxson):
-- book_count only, 9 -> 7 (The Mists of Avalon, The Forest House, Lady of
-- Avalon, Priestess of Avalon, Ancestors of Avalon, Ravens of Avalon, Sword
-- of Avalon). Status stays 'ongoing' -- last book 2009, no explicit
-- completion statement found from Paxson (who continued solo after
-- Bradley's 1999 death), absence of evidence isn't a completion signal.
update series set book_count = 7, updated_at = now()
where name = 'Avalon (Chronological Order)';

-- The Machineries of Empire (Yoon Ha Lee): ongoing/9 -> completed/3 (Ninefox
-- Gambit, Raven Stratagem, Revenant Gun). "Hexarchate Stories" is a short
-- story/novella collection, not a fourth mainline novel.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'The Machineries of Empire';

-- Little Brother (Cory Doctorow): book_count only, 9 -> 3 (Little Brother,
-- Homeland, Attack Surface). Status stays 'ongoing' -- no completion
-- statement found.
update series set book_count = 3, updated_at = now()
where name = 'Little Brother';

-- The Mysterious Benedict Society (Trenton Lee Stewart): book_count only,
-- 9 -> 5 (the 4-book main series plus "The Extraordinary Education of
-- Nicholas Benedict", a real prequel novel counted the same way as the
-- already-established Port of Shadows/Black Company precedent; "Mr.
-- Benedict's Book of Perplexing Puzzles..." is a puzzle-book companion, not
-- a novel, excluded). Status stays 'ongoing' -- no completion statement
-- found.
update series set book_count = 5, updated_at = now()
where name = 'The Mysterious Benedict Society';

-- Leviathan (Scott Westerfeld): ongoing/8 -> completed/3 (Leviathan,
-- Behemoth, Goliath).
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Leviathan';

-- The Space Trilogy (C.S. Lewis): ongoing/9 -> completed/3 (Out of the
-- Silent Planet, Perelandra, That Hideous Strength) -- a closed trilogy from
-- the 1930s-40s.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'The Space Trilogy';

-- Spin (Robert Charles Wilson): book_count only, 9 -> 3 (Spin, Axis,
-- Vortex). Status 'completed' already correct.
update series set book_count = 3, updated_at = now()
where name = 'Spin';

-- The Legends of the First Empire (Michael J. Sullivan): book_count only,
-- 8 -> 6 (Age of Myth, Age of Swords, Age of War, Age of Legend, Age of
-- Death, Age of Empyre). Status 'completed' already correct.
update series set book_count = 6, updated_at = now()
where name = 'The Legends of the First Empire';

-- Truly Devious (Maureen Johnson): book_count only, 8 -> 5 (the original
-- trilogy -- Truly Devious, The Vanishing Stair, The Hand on the Wall --
-- plus the same-universe/same-sleuth follow-on mysteries The Box in the
-- Woods and Nine Liars, all published under this series' own Wikipedia
-- listing; a 6th book, "The Velvet Knife", is scheduled for 2026-10-13 but
-- not yet published as of this migration, so excluded from the count.
-- Status 'ongoing' already correct.
update series set book_count = 5, updated_at = now()
where name = 'Truly Devious';

-- 1 confirmed already correct via live search: The Chronicles of the Black
-- Company (Glen Cook) -- status 'completed'/book_count 10 both verified
-- right (Books of the North x3, Port of Shadows interquel, Books of the
-- South x2, Books of Glittering Stone x4 = 10; The Silver Spike is a
-- spin-off told from a different POV, excluded; "A Pitiless Rain" -- Lies
-- Weeping (2025), They Cry (2026) -- is explicitly labeled a distinct "New
-- Series" continuing the same universe, not more Black Company books, per
-- Glen Cook's own Wikipedia bibliography page). No UPDATE needed.
