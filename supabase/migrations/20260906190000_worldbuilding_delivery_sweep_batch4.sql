-- execution-DNA trope sweep, worldbuilding delivery batch 4. 8 books
-- reviewed; 7 tagged, 1 left untagged (One Hundred Years of Solitude --
-- its distinctive passive-narrator "vivid summary" style is a general
-- narrative-voice characteristic, not specifically a lore/rules
-- delivery mechanism this trope pair targets).

-- worldbuilding_woven_into_narrative --------------------------------

-- Canterbury Tales frame structure: each pilgrim narrates their OWN
-- story in a distinct voice, building "a mosaic of perspectives"
-- rather than narrator-delivered lore -- the same character-account
-- pattern as Piranesi's journal and A Natural History of Dragons'
-- memoir, both already tagged.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Hyperion', 'Dan Simmons')
on conflict do nothing;

-- Extremely direct, repeated: reviewers use "woven" explicitly three
-- separate times -- "deftly woven into the fabric of the narrative,"
-- "phenomenally woven," "seamlessly woven."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Jade City', 'Fonda Lee')
on conflict do nothing;

-- "no infodump, no exposition," "thrown into his world in the same
-- way the characters are," reviewers explicitly say Gaiman "has woven
-- a masterpiece."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Neverwhere', 'Neil Gaiman')
on conflict do nothing;

-- Direct: "exposition comes naturally as Laurence explains the world
-- to Temeraire... diegetic... less arduous to read" -- textbook
-- definition of this trope, in-world dialogue carrying the lore
-- rather than narrator telling.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('His Majesty''s Dragon', 'Naomi Novik')
on conflict do nothing;

-- worldbuilding_via_exposition_dump -----------------------------------

-- Well-documented, independently confirmed pattern: the character Ian
-- Malcolm exists narratively as a vehicle for chaos-theory lectures,
-- explicitly "popularized... non-technical descriptions... accessible
-- to a general audience" -- a human-lecture equivalent of Snow Crash's
-- librarian AI or Foundation's clever-guy-explains-it dialogue.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Jurassic Park', 'Michael Crichton')
on conflict do nothing;

-- Direct: "dozens and dozens of pages of... momentum-shattering
-- history and world-building," climax "weighted with exposition,
-- especially in the Shrieking Shack" -- a specifically-named extended
-- verbal-explanation scene.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Harry Potter and the Prisoner of Azkaban', 'J.K. Rowling')
on conflict do nothing;

-- Same exact pattern as Foundation (book 1, already tagged): "exposition
-- presented in conversation... eavesdrop on the clever guy's
-- explanations," "exposition-heavy dialogue."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Foundation and Empire', 'Isaac Asimov')
on conflict do nothing;
