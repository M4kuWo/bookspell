-- Builds "The First Law World" as a real `universe` row, per the
-- design doc's own universe/series/book hierarchy (docs/schema/book-dna.md
-- "Series & universe" section) -- this exact case was named there as an
-- example and never actually implemented until now (docs/TODO.md's
-- catalog-wide shared-universe linking audit, one of the two known
-- starting cases).
--
-- Before: "First Law World" existed as an ad-hoc SERIES row (not a
-- universe) holding the 3 in-catalog standalones (Best Served Cold, The
-- Heroes, Red Country) with fabricated position_in_series values (4, 5,
-- 6, continuing The First Law trilogy's own numbering) -- while The
-- First Law and The Age of Madness, the two real series in this
-- continuity, had no universe_id linking them together at all.
--
-- After: a real universe row; The First Law and The Age of Madness both
-- link to it via series.universe_id (their own series_id stays
-- untouched -- this doesn't cross-contaminate either trilogy); the 3
-- standalones link to the universe DIRECTLY with series_id set to null
-- and no position_in_series (they were never really "book 4/5/6" of
-- anything, that was a modeling workaround), exactly matching the
-- design doc's "a book can link to a universe directly with no series"
-- case. The now-empty ad-hoc "First Law World" series row is deleted
-- (dependent-row count confirmed zero first, per CLAUDE.md's standing
-- rule) -- it was never a real series, just where the standalones had
-- to live before this fix existed.
--
-- Sharp Ends (a short-story collection set in this same continuity,
-- confirmed in-scope for normal ingestion 2026-09-08 -- the same
-- category as Arcanum Unbounded/The Last Wish, already fully tagged
-- novels in this catalog) is a real, separate gap -- not yet in
-- `books` at all. Deliberately NOT added in this migration: it needs
-- its own real ingestion (bibliographic data via Hardcover) and full
-- Book DNA tagging, not a quick INSERT alongside a linking fix.
-- Tracked as a separate follow-up.

insert into universe (name) values ('The First Law World');

update series set universe_id = (select id from universe where name = 'The First Law World')
where name = 'The First Law';

update series set universe_id = (select id from universe where name = 'The First Law World')
where name = 'The Age of Madness';

update books set
  series_id = null,
  universe_id = (select id from universe where name = 'The First Law World'),
  position_in_series = null
where title in ('Best Served Cold', 'The Heroes', 'Red Country') and author = 'Joe Abercrombie';

-- Verify the ad-hoc series is now empty before deleting it.
delete from series
where name = 'First Law World'
and not exists (select 1 from books where series_id = series.id);
