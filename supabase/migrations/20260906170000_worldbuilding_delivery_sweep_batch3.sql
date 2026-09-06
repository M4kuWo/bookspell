-- execution-DNA trope sweep, worldbuilding delivery batch 3. 10 books
-- reviewed; 8 tagged, 2 left untagged (A Feast for Crows, Blindsight --
-- discourse addressed pacing/reflective tone or concept density, not
-- the discovery-vs-narrator-exposition delivery axis).

-- worldbuilding_woven_into_narrative --------------------------------

-- "skillfully uses mundane exposition to drive foreshadowing and
-- suspense," backstory delivered through characters -- consistent
-- with A Game of Thrones, already tagged, same series.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Storm of Swords', 'George R.R. Martin')
on conflict do nothing;

-- Genuinely disputed: "masterful, immersive, vivid... extrapolating,
-- not just plopping" directly contradicted by a specific complaint of
-- "hundreds of pages about dry spider history."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Children of Time', 'Adrian Tchaikovsky')
on conflict do nothing;

-- Memoir/personal-account structure (Isabella's own first-person
-- narration of her scientific career) is itself a discovery/
-- experience-based delivery device, same pattern as Piranesi's
-- journal structure.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Natural History of Dragons', 'Marie Brennan')
on conflict do nothing;

-- Extremely direct: reviewers use the exact word -- "never feels like
-- an info dump -- it's woven so intricately into the story."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Black Sun', 'Rebecca Roanhorse')
on conflict do nothing;

-- worldbuilding_via_exposition_dump -----------------------------------

-- Direct complaint: "heavy on exposition to some readers." Backed by
-- the book's own well-documented structure -- the opening chapters are
-- literally a guided tour where the Director lectures visitors through
-- the hatchery process, one of the most cited examples of a lecture-
-- delivery device in classic SF/dystopian fiction.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Brave New World', 'Aldous Huxley')
on conflict do nothing;

-- Weaker/mixed: real, specific complaint that the opening trial scene
-- built for worldbuilding is "at best burdensome... busywork boring,"
-- but the majority of discourse instead praises the worldbuilding as
-- immersive ("felt real, it breathed").
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Stairs', 'Robert Jackson Bennett')
on conflict do nothing;

-- Direct: reviewers explicitly call the tangential asides "infodump
-- asides," describing "rambling discussions" readers "admit to
-- skimming" -- same author/pattern as Snow Crash, already tagged.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Cryptonomicon', 'Neal Stephenson')
on conflict do nothing;

-- Extremely direct and structural: the book is literally framed as a
-- series of in-world scholarly annotations and an "Editor's Preface"
-- summarizing centuries of critical commentary between each story --
-- static, exposition-heavy vignettes rather than character-POV scenes,
-- the same pattern as Foundation's Encyclopedia Galactica device.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City', 'Clifford D. Simak')
on conflict do nothing;
