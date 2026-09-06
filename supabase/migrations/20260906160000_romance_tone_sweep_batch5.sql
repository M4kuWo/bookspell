-- execution-DNA trope sweep, romance_tone batch 5 of the candidate pool.
-- 12 books reviewed against the strict presentation-specific evidence
-- standard; 11 tagged, 1 left untagged (Graceling -- discourse
-- addressed pacing/distraction, not presentation-of-emotion).

-- Direct: "unusually well-handled," "mutual respect and tested trust
-- rather than instant attraction," "not forced and not the main point."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Divergent', 'Veronica Roth')
on conflict do nothing;

-- Direct: "appropriately capturing teenage feelings without being
-- overly dramatic -- balancing humor with genuine emotional stakes."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Harry Potter and the Half-Blood Prince', 'J.K. Rowling')
on conflict do nothing;

-- Direct, romance-specific (distinct from Howl's own melodramatic
-- personality, a separate character trait): "romantic elements so
-- muted for most of the book," less overt than even the film
-- adaptation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Howl''s Moving Castle', 'Diana Wynne Jones')
on conflict do nothing;

-- Genuinely mixed: a direct "I love how melodramatic he is" quote
-- about Baz's romantic expression, alongside real restraint language
-- ("self-control," "restrained feelings held for a significant
-- portion") describing the same relationship's earlier arc.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Carry On', 'Rainbow Rowell')
on conflict do nothing;

-- Genuinely disputed, real contradiction: "deliciously melodramatic"
-- vs. "not exactly tense, but brooding," "subtle hints placed
-- throughout." Leaning melodramatic for the more enthusiastic, direct
-- quote.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Carmilla', 'J. Sheridan Le Fanu')
on conflict do nothing;

-- Direct: "melodrama and florid descriptions... exceedingly purple"
-- prose specifically describing the Clary/Jace dynamic -- consistent
-- with City of Bones, already tagged, same series/pairing.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Ashes', 'Cassandra Clare')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Glass', 'Cassandra Clare')
on conflict do nothing;

-- Direct: "emotionally restrained and complex rather than
-- melodramatic," Laura characterized by "coldness and distance."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('American Gods', 'Neil Gaiman')
on conflict do nothing;

-- Direct: "refreshingly restrained and unconventional... rather than
-- melodramatic."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Iron Widow', 'Xiran Jay Zhao')
on conflict do nothing;

-- Direct: "less angsty and full of tension, but more fun, playful,"
-- "witty banter," "more realistic drama... than other fantasy romance
-- tropes" -- a real contrast with House of Flame and Shadow (same
-- trilogy, next book, already tagged melodramatic).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('House of Sky and Breath', 'Sarah J. Maas')
on conflict do nothing;

-- Direct: "thoughtfully constructed rather than purely melodramatic,"
-- "emotional complexity... rather than over-the-top displays."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Catching Fire', 'Suzanne Collins')
on conflict do nothing;
