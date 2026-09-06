-- Battle Royale's author field was contaminated with two Polish
-- translator names appended after the real (sole) author -- surfaced
-- while re-running scripts/import_goodreads.py against today's larger
-- catalog for the repo owner's Goodreads library. Koushun Takami wrote
-- Battle Royale alone; "Urszula Knap, Maciej Kamuda" are the Polish
-- edition's translators, not co-authors. Same recurring pattern
-- CLAUDE.md tracks (Sapkowski/David French; Death Masks/Simon Vance
-- previously).
update books
set author = 'Koushun Takami'
where title = 'Battle Royale' and author = 'Koushun Takami, Urszula Knap, Maciej Kamuda';
