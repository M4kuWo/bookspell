-- romance_driven Tier 2 audit, batch 2 of 4 (parallel agents, disjoint book lists).
-- book_dna.drive is about narrative centrality: is the central relationship the
-- actual plot engine (what the book is ABOUT), not just present/explicit content
-- (that's romance_heat_frequency/intensity, untouched here).
--
-- Reviewed 54 books currently tagged romance_heat_frequency='occasional' with
-- drive != 'romance_driven'. Reclassifying 6 where the central relationship is
-- confirmed (via synopsis re-check, since `drive` is a HIGH_RISK_FIELD) to be
-- the actual plot engine, not a supporting thread in a plot/character-driven book.

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Divine Rivals' and author = 'Rebecca Ross')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Matched' and author = 'Ally Condie')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'New Moon' and author = 'Stephenie Meyer')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Once Upon a Broken Heart' and author = 'Stephanie Garber')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Our Wives Under the Sea' and author = 'Julia Armfield')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Paladin''s Grace' and author = 'T. Kingfisher')
  and drive != 'romance_driven';
