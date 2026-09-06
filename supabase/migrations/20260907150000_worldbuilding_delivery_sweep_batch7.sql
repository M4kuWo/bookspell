-- execution-DNA trope sweep, worldbuilding delivery batch 7. 8 books
-- reviewed; 6 tagged, 2 left untagged (A Fire Upon the Deep, Dungeon
-- Crawler Carl -- the former's discourse addressed prose density/
-- quality rather than delivery mechanism specifically; the latter's
-- LitRPG system-notification text is a distinct, already-separately-
-- captured form category rather than a clean fit for either side of
-- this trope pair).

-- worldbuilding_via_exposition_dump -----------------------------------

-- Direct, explicit contrast with its own predecessor: "unlike the
-- original Dune where Herbert left some worldbuilding elements
-- unexplained, allowing readers to speculate, Dune Messiah provides
-- more complete exposition." A real example of a sequel moving to the
-- opposite side of this trope pair from book 1 (Dune, already tagged
-- woven).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Dune Messiah', 'Frank Herbert')
on conflict do nothing;

-- Weak/mixed: one direct complaint about a lack of "organic
-- integration... no pseudo-technology info-dumping," but other reviews
-- praise the "fascinating exposition" and thematic weaving positively.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Binti', 'Nnedi Okorafor')
on conflict do nothing;

-- Same exact dialogue-heavy pattern as Foundation/Foundation and
-- Empire (both already tagged 0.6): "reliance on dialogue for
-- exposition," "very dialogue-heavy."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Forward the Foundation', 'Isaac Asimov')
on conflict do nothing;

-- Direct, repeated: "large sections... devoted to exposition," readers
-- explicitly noting "more exposition in this sequel" than book 1
-- (Children of Time, already tagged woven at low confidence/disputed)
-- leading to "uneven pacing."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Children of Ruin', 'Adrian Tchaikovsky')
on conflict do nothing;

-- Weaker/mixed: "exposition can be heavy at times," bloat complaints
-- ("cutting a hundred pages would not have been hard"), but tempered
-- by real appreciation for the depth of lore among genre readers.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Empire of Silence', 'Christopher Ruocchio')
on conflict do nothing;

-- worldbuilding_woven_into_narrative --------------------------------

-- Direct, clean: "discovering the world alongside the monks who were
-- trying to piece together the history of their own world," "dropped
-- into a world they couldn't recognize" -- the same discovery-based
-- pattern as Gideon the Ninth/Gardens of the Moon/The Goblin Emperor.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Canticle for Leibowitz', 'Walter M. Miller Jr.')
on conflict do nothing;
