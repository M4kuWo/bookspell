-- execution-DNA trope sweep, worldbuilding delivery batch 11 of the
-- candidate pool. 8 books reviewed against the presentation-of-delivery
-- evidence standard; 5 tagged (3 clean woven, 1 clean exposition-dump,
-- 1 disputed). 3 left untagged (The Wandering Inn -- no real discourse
-- found addressing delivery mechanism specifically; A Desolation Called
-- Peace -- only generic "woven prose" praise, not specific to
-- worldbuilding delivery; Blood Over Bright Haven -- a single vague
-- mention of an early "struggle" with exposition, not enough to anchor
-- a tag either way).

-- Direct, clean, repeated: nuances "revealed subtly and unobtrusively
-- without overt clunky exposition," praised for "a talent for
-- understatement" -- the reader "teases out" the world's rules over
-- several chapters rather than being told.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The City & The City', 'China Miéville')
on conflict do nothing;

-- Direct, clean, repeated: reviewers describe an explicit recurring
-- formula -- "action demonstrates a new feature... then an info dump
-- explains it in detail" -- with "heavy, lengthy exposition explaining
-- the magic system" that "drags it down."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Foundryside', 'Robert Jackson Bennett')
on conflict do nothing;

-- Weak/disputed: one strand praises rules introduced "naturally as the
-- plot unfolds," but another reviewer needed a glossary "just to keep
-- up," criticizing the "need to over-explain every aspect of his
-- world" -- real discourse, genuinely split on which read is accurate.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Tainted Cup', 'Robert Jackson Bennett')
on conflict do nothing;

-- Direct, clean, repeated: exposition "delivered to the reader when
-- the characters are required to know," conversations "feel organic,"
-- "never giving information for the sake of information," "explanations
-- never feeling forced," much of it "given through action."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Sword of Kaigen', 'M.L. Wang')
on conflict do nothing;

-- Direct: explicit contrast statement -- "rather than dwelling on
-- heavy exposition," the worldbuilding is described as "naturally
-- woven into the narrative through character development and
-- historical authenticity."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('She Who Became the Sun', 'Shelley Parker-Chan')
on conflict do nothing;
