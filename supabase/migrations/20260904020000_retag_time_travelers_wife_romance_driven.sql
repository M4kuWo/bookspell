-- Retags "The Time Traveler's Wife" (Audrey Niffenegger) to
-- drive: 'romance_driven'. Repo owner's own catch: this book was in
-- the Tier 1 romance_driven audit candidate pool (frequent+explicit
-- heat) but hadn't been reviewed yet -- and it's also one of his own
-- RATED books (liked), which the earlier "romance_driven has 0
-- occurrences in Mathias's rated history" finding had missed because
-- this specific book was still tagged character_driven at the time.
--
-- An unambiguous case, arguably cleaner than the 3 already retagged:
-- the entire novel's structure IS Henry and Clare's relationship
-- across nonlinear time (her childhood meeting him, their courtship,
-- marriage, having a child) -- there is no substantial external plot
-- beyond it; Henry's time-displacement is the premise/device the
-- relationship plays out through, not a separate plot thread.

update book_dna set drive = 'romance_driven'
where book_id = (select id from books where title = 'The Time Traveler''s Wife');
