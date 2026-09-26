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
