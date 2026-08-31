-- Removes the 7 dangling untagged rows confirmed out of catalog scope
-- (no fantasy/sci-fi content, or pure duplicate omnibus content) --
-- see project-log.md 2026-08-30/31 entries. Verified zero dependent
-- rows in book_dna/book_tropes/book_content_warnings/book_field_confidence
-- before deleting. Also removes the 4 series rows this deletion left
-- with zero books (single-book series named after the deleted book) --
-- deliberately NOT touching legitimate zero-book parent groupings
-- (Stormlight Archive, Stormlight Archive Era Two, Mistborn), which are
-- intentional per the series-hierarchy design.

delete from books where title in (
  'If We Were Villains', 'The Da Vinci Code', 'The Farseer Trilogy',
  'The Inheritance Games', 'The Pillars of the Earth', 'The Plague',
  'The Shadow of the Wind'
);

delete from series where name in (
  'Kingsbridge', 'The Inheritance Games', 'Robert Langdon', 'The Cemetery of Forgotten Books'
) and not exists (select 1 from books b where b.series_id = series.id);
