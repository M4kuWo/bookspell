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

## Hosting

Same live-fetch pattern as catalog-review (plain `fetch()` against the
public REST API) -- and, discovered while building this, the SAME
hosting too: this whole repo is already served by GitHub Pages from the
`main` branch root (Settings -> Pages), which is how `catalog-review`
has been reaching friends this whole time. This tool needs that same
always-on reachability -- friends rate books whenever they get around to
it, with no dependency on anyone's machine staying on -- and it gets it
for free, live at
https://m4kuwo.github.io/bookspell/tools/rate-books/ a minute or two
after any push to `main` touches this directory. No separate deploy step,
no `gh-pages` branch needed.

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

Nothing to do beyond the normal `git push origin main` -- GitHub Pages
rebuilds automatically from `main` on every push, same as any other
file in this repo.
