# Convention reading bundle

The following shared notice applies to every source below.

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*

## Source: docs/conventions/tagging.md

# Data quality / tagging




- **A `book_dna` schema change (new/removed/changed column) is not done
  until `docs/schema/book-dna.schema.yaml`, the relevant `docs/schema/
  book-dna*.md` file(s) (as of 2026-09-25, a 4-file split — `book-dna.md`
  for a core-vocabulary change, `book-dna-vocabulary-gaps.md` for a
  tracker promotion/status change, `book-dna-tables.md` for a related
  table's contract, `book-dna-decisions.md` for a new deferred proposal
  or rejection — update whichever one(s) actually own the thing that
  changed, not all four reflexively), AND `.claude/skills/tag-catalog-batch/
  SKILL.md` (its mandatory-column list, example INSERT, and any
  field-specific tagging guidance) are all updated in the same session
  as the migration** — not left for someone
  else to notice later. Real, already-happened example (2026-09-12):
  `romance_tone`/`worldbuilding_delivery` landed as real columns
  2026-09-11, but the schema docs were never touched (schema.yaml had no
  entry for either field at all) and the tagging skill still described
  them as tropes to insert into `book_tropes` — tropes whose vocabulary
  entries had been deleted the same day, so following the skill literally
  would have failed outright on the very first insert. **Before running
  `tag-catalog-batch`, independent of whether you trust the rule above
  was followed**: check the skill's mandatory `book_dna` column list
  against the table's actual live columns (`select column_name from
  information_schema.columns where table_name = 'book_dna'`) — if they
  don't match, fix the skill first, don't tag a batch against a stale
  list (a batch tagged with a missing mandatory column is the same
  silent-partial-insert failure mode the skill already warns about for
  every other field).
- Every Book DNA field is a **closed, controlled vocabulary** — never
  invent a value not listed in `docs/schema/book-dna.schema.yaml`. If a
  real gap exists, that's a schema change to propose, not a value to
  quietly make up.
- New trope/field vocabulary has to clear a real bar: **"does this
  change what gets recommended," not "is this a real term."** A trope
  that's accurate but doesn't discriminate between books a reader would
  and wouldn't want isn't worth adding.
- **Don't force-tag books that don't actually fit the catalog's scope**
  (sci-fi/fantasy for v1) just to make a completion number look better.
  If a book got pulled in by a broad genre search but genuinely has no
  SFF content, flag it for the repo owner and leave it untagged (or get
  it deleted — see "catalog scope" in `docs/conventions/catalog.md`).
- When genuinely uncertain between two plausible values for a field or
  trope, don't just guess and move on — use the confidence layer
  (`book_field_confidence`, or `book_tropes.confidence`/`.source`) to
  record that uncertainty. It's real, used input to scoring, not
  decorative.
- **The real tagging failure mode isn't "I don't know this book" — it's
  being confidently WRONG on a specific mechanical detail.** Every real
  tagging error caught by external readers so far (two separate rounds)
  came from confidently recalling a book well overall but getting one
  specific, checkable fact wrong — usually by over-pattern-matching to
  genre convention instead of the actual book (Dungeon Crawler Carl
  tagged third-person because LitRPG "usually is," when it's actually
  first-person; Empire of Silence tagged `first_contact` because
  space-opera-with-aliens "usually is" a first-contact story, when the
  war in it long predates the narrative). "If uncertain, check" doesn't
  catch this, because the tagger doesn't feel uncertain. **Fields with a
  confirmed track record of this failure — `person`, `pov_count`,
  `narrator_reliability`, `magic_system_hardness`, `overall_pace`,
  `romance_heat_intensity`, `drive`, `stakes_scope`, `narrative_closure`,
  `humor_level` (see `HIGH_RISK_FIELDS` in `scripts/scoring/constants.py`
  — moved there in the Phase B `scripts/scoring/` submodule split,
  2026-09-17; `scripts/recommend.py` is now just a 105-line CLI demo
  and no longer defines it — and this list is expected to keep growing)
  — deserve a quick check
  (re-reading a synopsis, a web search) even when you feel sure,** and
  any trope asserting a specific plot beat happened (not just a general
  theme/setting) warrants the same treatment. This is a standing policy,
  not a one-off note — add a field to that list the next time a real
  error surfaces on it, rather than assuming this list is now complete.
- **A book's `author` field must contain only genuine author(s) — not
  illustrators, translators, narrators, or editors.** This is not a
  one-time-fixed problem: it has already recurred more than once (65 of
  606 books found contaminated in one audit; then again on 2 freshly
  ingested books in the very next batch — "Season of Storms"/"The Lady
  of the Lake" came in as `"Andrzej Sapkowski, David   French"`, David
  French being the series' English translator). "Check if it looks
  contaminated" is not enough, because it keeps slipping through anyway
  — **every newly ingested book must have its author field explicitly
  verified against Hardcover's own `author_names`/`cached_contributors`
  data BEFORE it's inserted, not fixed reactively after it surfaces in
  a review.** If an author field has more than one name, check whether
  the later names are genuine co-authors (real, and common — don't
  assume contamination) or contributors, every single time, not just
  when a name "looks like" a contributor. This is a mandatory ingestion
  step, the same way the trope/CW density self-check below is mandatory
  for tagging — not an audit someone else runs afterward.
- **Never store Hardcover's own cover-image URL directly in
  `books.cover_url` — self-host it instead**, via
  `scripts/lib/self-host-cover.js`'s `selfHostCoverImage(sourceUrl,
  bookId)` (downloads the image, uploads it to this project's own
  `book-covers` Supabase Storage bucket, returns our own public URL).
  Decided 2026-09-18 after Hardcover's asset CDN broke for 7 already-
  ingested books with zero warning (an old `/books/<id>/...` path
  pattern started 403ing) — hotlinking makes this app's own image
  display depend on a third party's URL staying stable forever, which
  already proved false once. All 1254 already-ingested books were
  backfilled the same day (see `docs/project-log.md`'s 2026-09-18
  entries for the full pipeline, including two real mistakes caught
  and fixed during it: a migration that hardcoded LOCAL Postgres's own
  book UUIDs, which don't match hosted's for the same book, and picking
  the first working replacement URL rather than the highest-resolution
  one). One image per book for now — multiple cover-art variants (e.g.
  US vs UK editions) are a deliberately-deferred future idea, see
  `docs/schema/book-dna-decisions.md`'s deferred proposals. The 3 existing
  `scripts/ingest-*.js` files were deliberately NOT updated to call
  this helper — they're one-off scripts from already-completed
  ingestion rounds and won't run again as-is (this project's own
  pattern is a fresh script per ingestion round, not reusing an old
  one) — but any NEW ingestion script must call it instead of using
  `doc.image?.url` directly.
- **A tagging batch must self-check its own trope/content-warning
  density BEFORE the session ends — this is not an after-the-fact audit
  for someone else to catch later.** This has already gone wrong twice:
  a batch shipped meaningfully thinner than the catalog average (density
  visibly declining across sub-batches within the SAME session — a real
  sign of rushing/fatigue as a big batch drags on, not a one-off), and
  wasn't caught until a separate session audited it afterward and had to
  run a whole second enrichment pass to fix it. Catching this during the
  original tagging session is far cheaper than a second pass later, and
  is now an explicit, required step in `.claude/skills/tag-catalog-batch/
  SKILL.md` (Step 3) — every tagging session must query the CURRENT
  catalog-wide average (don't trust a hardcoded number here, it drifts
  as the catalog grows — as of 2026-09-02, roughly 5.9 tropes/book and
  1.75 content warnings/book, but query it fresh) against their own
  just-tagged batch's average, and go back and enrich the thin books
  before reporting the batch done if it's meaningfully below that.
- **Prioritize completing partially-tagged series before tagging new
  standalones.** Series DNA (the trajectory-aggregation feature) needs
  >= 2 tagged books per series to compute anything at all — finishing a
  partial series unlocks that; a new untagged standalone doesn't unlock
  anything yet.

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

