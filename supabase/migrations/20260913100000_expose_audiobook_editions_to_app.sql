-- audiobook_editions (1123 rows, real narrator/cast/edition data
-- collected separately from book_dna tagging) had RLS disabled AND no
-- grant to `authenticated` -- meaning the v1 app's new book-info modal
-- (2026-09-13) would have silently returned nothing for it, looking
-- identical to "no data collected" even for books with rich real data.
-- Caught before shipping by checking grants, not by observing the bug
-- live. Same pattern as `books`/`book_dna` (see
-- 20260913020000_grant_catalog_select_to_authenticated.sql and their
-- existing RLS policies): public catalog data, RLS enabled with a
-- permissive read policy rather than left ungated.
alter table audiobook_editions enable row level security;

create policy "public read access" on audiobook_editions
  for select to public
  using (true);

grant select on audiobook_editions to authenticated;
