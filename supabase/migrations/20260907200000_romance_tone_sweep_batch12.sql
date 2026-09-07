-- execution-DNA trope sweep, romance_tone batch 12 of the candidate pool.
-- 10 books reviewed against the strict presentation-specific evidence
-- standard; 8 tagged (3 clean, 5 including 3 genuinely disputed at 0.2),
-- 2 left untagged entirely (An Ember in the Ashes, Ruthless Vows --
-- real discourse found, but it was insta-love/drive/pacing/quality
-- complaints, never a clean presentation-of-emotion read).

-- Weak/disputed: direct "soppy and melodramatic most of the times" and
-- "cannot write a sex scene without it being melodramatic," but
-- countered by other readers finding the same beats "so, so beautiful"
-- and emotionally moving rather than overwrought -- genuinely split on
-- whether the same declarations read as earned or excessive.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Court of Wings and Ruin', 'Sarah J. Maas')
on conflict do nothing;

-- Direct, repeated, clean: "restrained," "tender and vulnerable,"
-- "an affinity for one another... rather than an overtly passionate
-- display" -- specifically contrasted against melodrama.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('This Is How You Lose the Time War', 'Amal El-Mohtar, Max Gladstone')
on conflict do nothing;

-- Direct: quoted sincere-yet-absurd declarations ("my arms love you, my
-- ears adore you") and explicit "over-the-top pining" -- heightened,
-- theatrical presentation played for extended emotional intensity, even
-- though the register is knowingly comedic rather than earnest.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Princess Bride', 'William Goldman')
on conflict do nothing;

-- Direct: "longing stares, secret glances, and thoughtful looks,"
-- physical restraint built into the premise itself, "sweet" and
-- focused on quiet connection rather than declarations.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Yumi and the Nightmare Painter', 'Brandon Sanderson')
on conflict do nothing;

-- Direct, repeated: "absurdly melodramatic teenagers," "amps up the
-- melodramatic love-triangle tension," quoted heightened declaration
-- ("our love can never be") -- consistent with Shatter Me (book 1),
-- already tagged melodramatic, same pairing.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Unravel Me', 'Tahereh Mafi')
on conflict do nothing;

-- Weak/disputed: "cheesy, and sooooo slow" is a direct presentation
-- complaint, but just as many reviewers call the same relationship
-- "so real" and "brilliantly written" -- genuinely split reception on
-- the tone itself, not just quality.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Wizard And Glass', 'Stephen King')
on conflict do nothing;

-- Direct, repeated: reviewer's own word "melodramatic," "fabulously
-- dramatic conclusion," "heartbreaking emotional... dramatic twists" --
-- explicitly more dramatic than book 1 (One Dark Window, already
-- tagged melodramatic).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Two Twisted Crowns', 'Rachel Gillig')
on conflict do nothing;

-- Weak/disputed: majority read is restrained/naturalistic ("believable,"
-- "slow-burn," "natural") but one reviewer directly calls the same
-- banter "corny dialogue" mixed with "overbaked descriptions of
-- sentimentality" -- real, but contested, presentation-specific split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('To Kill a Kingdom', 'Alexandra Christo, Stephanie Willis, Jacob York')
on conflict do nothing;
