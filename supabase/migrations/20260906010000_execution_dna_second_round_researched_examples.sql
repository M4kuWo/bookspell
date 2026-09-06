-- Second-round examples for the romance_tone validation probe, each
-- verified against real reader-discourse research (not pattern-matched
-- from genre reputation) before tagging -- see docs/project-log.md for
-- the full source quotes. Repo owner validated this specific batch
-- before applying.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('A Court of Thorns and Roses', 'Sarah J. Maas'),
  ('Twilight', 'Stephenie Meyer'),
  ('Shatter Me', 'Tahereh Mafi')
)
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('The Goblin Emperor', 'Katherine Addison'),
  ('The Traitor Baru Cormorant', 'Seth Dickinson')
)
on conflict do nothing;

-- Real, honest test of MIN_CONFIDENCE_TO_COUNT (0.3): initial research
-- turned out weaker than the genre-reputation guess that motivated
-- these two -- From Blood and Ash's reviews mostly praise the romance
-- as well-executed ("perfect slow burn," "never felt contrived"), and
-- Fourth Wing's real criticism is about derivative worldbuilding/plot
-- tropes, not melodramatic romance execution specifically. Tagged
-- anyway at a confidence below the counting floor -- recorded, visible,
-- excluded from scoring/weight-learning until real validation raises
-- either one above 0.3.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('From Blood and Ash', 'Jennifer L. Armentrout'),
  ('Fourth Wing', 'Rebecca Yarros')
)
on conflict do nothing;
