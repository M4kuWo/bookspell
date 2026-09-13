-- Real gap found while building the v1 app's rate.html (catalog
-- search) and its `ratings` -> `books` embed: 20260828040000 granted
-- SELECT on the catalog tables to the `anon` Postgres role only, for
-- the anon-key-only tools that existed at the time (catalog-review,
-- rate-books). A signed-in Supabase Auth user's requests run as the
-- `authenticated` role instead (a separate Postgres role, no implicit
-- grant inheritance from `anon`) -- the existing "public read access"
-- RLS policies already have no `to` clause so they apply to every
-- role, but RLS is a second gate AFTER the underlying GRANT, not a
-- substitute for it (the exact gotcha rating_submissions' own migration
-- comment already flagged for INSERT; this is the same thing for
-- SELECT). Without this, a logged-in user's catalog search/embed would
-- fail with a permission-denied error despite RLS allowing it.

grant select on
  books, book_dna, tropes, content_warning_types,
  book_tropes, book_content_warnings, series, universe
to authenticated;
