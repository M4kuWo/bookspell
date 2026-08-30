# Bookspell

A sci-fi/fantasy book discovery app built on structured **Book DNA**
attributes instead of aggregate star ratings. A 4.2-star average tells
you nothing about *why* — Bookspell tags every book on a controlled
vocabulary (pacing, tone, POV structure, tropes, content warnings, and
more) and recommends by matching a reader's own taste profile against
that structure, not by popularity.

This is a working prototype, not a shipped product: the catalog,
schema, and recommendation engine are built and validated; the actual
app (onboarding, UI, accounts) hasn't been built yet. See
[`docs/project-log.md`](docs/project-log.md) for the full, dated history
of what's been built and why.

## Current state

- **167 books** tagged (sci-fi/fantasy, v1 scope), spanning 82 series
  across 2 shared universes (Cosmere, Middle-earth).
- **Book DNA schema**: ~30 scalar fields (pacing, darkness, POV count,
  prose style, stakes scope, audiobook length, etc.) plus a controlled
  vocabulary of 120 tropes and 37 content warnings. Full spec:
  [`docs/schema/book-dna.md`](docs/schema/book-dna.md) (human-readable)
  and [`docs/schema/book-dna.schema.yaml`](docs/schema/book-dna.schema.yaml)
  (machine-readable).
- **Recommendation engine v1** ([`scripts/recommend.py`](scripts/recommend.py)):
  a per-user weighted vector built from a reader's liked/disliked books
  — no collaborative filtering, no fixed global formula. Supports
  genre-scoped profiles (fantasy vs. sci-fi vs. blended), a
  structural-vs-content field split so craft/format preferences
  (POV count, pacing) generalize across genres while tone/trope
  preferences stay genre-specific, and "summon something different" /
  "less of X" controls to guard against echo-chamber recommendations.
  Design and validation writeup: [`docs/recommendation-engine/v1-findings.md`](docs/recommendation-engine/v1-findings.md).
- **What's next**: see the "Future fields backlog" section at the
  bottom of `docs/schema/book-dna.md` for the full, actively-maintained
  roadmap of ideas under consideration.

## Repo layout

```
docs/
  project-log.md              running history — what got built, argued
                               over, and changed, and why (start here)
  schema/
    book-dna.md                human-readable schema spec + roadmap backlog
    book-dna.schema.yaml       machine-readable schema
  recommendation-engine/       design + validation writeups
  pilot/, catalog-audit/, ...  tagging-quality process records

scripts/
  recommend.py                 the recommendation engine prototype
  ingest-seed-catalog.js        bootstraps the catalog from Hardcover's API
  requirements.txt              Python deps (psycopg2)

supabase/
  migrations/                   every schema/data change, in order
  config.toml                   local dev config

tools/
  catalog-review/                internal QA tool — browse/filter the
                                  full tagged catalog in a browser
```

## Running things locally

**Database** (Postgres via Supabase CLI):
```
supabase start          # local dev DB at 127.0.0.1:54322
supabase db push        # apply pending migrations to the hosted project
```

**Recommendation engine** (reads `DATABASE_URL`, defaults to local):
```
pip install -r scripts/requirements.txt
python3 scripts/recommend.py
```
Or import `load_catalog`/`recommend` directly for a custom liked/disliked
list — see the `__main__` block in `scripts/recommend.py` for a working
example.

**Catalog ingestion** (needs `HARDCOVER_API_TOKEN` + `DATABASE_URL` in `.env`):
```
npm run ingest:seed-catalog
```

**Catalog review tool** — see [`tools/catalog-review/README.md`](tools/catalog-review/README.md).

## Design principles

A few things worth knowing before touching the schema or the engine:

- **Controlled vocabulary only, never free text** — every Book DNA
  field is a finite, enumerated set of values. That constraint is what
  makes similarity scoring possible at all.
- **Content warnings are descriptive, not a taste signal** — they're
  deliberately excluded from the recommendation score; they belong in
  hard filters ("never show me X"), not similarity matching.
- **New trope vocabulary has to earn its place**: the bar is "does this
  change a recommendation," not "is this a real term." A trope that's
  real but doesn't discriminate between books a reader would and
  wouldn't want gets left out.
- **Per-user weights, not a fixed formula** — how much a field matters
  is learned per user from how much it actually differs between their
  liked and disliked books, not applied identically to everyone.
