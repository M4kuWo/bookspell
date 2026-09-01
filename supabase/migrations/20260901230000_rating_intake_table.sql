-- Step 07 arriving early, in a narrow form: the public-facing rating
-- intake tool (tools/rate-books/) needs somewhere to write submissions
-- from friends who aren't signed into anything -- no accounts exist
-- yet, so this is genuinely public, unauthenticated write access via
-- the anon key, same key the catalog-review tool already uses for
-- reads. The 2026-08-29 RLS migration explicitly flagged this as
-- needing "its own, much narrower policy" when the data model existed --
-- this is that policy, and it's deliberately as narrow as a public
-- write policy can be:
--   - INSERT only. No SELECT, UPDATE, or DELETE for the anon role --
--     a submitter can add a rating but can never read back anyone's
--     submissions (including their own) or alter/remove any row via
--     the public API. Reading this table for real use (exporting into
--     data/ratings/*.json) goes through the service role, which
--     bypasses RLS, same as every other write in this project.
--   - No foreign-key requirement tying a submission to a specific
--     person/session -- there's no such concept yet -- rater_name is
--     just free text the submitter typed, same trust level as the
--     ratings lists collected by hand so far.
--   - A second submission for the same (rater_name, book_id) is just
--     another row, not an upsert -- last write wins when exporting,
--     decided by submitted_at, not enforced by the schema.

create table rating_submissions (
  id uuid primary key default gen_random_uuid(),
  rater_name text not null,
  book_id uuid not null references books(id),
  book_title text not null, -- denormalized for easy inspection without a join
  rating text not null check (rating in ('loved', 'liked', 'it_was_okay', 'disliked', 'hated')),
  submitted_at timestamptz not null default now()
);

alter table rating_submissions enable row level security;

-- The anon role has no default INSERT privilege on a newly created
-- table (unlike the pre-existing catalog tables, which must have gotten
-- theirs from an earlier project-setup step, not from anything in this
-- migration history) -- an RLS policy alone doesn't grant the
-- underlying privilege it's restricting. Confirmed by testing against
-- hosted's real REST API before trusting this: the policy alone
-- produced a silent RLS-violation rejection on every insert until this
-- grant was added.
grant insert on rating_submissions to anon;

create policy "public insert only" on rating_submissions
  for insert
  to anon
  with check (true);
