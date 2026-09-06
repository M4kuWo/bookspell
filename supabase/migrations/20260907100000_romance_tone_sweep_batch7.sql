-- execution-DNA trope sweep, romance_tone batch 7 of the candidate pool.
-- 10 books reviewed against the strict presentation-specific evidence
-- standard; 8 tagged, 2 left untagged (The Ballad of Songbirds and
-- Snakes, The Mists of Avalon -- discourse addressed whether it's a
-- genuine romance at all, or general narrative-voice style, not
-- presentation-of-emotion specifically).

-- Author's own direct statement about her own book's tone: "I love
-- writing in that slightly melodramatic register" -- about as
-- authoritative as evidence gets.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('She Who Became the Sun', 'Shelley Parker-Chan')
on conflict do nothing;

-- Direct: "romance leans toward restraint rather than melodrama,"
-- "understated and underdeveloped rather than overwrought."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Stardust', 'Neil Gaiman')
on conflict do nothing;

-- Direct, repeated: "dispensing with on-page relationship drama,"
-- "handled with restraint rather than explicit drama," "witty dialogue
-- and intellectual debates rather than emotional melodrama."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Atlas Six', 'Olivie Blake')
on conflict do nothing;

-- Direct, repeated: "grandiose ending was melodramatic," "dialogue is
-- melodramatic," writing "burdened with romantic cliches."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Invisible Life of Addie LaRue', 'V. E. Schwab')
on conflict do nothing;

-- Direct, consistent: "soft," "rather sweet," "slow burning," "secondary
-- to the story," "a delicate secret thing."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The House in the Cerulean Sea', 'TJ Klune')
on conflict do nothing;

-- Extremely direct: "restrained when the tone had to be subdued,"
-- "the romantic moments come without being melodramatic," "restrained
-- and beautiful."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Golem and the Djinni', 'Helene Wecker')
on conflict do nothing;

-- Direct: "sappy and saccharine," "cartoonish," "preachy" -- a real
-- shift from The House in the Cerulean Sea (book 1, same duology,
-- tagged understated above), consistent with the pattern of sequels
-- not preserving a series' established tone.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Somewhere Beyond the Sea', 'TJ Klune')
on conflict do nothing;

-- Direct: "mopey, melodramatic existence," "more words in sex scenes
-- and relationship issues than in worldbuilding."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Magicians', 'Lev Grossman')
on conflict do nothing;
