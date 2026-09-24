-- Import-coverage tracking, from the 2026-09-23 external AI review's R4
-- (docs/external-reviews/2026-09-23-gpt-review.md) -- confirmed 2026-09-24
-- that per-import matched/unmatched already shows in app/import.html/
-- api/main.py's response, but nothing PERSISTS it. This adds the
-- persistence: a running coverage percentage over time, and which
-- titles get repeatedly unmatched ACROSS different users' imports --
-- a real catalog-prioritization signal stronger than any one person's
-- single unmatched list.
--
-- Not public-catalog-style tables (see CLAUDE.md's "new public-catalog-
-- style table" grant rule) -- these hold a proxy for a user's private
-- reading history, closer in sensitivity to `ratings`/`book_suggestions`.
-- RLS pattern copied directly from `book_suggestions`
-- (20260913080000_ratings_reasons_array_format_and_suggestions.sql /
-- 20260920000000_admin_view_book_suggestions.sql): a user can see their
-- own rows, the repo owner's real Supabase Auth user id can see all of
-- them (same admin-scoping approach, no role system built for one real
-- admin). No INSERT grant to authenticated/anon on either table --
-- api/main.py writes via its own privileged direct Postgres connection
-- (`_db()`, using DATABASE_URL, not the anon/authenticated REST path),
-- the same way it already writes `ratings` -- so RLS only needs to
-- gate reads here, not writes.

create table if not exists import_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  matched_count int not null,
  unmatched_count int not null,
  created_at timestamptz not null default now()
);

alter table import_events enable row level security;
grant select on import_events to authenticated;

create policy "select own import events" on import_events
  for select to authenticated
  using (auth.uid() = user_id);

create policy "admin select all import events" on import_events
  for select using (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351');

create table if not exists import_unmatched_titles (
  id uuid primary key default gen_random_uuid(),
  import_event_id uuid not null references import_events (id) on delete cascade,
  -- Denormalized (also derivable via import_event_id -> import_events.user_id)
  -- so RLS policies and the cross-user aggregation query below don't
  -- need a join, matching book_suggestions' own precedent of carrying
  -- user_id directly rather than only through a foreign row.
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  author text,
  created_at timestamptz not null default now()
);

alter table import_unmatched_titles enable row level security;
grant select on import_unmatched_titles to authenticated;

create policy "select own unmatched titles" on import_unmatched_titles
  for select to authenticated
  using (auth.uid() = user_id);

create policy "admin select all unmatched titles" on import_unmatched_titles
  for select using (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351');

-- Coverage-percentage and repeated-unmatched-title queries, for
-- reference (not run here -- these are how the numbers described in
-- docs/TODO.md's import-coverage item actually get computed):
--
--   -- overall coverage:
--   select sum(matched_count)::float / nullif(sum(matched_count + unmatched_count), 0)
--   from import_events;
--
--   -- titles unmatched across the most distinct users (catalog-priority signal):
--   select title, author, count(distinct user_id) as distinct_users_missing_it
--   from import_unmatched_titles
--   group by title, author
--   order by distinct_users_missing_it desc, title;
