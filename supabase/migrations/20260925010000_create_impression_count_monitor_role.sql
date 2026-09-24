-- A genuinely count-only Postgres role for the impression-count
-- monitoring check (see recommendation_impressions' own migration,
-- 20260925000000, for why this alert exists and what threshold it
-- watches). Same principle as codx_readonly
-- (20260915000000_create_codx_readonly_role.sql): real technical
-- enforcement at the Postgres permission level, not just "this
-- workflow only happens to run count(*)."
--
-- Scoped to exactly ONE column of ONE table -- `select (id)` on
-- recommendation_impressions, not even a whole-table select the way
-- codx_readonly gets across its 5 catalog tables. `count(*)` only
-- needs SELECT privilege on some column, so this is sufficient for the
-- monitoring workflow's actual need (a row count) while being
-- confirmedly unable to read user_id/book_id/score/evidence_confidence
-- -- there is no legitimate reason for this role to see any real
-- content, only how many rows exist.
--
-- Role SHELL only (no LOGIN, no password) -- the actual
-- `ALTER ROLE ... WITH LOGIN PASSWORD '...'` step happens separately,
-- once, via a direct psql/supabase db query call never saved to a
-- committed file, per this project's standing rule never to commit a
-- hosted credential. Re-running this migration is safe and idempotent;
-- it never touches the password.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'impression_count_monitor') then
    create role impression_count_monitor nosuperuser nocreatedb nocreaterole noreplication nologin;
  end if;
end
$$;

grant usage on schema public to impression_count_monitor;
grant select (id) on recommendation_impressions to impression_count_monitor;
