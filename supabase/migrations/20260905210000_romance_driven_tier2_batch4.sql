-- romance_driven Tier 2 audit, batch 4 of 4 (parallel agents).
-- Reviewed 52 books currently tagged romance_heat_frequency = 'occasional'
-- with drive != 'romance_driven', applying the narrative-centrality test:
-- is the central relationship what the book is ABOUT (the plot engine),
-- or a strong supporting thread inside a plot/character/worldbuilding-driven
-- story? Most of the batch correctly stays as-is; these 5 are reclassified
-- because the romance itself is the book's central mechanism, not just a
-- prominent subplot inside a differently-driven story:
--   - The Night Circus: the Celia/Marco romance IS the plot device that
--     binds the circus and drives the central magical duel/competition.
--   - The Song of Achilles: the entire novel is a retelling of the Iliad
--     structured around the Achilles/Patroclus relationship as its
--     emotional and narrative engine (drive is independent of the
--     already-tagged mlm_romance trope, which is about content type).
--   - The Spellshop: cozy-fantasy romantasy; Kiela/Larran's romance is the
--     book's actual arc, not a subplot to a separate main plot.
--   - Tower of Dawn: functions as a stand-alone romance interlude within
--     Throne of Glass -- the Chaol/Yrene relationship is the book's focus,
--     with series politics paused/secondary for this volume.
--   - Yumi and the Nightmare Painter: Sanderson's own most romance-forward
--     Cosmere work; the developing Yumi/Painter relationship is the book's
--     central throughline, not incidental to the mystery-solving plot.
--
-- Idempotent: scoped by title+author subselect (never a raw UUID, since
-- local/hosted have different row UUIDs for the same book), and only
-- flips rows still at their pre-audit value so a rerun is a no-op.

update book_dna
set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'The Night Circus' and author = 'Erin Morgenstern');

update book_dna
set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'The Song of Achilles' and author = 'Madeline Miller');

update book_dna
set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'The Spellshop' and author = 'Sarah Beth Durst');

update book_dna
set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'Tower of Dawn' and author = 'Sarah J. Maas');

update book_dna
set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'Yumi and the Nightmare Painter' and author = 'Brandon Sanderson');
