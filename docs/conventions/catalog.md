# Catalog scope & series hierarchy

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*


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
