-- execution-DNA trope sweep, romance_tone batch 11 of the candidate pool.
-- 12 books reviewed against the strict presentation-specific evidence
-- standard; 8 tagged (2 clean, 3 disputed, 3 mixed-clean-enough), 4 left
-- untagged entirely (A Touch of Darkness, One Last Stop, Kingdom of the
-- Wicked -- all real, findable discourse but every piece of it was
-- drive/pacing/quality/genre-comparison, not a clean presentation read).

-- Direct: "restrained emotional approach," romance develops through
-- emotional intimacy (gift-giving, introspection) rather than
-- declarations; reviewers explicitly contrast this novella against the
-- earlier books' bigger swings -- "steering clear of excessive
-- sweetness and sadness," not melodramatic.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Court of Frost and Starlight', 'Sarah J. Maas')
on conflict do nothing;

-- Direct: "light romance fare," "subtle sex scenes," romance "doesn't
-- have an overwhelming presence," and a reader expecting steaminess/
-- drama was left disappointed by how restrained it actually is.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Dead Until Dark', 'Charlaine Harris')
on conflict do nothing;

-- Weak/disputed: "toned down... but still present," "breathless
-- emotional stakes of YA" alongside "toe-curling" scenes -- reviewers
-- explicitly note more restraint than Maas's usual register, but the
-- dramatic register hasn't gone away either.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('House of Earth and Blood', 'Sarah J. Maas')
on conflict do nothing;

-- Direct: "tortured, angsty, and glowering," "touch her and die vibes,"
-- "melodramatic fae drama," tension played for sustained intensity
-- rather than restraint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Quicksilver', 'Callie Hart')
on conflict do nothing;

-- Weak/disputed: "descriptions... too vague or too melodramatic" is a
-- direct word-match but paired with a contradicting "bland romance
-- scenes" complaint from the same discourse -- genuinely inconsistent
-- reception, not a clean read either way.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Lightlark', 'Alex Aster, Suzy Jackson')
on conflict do nothing;

-- Direct, quoted declarations: "You're worth it... every beat of my
-- heart is yours" -- extended, heightened emotional-intensity
-- declarations, not restraint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The One', 'Kiera Cass')
on conflict do nothing;

-- Extremely direct, repeated: "soapy, dramatic, and angsty... fantasy
-- equivalent of Gossip Girl," "constant push-pull between cruelty and
-- devotion," "characters can be a little over the top."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Zodiac Academy: The Awakening', 'Caroline Peckham, Susanne Valenti')
on conflict do nothing;

-- Direct: one reviewer's exact word "melodramatic," reinforced by
-- "lush, over-wrought prose" and "every single thing is overwrought" --
-- reception is polarized (other readers love the intensity), but the
-- presentation-specific complaint itself is clean and repeated.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('When the Moon Hatched', 'Sarah A. Parker')
on conflict do nothing;

-- Weak/disputed: one critic calls it "beautifully melodramatic" and
-- notes the author "crossing fingers the romance calms itself down,"
-- but other reviewers read the same relationship as "heartbreakingly
-- lovely" rather than overwrought -- genuinely split discourse.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Strange the Dreamer', 'Laini Taylor')
on conflict do nothing;
