-- Retags 3 books to drive: 'romance_driven' (the value added in
-- 20260904000000_add_romance_driven_to_drive_field.sql) -- these are
-- exactly the books the repo owner's own structural review flagged as
-- "questionable" recommendations, and checking them directly confirms
-- why: all 3 are romance_heat_frequency=frequent, intensity=explicit,
-- with 3+ romance-structural tropes each (forbidden_love,
-- enemies_to_lovers, fated_mates, hidden_identity_romance), and are
-- all widely-recognized romantasy where the central relationship IS
-- the book's plot engine, not a supporting thread to an unrelated
-- external plot -- a clear case for the new value, not a borderline
-- judgment call.
--
-- Deliberately NOT a bulk pass across the wider candidate pool: a
-- broader query (romance_heat_frequency=frequent AND intensity=explicit)
-- returned 24 books total, but that filter alone is not sufficient
-- signal -- it also matched Gravity's Rainbow (Pynchon) and Stranger in
-- a Strange Land (Heinlein), neither of which should ever be tagged
-- romance_driven despite genuinely explicit content. The remaining
-- candidates need real per-book judgment (is romance THE engine, or
-- one strong thread among several), not a blanket reclassification --
-- left for a dedicated tagging-session review pass, not guessed here.

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'From Blood and Ash');

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'Daughter of No Worlds');

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'House of Earth and Blood');
