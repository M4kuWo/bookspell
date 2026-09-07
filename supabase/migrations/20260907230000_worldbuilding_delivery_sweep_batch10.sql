-- execution-DNA trope sweep, worldbuilding delivery batch 10 of the
-- candidate pool. 7 books reviewed against the presentation-of-delivery
-- evidence standard; 6 tagged (2 clean woven, 2 clean exposition-dump,
-- 2 disputed at 0.2 -- one on each side), 1 left untagged (Ninth House
-- -- real discourse found, but it addressed worldbuilding DENSITY/depth,
-- not the delivery mechanism itself).
--
-- Candidate list confirmed against a freshly saved, complete query
-- result before picking any titles, per the batch-11 process fix.

-- Weak/disputed: majority discourse describes exposition kept "at a
-- minimum" and worldbuilding "woven" through the narrative rather than
-- info-dumps, but one reviewer directly describes the opening as
-- feeling like "planet info-dump, population: cardboard cutouts" --
-- real, but contested.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Fire Upon the Deep', 'Vernor Vinge')
on conflict do nothing;

-- Direct, clean: the book structurally requires "several lectures over
-- the course of the novel," lecture-style "calcas" appendices, and an
-- extensive invented vocabulary that needs a glossary readers must
-- consult "near constant[ly]" -- delivery is explicitly lecture-based.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Anathem', 'Neal Stephenson')
on conflict do nothing;

-- Weak/disputed: "several consecutive pages of loans, taxes and
-- commodity trading" and readers who "completely zone out during all
-- the meetings" point toward dense, lecture-like delivery, but other
-- reviewers found the same material "viscerally riveting" rather than
-- a slog -- real but mixed on how the mechanism actually reads.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Traitor Baru Cormorant', 'Seth Dickinson')
on conflict do nothing;

-- Direct, clean: the hidden world of gods is explicitly "woven
-- expertly into the main narrative" as Shadow gradually learns it
-- through interspersed stories and travel interludes, not narrator
-- exposition.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('American Gods', 'Neil Gaiman')
on conflict do nothing;

-- Direct, clean, widely discussed: the Council of Elrond chapter alone
-- is "nearly 50 pages of exposition," "mostly exposition" delivered as
-- "layers of reported speech," criticized for its "complete dearth of
-- action" -- a famous, oft-cited example of the book's characteristic
-- lecture/history-recitation delivery style.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Lord of the Rings', 'J.R.R. Tolkien')
on conflict do nothing;

-- Direct, clean, repeated: praised for setting up extensive characters
-- and locations "without it ever feeling like an info dump," character
-- growth "shown over a period of time, rather than told... in repeated
-- info-dumps" -- one reviewer's minor exception noted but not
-- treated as a genuine split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Malice', 'John Gwynne')
on conflict do nothing;
