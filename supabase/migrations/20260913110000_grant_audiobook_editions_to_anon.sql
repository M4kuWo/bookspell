-- Follow-up to 20260913100000: that migration granted `authenticated`
-- select on audiobook_editions (for the v1 app's book-info modal), but
-- missed `anon` -- checked against books/book_dna's existing grants
-- (both anon AND authenticated) and found the mismatch. tools/catalog-
-- review/index.html queries audiobook_editions using the anon key
-- directly as its bearer token (no login), so it's been running under
-- the `anon` role this whole time -- meaning its own audiobook-edition
-- display has likely been silently empty since that table was created,
-- for the same underlying reason the v1 app's modal was.
grant select on audiobook_editions to anon;
