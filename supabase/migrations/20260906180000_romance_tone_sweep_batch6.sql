-- execution-DNA trope sweep, romance_tone batch 6 of the candidate pool.
-- 11 books reviewed against the strict presentation-specific evidence
-- standard; 8 tagged, 3 left untagged (One Last Stop, Emily Wilde's
-- Encyclopaedia of Faeries, Middlegame -- discourse addressed
-- believability, relationship-dynamic health, or reader emotional
-- reaction rather than the book's own presentation of romantic emotion).

-- Weak/disputed: direct "PG teen angst romance... fixation on" lean
-- toward melodrama, contradicted by "restrained and underdeveloped"
-- complaints from other readers.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Insurgent', 'Veronica Roth')
on conflict do nothing;

-- Extremely direct, repeated: "incredible restraint," "restraint...
-- psychological impact," "rather than being melodramatic... literary
-- and tender," "restrained, literary approach rather than melodramatic
-- presentation" -- explicit contrast used multiple times.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Our Wives Under the Sea', 'Julia Armfield')
on conflict do nothing;

-- Weak/disputed: repetitive self-deprecating "whingeing"/"pitiful"
-- inner monologues are real presentation evidence for an overwrought,
-- melodrama-adjacent style, but countered by "sweet" and "slow burn"
-- characterizations from other readers.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Paladin''s Grace', 'T. Kingfisher')
on conflict do nothing;

-- Direct: "notably restrained," "coy romance," characters "sheepishly
-- avoiding the conversation" -- same author/consistent tone in both
-- books of this duology.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Legends & Lattes', 'Travis Baldree')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Bookshops & Bonedust', 'Travis Baldree')
on conflict do nothing;

-- Direct: "grounded rather than melodramatic," "woven into a darker
-- narrative rather than being a central melodramatic focus."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Nevernight', 'Jay Kristoff')
on conflict do nothing;

-- Direct: "Four being all melodramatic for a couple of chapters,"
-- "like watching two ten year olds playing make believe" -- a real
-- shift from book 1 (Divergent, already tagged understated) as the
-- series' tone visibly changes by book 3.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Allegiant', 'Veronica Roth')
on conflict do nothing;

-- Direct: explicit framing against "dramatic emotional outbursts or
-- high-intensity conflict" in favor of slow-burn, banter-driven
-- development.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Assistant to the Villain', 'Hannah Nicole Maehrer')
on conflict do nothing;
