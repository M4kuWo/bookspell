-- Fix 4 author-field contamination cases identified during catalog
-- tagging batch 8 (2026-09-20, migration 20260920030000) but never
-- actually applied there -- that migration's own comment said they
-- were "fixed at tagging time" while leaving `books.author` untouched
-- and explicitly deferring the real fix to "a separate authorship-fix
-- migration." This is that migration, landed the same session rather
-- than left pending.
--
-- Each re-verified directly against Hardcover's own cached_contributors
-- data (queried live via GraphQL) before writing anything, per
-- CLAUDE.md's mandatory author-field verification standard:
--   Titus Groan (hardcover_id 309438): Mervyn Peake (author) + Anthony
--     Burgess (contribution: "Foreword", one edition's foreword writer,
--     not a co-author)
--   The Historian (385010): Elizabeth Kostova (author) + Justine Eyre,
--     Paul Michael (both contribution: "Narrator")
--   What You Are Looking for Is in the Library (809366): Michiko Aoyama
--     (author) + Alison Watts (contribution: "Translator"), Rohan Eason
--     (contribution: "Illustrator")
--   When the Moon Hits Your Eye (1443471): John Scalzi (contribution:
--     "Author") + Wil Wheaton (contribution: "Narrator")
--
-- All 4 titles confirmed unique in `books` before writing.

update books set author = 'Mervyn Peake'
where title = 'Titus Groan';

update books set author = 'Elizabeth Kostova'
where title = 'The Historian';

update books set author = 'Michiko Aoyama'
where title = 'What You Are Looking for Is in the Library';

update books set author = 'John Scalzi'
where title = 'When the Moon Hits Your Eye';
