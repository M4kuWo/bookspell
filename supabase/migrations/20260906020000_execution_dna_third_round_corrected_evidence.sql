-- Third round of romance_tone examples. Re-reviewed against a
-- clarified, stricter evidence standard the repo owner set explicitly:
-- romance_tone evidence must describe emotional PRESENTATION/EXPRESSION
-- specifically -- page-time/plot-importance (that's `drive`), pacing
-- (slow/fast burn is a separate axis), toxicity/relationship health,
-- craft quality, and explicitness (that's romance_heat_intensity) do
-- NOT count as supporting evidence either way. See docs/project-log.md
-- for the full re-analysis; two entries changed as a direct result of
-- applying this stricter standard.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Throne of Glass', 'Sarah J. Maas')
on conflict do nothing;

-- Genuinely disputed in real discourse (some reviews call it a
-- well-earned slow burn, one specifically calls it "insta-love
-- disguised as slow-burn") -- tagged below MIN_CONFIDENCE_TO_COUNT,
-- recorded but excluded from calculations until validated.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Caraval', 'Stephanie Garber')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('The Priory of the Orange Tree', 'Samantha Shannon'),
  ('Spinning Silver', 'Naomi Novik')
)
on conflict do nothing;

-- The Bear and the Nightingale: original "restrained" read conflated
-- the romance's slow BUILD-UP (a pacing/drive-adjacent fact) with its
-- actual emotional presentation. Re-checked specifically for the
-- latter: the culminating moment is described as "quick and fierce"/
-- "emotionally charged," with real reader discomfort about the power
-- dynamic -- not a clean "restrained" case under the stricter
-- standard. Downgraded below MIN_CONFIDENCE_TO_COUNT rather than kept
-- at full confidence.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Bear and the Nightingale', 'Katherine Arden')
on conflict do nothing;
