-- Death Masks (Dresden Files #5) author field was contaminated with the
-- audiobook narrator "James Marsters" (the actor, best known as Spike
-- in Buffy) appended as a second author -- this is not a co-authorship,
-- Jim Butcher is the sole author. Surfaced while testing the Goodreads
-- library-export importer (scripts/import_goodreads.py) against a real
-- export: the contaminated author field caused the exact_title_author
-- match to miss a book that IS tagged in the catalog, and the fuzzy
-- fallback also missed it because it buckets candidates by normalized
-- author. Per CLAUDE.md's standing author-contamination policy --
-- title-scoped, matches current (contaminated) value defensively so
-- this can't touch an unrelated row if the value already changed.
update books
set author = 'Jim Butcher'
where title = 'Death Masks' and author = 'Jim Butcher, James Marsters';
