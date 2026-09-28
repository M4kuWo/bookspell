# Convention reading bundle

The following shared notice applies to every source below.

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*

## Source: docs/conventions/scoring.md

# Recommendation engine (`scripts/recommend.py`)




- **Read `docs/scoring-test-protocol.md` before changing any scoring
  logic** (`build_profile`, `score_book`, `explain_book`, or anything
  that computes a weight). It has a running table of every idea tried
  so far — landed, rejected, and deferred — and why. Several ideas that
  looked like clear wins under an incomplete test turned out not to be;
  don't re-litigate a rejected idea, or claim a win, without checking
  that table first. **Answer its "Before proposing any scoring change:
  the 10-question gate" section before writing any code** — a real,
  binding pre-check (adopted 2026-09-24), not optional framing. Read
  the protocol per its own "Reading contract" (front section in full,
  then complete relevant history entries found by search); its running
  table is navigation, not an authoritative current-status index.
- **Every scoring change must be checked against at least two failure
  scenarios before landing**, not just the one that motivated it: a
  fix that helps a real signal from getting diluted by many unrelated
  agreeing fields has repeatedly turned out to reopen a different,
  previously-fixed bug where one field dominates everything else
  (or vice versa). `scripts/scoring_tests.py` has both scenarios ready
  to run.
- **A discount/adjustment must be conditional on the specific book
  being scored, never a blanket adjustment applied regardless of
  context.** A real bug shipped briefly because of this: a redundancy
  discount between two correlated fields was applied as a flat
  per-profile weight reduction, which wrongly discounted a field for
  candidate books where the correlation didn't actually apply. Fixed by
  moving the discount into `score_book()`/`explain_book()`, applied
  per-book. See `REDUNDANCY_DISCOUNTS` for the pattern.
- **Rater data lives in `data/ratings/{name}.json`**, not hardcoded in
  test scripts — there's no real user/account system yet, so this is
  the durable stand-in. See `data/ratings/README.md` for the current
  roster. Add a new person's file there, then a new scenario in
  `scripts/scoring_tests.py`, rather than replacing existing data.
- **A/B testing an experimental scoring variant via monkeypatch must
  verify the patch lands on the SAME module object
  `scripts/scoring_tests.py` actually calls — don't just trust that the
  before/after numbers look different (or the same).** Real,
  already-happened example: an experimental variant was A/B tested by
  doing `import scripts.recommend as R; R.build_profile =
  R.build_profile_per_value` and rerunning the suite, which reported
  "byte-identical, zero regressions" — but `scripts/scoring_tests.py`
  internally does `sys.path.insert(...); import recommend as R`, a
  SEPARATE import of the same file under a different `sys.modules` key,
  hence a genuinely different module object with its own independent
  copy of every name. The monkeypatch silently never touched the module
  the benchmark actually calls (`scripts.recommend is not
  (path-inserted) recommend`), so the "safe" finding was measuring
  unmodified scoring against itself. Once actually landed (by editing
  the real file's own module-level names, which both import paths
  execute), the true benchmark showed a severe regression that had
  looked completely invisible under the flawed test.

  **Updated 2026-09-17 after Phase B (the `scripts/recommend.py` ->
  `scripts/scoring/` submodule split, see `docs/scoring-test-protocol.md`'s
  "Phase B" entries) — the exact verification command above no longer
  applies.** `scripts/scoring_tests.py` no longer has a single `R`
  object to compare; it imports several `scripts/scoring/` submodules
  directly (`pipeline`, `profile`, `series`, etc.). The underlying risk
  is identical, just spread across more names — **verify the specific
  submodule's identity, then the specific function's actual global
  lookup**, not just "some module resolved the same":
  ```python
  import scripts.scoring_tests as T
  from scoring import pipeline
  assert T.pipeline is pipeline
  assert T.pipeline.score_candidate.__globals__ is vars(pipeline)
  # after installing a variant on pipeline.score_book:
  assert T.pipeline.score_candidate.__globals__["score_book"] is variant
  ```
  The `__globals__` check matters because it's the actual binding a
  function looks up at call time — module identity alone doesn't prove
  a specific rebound name is what a specific function will actually
  use. (Proposed by CODX, Task 12, after correctly flagging that the
  original command was now stale — see
  `docs/codx-reviews/codx-phase-b-shim-removal-2026-09-17.md`.) Or
  avoid the whole class of bug by editing `scoring_tests.py`'s own
  `_full_score()` directly to call the experimental variant, the way
  the series-trajectory-penalty experiment (tested successfully) did
  it — still the simplest, most reliable option regardless of module
  structure.

## Source: docs/conventions/catalog.md

# Catalog scope & series hierarchy




- v1 scope is **sci-fi/fantasy only**. Hardcover's genre search
  sometimes pulls in off-genre books; these get left untagged and
  flagged for the repo owner. **As of 2026-09-21, the default
  resolution is archiving, not deletion**: `books.archived` (boolean,
  default `false`) plus `archived_reason` (text) and `archived_at`
  (timestamptz) — set `archived = true` with a real reason
  (`non_sff_genre_leakage`, `graphic_novel`, `unpublished`,
  `omnibus_duplicate`, or a new reason string if a genuinely new
  category comes up) rather than deleting the row outright. The
  bibliographic data is real and may be useful later (a scope
  expansion, a different catalog use), so keep it rather than lose it
  — but make sure it's actually excluded from anything user-facing
  (see `app/rate.html`'s book-search queries for the pattern: filter
  `archived = false` on any direct `books` query a reader can trigger).
  `tools/catalog-review` and the scoring engine's `load_catalog()`
  don't need a separate filter — both already inner-join `book_dna`,
  and an archived book is by definition untagged, so it's already
  invisible there. **Every `UPDATE ... SET archived = true` must be
  scoped by `(title, author)`, not title alone** — a real duplicate-
  title collision (two different "Quicksilver" rows, one already
  tagged) was caught by this exact migration's own rolled-back-
  transaction test; a title-only `WHERE` would have silently archived
  an unrelated, already-tagged book too. Outright deletion is still the
  right call for genuinely bad data (a duplicate row, a confirmed
  mis-ingest) rather than a real book that's just out of this
  catalog's current genre scope — don't delete a book that would fit
  this archive mechanism instead.
- **Graphic novels/comics are out of v1 scope** (decided 2026-09-04,
  see `20260904090000_remove_out_of_scope_graphic_novels.sql`) — the
  schema has no format/medium field distinguishing a visual comic from
  prose, and several fields (page/word-count-driven pacing signals in
  particular) mean something different for a comic than a novel. This
  was raised as an open question earlier (prompted by *Saga, Vol. 1*
  already sitting tagged in the catalog) and left genuinely unresolved
  for a while — during that window, two more graphic novels (*Saga,
  Vol. 2*, *The Sandman, Vol. 1*) got tagged anyway by treating the
  already-tagged *Saga, Vol. 1* as an implicit precedent rather than
  re-checking the still-open question. All three now have their Book
  DNA removed (`books` rows left in place, untagged, not deleted — same
  treatment as any other confirmed-out-of-scope-but-real-SFF-work
  case). **If you encounter a graphic novel/comic in the untagged
  queue, skip and flag it — don't tag it, and don't treat any
  already-tagged comic as a precedent that settles the question.**
- `books.series_id` always points at a **leaf** series, never a parent
  "umbrella" one (e.g. Mistborn's books link to "Mistborn Era One" /
  "Era Two", never the parent "Mistborn" row, which has zero books
  directly). Anything that aggregates by series (Series DNA, etc.)
  should just group by `series_id` directly — no special-casing needed
  to exclude parent series or shared universes, the data model already
  does it for free.
- **Short-story collections are in scope, connected-continuity or not**
  (clarified 2026-09-08) — a pure anthology of unrelated stories is a
  real book like any other as long as it's genuinely sci-fi/fantasy;
  it doesn't need to push a shared continuity forward the way *Sharp
  Ends*/*Arcanum Unbounded*/*The Last Wish* do to belong here. Both
  kinds get tagged as normal novels, same `work_type`.
- **A story appearing both as its own standalone entry AND inside a
  separate anthology is expected, not a duplicate to merge or
  remove** (clarified 2026-09-08) — e.g. *Edgedancer* is its own
  catalog row (Stormlight Archive #2.5) and is also one of the stories
  collected in *Arcanum Unbounded*, a separate catalog row. Keep both;
  this is a different situation from the omnibus/compilation-duplicate
  case (`docs/schema/book-dna-tables.md`'s current operational rule
  for this — skip tagging a duplicate compilation; the deferred
  `edition_kind` data-model proposal is in `book-dna-decisions.md` —
  one edition of the same book represented twice), not the same
  problem wearing a different face.

