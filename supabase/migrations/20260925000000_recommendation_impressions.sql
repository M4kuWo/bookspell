-- Prospective recommendation-outcome tracking, part 1: impressions.
-- (docs/TODO.md's item -- design pass done 2026-09-25 with the repo
-- owner, see docs/project-log.md's 2026-09-25 entry for the full
-- reasoning, including why this was NOT built as "just add a table"
-- without that pass first.)
--
-- Records what /recommendations actually SHOWED a user: which book, at
-- what rank/score, in which genre pool, and this candidate's
-- evidence_confidence at the time (scripts/scoring/confidence.py,
-- landed the same day) -- so a later analysis can ask "did a book we
-- scored highly / were confident about actually get rated well," using
-- real ongoing usage instead of only the ~4-person manual rater
-- benchmark (scripts/scoring_tests.py).
--
-- Deliberately NOT a second "outcome" table with its own logged events
-- (opened detail, viewed explanation, etc.) -- that would need new
-- frontend click-tracking instrumentation, which is out of scope for
-- this pass (the repo owner is mid-visual-overhaul on app/ himself).
-- "Outcome" for now is computed by joining this table against the
-- EXISTING `ratings` table on (user_id, book_id) and comparing
-- timestamps (see the reference query at the bottom) -- a real,
-- already-available signal that needed zero new frontend code.
--
-- Retention: indefinite for now (explicit 2026-09-25 decision, not an
-- oversight) -- matches every other user-data table in this project,
-- none of which has a purge policy either. Real storage is bounded by
-- Supabase's free-tier 500MB total, which back-of-envelope math puts
-- at roughly 1.6M rows of this shape before it's a genuine concern (at
-- ~300 bytes/row including index overhead) -- rather than build purge
-- machinery nobody has needed yet, a monitoring role + scheduled check
-- (`20260925010000_create_impression_count_monitor_role.sql`,
-- `.github/workflows/impression-count-check.yml`) alerts at 100,000
-- rows, ~16x below that real ceiling -- early warning of real traction
-- long before it's an actual capacity problem, not a hard limit.
--
-- RLS/grant pattern matches ratings/import_events' own precedent: own
-- rows + the repo owner's admin uid, no insert grant to authenticated/
-- anon -- api/main.py writes via its own privileged `_db()` connection
-- (DATABASE_URL), the same way ratings/import_events already do.
create table recommendation_impressions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  book_id uuid not null references books (id),
  -- null = the combined ''/None pool (see api/main.py's own
  -- genre validation: `genre not in (None, "fantasy", "sci_fi")`).
  genre text check (genre in ('fantasy', 'sci_fi')),
  rank int not null check (rank > 0),
  score numeric not null,
  -- Guaranteed in [0, 1] by scoring/confidence.py's own
  -- evidence_confidence()'s construction (an average of two already-
  -- bounded [0,1] components, then round()ed) -- safe to enforce here,
  -- unlike `score` above, which this migration deliberately does NOT
  -- range-check (no equivalent ironclad guarantee has been audited).
  evidence_confidence numeric not null check (evidence_confidence >= 0 and evidence_confidence <= 1),
  created_at timestamptz not null default now()
);

alter table recommendation_impressions enable row level security;
grant select on recommendation_impressions to authenticated;

create policy "select own recommendation impressions" on recommendation_impressions
  for select to authenticated
  using (auth.uid() = user_id);

create policy "admin select all recommendation impressions" on recommendation_impressions
  for select using (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351');

-- Shown-score-vs-later-rating correlation, for reference (not run here
-- -- how the "did this predict outcome" analysis this table exists for
-- actually gets computed):
--
--   select ri.score, ri.evidence_confidence, r.rating, r.created_at - ri.created_at as time_to_rate
--   from recommendation_impressions ri
--   join ratings r on r.user_id = ri.user_id and r.book_id = ri.book_id
--   where r.created_at > ri.created_at
--   order by ri.created_at;
--
-- Row-count check for the 100,000-row monitoring alert above:
--
--   select count(*) from recommendation_impressions;
