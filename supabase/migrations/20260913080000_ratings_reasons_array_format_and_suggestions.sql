-- Real-user-testing feedback batch 3 (2026-09-13):
-- - #1: "why did you feel this way" should allow more than one pick --
--   `reason` (singular text, added this same day in 20260913070000)
--   converted to `reasons text[]`. Zero rows exist yet in `ratings`
--   (no real users), so a clean drop+add is safe -- no backfill needed.
-- - #4: format (book vs. audiobook) per rating, so a reader who reads
--   the same series in both formats across books can track which.
-- - #2: a lightweight "suggest a missing book/series" intake so the
--   tagging side can prioritize real reader requests instead of only
--   working off Hardcover genre-search pulls.
alter table ratings drop column if exists reason;
alter table ratings add column if not exists reasons text[];
alter table ratings add column if not exists format text check (format in ('print', 'audiobook'));

create table if not exists book_suggestions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  author text,
  series_name text,
  note text,
  status text not null default 'open' check (status in ('open', 'tagged', 'rejected')),
  created_at timestamptz not null default now()
);

alter table book_suggestions enable row level security;
grant select, insert on book_suggestions to authenticated;

create policy "select own suggestions" on book_suggestions
  for select to authenticated
  using (auth.uid() = user_id);

create policy "insert own suggestions" on book_suggestions
  for insert to authenticated
  with check (auth.uid() = user_id);
