-- Local dev had RLS off catalog-wide (fine on localhost). Now that the
-- project is hosted and genuinely internet-reachable, replace that
-- implicit "everything open" default with explicit, auditable
-- public-read policies -- read access for the catalog tables (book
-- metadata and DNA tags, nothing sensitive), nothing else. Write access
-- stays restricted to the service role (used by ingestion/tagging
-- scripts and migrations), which bypasses RLS entirely.
--
-- This intentionally does NOT set a precedent for future tables. Step 07
-- (onboarding/ratings, friend graph) will introduce real user data --
-- those tables need their own, much narrower policies (a user reads/
-- writes their own rows only), decided when that data model exists.

alter table books enable row level security;
alter table book_dna enable row level security;
alter table tropes enable row level security;
alter table content_warning_types enable row level security;
alter table book_tropes enable row level security;
alter table book_content_warnings enable row level security;
alter table series enable row level security;
alter table universe enable row level security;

create policy "public read access" on books for select using (true);
create policy "public read access" on book_dna for select using (true);
create policy "public read access" on tropes for select using (true);
create policy "public read access" on content_warning_types for select using (true);
create policy "public read access" on book_tropes for select using (true);
create policy "public read access" on book_content_warnings for select using (true);
create policy "public read access" on series for select using (true);
create policy "public read access" on universe for select using (true);
