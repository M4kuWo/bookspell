-- execution-DNA trope sweep, worldbuilding delivery batch 18 of the
-- candidate pool. 6 books reviewed against the presentation-of-delivery
-- evidence standard; 3 tagged (2 clean woven, 1 disputed exposition-
-- dump). 3 left untagged (Fairy Tale -- the only real criticism found
-- was about STORY pacing, "takes half the novel to get going," not
-- delivery mechanism specifically; Dungeon Crawler Carl -- search
-- results explicitly turned up no discourse on info-dumping either
-- way; Eragon -- no specific exposition-delivery discourse found
-- despite two attempts, only general worldbuilding-depth praise).

-- Weak/disputed: one reviewer praises the book for "deftly avoid[ing]
-- the pitfalls of over-exposition," but another directly complains
-- the novel "occasionally drags during... expository scenes" -- a
-- real, clean split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Godkiller', 'Hannah Kaner')
on conflict do nothing;

-- Direct, clean: praised for its "refusal to provide maps, glossaries,
-- and tidy exposition," deliberately doesn't "hold the reader's hand"
-- -- a programmatic choice to withhold explanation, not narrator
-- info-dumping (even though the resulting density is itself
-- disorienting to some readers, a separate density complaint from
-- delivery mechanism).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Black Leopard, Red Wolf', 'Marlon James')
on conflict do nothing;

-- Direct, clean: readers "don't have to worry about getting bogged
-- down in too much exposition" despite a large POV cast, prose
-- described as "economical and evocative," no info-dumping issues
-- reported.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Little Hatred', 'Joe Abercrombie')
on conflict do nothing;
