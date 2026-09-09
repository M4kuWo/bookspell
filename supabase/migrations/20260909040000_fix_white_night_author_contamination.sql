-- Data-quality fix, caught incidentally while researching Dresden
-- Files GraphicAudio editions (Step A2 batch 7). "White Night"'s
-- author field was "Jim Butcher, Chris McGrath" -- Chris (Christian)
-- McGrath is the Dresden Files cover illustrator, not a co-author
-- (confirmed: he's illustrated the whole series' covers, per his own
-- bio and Reactor's "Chris McGrath and the Dresden Files" piece).
-- Matches this project's recurring author-field-contamination pattern
-- (CLAUDE.md's "author field must contain only genuine author(s)"
-- section) -- fixed on discovery per that standing policy, not left
-- for a future audit to catch.
update books
set author = 'Jim Butcher'
where title = 'White Night' and author = 'Jim Butcher, Chris McGrath';
