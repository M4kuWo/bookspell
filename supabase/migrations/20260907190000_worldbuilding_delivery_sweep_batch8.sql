-- execution-DNA trope sweep, worldbuilding delivery batch 8 of the
-- candidate pool (dense-worldbuilding books). 6 books reviewed against
-- the presentation-of-delivery evidence standard (delivery mechanism,
-- not how much lore exists); all 6 had clean enough real discourse to
-- tag, though 2 landed disputed rather than clean.

-- Direct, repeated, clean: "almost no exposition -- everything you
-- learn happens through action, through story," explicitly praised as
-- avoiding infodumped worldbuilding despite the book's length and
-- density.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Fifth Season', 'N.K. Jemisin')
on conflict do nothing;

-- Direct: instead of characters "laboriously explaining" the world to
-- each other, history and magic rules arrive via footnotes framed as
-- primary-source texts -- explicitly described as not requiring "a
-- giant exposition chapter" and coming to the reader "naturally...
-- not forced at all."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Jonathan Strange & Mr Norrell', 'Susanna Clarke')
on conflict do nothing;

-- Weak/disputed: one clear complaint of "a great deal of exposition...
-- often in heavy dialogue that can make reading a grind," directly
-- contradicted by other reviewers praising how the magic system
-- "comes at you when and where you need it" without overwhelming --
-- genuinely split reception on the delivery mechanism itself.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Mistborn: The Final Empire', 'Brandon Sanderson')
on conflict do nothing;

-- Weak/disputed: readers explicitly disagree on the mechanism itself --
-- some say the book does "absolutely no world building" (i.e. nothing
-- is explained, sink-or-swim), others point to specific "exposition
-- dumps covering Gideon and Harrow's shared history" that "raise more
-- questions than they answer" -- real discourse, but contradictory
-- about which delivery style is even happening.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Gideon the Ninth', 'Tamsyn Muir')
on conflict do nothing;

-- Direct, clean: heavy, repeated criticism of Heinlein "lecturing" via
-- his characters -- "the novel really did seem like an excuse... to go
-- from topic to topic explaining," "too much an attempt to lecture,"
-- the back half described as "mostly pointless exposition" alongside
-- philosophical discussion, not discovery through plot.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Stranger in a Strange Land', 'Robert A. Heinlein')
on conflict do nothing;

-- Direct: Mieville "sacrifices plot and characters for worldbuilding
-- and exposition" as a deliberate stylistic choice, "dragging readers
-- down into New Crobuzon long before the real plot is introduced" --
-- narrator-driven descriptive exposition, not character discovery.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Perdido Street Station', 'China Miéville')
on conflict do nothing;
