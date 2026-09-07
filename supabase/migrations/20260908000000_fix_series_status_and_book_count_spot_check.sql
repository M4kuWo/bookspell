-- Fixes 5 series rows with wrong status/book_count, flagged directly by
-- the repo owner (The Divine Cities showing as 4 books ongoing when it's
-- a completed trilogy; Between Earth and Sky showing ongoing when
-- complete; The Age of Madness showing 6 books ongoing when it's a
-- completed trilogy; "First Law World" showing 17 books ongoing when
-- it's 3 completed standalones; The Dresden Files showing 79 books).
--
-- ROOT CAUSE (found in scripts/ingest-seed-catalog.js, confirmed against
-- these 5 examples, and a broader query shows this affects most of the
-- 343-row series table, not just these 5 -- see docs/project-log.md's
-- 2026-09-08 entry for the full audit and why a catalog-wide fix isn't
-- attempted here):
--   - `status`: fetchSeriesCompletion() reads Hardcover's `is_completed`
--     field and treats anything other than a literal `true` as
--     'ongoing' -- including null/missing data, which Hardcover leaves
--     sparse/uncurated for most series. A completed series with no
--     explicit is_completed=true flag on Hardcover silently defaults to
--     'ongoing' with no way to tell the difference from a genuinely
--     unfinished one.
--   - `book_count`: pulled directly from Hardcover's own `books_count`
--     field on the series object, which is a raw count of every
--     edition/omnibus/box-set/translation Hardcover has tagged under
--     that series slug, not a curated "real mainline installments"
--     count -- explains why classic/heavily-reprinted series show
--     wildly inflated numbers.
--
-- Neither field is read anywhere in scripts/recommend.py (checked
-- before this migration) -- this is a display-only bug in
-- tools/catalog-review/, not a scoring bug.
--
-- Dresden Files' 18 count verified via web search 2026-09-08 (18
-- published novels as of 2026, a 19th -- Mirror Mirror -- announced but
-- unpublished, so not counted, matching this project's existing
-- convention of not counting unpublished books e.g. Winds of Winter).

update series set status = 'completed', book_count = 3
where name = 'The Divine Cities';

update series set status = 'completed'
where name = 'Between Earth and Sky';

update series set status = 'completed', book_count = 3
where name = 'The Age of Madness';

update series set status = 'completed', book_count = 3
where name = 'First Law World';

update series set book_count = 18
where name = 'The Dresden Files';
