-- execution-DNA trope sweep, worldbuilding delivery batch 15 of the
-- candidate pool. 7 books reviewed against the presentation-of-delivery
-- evidence standard; 6 tagged (5 clean woven, 2 disputed exposition-
-- dump -- one book, Homeland, tagged on both sides). 1 left untagged
-- (A Little Hatred -- discourse was too vague/generic about exposition
-- specifically, mostly praising worldbuilding breadth).

-- Direct, clean, repeated: "lack of lengthy exposition," information
-- "never overwhelming and never distracts from the plot," praised for
-- its "measured, character-focused approach... without resorting to
-- information dumps."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Blood Song', 'Anthony Ryan')
on conflict do nothing;

-- Direct, clean, repeated: setting and magic "gently weaves... into
-- character interactions seamlessly, without overwhelming readers,"
-- explicitly "rather than relying on info dumps."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Promise of Blood', 'Brian McClellan')
on conflict do nothing;

-- Direct, clean: "intricate without feeling cumbersome," pieces
-- "fall into place over time," integrating "seamlessly... rather than
-- presenting exposition in a heavy-handed manner" (delivered partly via
-- epigraphs, similar to other footnote/epigraph-style devices already
-- tagged woven elsewhere in this sweep).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Justice of Kings', 'Richard Swan')
on conflict do nothing;

-- Direct, clean: "stingy with its exposition," with the closest thing
-- to lore delivered as character debates on magic theory --
-- specifically contrasted against "traditional info dumps."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Atlas Six', 'Olivie Blake')
on conflict do nothing;

-- Direct, clean (majority read): despite having to build an entire
-- drow society from scratch, "the pace never sags" and "the exposition
-- rarely feels contrived."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Homeland', 'R. A. Salvatore')
on conflict do nothing;

-- Weak/disputed counterpoint on the same book: a specific, real
-- exception -- "Salvatore steps away from Drizzt to confide in the
-- reader about seasonal change," a narrator aside reviewers say
-- "badly break[s] the flow" -- real, but a minority complaint against
-- the book's otherwise-woven reputation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Homeland', 'R. A. Salvatore')
on conflict do nothing;

-- Weak/disputed: one strand insists the slow ~200-page opening "does
-- not feel like a lore dump" and is "woven into the narrative as
-- stories-within-stories," but other reviewers call it "exposition-
-- heavy" and say the story "immediately stops for more world
-- building" -- a real, clean split on the same stretch of book.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Dragonbone Chair', 'Tad Williams')
on conflict do nothing;
