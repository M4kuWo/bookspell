# Catalog review tool

A throwaway internal QA tool, not part of the product. Lets you browse
the full 168-book catalog with all Book DNA fields rendered readably, and
filter across the whole catalog by any field/trope/content-warning
combination, so tagging issues (a wrong tag, an inconsistent field, a
data gap) are easy to spot by eye — the same discipline as the original
30-book pilot, just self-paced and at full catalog scale.

No editing capability by design: if review turns up something wrong,
fix it directly in the database (a SQL `UPDATE`), the same way every
other tagging correction in this project has been made.

## Running it

Points at the hosted Supabase project (`bookspell`,
`yhvubjqstswxvctdikbc`) as of 2026-08-29 — no local Docker/`supabase
start` required.

1. Serve this directory as static files — it needs to be loaded via
   `http://`, not opened directly as a `file://` path, for the
   browser's CORS handling to cooperate with the REST API:
   ```
   cd tools/catalog-review
   python3 -m http.server 8765
   ```
2. Open `http://127.0.0.1:8765/` in a browser.

That's it — no build step, no dependencies. It's a single static HTML
file that queries Supabase's auto-generated REST API directly with the
project's publishable (anon-equivalent) key. That key is safe to have in
this file — it's meant for exactly this (client-side, public) use, and
only has read access to the catalog tables, gated by both a table grant
and an explicit RLS "public read" policy (see
`supabase/migrations/20260829000000_enable_rls_public_read.sql`).

To point this at local Supabase instead (e.g. testing against in-progress
schema changes before pushing them), swap `API_URL`/`ANON_KEY` at the top
of `index.html` for `http://127.0.0.1:54321/rest/v1` and the local anon
key from `supabase status`.
