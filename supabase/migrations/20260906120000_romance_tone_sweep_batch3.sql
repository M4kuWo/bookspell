-- execution-DNA trope sweep, romance_tone batch 3 of the candidate pool.
-- 9 books reviewed against the strict presentation-specific evidence
-- standard; 6 tagged, 3 left untagged (Legendborn, Dead Until Dark,
-- Ruthless Vows -- all had real discourse, but it addressed pacing,
-- investment, or general craft quality rather than presentation-of-
-- emotion specifically).

-- Direct, repeated: "characterized as still melodramatic," "lost in a
-- haze of melodrama," "turns of phrase... felt like crutches to
-- bolster drama." Consistent with New Moon (already tagged, same
-- trilogy) and Bella's characterization across the series.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Eclipse', 'Stephenie Meyer')
on conflict do nothing;

-- Direct: "same argument for the 100th time," "quarreling every time
-- they saw each other," explicitly characterized as "leaning more
-- melodramatic than restrained."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Iron Flame', 'Rebecca Yarros')
on conflict do nothing;

-- Direct: "takes a definite backseat," "not too rushed," "sweet,"
-- "well done and very sweet" -- consistent restraint characterization,
-- with the one counter-quote being a craft-quality complaint
-- ("wasn't believable") rather than a tone one.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Sorcery of Thorns', 'Margaret  Rogerson')
on conflict do nothing;

-- Genuinely disputed: "doesn't force her... waits for her to be ready"
-- (restraint) directly contradicted by an explicit "melodramatic and
-- mushy" quote. Leaning melodramatic since that's the more specific,
-- directly-worded quote.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Kingdom of Ash', 'Sarah J. Maas')
on conflict do nothing;

-- Genuinely disputed: "excessively wordy and melodramatic" (direct
-- quote about the dialogue specifically) vs. "quiet understanding of
-- two predators," "slow-burn revelation." Real contradiction between
-- two similarly specific quotes.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Serpent and the Wings of Night', 'Carissa Broadbent')
on conflict do nothing;

-- Direct: "easy-to-read, low-conflict romance," "settled and loving
-- relationship" -- an established-couple book explicitly characterized
-- as low-drama.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Sweep of the Heart', 'Ilona Andrews')
on conflict do nothing;
