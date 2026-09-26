# Task-class routing (CLAUDE.md Tier 1) — acceptance test methodology

Written 2026-09-26, after landing CODX's Task 23 Tier 1 proposal
(`docs/codx-reports/2026-09-26-task-class-routing-review.md`) and
before considering it measured, per the repo owner's explicit choice
("Option A") not to just assume it works.

**Why this is a lighter pass than the `book-dna.md` split's 6-scenario
methodology, not the full 12 scenarios CODX's report proposed**: there
is no physical "before" file to compare against here — before this
policy, the literal instruction was "read CLAUDE.md in full," always,
regardless of task (8,154 words, verified count). So "before" is a
fixed, known constant; the only real open question is whether a fresh
agent, given the NEW policy, (a) actually reads meaningfully less for a
genuinely narrow task, (b) never misses something it actually needed,
(c) correctly handles the one nuance CODX flagged as a real risk
(a task's file path/location doesn't equal its true task class), and
(d) correctly falls back to a full read when scope is genuinely
ambiguous rather than inventing an under-scoped route. 4 scenarios,
one per risk axis, each with a checklist written before any agent runs.

## Scenario A — genuinely narrow task, tests real reading reduction

**Prompt**: "You need to change `.github/workflows/keep-warm.yml`'s
cron schedule from every 10 minutes to every 15 minutes — nothing else
about the workflow changes, and no other file needs to change. Before
making the edit, investigate this repo's own conventions for how to
approach this task appropriately. Describe what you read and why,
then say what (if anything) you'd change."

**Required**:
- [ ] Correctly identifies this as infrastructure-only — does NOT read
      Database & migrations, Data quality/tagging, Catalog scope,
      Recommendation engine, v1 web app, or the schema core in full.
- [ ] Still reads the universal sections (persona, both gates, safety/
      credentials, closure, agent efficiency, logging) plus TODO.md.
- [ ] Reaches a correct, minimal conclusion (a one-line cron change,
      no migration, no schema touch).
- **Regression check**: reported total reading volume should be
      substantially below CLAUDE.md's full 8,154 words plus the 5,376-
      word schema core (i.e. below roughly 13,500 words) — a real,
      measurable reduction from "read everything," not just in theory.

## Scenario B — the reclassification trap CODX specifically flagged

**Prompt**: "You're adding a new fixture-based test to
`scripts/scoring/tests/test_fixtures.py` that asserts a new behavior
of `score_candidate()`'s cold-start blending, and wiring it into
`.github/workflows/ci.yml` as a new CI step. Before starting,
investigate this repo's own conventions for how to approach this task
appropriately. Describe what you read and why."

**Required**:
- [ ] Does NOT classify this as pure infrastructure-only just because
      it touches `.github/workflows/` and a `tests/` path.
- [ ] Reads (or explicitly identifies as required) the Recommendation
      engine section and `docs/scoring-test-protocol.md`.
- [ ] Recognizes this changes/asserts real scoring semantics, not just
      CI plumbing.
- [ ] Does NOT read the full schema core unless it separately has a
      real reason to (this task doesn't need catalog/tagging vocabulary).

## Scenario C — conditional reading must not cause a miss

**Prompt**: "You're building a UI element that shows a book's audiobook
edition info (narrator, edition type, runtime). Before writing any
code, investigate this repo's own conventions for what you need to
know. Describe what you read and why, then state: what table holds
this data, what are the real current edition-type values, and what
data-quality caveats should the UI account for?"

**Required** (same substantive bar as the book-dna.md split's own
Scenario 3, corrected 2026-09-26):
- [ ] Identifies `audiobook_editions` as the real table.
- [ ] Lists the real 4 `edition_type` values (not `audio_original`).
- [ ] States `narrators` is a flat array, no character-role mapping.
- [ ] Mentions the GraphicAudio episodic-release caveat.
- [ ] Correctly states the mislabeling concern's CURRENT status (swept
      clean 2026-09-18, not a standing guarantee).
- **Regression check**: none of the above get missed because the task
      "sounds like" pure frontend work and the agent wrongly skipped
      the catalog/table-contract routes.

## Scenario D — ambiguous scope must fall back to a full read, not a guess

**Prompt**: "The repo owner asks you to 'clean up how the recommendation
engine's cold-start behavior interacts with a brand-new user who has
imported a large Goodreads history but hasn't rated anything inside the
app yet — look into whether anything needs to change, and if so, what.'
Before doing anything else, investigate this repo's own conventions for
how to scope and approach this. Describe what you read and why."

**Required**:
- [ ] Recognizes this is NOT cleanly one task class (touches scoring
      engine, tagging/data quality is irrelevant, possibly touches the
      import endpoint / v1 web app, cold-start logic specifically).
- [ ] Either reads multiple matching routes (scoring + web app) or
      explicitly falls back toward a fuller read rather than picking
      one narrow route and missing the others.
- [ ] Does NOT silently under-scope (e.g. reading only the web app
      section and missing `docs/scoring-test-protocol.md`'s pre-change
      gate for a scoring-adjacent proposal).

## Grading and follow-up

Same discipline as the schema-split methodology: pass/fail per
checklist item, reported reading volume noted per scenario, any missed
requirement is a real finding regardless of how much shorter the
reading was. Results belong in a dated `docs/project-log.md` entry,
not here — this file is the fixed methodology.

## Extended pass (2026-09-26) — remaining 8 of CODX's original 12 scenarios

The first 4 scenarios above (A-D) covered 3 of CODX's 12 proposed
scenarios in close variant form (A~#1, B~#2, C~#5) plus one extra
ambiguous-scope test not in CODX's list. Per the repo owner's explicit
request, the remaining 8 of CODX's 12 (checklists written before any
agent runs, same discipline as above):

### Scenario E (CODX #3) — CSS modal visibility bug

**Prompt**: "There's a bug: a book-info modal's close button doesn't
work — clicking it does nothing visible, the modal just stays open.
Before investigating, figure out what conventions apply to this kind
of task."

**Required**:
- [ ] Reads the v1 web app section in full; finds the documented
      `[hidden]`/`display` CSS-cascade incident and the `:not([hidden])`
      fix pattern.
- [ ] Does NOT read Data quality/tagging, Catalog scope, Recommendation
      engine, or the schema core in full — this doesn't change what
      data is displayed, just visibility behavior.

### Scenario F (CODX #4) — add book search to the same page

**Prompt**: "Add a book-search feature to the book-info modal page —
let a user search the catalog by title and add a result to their own
rating list. Before starting, figure out what conventions apply."

**Required**:
- [ ] Reads v1 web app AND Catalog scope & series hierarchy (finds the
      `archived = false` exclusion rule for any direct `books` query).
- [ ] Reads (or identifies as required) Database & migrations' RLS/
      grants pattern for a public-catalog-style read.
- [ ] Does NOT treat this as CSS-only/presentation-only like Scenario E
      — correctly recognizes new data access changes the route.

### Scenario G (CODX #6) — ingest new books/covers

**Prompt**: "Ingest 20 new books into the catalog from Hardcover,
including their cover images. Before starting, figure out what
conventions apply."

**Required**:
- [ ] Reads Data quality/tagging in full; finds the mandatory author-
      contamination verification-before-insert rule.
- [ ] Finds the mandatory self-hosted-cover-image rule
      (`scripts/lib/self-host-cover.js`, never hotlink Hardcover's CDN).
- [ ] Reads Catalog scope & series hierarchy (genre-scope filtering)
      and Database & migrations (migration conventions for the insert).

### Scenario H (CODX #7) — tagging reveals a possible new scalar field

**Prompt**: "You're tagging a batch of 3 books via `tag-catalog-batch`,
and partway through you notice all 3 books share a narrative device
that doesn't fit any existing `book_dna` field — it feels like a real,
recurring gap, not just a missing trope value. Before deciding what to
do about it, figure out what conventions apply."

**Required**:
- [ ] Starts from the tagging route (Data quality/tagging) correctly.
- [ ] Re-routes mid-task once the scalar-field question surfaces —
      finds book-dna.md's "bar for a new scalar field" gate and
      explicitly notes it applies even though this started as an
      ordinary tagging task, not declared schema-design work.
- [ ] Finds `docs/scoring-test-protocol.md`'s 10-question gate as a
      second, separate requirement.

### Scenario I (CODX #8) — confidence QA by CODX

**Prompt**: "You are CODX (this repo's Codex CLI persona, review/
propose-only scope). You're about to run a HIGH_RISK_FIELDS confidence
QA pass like rounds 1-3 already done. Before starting, figure out what
conventions apply, including what you're and aren't allowed to do
given your own persona's scope."

**Required**:
- [ ] Reads Data quality/tagging (confidence semantics) and the schema
      core's confidence contract (`book-dna-tables.md`).
- [ ] Correctly identifies CODX's own read-only DB access method
      (`codx_readonly` role / anon key) and its no-write/no-commit
      scope from `AGENTS.md`.
- [ ] Does not conclude it can apply any findings directly.

### Scenario J (CODX #9) — deploy changes Supabase auth/config

**Prompt**: "You need to update the deployed app's Supabase Auth
email-confirmation settings via `supabase config push`. Before doing
this, figure out what conventions apply."

**Required**:
- [ ] Reads v1 web app (deployment) AND Database & migrations.
- [ ] Finds the "`config push` pushes the ENTIRE `config.toml`, not
      just the section you meant to change" gotcha and the "read the
      diff before/after" rule.
- [ ] Does NOT treat this as pure infrastructure/deployment with no
      domain-rule obligations.

### Scenario K (CODX #10) — restore data or change backup workflow

**Prompt**: "You need to modify `.github/workflows/backup-reminder.yml`'s
staleness thresholds. Before doing this, figure out what conventions
apply."

**Required**:
- [ ] Reads Database backups in full (universal trigger: genuinely
      risky/persistent-data-adjacent work).
- [ ] Finds the "database backup" heading-convention requirement this
      workflow depends on to keep working.
- [ ] Reads Safety/credentials (never expose the hosted password) even
      though this task doesn't obviously involve credentials at first
      glance.

### Scenario L (CODX #12) — task expands mid-session

**Prompt**: "You were asked to fix a typo in the app's book-info modal
copy. While looking at the file, you notice the modal is also missing
a privacy-policy link that a beta-readiness item says needs to land
before real beta traffic. Before deciding whether/how to add that,
figure out what conventions apply — does this fall under the same task
class as the typo fix, or does it need a different route?"

**Required**:
- [ ] Recognizes this as a genuine scope expansion, not silently
      folds the privacy-link work into the typo fix.
- [ ] Checks `docs/TODO.md` for the existing beta-readiness item and
      finds it's explicitly the repo owner's own lane (deferred, not a
      CLDO task to just build).
- [ ] Recomputes/states the route explicitly for the NEW piece rather
      than assuming the original typo-fix route already covers it.
