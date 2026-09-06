# Dogfood tool (internal only)

A minimal local Streamlit app for interacting with
`scripts/recommend.py` directly -- pick a rater, add/fix a rating, build
"none of X" / "less of X" rules against a real search box, and see live
recommendations with a per-book explanation (the same
`audit_book_score()` pipeline breakdown used throughout this project's
own testing).

**This is explicitly NOT the real product UI.** It exists to (a) let a
real person exercise the manual-rules mechanism (built 2026-09-05)
instead of only checking it algebraically, and (b) accelerate getting
real tester data -- several open questions (`romance_tone` validation,
the execution-DNA probe, per-value nominal weight learning) are all
bottlenecked on having more real users, and this is the fastest path to
that. It's a throwaway/internal artifact, built with a different
architecture (a local Python process calling `recommend.py` directly)
than `tools/rate-books/`/`tools/catalog-review/`'s static-page-against-
Supabase-REST pattern -- deliberately different, because this tool
needs to run live Python scoring logic, not just read/write rows, and
it's for the repo owner (not an external, account-less visitor), so the
"must work as a static page" constraint those two tools have doesn't
apply here.

## Setup (already done once, kept here for a fresh machine)

```
python3 -m venv tools/dogfood/.venv
tools/dogfood/.venv/bin/pip install streamlit psycopg2-binary
```

## Run

```
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  tools/dogfood/.venv/bin/streamlit run tools/dogfood/app.py \
  --server.address 127.0.0.1
```

Then open the printed `http://localhost:8501` URL.

**`--server.address 127.0.0.1` is not optional** -- without it,
Streamlit binds to all interfaces and prints an "External URL"
reachable from outside this machine while it's running (confirmed
during testing). This tool has no auth of its own, so don't run it
without pinning the bind address, and don't leave it running unattended
on a network you don't trust.

## What it does

- **Rater picker** (sidebar): switches between `data/ratings/*.json`.
- **Add or fix a rating** (sidebar): the exact workflow that caught
  several real gaps tonight (missing Demon Cycle/Age of Madness
  sequels, Forsworn) -- writes directly back to that rater's JSON file,
  no DB involved (ratings live in JSON, not Postgres, same as
  everywhere else in this project).
- **Rule builder** (sidebar): search box over `list_user_rule_targets()`
  (every trope + every real field:value pair in the catalog), "None of
  this" (hard exclude) / "Less of this" (soft multiplicative discount,
  default strength unless "Advanced" is toggled on for a custom
  0.0-1.0 slider), a visible list of active rules each with its own
  remove button, and "Reset all rules."
- **Recommendations**: genre + count, then a real `recommend()` call
  with the active rules applied. Each result shows its cover (from
  `books.cover_url`, fetched separately from `R.load_catalog()`'s own
  query -- cover art has no scoring use, so it's kept out of the shared
  engine's query) next to an expander with its full `audit_book_score()`
  pipeline (every stage's score, top matches/mismatches) -- not just a
  ranked list, the actual "why" for each one. The same cover also
  previews in "Add or fix a rating" once a book is picked.

## Known limitations

- Exercised end-to-end in a browser (2026-09-06): rater picker, rating
  add/fix, rule search/exclude/reduce/remove/reset, and recommendations
  with the audit breakdown all confirmed working. One real UX pattern
  to know: a few sidebar sections (ratings count, active-rules list)
  are rendered *before* the button logic that mutates them in script
  order, so a change sometimes only shows on the *next* rerun, not the
  one triggered by the click itself -- not a bug, just Streamlit's
  top-to-bottom script execution; a stale-looking screenshot right
  after a click doesn't necessarily mean the click failed.
- ~2 of 873 catalog books have no `cover_url` -- those just show no
  image (not a broken-image icon), same silent-skip pattern as any
  other optional field in this tool.
- No auth, no multi-user support, no persistence beyond the same
  `data/ratings/*.json` files every other script already reads/writes.
  Two people should not run this against the same rater file at the
  same time (same collision risk as any other tool editing those files
  directly).
- `list_user_rule_targets()`'s labels are simple title-cased renderings
  of the raw id/value (see its own docstring) -- fine for internal use,
  would want a curated label map for anything more public-facing.
