-- execution-DNA trope sweep, romance_tone batch 8 of the candidate pool.
-- 11 books reviewed against the strict presentation-specific evidence
-- standard; 10 tagged, 1 left untagged (The Princess Bride -- its
-- discourse addressed comedic self-awareness/narrative framing, not
-- the restrained-vs-melodramatic presentation axis).

-- Weak/mixed: a direct "occasional melodramatics" quote, but most
-- discourse addresses pacing/exposition or relationship-dynamic health
-- rather than presentation specifically.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Space Between Worlds', 'Micaiah Johnson')
on conflict do nothing;

-- Direct: "emotionally restrained rather than melodramatic" -- explicit
-- contrast, specific to book 1.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The City of Brass', 'S. A. Chakraborty')
on conflict do nothing;

-- Weaker: "wistful recollections... tragic romance and angst" is a real
-- shift in intensity from book 1's explicit restraint, but not clearly
-- melodramatic-declaration-style either -- longing and angst can still
-- be quietly presented. Tagged at low confidence rather than the clean
-- 0.6 book 1 earned.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Kingdom of Copper', 'S. A. Chakraborty')
on conflict do nothing;

-- Direct: "restrained and underdeveloped rather than melodramatic,"
-- "lack of build up... makes the climax less melodramatic."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Assassin''s Blade', 'Sarah J. Maas')
on conflict do nothing;

-- Direct, character-specific: "restrained, intelligent... each word
-- carefully chosen" describing Mateo's own romantic expression --
-- more specific to the actual central relationship than the
-- countervailing "melodrama" complaint, which addresses the book's
-- broader handling of its mortality theme rather than the romance itself.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('They Both Die at the End', 'Adam Silvera')
on conflict do nothing;

-- Weak: "a little too distant" (this book specifically; the
-- "melodramatic" characterization found applies to the SEQUEL, not
-- this book) -- real but modest lean toward reserved presentation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('These Violent Delights', 'Chloe Gong')
on conflict do nothing;

-- Direct: "well-developed relationship rather than a melodramatic one,"
-- "slow-burn," "well-written."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Jasmine Throne', 'Tasha Suri')
on conflict do nothing;

-- Extremely direct, repeated: "full of restraint," "restrained rather
-- than melodramatic," "overly reserved" (a complaint about too MUCH
-- restraint, not a contradiction).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Ministry of Time', 'Kaliane Bradley')
on conflict do nothing;

-- Direct, repeated: "deliciously dramatic," "melodrama," "fits of
-- jealousy" -- consistent with The Selection (book 1, already tagged
-- melodramatic).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Elite', 'Kiera Cass')
on conflict do nothing;

-- Direct, repeated: "please reel it in," "felt kind of forced," "so
-- much... drama," "the drama surrounding their relationship," "too
-- drawn out."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Royal Assassin', 'Robin Hobb')
on conflict do nothing;
