-- execution-DNA trope sweep, worldbuilding delivery batch 13 of the
-- candidate pool. 6 books reviewed against the presentation-of-delivery
-- evidence standard; all 6 tagged clean (4 woven, 2 exposition-dump).
-- No skips, no disputed cases this batch -- unusually clean evidence
-- across the board, not a relaxed bar.

-- Extremely direct, repeated: "the first 19 pages are a nearly
-- uninterrupted info dump," continuing for most of the book --
-- "monstrously long" paragraphs "flooded with exposition" that "sucked
-- the pace out of any of the action scenes."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Deadly Education', 'Naomi Novik')
on conflict do nothing;

-- Direct, clean: exposition is "notably woven into the narrative
-- through the protagonist's journey," the world rebuilt through "the
-- progressive shattering of Senlin's preconceptions" rather than
-- narrator explanation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Senlin Ascends', 'Josiah Bancroft')
on conflict do nothing;

-- Direct, clean, repeated: "a masterful job of introducing her world
-- and characters without long expositions or info dumps," "masterfully
-- stitches together" many plot/worldbuilding threads "without resorting
-- to heavy exposition or info dumps."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Bone Shard Daughter', 'Andrea Stewart')
on conflict do nothing;

-- Direct, clean: praised for "avoiding the pitfall of lengthy
-- infodumps," with cultural/worldbuilding detail "weaving... naturally
-- into the narrative" through character background rather than
-- narrator explanation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Grace of Kings', 'Ken Liu')
on conflict do nothing;

-- Direct, clean, repeated: "a lot of exposition and lots of telling
-- over showing," criticized for being "dragged down by overly lengthy
-- descriptions and meandering side discussions."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Children of Memory', 'Adrian Tchaikovsky')
on conflict do nothing;

-- Direct, clean: exposition "woven into character development rather
-- than heavy-handed," backstory supplied through character
-- introduction rather than narrator info-dump, the story flowing "with
-- a natural ease."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Golem and the Djinni', 'Helene Wecker')
on conflict do nothing;
