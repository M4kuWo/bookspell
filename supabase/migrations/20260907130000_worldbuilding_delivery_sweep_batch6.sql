-- execution-DNA trope sweep, worldbuilding delivery batch 6. 6 books
-- reviewed; all 6 tagged (no skips this batch).

-- worldbuilding_woven_into_narrative --------------------------------

-- Direct: "not in awkward info dumps but naturally: through a young
-- man's eyes as he learns about his world, through stories told by
-- various characters" -- the frame-narrative-as-discovery pattern,
-- consistent with Piranesi/A Natural History of Dragons/Hyperion.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Name of the Wind', 'Patrick Rothfuss')
on conflict do nothing;

-- Extremely direct: "no dumps of exposition," Wolfe "trusting" readers,
-- narrator "does not bother to spoon-feed" -- one of the cleanest
-- possible examples, matched by the book's famously oblique, demanding
-- style.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Shadow of the Torturer', 'Gene Wolfe')
on conflict do nothing;

-- Weak/thin: one specific "tightly woven plotline" quote, but most
-- discourse addresses overall quality/blandness rather than the
-- specific discovery-vs-exposition delivery mechanism.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Player of Games', 'Iain M. Banks')
on conflict do nothing;

-- Genuinely disputed within the same source: "exposition unfolds
-- naturally through conversations" directly contradicted by a specific
-- complaint that every reference to history/myth triggers "a
-- relatively long story describing the event" -- a real, narrower
-- info-dump pattern layered on top of an otherwise natural delivery.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Priory of the Orange Tree', 'Samantha Shannon')
on conflict do nothing;

-- worldbuilding_via_exposition_dump -----------------------------------

-- Direct, clean: "lengthy passages of technical exposition about...
-- quantum mechanics... particle physics," readers comparing it to
-- "reading a physics textbook."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Three-Body Problem', 'Liu Cixin')
on conflict do nothing;

-- Weaker/mixed: the narrator explicitly addresses the reader with
-- extended philosophical exposition (Mycroft narrates directly to the
-- audience) -- a real, formal exposition device, though reviewers
-- specifically credit the book with never fully tipping into infodump.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Too Like the Lightning', 'Ada Palmer')
on conflict do nothing;
