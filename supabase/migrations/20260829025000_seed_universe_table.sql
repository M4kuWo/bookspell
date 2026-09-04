-- Backfill the `universe` table's seed rows into a tracked migration.
--
-- Both rows below (The Cosmere, Middle-earth) already exist on hosted --
-- they were inserted directly against hosted's Postgres connection
-- back on 2026-08-28, in the same window the schema itself was stood
-- up, without ever being captured in a migration file. That's exactly
-- the "changed hosted data with no corresponding migration file" bug
-- CLAUDE.md's Database & migrations section warns about -- it went
-- undetected until now because every local Supabase instance that's
-- existed since then inherited persisted container state rather than
-- ever replaying the migration history from an empty database.
--
-- Discovered 2026-09-05 when standing up a genuinely fresh local
-- Supabase instance (via `supabase start` on a machine that had never
-- run it before) failed partway through
-- 20260829030000_series_hierarchy.sql: it references
-- universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e' (The Cosmere),
-- which no earlier migration ever creates.
--
-- Timestamped to apply before 20260829030000_series_hierarchy.sql so a
-- from-scratch local bootstrap works. UUIDs are hosted's real, existing
-- values (verified via a direct read, not guessed), and the insert is
-- on-conflict-safe so reapplying it to hosted (where the rows already
-- exist) is a no-op.
insert into universe (id, name) values
  ('6862330c-db3a-4b83-abaa-448406c1f77e', 'The Cosmere'),
  ('a1e6b6d4-3f9a-4b1e-9f2b-3d6e2c8a7b10', 'Middle-earth')
on conflict (id) do nothing;
