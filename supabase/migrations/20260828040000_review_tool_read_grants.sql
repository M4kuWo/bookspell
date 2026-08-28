-- Read-only grants for the internal catalog review tool, which queries
-- Supabase's auto-generated REST API (PostgREST) directly from a static
-- HTML page as the anon role. Local dev only; RLS is off catalog-wide
-- and there's no sensitive data in these tables (book metadata and DNA
-- tags), so a blanket SELECT grant is fine here.

grant usage on schema public to anon;
grant select on
  books, book_dna, tropes, content_warning_types,
  book_tropes, book_content_warnings, series, universe
to anon;
