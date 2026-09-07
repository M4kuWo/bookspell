-- execution-DNA trope sweep, worldbuilding delivery batch 12 of the
-- candidate pool. 6 books reviewed against the presentation-of-delivery
-- evidence standard; 4 tagged (2 clean woven, 1 clean exposition-dump,
-- 1 disputed). 2 left untagged (Watership Down -- the El-ahrairah myths
-- are delivered as dedicated in-world storytelling chapters, not
-- clearly a narrator-exposition-vs-discovery case either way; The
-- Magicians -- discourse was too synthesized/hedged, no clean direct
-- quote on the delivery mechanism specifically).

-- Direct, clean, repeated: a "sheer avalanche" of exposition that
-- "constantly pulls the reader out of the already slow story," with a
-- character backstory sidebar reviewers say "could easily be excised
-- from the novel."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Discovery of Witches', 'Deborah Harkness')
on conflict do nothing;

-- Weak/disputed: some reviewers praise the footnotes as a "stroke of
-- genius" that expands worldbuilding "without being info-dumpy," but
-- others explicitly say footnotes "should have been woven into the
-- story itself" and call the technique "lazy" -- a real, clean split
-- on whether the mechanism itself is dumping or weaving.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Nevernight', 'Jay Kristoff')
on conflict do nothing;

-- Direct, clean: "few convenient infodumps to help the reader catch
-- up," characters "don't bother explaining things they already know to
-- one another" -- readers must "plow forward trusting" the author,
-- deliberately withheld exposition.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Blindsight', 'Peter Watts')
on conflict do nothing;

-- Direct, clean: described as "organic, even subdued, about how this
-- universe works," explicitly not "heavy-handed," "skillfully
-- integrated into the narrative."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Some Desperate Glory', 'Emily Tesh')
on conflict do nothing;
