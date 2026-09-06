-- execution-DNA trope sweep, romance_tone batch 9 of the candidate pool.
-- 10 books reviewed against the strict presentation-specific evidence
-- standard; 7 tagged, 3 left untagged (Legend, Black Leopard Red Wolf,
-- A Study in Drowning -- discourse addressed series-wide impressions,
-- overall prose subtlety, or craft-quality complaints rather than
-- presentation-of-emotion specifically for this exact book).

-- Weak/disputed: "tepid" love triangle and "very real, didn't happen
-- in an instant" both point toward restraint, but the underlying
-- discourse is really about pacing/believability rather than a clean
-- tone-presentation read.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Matched', 'Ally Condie')
on conflict do nothing;

-- Weak: "restrained tension and emotional connection... not explicit"
-- is real but conflates heat-level (excluded evidence) with tone; the
-- rest of the discourse focuses on sexual tension/chemistry rather
-- than declaration-style vs. restraint specifically.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Queen of Shadows', 'Sarah J. Maas')
on conflict do nothing;

-- Direct: "clear, controlled and understated prose," "restraint and
-- subtlety" specifically describing how the Tommy/Kathy romance
-- unfolds -- a separate, later complaint about a melodramatic
-- REVELATION scene concerns the book's sci-fi exposition, not this
-- relationship's presentation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Never Let Me Go', 'Kazuo Ishiguro')
on conflict do nothing;

-- Direct: "restrained, with simple allusions," "thoughtful and warm
-- rather than overtly dramatic."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('In the Lives of Puppets', 'TJ Klune')
on conflict do nothing;

-- Direct: "read like a parody of YA romance," "forced angst" --
-- consistent with City of Bones/Ashes/Glass, all already tagged
-- melodramatic, same series/pairing.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Fallen Angels', 'Cassandra Clare')
on conflict do nothing;

-- Extremely direct, repeated: "melodramatic," "self-consciously
-- melodramatic in both plot and writing," "soap opera-esque," "over-
-- the-top angst."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('One Dark Window', 'Rachel Gillig')
on conflict do nothing;

-- Direct, repeated: the climactic scene "dragging out melodramatically,"
-- "overly sentimental," "the most cliche scene I have ever read."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ready Player One', 'Ernest Cline')
on conflict do nothing;
