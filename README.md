# Bookspell

A sci-fi/fantasy book discovery app built on structured **Book DNA**
attributes instead of aggregate star ratings. A 4.2-star average tells
you nothing about *why* — Bookspell tags every book on a controlled
vocabulary (pacing, tone, POV structure, tropes, content warnings, and
more) and recommends by matching a reader's own taste profile against
that structure, not by popularity or what other users liked.

This is a working prototype in active validation, not a shipped
product: the catalog, schema, and recommendation engine are built and
under real-reader testing; the actual app (onboarding, UI, accounts)
hasn't been built yet. See [`docs/project-log.md`](docs/project-log.md)
for the full, dated history of every decision, bug, and fix.

| | |
|---|---|
| Books in catalog | 606 |
| Fully tagged | 307 |
| Series tracked | 251 |
| Tropes in vocabulary | 123 |
| Content warning types | 37 |
| Shared universes | 2 (Cosmere, Middle-earth) |

## How the recommendation logic works, in plain terms

No collaborative filtering, no "users who liked X also liked Y" — there
aren't enough users yet for that to mean anything, and it wouldn't
explain *why* anyway. Instead, each book has ~30 structured attributes
(pacing, darkness, POV structure, romance heat, tropes, and more), and
a reader's own like/dislike history is compared directly against those
attributes.

1. **Build a taste profile.** From everything a reader has rated
   (`loved` down to `hated`, a 5-tier scale, not a flat thumbs up/down),
   the engine computes a *centroid* — the attribute values their loved
   books tend to share — and a *weight* per field, based on how much
   that field actually differs between their liked and disliked books.
   A reader who loves and hates books across every pacing speed learns
   "pacing doesn't matter much to you"; a reader whose dislikes are all
   slow and whose loves are all fast learns the opposite.
2. **Score a candidate book** by comparing it field-by-field against
   that profile, weighting each comparison by how much that field
   matters to this specific reader, and averaging it into one score.
3. **Explain the match** in a sentence or two, naming the specific
   fields/tropes that pulled the score up or down — not just a number.

A few real problems surfaced in testing and what fixes them:

- **A correct signal can get outvoted.** If a reader dislikes a book
  specifically for being first-person, but everything else they've
  rated happens to agree on a dozen other traits, that one real signal
  can get diluted into irrelevance by everything else agreeing for
  unrelated reasons. Partially addressed (see Current issues below —
  not fully solved).
- **A field can dominate everything else.** If a reader's ratings
  happen to split cleanly on one structural trait (say, POV count),
  that field can end up so heavily weighted it functions as a near
  hard-filter, drowning out genre, tone, and trope preferences
  entirely. Fixed with a weight cap, later refined further (see below).
- **Two fields can double-count the same fact.** First-person narration
  and single-POV structure aren't independent — one usually implies the
  other. Counting both at full strength effectively double-counts one
  signal. Fixed with a *conditional redundancy discount*: when a
  specific candidate book actually exhibits both correlated values, one
  gets discounted for that book specifically — not a blanket rule
  applied regardless of context.
- **A series shouldn't out-vote a standalone.** A reader who loved all
  6 Wheel of Time books didn't give 6x the evidence of someone who
  loved one standalone with the same traits — it's largely the same
  underlying taste, repeated. Fixed: a book's vote is now split evenly
  among its series-mates present in the same ratings pool.
- **Don't recommend a book whose predecessor hasn't been read.**
  Recommending book 3 of a trilogy to someone who's only confirmed book
  1 is a real spoiler risk and mostly useless. Fixed: a series
  installment is excluded from recommendations unless every earlier
  installment has been rated.

The full design writeup with worked examples is in
[`docs/scoring-test-protocol.md`](docs/scoring-test-protocol.md) and
[`docs/project-log.md`](docs/project-log.md).

## Current state

- **Book DNA schema**: ~30 scalar fields (pacing, darkness, POV count,
  prose style, stakes scope, audiobook length, etc.) plus a controlled
  vocabulary of 123 tropes and 37 content warnings. Full spec:
  [`docs/schema/book-dna.md`](docs/schema/book-dna.md) (human-readable)
  and [`docs/schema/book-dna.schema.yaml`](docs/schema/book-dna.schema.yaml)
  (machine-readable).
- **Confidence layer**: every tag can carry a confidence score and a
  source (`ai_inferred`, `manual_review`, etc.) instead of being trusted
  at face value. A field with a track record of real tagging errors
  defaults to reduced trust when unassessed, so a human-verified
  correction actually outranks an unverified guess rather than tying
  with it.
- **Recommendation engine v1** ([`scripts/recommend.py`](scripts/recommend.py)):
  per-user weighted profile (see above), genre-scoped profiles
  (fantasy vs. sci-fi vs. blended), a structural-vs-content field split
  so craft/format preferences generalize across genres while
  tone/trope preferences stay genre-specific, series-position
  awareness, series-aware weighting, conditional redundancy discounts,
  Series DNA (aggregate trajectory across a tagged series — does a
  series improve, worsen, or stay consistent book to book), and
  "summon something different" / "less of X" diversity controls.
- **Real external reader validation**: the catalog-review tool
  ([`tools/catalog-review/`](tools/catalog-review/)) is in front of
  real test readers, whose feedback has already caught and fixed
  genuine tagging errors across 10+ fields, several missing tropes, and
  a mis-flagged spoiler — see the Hurdles overcome section below.
- **Reusable scoring test suite** ([`scripts/scoring_tests.py`](scripts/scoring_tests.py)):
  every scoring change gets checked against real held-out ratings, a
  reconstructed "one field dominates" scenario, and a sparse-data
  scenario, before it's considered safe to land — see
  [`docs/scoring-test-protocol.md`](docs/scoring-test-protocol.md).

## Roadmap

Near-term, roughly in order:

1. **Grow the tagged catalog.** 307 of 606 books are tagged; a 299-book
   reserve batch is fully untagged. Priority: finish partially-tagged
   series before tagging new standalones (Series DNA needs 2+ tagged
   books per series to compute anything).
2. **Recruit more real readers.** Every scoring conclusion so far is
   based on exactly one real rater's ratings (mine) — see "Currently
   being worked on" below for why that matters.
3. **Fix the dilution problem properly.** One structural field getting
   correctly detected but outvoted by many unrelated agreeing fields —
   several approaches tried, none has fully solved it yet (see below).
4. **Author-affinity**, tempered by which specific sub-style of an
   author's catalog a reader actually responds to, not a flat "you like
   this author" boost. Logically validated, not yet landed.
5. **Fix spoiler leakage** in the explanation layer — some
   spoiler-flagged fields have already shown up in generated
   explanations.
6. Real app: onboarding flow, UI, accounts. Not started.
7. (Further out) A guide-character UX — a witch/wizard leading the
   reader through "summoning" a book recommendation, with matching
   illustrated art. Purely presentation-layer, deliberately deferred
   until recommendation quality is proven.

The single source of truth for sequencing and open questions is the
[project planning document](docs/project-log.md) plus the "Future
fields backlog" section at the bottom of
[`docs/schema/book-dna.md`](docs/schema/book-dna.md).

## Currently being worked on

- **The "one field dominates" vs. "a real signal gets diluted" tension.**
  A flat cap on how much any one field can matter fixes the first
  problem and reopens the second; removing the cap does the reverse.
  Several fixes tried (a structural-field weight boost, category-based
  weight budgets, a BM25-style saturating curve, Bayesian-average
  shrinkage) — none has cleanly solved dilution without risking
  domination elsewhere. The redundancy discount (see above) is a real,
  narrow win for domination specifically, not a general answer.
- **Everything is tuned against one rater.** All scoring conclusions —
  including "this idea doesn't work" — come from a single person's ~55
  ratings. `docs/scoring-test-protocol.md` explicitly tracks which
  ideas are "deferred" (not disproven, just not shown to help *this*
  rater at *this* scale) vs. genuinely rejected, specifically so a
  second or third rater's data can revisit them rather than assume
  they're settled.
- **Author-field data quality.** 65 of 606 books had contaminated
  author fields (translator, illustrator, or narrator credits mixed in
  from the ingestion source) — cleaned up, but the broader bibliographic
  data hasn't had a full audit for other latent issues.
- **A ~30-book "framing device" audit.** A new trope
  (`retrospective_memoir_narration`) was added and applied to the 2
  books directly confirmed; the other ~30 books sharing the broader
  `framing_device` tag haven't been individually checked for whether
  they actually match this more specific pattern.

## Hurdles overcome

A few of the more interesting bugs and near-misses this project has
already been through:

- **A migration-tracking desync from a cross-machine mistake.** A
  session on a different machine applied migrations directly against
  hosted Postgres instead of through `supabase db push`, so hosted's own
  tracking table didn't know they'd happened — the next real push tried
  to redo them and failed on a non-idempotent statement. Fixed with
  `supabase migration repair`, and the exact failure mode is now
  documented in [`CLAUDE.md`](CLAUDE.md) so it doesn't happen twice.
- **A left-join bug made untagged books look tagged.** The catalog
  review tool's Supabase query used a default left join, so untagged
  reserve-batch books showed up with blank fields — indistinguishable
  from genuinely under-tagged books, and it fed a real tester's first
  round of (partially false) feedback before being caught.
- **Real reader feedback caught real tagging errors, fast.** Within one
  message from one external reader: two mistagged books (wrong POV
  person, a first-contact trope that didn't actually apply), a missing
  spoiler flag, and the discovery that the schema was missing a value
  entirely (`narrator_reliability` had no way to express "deliberately
  ambiguous," only reliable/unreliable).
- **Catalog expansion alone didn't fix bad recommendations.** Doubling
  the catalog size was hypothesized to help profile accuracy; a
  controlled rerun of the same test showed near-zero score movement —
  the fix needed better *counter-examples* in the training data, not a
  bigger candidate pool.
- **A held-out test caught the engine confidently recommending deep
  sequels** to a reader who'd only confirmed reading an early book in
  that series — a real, since-fixed gap, not a hypothetical one.
- **A "same fact stated twice" bug hid inside a bug fix.** A discount
  meant to fix one field dominating another was itself asymmetric in a
  way that wasn't caught until a sharper follow-up question ("wait, is
  this a one-way implication?") revealed the fix needed to be
  conditional on the specific book being scored, not a blanket
  adjustment — see `docs/scoring-test-protocol.md`.

## Repo layout

```
docs/
  project-log.md               running history — what got built, argued
                                over, and changed, and why (start here)
  scoring-test-protocol.md     scoring-engine test scenarios + a running
                                log of what's been tried, landed, or deferred
  schema/
    book-dna.md                 human-readable schema spec + roadmap backlog
    book-dna.schema.yaml        machine-readable schema
  recommendation-engine/        design + validation writeups
  data-quality/                 catalog data-quality audit records
  pilot/, catalog-audit/,       tagging-quality process records
  remaining-catalog-tagging/, step04-test-batch/

scripts/
  recommend.py                  the recommendation engine
  scoring_tests.py               reusable scoring test scenarios
  ingest-seed-catalog.js         bootstraps the catalog from Hardcover's API
  backfill-audio-duration.js     audiobook-length backfill utility
  insert-tagged-batch.py         helper for applying a tagging migration
  feedback_log.jsonl             logged post-read "why didn't it work" feedback
  requirements.txt               Python deps (psycopg2)

supabase/
  migrations/                    every schema/data change, in order
  config.toml                    local dev config

tools/
  catalog-review/                internal QA tool — browse/filter the
                                  full tagged catalog in a browser

.claude/skills/
  tag-catalog-batch/             batch-tagging skill for outsourced
                                  tagging sessions

CLAUDE.md                        working conventions for this repo —
                                  read before touching migrations or data
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

**Scoring test suite**:
```
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres python3 scripts/scoring_tests.py
```

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
- **A correction should outrank a guess** — a human-verified tag fix
  needs real headroom above an unassessed default to actually matter,
  not just tie with it.
- **Discounts and adjustments are conditional on the specific book being
  scored, never a blanket rule applied regardless of context** — a fix
  discovered the hard way after an early version of the redundancy
  discount got this wrong.
- **Every scoring change gets checked against more than one failure
  scenario before landing** — a fix that helps one case has repeatedly
  turned out to reopen a different, previously-fixed one. See
  `docs/scoring-test-protocol.md`.
- **Don't confidently guess on a factual question** — check the DB,
  check the catalog, or do a quick search rather than trust recall,
  especially for anything mechanical (POV structure, whether a specific
  plot beat occurs). This project's tagging errors have consistently
  come from confident-but-wrong recall, not felt uncertainty.
