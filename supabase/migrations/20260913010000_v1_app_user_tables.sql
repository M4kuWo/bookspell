-- Bookspell v1 web app, step 1 of the build (see docs/TODO.md's P0
-- entry and docs/project-log.md's 2026-09-12 "Bookspell v1 web app"
-- entry for the full plan). Three new tables, all scoped to a real
-- Supabase Auth user via `auth.uid()` -- this is the first real
-- per-user data model this project has had; every prior tool
-- (catalog-review, rate-books, dogfood) was either read-only,
-- anonymous-write-only, or single-user-local.
--
-- Deliberately NOT touching data/ratings/*.json or anything that reads
-- it (scripts/scoring_tests.py) -- those stay the test-fixture rater
-- data exactly as CLAUDE.md documents; these new tables are the LIVE
-- product's own store, unrelated until/unless someone chooses to
-- import their history through the app.
--
-- RLS + grant pattern follows the two real precedents already in this
-- project rather than guessing: the public-read catalog tables
-- (grant + a permissive `using (true)` policy, 20260828040000 /
-- 20260829000000) and rating_submissions' own narrower insert-only
-- policy (20260901230000) -- whose own comment already flagged the
-- easy-to-miss gotcha this migration follows carefully: an RLS policy
-- alone does NOT grant the underlying privilege it restricts, both are
-- required together, and this was confirmed by that migration testing
-- against a real REST call before trusting it. Here, every policy is
-- scoped to `auth.uid()` matching the row's own `user_id` (or `id` for
-- `profiles`), instead of a blanket `true` -- a user can only ever
-- see/change their own data through the anon-key + JWT REST path the
-- frontend uses (`supabase-js` sends the user's own JWT once signed
-- in, which is how PostgREST resolves `auth.uid()` inside RLS).

create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  format_preference text check (format_preference in ('print', 'audiobook', 'mixed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;
grant select, insert, update on profiles to authenticated;

create policy "select own profile" on profiles
  for select to authenticated
  using (auth.uid() = id);

create policy "insert own profile" on profiles
  for insert to authenticated
  with check (auth.uid() = id);

create policy "update own profile" on profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create table ratings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  book_id uuid not null references books (id),
  rating text not null check (rating in ('loved', 'liked', 'it_was_okay', 'disliked', 'hated')),
  rated_date date,
  review text,
  source text not null default 'manual' check (source in ('manual', 'goodreads_import')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, book_id)
);

alter table ratings enable row level security;
grant select, insert, update, delete on ratings to authenticated;

create policy "select own ratings" on ratings
  for select to authenticated
  using (auth.uid() = user_id);

create policy "insert own ratings" on ratings
  for insert to authenticated
  with check (auth.uid() = user_id);

create policy "update own ratings" on ratings
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own ratings" on ratings
  for delete to authenticated
  using (auth.uid() = user_id);

create table user_rules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  -- same string shape recommend.py's parse_user_rule_key() already
  -- accepts: a bare trope id, or "field:value" -- validated at the
  -- application layer (against list_user_rule_targets()'s live output),
  -- not re-validated here against the DNA vocabulary, since that
  -- vocabulary already has its own closed-vocabulary enforcement
  -- elsewhere and duplicating it in a CHECK constraint would drift.
  rule_key text not null,
  rule_type text not null check (rule_type in ('exclude', 'reduce')),
  -- only meaningful for rule_type = 'reduce' (recommend.py's
  -- DEFAULT_REDUCE_STRENGTH = 0.6 is the UI's own default, not
  -- enforced here); NULL for 'exclude' rows.
  strength numeric check (strength is null or (strength > 0 and strength <= 1)),
  created_at timestamptz not null default now(),
  unique (user_id, rule_key)
);

alter table user_rules enable row level security;
grant select, insert, update, delete on user_rules to authenticated;

create policy "select own rules" on user_rules
  for select to authenticated
  using (auth.uid() = user_id);

create policy "insert own rules" on user_rules
  for insert to authenticated
  with check (auth.uid() = user_id);

create policy "update own rules" on user_rules
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own rules" on user_rules
  for delete to authenticated
  using (auth.uid() = user_id);
