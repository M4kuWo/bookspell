-- romance_driven Tier 2 audit, batch 3 of 4 parallel batches.
-- Reviewed 54 books currently tagged romance_heat_frequency = 'occasional'
-- with drive != 'romance_driven', for narrative centrality (is the central
-- relationship the book's actual plot engine, not just explicitness/heat).
-- Reclassifying the 4 where the central romance genuinely IS what the book
-- is about, per the same test used in the Tier 1 audit.

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Ruthless Vows' and author = 'Rebecca Ross')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Strange the Dreamer' and author = 'Laini Taylor')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Sweep of the Heart' and author = 'Ilona Andrews')
  and drive != 'romance_driven';

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'The Host' and author = 'Stephenie Meyer')
  and drive != 'romance_driven';
