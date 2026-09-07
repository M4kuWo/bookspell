-- execution-DNA trope sweep, romance_tone batch 13 of the candidate pool.
-- 11 books reviewed against the strict presentation-specific evidence
-- standard; 7 tagged (5 understated, 2 melodramatic -- 2 of the 7
-- disputed at 0.2), 4 left untagged entirely (The Everlasting, Tower
-- of Dawn, Graceling, A Study in Drowning -- real discourse found for
-- each, but it addressed prominence/pacing/relationship-dynamics/
-- quality rather than a clean presentation-of-emotion read).

-- Direct, clean: reviewers explicitly describe the prequel's love story
-- as "compressed and narrated in an almost matter-of-fact, emotionless
-- manner" -- deliberately restrained rather than melodramatic.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Ballad of Songbirds and Snakes', 'Suzanne Collins')
on conflict do nothing;

-- Direct, clean: "lacks any real tension or passion," love interest
-- "woos with kindness and patience" -- restrained, gentle courtship
-- explicitly contrasted against dramatic emotional beats.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Spellshop', 'Sarah Beth Durst')
on conflict do nothing;

-- Direct, clean, repeated: "not syrupy," "not built out of grand
-- sentimental speeches," "quieter and more sideways" -- one reviewer's
-- passing "a bit much" complaint is presented as a minor dissent, not a
-- genuine even split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Emily Wilde''s Encyclopaedia of Faeries', 'Heather Fawcett')
on conflict do nothing;

-- Direct, clean: attraction stays "in the background," described
-- consistently as "restrained and slow-burning rather than
-- melodramatic," with plot/character kept in the foreground.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Magic Bites', 'Ilona Andrews')
on conflict do nothing;

-- Weak: the only presentation-specific line found ("the emotional
-- description leans heavily toward melodrama") is real but isolated;
-- most of the discourse is insta-love/pacing/convenience criticism,
-- which is excluded evidence.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Legendborn', 'Tracy Deonn')
on conflict do nothing;

-- Weak/disputed: "emotional without tipping into melodrama" and
-- "romance glimmers only as a fevered possibility" support restraint,
-- but a separate reviewer explicitly flags "sparkles and melodrama"
-- and calls the book "overly indulgent" -- genuinely contested.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Bury Our Bones in the Midnight Soil', 'V. E. Schwab')
on conflict do nothing;

-- Direct, repeated, clean: "deliciously angsty and slow-burning,"
-- "angsty slow burn, mutual pining," "an angsty romance cranked up to
-- eleven."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Powerless', 'Lauren  Roberts')
on conflict do nothing;
