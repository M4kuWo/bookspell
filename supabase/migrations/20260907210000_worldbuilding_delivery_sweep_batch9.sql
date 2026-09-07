-- execution-DNA trope sweep, worldbuilding delivery batch 9 of the
-- candidate pool (dense-worldbuilding books). 6 books reviewed against
-- the presentation-of-delivery evidence standard; all 6 had clean
-- enough real discourse to tag (5 clean, 1 disputed).
--
-- Candidate list confirmed against a freshly saved, complete query
-- result this batch (not a truncated console view) -- see the
-- 2026-09-07 batch 11 process-note log entry for why that check
-- matters now.

-- Direct, repeated, clean: "page after page of technical detail,"
-- explicit "info-dumps," reviewers noting the first two-thirds
-- "consists mostly of exposition" and could have been 200-300 pages
-- shorter without it.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Seveneves', 'Neal Stephenson')
on conflict do nothing;

-- Direct, clean: explicitly described as taking a "minimalist approach
-- to explanation," "avoids infodumps," trusts the reader "to keep up"
-- rather than explaining jargon and concepts directly.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ninefox Gambit', 'Yoon Ha Lee')
on conflict do nothing;

-- Direct, clean: readers "are not given much information about why
-- things are the way they are" and this is explicitly called out as
-- "intentional," a defining characteristic of Erikson's approach --
-- withheld exposition, discovery/mystery over narrator explanation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Deadhouse Gates', 'Steven Erikson')
on conflict do nothing;

-- Direct, clean: "expository monologues and dialogues... provide
-- extensive world-building," described as "a philosophy thesis with
-- characters," each chapter headed by an in-world lecture/journal
-- excerpt "waxing lyrical on philosophy, governance, politics" --
-- narrator/character lecture, not discovery.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('God Emperor of Dune', 'Frank Herbert')
on conflict do nothing;

-- Direct: explicit contrast statement -- "rather than heavy exposition,
-- an entire alien culture was so well developed and explained that any
-- reader could easily understand it" -- delivered through story and
-- character rather than narrator lecture.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Use of Weapons', 'Iain M. Banks')
on conflict do nothing;

-- Weak/disputed: one strand of discourse praises worldbuilding that
-- "focuses on CHARACTERS rather than every planet and ship and
-- technical science thing," but another reviewer calls the same book's
-- worldbuilding "less adventurous and more obvious" than book 1 --
-- real but genuinely mixed on the delivery mechanism itself.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ancillary Sword', 'Ann Leckie')
on conflict do nothing;
