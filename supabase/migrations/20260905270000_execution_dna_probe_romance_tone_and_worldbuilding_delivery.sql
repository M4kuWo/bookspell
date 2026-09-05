-- Validation probes (NOT a catalog-wide rollout) for two execution-DNA
-- concepts, encoded as tropes per this project's per-value nominal
-- weight-learning limitation (tropes already get real per-value
-- learning). Both surfaced analyzing Mathias's own Goodreads review
-- text -- see docs/project-log.md for the full source quotes.
--
-- Tagged at MODERATE confidence (not the default 1.0/unassessed) --
-- both are genuinely more subjective/execution-level judgments than a
-- plot-event trope, closer in kind to message_intensity's own
-- subjectivity than to a trope like `revenge`. Per repo owner's own
-- framing: apply now using the confidence/source layer rather than
-- treating "apply now" and "wait for real users" as mutually
-- exclusive -- ai_inferred, moderate confidence, ready to be corrected
-- by community tagging once real users exist.
insert into tropes (id, group_name, spoiler) values
  ('understated_romance', 'romance_relationships', false),
  ('melodramatic_romance_subplot', 'romance_relationships', false),
  ('worldbuilding_woven_into_narrative', 'setting_worldbuilding', false)
on conflict (id) do nothing;

-- understated_romance: the romantic relationship is written with
-- restraint -- grounded, low on contrived misunderstandings/toxic
-- push-pull, even where genuinely present as a strong thread. Real
-- positive examples from the repo owner's own loved/liked history:
-- Warbreaker (Siri/Susebron), Six of Crows (Kaz/Inej), Shadows of
-- Self/The Bands of Mourning/The Lost Metal (Wax/Steris).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('Warbreaker', 'Brandon Sanderson'),
  ('Six of Crows', 'Leigh Bardugo'),
  ('Shadows of Self', 'Brandon Sanderson'),
  ('The Bands of Mourning', 'Brandon Sanderson'),
  ('The Lost Metal', 'Brandon Sanderson')
)
on conflict do nothing;

-- melodramatic_romance_subplot: repetitive "will they/won't they"
-- tension, soap-opera-style romantic drama, played for extended
-- conflict rather than restraint. Real examples, both with an explicit
-- complaint in the repo owner's own review text -- The Wise Man's Fear
-- ("most of the book is about this will they-won't they relationship
-- with this dena girl and it is so repetitive", hated) and The Well of
-- Ascension ("a little too much soap opera in it... the rich guy falls
-- in love with the poor girl concept... Vin has kind of a thing for
-- Ellend's secret brother. Really?" -- a real negative pull on an
-- otherwise-loved book, not expected to flip its rating).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('The Wise Man''s Fear', 'Patrick Rothfuss'),
  ('The Well of Ascension', 'Brandon Sanderson')
)
on conflict do nothing;

-- worldbuilding_woven_into_narrative: lore/rules delivered through
-- character discovery and dialogue rather than narrator exposition --
-- distinct from worldbuilding_density (how MUCH lore exists, not how
-- it's delivered; Book of the Ancestor is independently tagged
-- worldbuilding_density: dense on all 3 books, which this doesn't
-- contradict). Direct quote: "unlike many fantasy books I've read
-- lately which bombard you with info dumps, here the exposition is
-- subtle and intriguing... That is basically how I feel about Book of
-- the Ancestor" -- explicitly about the whole trilogy, not one book.
-- NO negative counterpart found in the repo owner's own rated history
-- (checked directly: Way of Kings, Eye of the World, Words of Radiance
-- are all loved, none flagged for info-dumping) -- this probe is
-- expected to hit the same structural ceiling the True Bastards probe
-- did (no disliked-side presence means no learnable contrast), tagged
-- anyway for an honest test rather than skipped.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('Red Sister', 'Mark Lawrence'),
  ('Grey Sister', 'Mark Lawrence'),
  ('Holy Sister', 'Mark Lawrence')
)
on conflict do nothing;
