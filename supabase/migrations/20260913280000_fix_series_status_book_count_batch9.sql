-- series.status/book_count fix, batch 9 (16 series corrected).
-- Same root cause as batches 1-8 (see those migrations' headers and
-- docs/TODO.md's "series.status/book_count is systemically wrong
-- catalog-wide" entry): status defaults to 'ongoing' whenever
-- Hardcover's is_completed flag isn't explicitly true, and book_count
-- is Hardcover's raw edition/omnibus/box-set count rather than a
-- curated mainline-installment count. Neither field is read by
-- scripts/recommend.py -- display-only bug in tools/catalog-review/.
--
-- Candidate pool ranked by Hardcover's raw book_count descending
-- (batch 8's finding: our own catalog's "books currently linked" proxy
-- has saturated at 1 book/series for everything left), excluding the
-- 173 names checked across batches 1-8 plus the 24 still-unsettled
-- flagged names. Every value below verified via live web search
-- before being written -- no guessing.

-- The Horus Heresy (Warhammer 40k, Dan Abnett et al.): raw count 292
-- was an inflated Hardcover edition/format artifact. The main series
-- concluded Feb 2019 at 54 full-length novels (The Buried Dagger,
-- James Swallow) -- the continuation ("Siege of Terra") is a separate
-- series, not more Horus Heresy mainline installments.
update series set status = 'completed', book_count = 54, updated_at = now()
where name = 'The Horus Heresy';

-- Vorkosigan Saga (Publication Order) (Lois McMaster Bujold): 16 novels
-- (1986-2016) in this reading order, excluding the ~6 shorter
-- novellas/short works also set in the universe. Left 'ongoing' --
-- Bujold has not announced the series closed, only that nothing new has
-- shipped since Gentleman Jole and the Red Queen (2016)/The Flowers of
-- Vashnoi novella (2018); absence of a completion statement isn't
-- itself evidence to flip to 'completed' (Old Kingdom precedent, batch 3).
update series set book_count = 16, updated_at = now()
where name = 'Vorkosigan Saga (Publication Order)';

-- Oz (L. Frank Baum): our catalog's only linked book and author is Baum
-- himself. Baum wrote 14 Oz novels (1900-1920, Wonderful Wizard of Oz
-- through Glinda of Oz) before his death in 1919; the wider "Famous
-- Forty" (40 books, continued by Ruth Plumly Thompson and others after
-- Baum's death) is a different, multi-author extended-franchise
-- question, not this Baum-authored series row.
update series set status = 'completed', book_count = 14, updated_at = now()
where name = 'Oz';

-- Rivers of London (Ben Aaronovitch): 10 main numbered novels
-- (2011-2025, Rivers of London through Stone and Sky), excluding
-- companion novellas (What Abigail Did That Summer, The October Man,
-- etc.). Left 'ongoing' -- no completion statement found, series
-- actively continuing as of the 2025 release.
update series set book_count = 10, updated_at = now()
where name = 'Rivers of London';

-- The Plated Prisoner (Raven Kennedy): confirmed-complete 6-book dark
-- fantasy romance series (Gild through Goldfinch).
update series set status = 'completed', book_count = 6, updated_at = now()
where name = 'The Plated Prisoner';

-- Expeditionary Force (Craig Alanson): 19 main numbered novels
-- published through 2026 (Columbus Day through Ground State),
-- excluding bonus/supplementary titles. Left 'ongoing' -- actively
-- publishing, most recent entry released this year.
update series set book_count = 19, updated_at = now()
where name = 'Expeditionary Force';

-- Memory, Sorrow, and Thorn (Tad Williams): the original trilogy is 3
-- books (The Dragonbone Chair, Stone of Farewell, To Green Angel
-- Tower) -- To Green Angel Tower was split into two paperback volumes
-- for length, which is a print-format split of one novel, not two
-- separate books, same convention already applied elsewhere in this
-- task. status was already correctly 'completed'; only book_count
-- (a Hardcover raw-edition artifact) needed fixing.
update series set book_count = 3, updated_at = now()
where name = 'Memory, Sorrow, and Thorn';

-- Vampire Academy (Richelle Mead): confirmed-complete 6-book main
-- series (Vampire Academy through Last Sacrifice); Bloodlines is a
-- separate 6-book spin-off series, not more Vampire Academy books.
update series set status = 'completed', book_count = 6, updated_at = now()
where name = 'Vampire Academy';

-- Heechee Saga (Frederik Pohl): 5 novels (Gateway through The Boy Who
-- Would Live Forever, 1977-2004); Pohl died in 2013 with no further
-- entries, confirming completed.
update series set status = 'completed', book_count = 5, updated_at = now()
where name = 'Heechee Saga';

-- Laundry Files (Charles Stross): "The Regicide Report" (Jan 2026) is
-- explicitly confirmed as the 14th and FINAL book in the series --
-- a strong, unambiguous completion signal, not an absence-of-evidence
-- guess.
update series set status = 'completed', book_count = 14, updated_at = now()
where name = 'Laundry Files';

-- Magnus Chase and the Gods of Asgard (Rick Riordan): confirmed-complete
-- 3-book trilogy (The Sword of Summer through The Ship of the Dead,
-- 2015-2017); companion guidebooks excluded as non-mainline.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Magnus Chase and the Gods of Asgard';

-- The Trials of Apollo (Rick Riordan): status was already correctly
-- 'completed' (The Tower of Nero confirmed as the finale); book_count
-- was the Hardcover raw-edition artifact needing correction to the
-- real 5-book count.
update series set book_count = 5, updated_at = now()
where name = 'The Trials of Apollo';

-- Howl's Moving Castle (Diana Wynne Jones): confirmed-complete 3-book
-- "World of Howl" series (Howl's Moving Castle, Castle in the Air,
-- House of Many Ways); Jones died in 2011 with no further entries.
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Howl''s Moving Castle';

-- The Queen's Thief (Megan Whalen Turner): confirmed-complete 6-book
-- series (The Thief through Return of the Thief, 1996-2020), explicitly
-- marketed as the series' 20-years-in-the-making conclusion.
update series set status = 'completed', book_count = 6, updated_at = now()
where name = 'The Queen''s Thief';

-- Night's Dawn (Peter F. Hamilton): confirmed-complete 3-book trilogy
-- (The Reality Dysfunction, The Neutronium Alchemist, The Naked God,
-- 1996-1999).
update series set status = 'completed', book_count = 3, updated_at = now()
where name = 'Night''s Dawn';

-- Graceling Realm (Kristin Cashore): 5 novels (Graceling, Fire,
-- Bitterblue, Winterkeep, Seasparrow, through 2022) -- book_count only,
-- left 'ongoing' on absence of a completion statement (no announced
-- retirement or confirmed "final book" framing found), same
-- absence-of-evidence convention as Rivers of London/Vorkosigan Saga
-- above.
update series set book_count = 5, updated_at = now()
where name = 'Graceling Realm';
