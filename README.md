<div align="center">

# 📖 Bookspell

**A sci-fi/fantasy book discovery app built on structured "Book DNA," not star ratings.**

A 4.2-star average tells you nothing about *why*. Bookspell tags every book on a
controlled vocabulary — pacing, tone, POV structure, tropes, content warnings,
and more — and recommends by matching a reader's own taste profile against
that structure, not by popularity or "users who liked X also liked Y."

[**Live web app**](https://m4kuwo.github.io/bookspell/app/) ·
[Browse the tagged catalog](https://m4kuwo.github.io/bookspell/tools/catalog-review/) ·
[Rate books](https://m4kuwo.github.io/bookspell/tools/rate-books/) ·
[Project log](docs/project-log.md) ·
[Roadmap](docs/TODO.md)

*Private prototype, actively in development — not a shipped, polished product yet.*

</div>

---

## Status at a glance

| | |
|---|---|
| 📚 Books in catalog | **1,256** |
| ✅ Fully tagged | **1,018** (81%) — the catalog was deliberately expanded ~45% this month; absolute tagged count keeps climbing, see [Roadmap](#-roadmap) |
| 📖 Series tracked | 484, spanning **18 shared universes** (Cosmere, Middle-earth, Westeros, the Grishaverse, and 14 more) |
| 🏷️ Tropes in vocabulary | 152, applied **5,505** times |
| ⚠️ Content warning types | 38 |
| 🎧 Audiobook editions tracked | 1,123 (narrators, cast, production type) |
| 🧑‍🤝‍🧑 Real raters | 4 people, 335+ real ratings, plus one imported Goodreads history |
| 🌐 v1 web app | **Live** — real accounts, manual rating, live recommendations, Goodreads/Fable CSV import |

Everything above is real, queryable data — not aspirational. Browse it yourself at the links above.

## Table of contents

- [How the recommendation engine works](#-how-the-recommendation-engine-works)
- [Architecture](#-architecture)
- [Current state](#-current-state)
- [Roadmap](#-roadmap)
- [Hurdles overcome](#-hurdles-overcome)
- [How this repo is actually built](#-how-this-repo-is-actually-built)
- [Repo layout](#-repo-layout)
- [Running things locally](#-running-things-locally)
- [Design principles](#-design-principles)

## 🧠 How the recommendation engine works

No collaborative filtering, no "users who liked X also liked Y" — there aren't
enough users yet for that to mean anything, and it wouldn't explain *why*
anyway. Instead, each book has ~30 structured attributes (pacing, darkness,
POV structure, romance heat, tropes, and more), and a reader's own like/dislike
history is compared directly against those attributes.

1. **Build a taste profile.** From everything a reader has rated (`loved` down
   to `hated`, a 5-tier scale, not a flat thumbs-up/down), the engine computes
   a *centroid* — the attribute values their loved books tend to share — and a
   *weight* per field, based on how much that field actually differs between
   their liked and disliked books. A reader who loves and hates books across
   every pacing speed learns "pacing doesn't matter much to you"; a reader
   whose dislikes are all slow and loves are all fast learns the opposite.
2. **Score a candidate book** by comparing it field-by-field against that
   profile, weighting each comparison by how much that field matters to this
   specific reader, and averaging it into one score.
3. **Explain the match** in a sentence or two, naming the specific
   fields/tropes that pulled the score up or down — not just a number.

<details>
<summary><strong>A few real problems surfaced in testing, and what fixed them</strong></summary>

- **A correct signal can get outvoted.** If a reader dislikes a book
  specifically for being first-person, but everything else they've rated
  happens to agree on a dozen other traits, that one real signal can get
  diluted into irrelevance. A weighted average is compensatory by
  construction — no amount of weight-tuning fixes that, only a different
  aggregation shape does. Fixed two ways, both conditional on real per-user
  statistical evidence: the strongest mismatch is surfaced as an explicit
  "possible dealbreaker" callout, and — only once there's enough history to
  trust it — a real dealbreaker caps the score outright.
- **A field can dominate everything else.** If a reader's ratings happen to
  split cleanly on one structural trait, that field can end up so heavily
  weighted it functions as a near hard-filter. Fixed with a weight cap.
- **Two fields can double-count the same fact.** First-person narration and
  single-POV structure aren't independent. Fixed with a *conditional
  redundancy discount* — applied per candidate book, never as a blanket rule.
- **A series shouldn't out-vote a standalone.** Loving all 6 Wheel of Time
  books isn't 6x the evidence of loving one standalone with the same traits.
  Fixed: a book's vote is split evenly among its rated series-mates.
- **Don't recommend book 3 of a trilogy to someone who's only read book 1.**
  Fixed: a series installment is excluded unless every earlier one is rated.
- **A "Poor match" label that could never actually fire.** A fixed numeric
  cutoff sat below every genuinely disliked book's real score, across every
  rater. Fixed: the cutoff is now calibrated per user from the gap between
  their own liked and disliked scores.

Full writeups with worked examples: [`docs/scoring-test-protocol.md`](docs/scoring-test-protocol.md)
and [`docs/project-log.md`](docs/project-log.md).

</details>

**Recently consolidated** (Sept 2026): every scoring entry point —
ranking, explanation, evaluation, and audit — now runs through one
canonical `score_candidate()` function instead of four separately
maintained call sites that had already drifted out of sync once (a real,
already-fixed class of bug). See [Current state](#-current-state) below.

## 🏗️ Architecture

```mermaid
flowchart LR
    Reader(["🧑 Reader"])
    App["Static web app<br/>(GitHub Pages)"]
    Auth[("Supabase Auth")]
    DB[("Supabase Postgres<br/>catalog · ratings · rules")]
    API["FastAPI backend<br/>(Render)"]
    Engine["recommend.py<br/>scoring engine"]
    Tagging["Book DNA tagging<br/>(.claude/skills/)"]

    Reader -->|browse, rate, import| App
    App --> Auth
    App -->|catalog browse, manual ratings, rules| DB
    App -->|recommendations, CSV import| API
    API --> Engine
    Engine --> DB
    Tagging -->|batch INSERTs, versioned migrations| DB
```

| Layer | Tech | Notes |
|---|---|---|
| Frontend | Static HTML/CSS/JS, no build step | `app/` — auth, dashboard, manual rating, Goodreads/Fable import; deployed on GitHub Pages |
| Backend API | FastAPI (Python) | `api/` — the only part needing live Python: scoring calls + CSV parsing; deployed on Render's free tier (cold start ~30-60s after idle) |
| Database | Supabase (Postgres) | Catalog, Book DNA, ratings, auth, RLS-scoped user data |
| Scoring engine | Pure Python, no ML framework | [`scripts/recommend.py`](scripts/recommend.py) — see below |
| Data pipeline | Versioned SQL migrations + batch-tagging skills | [`supabase/migrations/`](supabase/migrations/), [`.claude/skills/`](.claude/skills/) |

## 📊 Current state

- **Book DNA schema**: ~30 scalar fields (pacing, darkness, POV count, prose
  style, stakes scope, audiobook length, etc.) plus a controlled vocabulary of
  152 tropes and 38 content warnings. Full spec:
  [`docs/schema/book-dna.md`](docs/schema/book-dna.md) (human-readable) and
  [`docs/schema/book-dna.schema.yaml`](docs/schema/book-dna.schema.yaml)
  (machine-readable).
- **Confidence layer**: every tag can carry a confidence score and a source
  (`ai_inferred`, `manual_review`, etc.) instead of being trusted at face
  value. Fields with a track record of real tagging errors default to reduced
  trust when unassessed, so a verified correction actually outranks an
  unverified guess.
- **Recommendation engine** ([`scripts/recommend.py`](scripts/recommend.py)):
  per-user weighted profile, genre-scoped profiles, a structural-vs-content
  field split so craft/format preferences generalize across genres while
  tone/trope preferences stay genre-specific, series-position awareness,
  Series DNA (does a series improve, worsen, or stay consistent book to
  book), diversity controls, a per-user calibrated "Poor match" threshold, a
  two-tier dealbreaker mechanism, and a cold-start fallback for readers the
  engine doesn't know well yet. **All four scoring entry points — ranking,
  explanation, evaluation, and audit — now share one canonical
  `score_candidate()` implementation**, closing off the exact "test code
  silently drifted from production" bug class that caused real regressions
  earlier this project.
- **v1 web app is live**: real Supabase Auth accounts, per-genre
  recommendations with full "why this matched" explanations, manual rating
  with edit, Goodreads/Fable CSV import, persistent "none of X"/"less of X"
  filter rules. Onboarding/polish/mobile pass still ahead — see
  [Roadmap](#-roadmap).
- **Real external reader validation**: the [catalog review tool](https://m4kuwo.github.io/bookspell/tools/catalog-review/)
  is in front of real test readers, whose feedback has already caught and
  fixed genuine tagging errors across 10+ fields, several missing tropes, and
  a mis-flagged spoiler.
- **Real rater data** ([`data/ratings/`](data/ratings/)): 4 people's real
  liked/disliked lists (335+ ratings total), collected via a no-account,
  mobile-friendly [rating page](https://m4kuwo.github.io/bookspell/tools/rate-books/)
  that saves straight into the live catalog.
- **Reusable scoring test suite** ([`scripts/scoring_tests.py`](scripts/scoring_tests.py)):
  every scoring change is checked against real held-out ratings across every
  rater, a "one field dominates" stress test, a sparse-data scenario,
  series/author-isolated held-out splits, a DNA-field ablation study, and a
  benchmark scorecard — before anything is considered safe to land. Full
  running log of what's been tried, landed, or deferred:
  [`docs/scoring-test-protocol.md`](docs/scoring-test-protocol.md).

## 🗺️ Roadmap

Near-term, roughly in order — the living, prioritized version is
[`docs/TODO.md`](docs/TODO.md):

1. **Keep closing the tagging gap.** The catalog grew from ~870 to 1,256
   books this month (a deliberate scope expansion, not scope creep going
   unchecked) — 1,018 are tagged, with the rest a real, actively-worked
   backlog rather than a handful of permanent exceptions like before.
   Audiobook edition data (1,123 rows) and two ongoing presentation-style
   trope sweeps (`romance_tone`, `worldbuilding_delivery`) are both well
   underway alongside it.
2. **Recruit more real readers.** 4 real raters exist now; most scoring
   conclusions are still primarily validated against one rater's larger
   dataset and only lightly cross-checked against the others, whose
   histories are newer and thinner. Bulk third-party rating datasets were
   evaluated and set aside — their licenses are academic/non-commercial-use
   only, incompatible with this project's commercial intent.
3. **Import an existing reading history on signup** — likely a real adoption
   blocker, not just a nice-to-have, for readers already invested in
   Goodreads/StoryGraph. The CSV import mechanics exist
   (`POST /import/goodreads`); mapping an imported star rating onto Book DNA
   fields with no structured signal is the real remaining design work.
4. **Extend the dilution fix beyond the easy case** — a statistically
   validated dealbreaker cap works, but only once a rater has enough
   disliked-book history to validate it, and a known edge case (categorical
   fields matching all-or-nothing) hasn't shown up in real data yet.
5. **Author-affinity**, weighted toward which specific sub-style of an
   author's catalog a reader actually responds to — logically validated, not
   yet landed.
6. **Fix spoiler leakage** in the explanation layer.
7. **Onboarding, polish, a real mobile pass** on the now-live v1 app.
8. *(Further out)* A guide-character UX — a witch/wizard leading the reader
   through "summoning" a recommendation — deliberately deferred until
   recommendation quality is proven.

<details>
<summary><strong>What's actively being worked on right now</strong></summary>

- **The "one field dominates" vs. "a real signal gets diluted" tension** — a
  real fix landed (a statistically validated dealbreaker cap), but it's
  currently dormant for most real raters simply because their data hasn't
  grown enough to validate a field yet — the threshold is doing its job, not
  broken. A graduated (non-flat-cap) version is built and structurally
  verified but can't be proven against real data until some field/rater pair
  actually validates.
- **Most scoring conclusions are still tuned against one rater's data.**
  `docs/scoring-test-protocol.md` explicitly tracks which ideas are
  "deferred" (not disproven, just not yet shown to help at other raters'
  current scale) vs. genuinely rejected.
- **Author-field data quality** is a recurring, actively-monitored issue —
  translator/illustrator/narrator credits keep slipping into the `author`
  field from the ingestion source. Every newly ingested or re-tagged book
  now gets its author field explicitly verified against source metadata
  before being trusted, rather than fixed reactively after it surfaces.
- **Ongoing vocabulary-gap sweeps** across the whole catalog, looking for
  trope/content-warning gaps that only show up once enough books share a
  pattern to be worth a new vocabulary entry.

</details>

## 🧗 Hurdles overcome

A few of the more interesting bugs and near-misses this project has already
been through:

<details>
<summary><strong>Click to expand — real incidents, real fixes</strong></summary>

- **A migration-tracking desync from a cross-machine mistake.** A session on
  a different machine applied migrations directly against hosted Postgres
  instead of through `supabase db push`, so hosted's own tracking table
  didn't know they'd happened — the next real push tried to redo them and
  failed. Fixed with `supabase migration repair`, and the exact failure mode
  is now documented in [`CLAUDE.md`](CLAUDE.md) so it doesn't happen twice.
- **A left-join bug made untagged books look tagged**, feeding a real
  tester's first round of partially-false feedback before being caught.
- **Real reader feedback caught real tagging errors, fast** — within one
  message from one external reader: two mistagged books, a missing spoiler
  flag, and a schema gap (`narrator_reliability` had no way to express
  "deliberately ambiguous").
- **Catalog expansion alone didn't fix bad recommendations** — doubling
  candidate-pool size moved scores almost not at all; the fix needed better
  *counter-examples* in training data, not more candidates.
- **A "same fact stated twice" bug hid inside a bug fix** — a discount meant
  to fix one field dominating another was itself asymmetric until a sharper
  follow-up question surfaced it.
- **A silent, split-import test-validation bug**: an A/B test of an
  experimental scoring variant monkeypatched one imported copy of the
  scoring module while the real benchmark suite had separately imported a
  second copy under a different name — the "byte-identical, zero
  regressions" result was measuring unmodified code against itself. Caught
  before the variant landed by asserting the two "same" module objects were
  actually the same object (they weren't).
- **A silent truncation bug caught before it ever shipped**, during the
  recent scoring-engine consolidation: a literal migration of one caller
  would have quietly turned an "unlimited results" request into "5 results
  max," because two functions used the same sentinel value (`None`) to mean
  two different things. Caught by a direct before/after probe, not assumed
  safe because the code compiled and ran.

</details>

## 🤖 How this repo is actually built

This is a real, working detail worth knowing if you're poking around the
codebase: Bookspell is developed through a **multi-agent workflow across
three standing personas** — two Claude Code sessions with different roles
(the primary engineering session, and a dedicated data/tagging session), plus
an independent Codex CLI instance used for code review and validated
engine-refactor execution, kept in review-only/no-hosted-write scope by
design. There's no live channel between them; task handoff and review
happen entirely through files committed to this repo.

Curious how that actually works? Start with
[`docs/persona-workflow.md`](docs/persona-workflow.md) (the mechanics),
[`CLAUDE.md`](CLAUDE.md) (repo conventions every session reads first), and
[`AGENTS.md`](AGENTS.md) (the Codex-specific counterpart).

## 📁 Repo layout

```text
docs/
  project-log.md               running history — what got built, argued
                                over, and changed, and why (start here)
  TODO.md                       prioritized, mutable task backlog
  scoring-test-protocol.md      scoring-engine test scenarios + a running
                                 log of what's been tried, landed, or deferred
  persona-workflow.md           how tasks move between the three personas
  codx-tasks/                   CODX's current assignment (one file, always
                                 current — see persona-workflow.md)
  codx-reviews/                 permanent record of every CODX proposal
                                 CLDO has independently verified and applied
  PENDING_APPROVALS.md          cross-session destructive-action approval gate
  schema/
    book-dna.md                 core schema reference, always read in full
    book-dna-vocabulary-gaps.md active tracker (read before tagging/gap sweeps)
    book-dna-tables.md          current contracts for tables that grew out of
                                 this schema (audiobook_editions, work_type, etc.)
    book-dna-decisions.md       deferred proposals + rejected decisions + history
    book-dna.schema.yaml        machine-readable schema (exact, exhaustive vocabulary)
  pilot/, catalog-audit/,       earlier-phase tagging-quality process
  remaining-catalog-tagging/,   records, superseded by the skills in
  step04-test-batch/            .claude/skills/ but kept for history
  recommendation-engine/,       older design/validation writeups, superseded
  data-quality/                 by scoring-test-protocol.md but kept for history

scripts/
  recommend.py                  the recommendation engine
  scoring_tests.py               reusable scoring test scenarios
  ingest-seed-catalog.js         bootstraps the catalog from Hardcover's API
  requirements.txt               Python deps (psycopg2)

app/                             v1 web app — static HTML/CSS/JS, no build
                                  step, Supabase Auth + direct Supabase
                                  queries for everything except live scoring

api/                             FastAPI backend — the only part needing
                                  live Python (scoring calls, CSV import)

data/
  ratings/                       one {name}.json per real rater — the
                                  durable stand-in for a real accounts
                                  system, pre-dating the v1 app's real one

supabase/
  migrations/                    every schema/data change, in order
  config.toml                    local dev config

tools/
  catalog-review/                browse/filter the full tagged catalog —
                                  live at the link above
  rate-books/                    public, no-account rating intake form
  dogfood/                       internal Streamlit tool for live scoring
                                  debugging (repo owner only)

.claude/skills/                  batch-tagging and QA skills (Book DNA,
                                  audiobook editions, trope-gap sweeps)

CLAUDE.md                        working conventions — read before touching
                                  migrations or data
AGENTS.md                        the same, for Codex CLI specifically
```

## 🚀 Running things locally

**Database** (Postgres via Supabase CLI):
```bash
supabase start          # local dev DB at 127.0.0.1:54322
supabase db push        # apply pending migrations to the hosted project
```

**Recommendation engine** (reads `DATABASE_URL`, defaults to local):
```bash
pip install -r scripts/requirements.txt
python3 scripts/recommend.py
```

**Scoring test suite**:
```bash
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres python3 scripts/scoring_tests.py
```

**Backend API** (see [`api/README.md`](api/README.md) for full details):
```bash
cd api && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres \
SUPABASE_JWKS_URL=https://yhvubjqstswxvctdikbc.supabase.co/auth/v1/.well-known/jwks.json \
.venv/bin/uvicorn main:app --reload
```

**Frontend** (`app/`): static files, no build step — open directly or serve
with any static file server; it talks to the hosted Supabase project and API
by default.

**Catalog ingestion** (needs `HARDCOVER_API_TOKEN` + `DATABASE_URL` in `.env`):
```bash
npm run ingest:seed-catalog
```

## 🎯 Design principles

A few things worth knowing before touching the schema or the engine:

- **Controlled vocabulary only, never free text** — every Book DNA field is a
  finite, enumerated set of values. That constraint is what makes similarity
  scoring possible at all.
- **Content warnings are descriptive, not a taste signal** — deliberately
  excluded from the recommendation score; they belong in hard filters, not
  similarity matching.
- **New trope vocabulary has to earn its place**: the bar is "does this
  change a recommendation," not "is this a real term."
- **Per-user weights, not a fixed formula** — how much a field matters is
  learned per user, not applied identically to everyone.
- **A correction should outrank a guess** — a human-verified tag fix needs
  real headroom above an unassessed default to actually matter.
- **Discounts and adjustments are conditional on the specific book being
  scored, never a blanket rule** — a fix discovered the hard way after an
  early version got this wrong.
- **Every scoring change gets checked against more than one failure
  scenario before landing** — a fix that helps one case has repeatedly
  turned out to reopen a different, previously-fixed one.
- **Don't confidently guess on a factual question** — check the DB, the
  catalog, or do a quick search rather than trust recall. This project's
  tagging errors have consistently come from confident-but-wrong recall,
  not felt uncertainty.
- **A problem in how scores are combined can't be fixed by retuning the
  weights that feed into it** — a weighted average is compensatory by
  construction; a real signal getting outvoted needs a different
  aggregation shape, not another weight adjustment inside the same shape.
- **A statistically "validated" pattern still needs a sample-size floor** —
  a small enough sample lets noise clear almost any fixed threshold.

---

<div align="center">

Built and maintained as an active, evolving prototype — not a finished
product. See [`docs/project-log.md`](docs/project-log.md) for the complete,
dated history of every decision, bug, and fix.

</div>
