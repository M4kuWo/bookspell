-- series.status/book_count fix, batch 10 (CLDA, 2026-09-14)
-- Continuing the P2 task documented in docs/TODO.md ("series.status/book_count
-- is systemically wrong catalog-wide"): series.status defaults to 'ongoing'
-- whenever Hardcover's is_completed flag isn't explicitly true, and
-- series.book_count is Hardcover's raw edition/omnibus/box-set count, not a
-- curated mainline-installment count. Doesn't affect scoring (neither field
-- is read by scripts/recommend.py) -- display-only bug in tools/catalog-review/.
--
-- Candidates ranked using Hardcover's raw book_count descending (per batches
-- 8-9's finding: the "books currently linked in our catalog" signal has
-- saturated at 1 book/series catalog-wide), excluding the 189 names already
-- checked in batches 1-9 plus the 40 still-unsettled flagged names carried
-- from batch 9. Every value below verified via live web search before being
-- written; each book1 identity spot-checked against the row's own linked
-- `books` row to rule out a wrong-book-linkage bug before trusting the
-- fix (all 15 matched cleanly this batch).
--
-- 15 real fixes, 0 confirmed-already-correct.

BEGIN;

-- The Powerless Trilogy (Lauren Roberts) -- ongoing/19 -> completed/3.
-- Mainline trilogy is Powerless, Reckless, Fearless; "Powerful" and
-- "Fearful" are same-timeline novellas from a different POV, excluded per
-- this task's companion-novella convention. Author has confirmed the
-- series (trilogy + 2 companion novellas) as complete.
UPDATE series SET status = 'completed', book_count = 3
WHERE name = 'The Powerless Trilogy';

-- Zodiac Academy (Peckham & Valenti) -- book_count only, 19 -> 9.
-- Status was already correctly 'completed'. The core Vega-twins arc is 9
-- numbered mainline books (The Awakening ... Restless Stars); "Wrath and
-- Ruin" and other spin-off trilogies set later in the same universe are
-- separate series, not counted here.
UPDATE series SET book_count = 9
WHERE name = 'Zodiac Academy';

-- The Lost Fleet (Jack Campbell) -- ongoing/18 -> completed/6.
-- The original mainline series (Dauntless ... Victorious) is 6 novels,
-- completed 2010. "Beyond the Frontier" and "Lost Stars" are separate
-- spin-off series continuing the same universe/character, not more of
-- this series.
UPDATE series SET status = 'completed', book_count = 6
WHERE name = 'The Lost Fleet';

-- Dark Olympus (Katee Robert) -- ongoing/18 -> completed/10.
-- 10 mainline installments (Neon Gods ... Shattered Gods, June 2026);
-- "Stone Heart" is a 0.5 prequel novella, excluded per convention. Author
-- and publisher confirm the series concluded with Shattered Gods.
UPDATE series SET status = 'completed', book_count = 10
WHERE name = 'Dark Olympus';

-- The Passage (Justin Cronin) -- ongoing/16 -> completed/3.
-- The Passage, The Twelve, The City of Mirrors -- a confirmed-closed
-- trilogy (2010-2016).
UPDATE series SET status = 'completed', book_count = 3
WHERE name = 'The Passage';

-- The Bone Season (Samantha Shannon) -- book_count only, 15 -> 5.
-- Status correctly stays 'ongoing': 5 of a planned 7 novels published so
-- far (through The Dark Mirror, 2025), book 6 ("The Moth Reborn") already
-- scheduled for early 2027.
UPDATE series SET book_count = 5
WHERE name = 'The Bone Season';

-- Thursday Next (Jasper Fforde) -- ongoing/15 -> completed/8.
-- 8 books total; "Dark Reading Matter" (Sept 2026) explicitly marketed as
-- the final novel in the series.
UPDATE series SET status = 'completed', book_count = 8
WHERE name = 'Thursday Next';

-- The Talents Trilogy (J.M. Miro) -- ongoing/11 -> completed/3.
-- Dark fantasy trilogy (Ordinary Monsters, Bringer of Dust, The Cairndale
-- Orphan) -- NOT Octavia Butler's Earthseed/"Parable of the Talents"
-- (that's the already-fixed/flagged "Earthseed" row); confirmed via the
-- row's own linked book1 ("Ordinary Monsters") before writing this. All 3
-- planned installments now published.
UPDATE series SET status = 'completed', book_count = 3
WHERE name = 'The Talents Trilogy';

-- St. Leibowitz (Walter M. Miller Jr.) -- ongoing/14 -> completed/2.
-- A Canticle for Leibowitz (1959) and Saint Leibowitz and the Wild Horse
-- Woman (1997, the only sequel Miller wrote before his 1996 death).
UPDATE series SET status = 'completed', book_count = 2
WHERE name = 'St. Leibowitz';

-- The Wicked Years (Gregory Maguire) -- ongoing/14 -> completed/4.
-- Wicked, Son of a Witch, A Lion Among Men, Out of Oz -- the core
-- 4-book run, completed 2011. The later "Another Day" trilogy
-- (2021-2023) continues the wider Wicked universe as a separate series,
-- not more of this one.
UPDATE series SET status = 'completed', book_count = 4
WHERE name = 'The Wicked Years';

-- The Darkest Minds (Alexandra Bracken) -- ongoing/14 -> completed/4.
-- The Darkest Minds, Never Fade, In the Afterlight, plus The Darkest
-- Legacy (2018, same universe/new protagonist, published as book 4 of
-- this series rather than a separately branded spin-off). No further
-- entries announced since 2018.
UPDATE series SET status = 'completed', book_count = 4
WHERE name = 'The Darkest Minds';

-- Lady Astronaut Universe (Mary Robinette Kowal) -- book_count only,
-- 14 -> 4. Status correctly stays 'ongoing': 4 novels published
-- (The Calculating Stars ... The Martian Contingency), a 5th confirmed
-- for 2026.
UPDATE series SET book_count = 4
WHERE name = 'Lady Astronaut Universe';

-- The Dandelion Dynasty (Ken Liu) -- ongoing/14 -> completed/4.
-- The Grace of Kings, The Wall of Storms, The Veiled Throne, Speaking
-- Bones (2022) -- publisher-confirmed as the final installment.
UPDATE series SET status = 'completed', book_count = 4
WHERE name = 'The Dandelion Dynasty';

-- Codex Alera (Jim Butcher) -- ongoing/13 -> completed/6.
-- Furies of Calderon through First Lord's Fury (2004-2009), a
-- long-completed 6-book epic fantasy series.
UPDATE series SET status = 'completed', book_count = 6
WHERE name = 'Codex Alera';

-- The Invisible Library (Genevieve Cogman) -- book_count only, 11 -> 8.
-- Status was already correctly 'completed'. 8 books total (The Invisible
-- Library ... The Untold Story, 2021).
UPDATE series SET book_count = 8
WHERE name = 'The Invisible Library';

COMMIT;
