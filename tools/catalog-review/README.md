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

1. Make sure the local Supabase stack is running: `supabase start` (from
   the project root).
2. Serve this directory as static files — it needs to be loaded via
   `http://`, not opened directly as a `file://` path, for the
   browser's CORS handling to cooperate with the local PostgREST API:
   ```
   cd tools/catalog-review
   python3 -m http.server 8765
   ```
3. Open `http://127.0.0.1:8765/` in a browser.

That's it — no build step, no dependencies. It's a single static HTML
file that queries Supabase's auto-generated REST API
(`http://127.0.0.1:54321`) directly with the local anon key (safe to
have in this file — it's the well-known Supabase local-dev default key,
not a real secret, and only has read access granted to it here).
