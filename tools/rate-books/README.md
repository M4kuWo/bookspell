# Rate books (public intake form)

A mobile-friendly page for external readers to rate books without any
account: type a name, search the real catalog, tap a rating. Each
rating saves immediately (no final "submit" step) directly into the
hosted `rating_submissions` table via Supabase's public REST API, using
the same read-only-safe publishable key `tools/catalog-review/` already
uses for reads, plus a narrow, insert-only RLS policy for this one
table (see `supabase/migrations/20260901230000_rating_intake_table.sql`
and its follow-ups).

Built as a plain static page, not a Claude Artifact — every Claude
Artifact persistence capability (`db`, `artifact`) requires the visitor
to be a signed-in member of the owner's organization, which rules out
genuinely external, account-less friends. A static page calling our own
Supabase project directly has no such restriction.

## Why not the same live-fetch pattern as catalog-review, hosted the same way

It is the same pattern (plain `fetch()` against the public REST API) --
the difference is hosting. `catalog-review` only needs to run when the
repo owner is actively reviewing tagging quality, so a local
`python3 -m http.server` is fine. This tool needs to be reachable
whenever a friend gets around to rating books, without depending on
anyone's machine staying on -- so it's deployed to GitHub Pages instead
(see the `gh-pages` branch), a stable, always-on URL.

## Data flow

1. Page loads, fetches nothing until you search.
2. Searching queries `books` (title/author `ilike`) via the anon key --
   the same real, live catalog `catalog-review` reads, so it's never
   stale relative to ongoing tagging work.
3. Tapping a rating `POST`s to `rating_submissions` with
   `Prefer: return=minimal` (no read-back -- the anon key can insert
   but never select, update, or delete on this table, by design).
4. Periodically, someone with database access exports
   `rating_submissions` into `data/ratings/{name}.json` (see that
   directory's own README) -- there's no live sync; it's a manual pull
   for now, matching every other rater's data in this project so far.

## Redeploying after an edit

```
git subtree split --prefix=tools/rate-books -b gh-pages-update
git push origin gh-pages-update:gh-pages --force
git branch -D gh-pages-update
```

(`--force` is safe here specifically because `gh-pages` holds no
history worth keeping -- it's a deploy target, regenerated from
`tools/rate-books/` on `main` every time, never edited directly.)
