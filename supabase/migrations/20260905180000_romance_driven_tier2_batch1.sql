-- romance_driven Tier 2 audit, batch 1 of 4 (parallel agents, 54-book batch).
-- Reclassifying book_dna.drive to 'romance_driven' for books where the central
-- relationship is the actual plot engine (narrative centrality), not just books
-- with heavy romance content -- romance_heat_frequency/intensity is untouched.
--
-- A Dowry of Blood: entire novel is a first-person letter to her vampire lover
--   explaining their (and the found-family/polyamorous unit's) relationship --
--   there is no plot thread independent of that relationship.
-- Assistant to the Villain: romantic-comedy fantasy; the will-they-won't-they
--   with her villain boss is the book's central engine, office/traitor intrigue
--   is a light backdrop, not the point.
-- City of Lost Souls: unlike other Mortal Instruments entries (kept as-is),
--   this volume's central conflict IS the romantic bond itself -- Clary cannot
--   act against Sebastian without killing Jace, making Jace/Clary's relationship
--   the literal plot mechanism, not a subplot alongside an external threat.
-- Daughter of Smoke & Bone: the Karou/Akiva romance (past-life star-crossed
--   lovers Madrigal/Akiva) is inseparable from the chimaera/seraphim war --
--   the war's resolution is explicitly tied to their relationship.
update book_dna set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'A Dowry of Blood' and author = 'S.T. Gibson');

update book_dna set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'Assistant to the Villain' and author = 'Hannah Nicole Maehrer');

update book_dna set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'City of Lost Souls' and author = 'Cassandra Clare');

update book_dna set drive = 'romance_driven'
where drive != 'romance_driven'
  and book_id = (select id from books where title = 'Daughter of Smoke & Bone' and author = 'Laini Taylor');
