-- Add a release-date RANGE to audiobook_editions instead of a single
-- release_date column. Repo owner's explicit design call (see
-- docs/TODO.md's 2026-09-18 runtime_minutes/release_date entry): a
-- single date would misrepresent an in-progress multi-part dramatized
-- release (e.g. GraphicAudio's Wind and Truth, released across 5 parts
-- over ~4 months) -- a range ("2019-2023") is honest about that, a
-- single date isn't. A single-release edition gets both columns set to
-- the same date; a multi-part one gets a genuinely different start/end,
-- with release_date_end left null until release_status =
-- 'fully_released' (the end date isn't knowable before then).
--
-- Schema only -- no backfill here. Populating these needs real
-- per-row research (Hardcover's editions type has this data but with
-- real caveats, per the Dragon Reborn TODO entry), added to the
-- standing tag-audiobook-editions research backlog instead of guessed
-- at in this migration.

alter table audiobook_editions
  add column if not exists release_date_start date,
  add column if not exists release_date_end date;

comment on column audiobook_editions.release_date_start is
  'First (or only) part''s release date. Null until researched.';
comment on column audiobook_editions.release_date_end is
  'Last part''s release date. For a single-release edition, equals release_date_start. Left null for an in_progress/announced multi-part release until release_status becomes fully_released.';
