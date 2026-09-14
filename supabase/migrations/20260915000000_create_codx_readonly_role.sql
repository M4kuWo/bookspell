-- A genuinely read-only Postgres role for CODX (Codex CLI), so it can
-- run scripts/scoring_tests.py's real suite (which needs a direct
-- Postgres connection via load_catalog(), not just the public anon
-- REST key) without ever being able to write -- real technical
-- enforcement at the Postgres permission level, matching the same
-- principle as CODX's push-blocking pre-push hook: don't rely on
-- policy/trust, make the unwanted action actually impossible.
--
-- Scoped to exactly the tables load_catalog() reads (books, book_dna,
-- book_tropes, book_field_confidence, series) -- NOT a blanket grant on
-- the whole public schema, and deliberately excludes every user-data
-- table (ratings, user_rules, profiles, book_suggestions). Rater data
-- for scoring_tests.py comes from local data/ratings/*.json files, not
-- the `ratings` table, so this role never needs to see real user data
-- at all, read-only or otherwise.
--
-- This migration creates the role SHELL only (no LOGIN, no password --
-- a role with no password literally cannot authenticate). The actual
-- `ALTER ROLE ... WITH LOGIN PASSWORD '...'` step happens separately,
-- once, via a direct psql/supabase db query call that is NEVER saved
-- to a file that gets committed -- per this project's standing rule
-- never to commit a hosted credential. Re-running this migration is
-- safe and idempotent; it never touches the password.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'codx_readonly') then
    create role codx_readonly nosuperuser nocreatedb nocreaterole noreplication nologin;
  end if;
end
$$;

grant usage on schema public to codx_readonly;
grant select on books, book_dna, book_tropes, book_field_confidence, series to codx_readonly;
