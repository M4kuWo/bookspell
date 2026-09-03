-- Adds 'romance_driven' as a new value to book_dna.drive's controlled
-- vocabulary. Repo owner's own gap analysis (2026-09-04, see
-- docs/scoring-test-protocol.md's "structural issues" entry): the
-- existing romance_heat_frequency/romance_heat_intensity fields measure
-- EXPLICITNESS, not narrative centrality -- a book can be high-heat and
-- still have romance as a supporting thread, or low-heat with the
-- central relationship AS the plot. This value captures specifically
-- when the central relationship(s), not the external plot or a
-- character's individual arc, is what the book is actually about --
-- same precedent as worldbuilding_driven's earlier addition to this
-- same field. Does NOT capture execution quality/tone (juvenile vs.
-- mature, formulaic vs. earned) -- that's a harder, more subjective
-- axis, deliberately not added yet pending a validation probe (see
-- book-dna.md's backlog).

alter table book_dna drop constraint book_dna_drive_check;
alter table book_dna add constraint book_dna_drive_check
  check (drive = any (array['character_driven', 'plot_driven', 'balanced', 'worldbuilding_driven', 'romance_driven']));
