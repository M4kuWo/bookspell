-- Removes two books flagged during today's catalog tagging batches as
-- genuinely out of v1 scope (sci-fi/fantasy only), confirmed by the
-- repo owner 2026-09-09:
--   - Shogun (James Clavell) -- historical fiction, no SFF content.
--     Pulled in by a broad genre search, same pattern as every other
--     confirmed-out-of-scope book this project has hit before.
--   - The Screwtape Letters (C. S. Lewis) -- theological satire, not
--     genre fantasy.
-- Both were untagged (no book_dna/book_tropes/book_content_warnings/
-- book_field_confidence/audiobook_editions rows -- verified before
-- writing this migration), so no dependent-row cleanup is needed
-- beyond the books rows themselves.
--
-- Shogun was also the only book in the "Asian Saga: Chronological
-- Order" series row -- deleting it leaves that series orphaned with
-- zero books, so it's removed too rather than left as dangling
-- clutter (same cleanup pattern as the 2026-09-08 Cosmere duplicate-
-- series fix).

delete from books where title = 'Shōgun' and author = 'James Clavell';
delete from books where title = 'The Screwtape Letters' and author = 'C. S. Lewis';
delete from series where name = 'Asian Saga: Chronological Order'
  and not exists (select 1 from books where series_id = series.id);
