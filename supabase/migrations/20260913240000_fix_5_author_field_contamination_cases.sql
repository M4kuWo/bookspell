-- Fix 5 author-field contamination cases flagged (analysis-only) during
-- catalog-trope-gap-sweep #3, 2026-09-13 (see docs/project-log.md's
-- 2026-09-13 "sweep #3" entry) -- illustrator/narrator/introduction
-- credits appended to the author field, the same recurring pattern
-- CLAUDE.md's "Data quality / tagging" section already tracks (the
-- Sapkowski/David French translator case, the 65-of-606-book audit).
--
-- Each verified directly against Hardcover's own cached_contributors data
-- (contribution role per name) before fixing, per CLAUDE.md's mandatory
-- author-field verification standard -- not just "looks contaminated":
--   Acceptance (hardcover_id 321750): Jeff VanderMeer (primary author,
--     contribution: null) + Helen Macdonald (contribution: "Introduction")
--   Doomsday Book (hardcover_id 10086): Connie Willis (author) + Daniel
--     Dos Santos (contribution: "Illustrator")
--   The Eyre Affair (hardcover_id 117696): Jasper Fforde (author) + Susan
--     Duerdan (contribution: "Narrator")
--   Nine Princes in Amber (hardcover_id 128171): Roger Zelazny (author) +
--     Tim White (contribution: "illustrator") -- DB's stored value also
--     had Hardcover's own raw internal-whitespace noise ("Tim          White"),
--     cleaned up as part of this fix
--   Shadows for Silence in the Forests of Hell (hardcover_id 427840):
--     Brandon Sanderson (contribution: "Author", primary: true) + Kate
--     Reading (contribution: "Narrator")
--
-- All 5 titles confirmed unique in `books` before writing (no ambiguous
-- subselect risk).

update books set author = 'Jeff VanderMeer'
where title = 'Acceptance';

update books set author = 'Connie Willis'
where title = 'Doomsday Book';

update books set author = 'Jasper Fforde'
where title = 'The Eyre Affair';

update books set author = 'Roger Zelazny'
where title = 'Nine Princes in Amber';

update books set author = 'Brandon Sanderson'
where title = 'Shadows for Silence in the Forests of Hell';
