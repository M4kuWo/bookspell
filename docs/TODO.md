# Project TODO

A prioritized, cross-cutting task backlog -- distinct from the two docs
that already exist and cover different ground:

- `docs/project-log.md` is append-only HISTORY (what already happened,
  dated, never rewritten).
- `docs/schema/book-dna.md`'s "Future fields backlog" is specifically
  SCHEMA/FIELD ideas (new DNA values, deferred vocabulary).
- **This file** is forward-looking and mutable: things we've decided
  are worth doing, ordered by priority, checked off or re-ordered as
  the project moves. Update it directly (not append-only) as work
  starts/finishes/gets reprioritized. Where an item is really a schema
  idea, it stays tracked in book-dna.md and this file just points to it
  rather than duplicating the writeup.

Priority is P0 (do next) / P1 (soon, real value) / P2 (ongoing/routine)
/ P3 (blocked or parked -- not actionable right now, don't pick these
up without checking whether the blocker cleared).

**Token-economy note (2026-09-07)**: a heavy session today -- pace
future work accordingly. Cheap/quick items are ordered first within
each tier on purpose; the genuinely taxing ones (marked below) are
worth deferring to a later session rather than batching in for
"efficiency," which just concentrates cost instead of reducing it.

## P0

- [x] **Gate `book_length`/`audiobook_length` by listener format
  preference.** LANDED 2026-09-07 -- see scoring-test-protocol.md.
  Mathias's own `_meta.format_preference` set to `"audiobook"` per his
  direct statement.
- [x] **Push today's commits** -- confirmed 2026-09-07: `main` is up to
  date with `origin/main`, working tree clean, README refresh
  (e18576a) is the latest commit on both.

## P1

- [ ] **Audiobook edition data, see `.claude/skills/tag-audiobook-
  editions/SKILL.md`** (written 2026-09-07). Runs on a SEPARATE
  session's token budget, not this one -- fine to kick off any time
  regardless of this session's own economizing. Expect this to take
  many sessions end-to-end; that's by design, not a problem to fix.
  **Progress as of 2026-09-08: Step A1a done for GraphicAudio** (series-
  level catalog pulled and logged in full in project-log.md's
  2026-09-08 "audiobook-editions skill, Step A1a" entry -- 108 Fantasy-
  genre series + 59 Science Fiction-genre series, real overlap between
  the two). **Real limitation hit and flagged**: GraphicAudio's site
  loads author names and its "Stand-Alone Titles" subcategory
  dynamically via JS -- a static-HTML fetch could only get series
  names, not authors or standalone (non-series) titles. Whoever
  continues this should check whether a JS-capable fetch (browser
  automation, or a GraphicAudio search/API) is available before
  starting Step A1b, since author names would make matching more
  reliable than title-only. Remaining steps, in order:
  1. Step A1a for BBC Audio (its own session -- not yet started).
  2. Step A1b: cross-reference GraphicAudio's series list against ours
     (own session), report the real match count -- promising signs
     already visible just from series names (Mistborn, Stormlight
     Archive, Dresden Files, Throne of Glass, Red Rising Saga, The
     Murderbot Diaries, and more, per the project-log.md entry), but
     not yet formally verified against `books`/`series`. Then the same
     for BBC Audio's list once pulled.
  3. Step A2: research + insert confirmed matches, capped at 10-15 per
     session.
  4. Sub-task B (Audible Originals, audio-only new entries,
     `work_type = 'audio_original'`): candidate discovery as its own
     session, then ingestion+tagging in normal 15-20/session batches.
  - Open sub-question, not yet checked: whether Hardcover's API exposes
    standard-edition narrator data as a contributor role (same source
    already used for author verification) -- possibly near-bulk-
    fetchable, cheaper than the dramatized-edition path.
- [ ] **(Taxing -- defer) Promote `romance_tone`/`worldbuilding_
  delivery` from trope pairs to real scalar fields.** Both pairs show
  ZERO overlap in the actual data (confirmed 2026-09-07) -- genuinely
  one-axis spectrums, not independent tags. Deliberately built as
  tropes first as a cheap validation probe before committing to schema
  -- see book-dna.md's "Romance TONE/execution-quality" entry and
  scoring-test-protocol.md's 2026-09-05 "Execution-DNA validation
  probes" entry; the probe already validated (correctly-signed
  weights, confirmed in production). Converting needs a migration +
  backfill + `recommend.py` field-handling changes + removing the old
  trope pair -- real, multi-step engineering work, not urgent. Good
  candidate for a session with a fresh token budget.

## P2 (ongoing/routine, not new decisions)

- [ ] **Continue the romance_tone/worldbuilding_delivery tagging
  sweep** -- as of 2026-09-07 end-of-session: romance_tone batch 19,
  worldbuilding-delivery batch 16 done (~136 romance_tone candidates
  and ~399 worldbuilding candidates remain). Remember the mandatory
  density self-check (CLAUDE.md) before ending any batch session.
  **For romance_tone specifically, default to a broad search + targeted
  follow-up per candidate (not a single search)** -- see
  project-log.md's 2026-09-07 session-wrap-up entry: the easy,
  heavily-reviewed candidate pool is depleting, single searches are
  increasingly landing nothing usable or (once, caught) misattributing
  a quote to the wrong romance pairing in a book with more than one.
  worldbuilding-delivery isn't showing this depletion yet -- single
  searches there are still landing 5-6 clean tags routinely, no process
  change needed for that pool for now.
- [ ] **Catalog tagging completion** -- 873 books total, 45 untagged as
  of 2026-09-07. Checked the "finish partially-tagged series" angle
  first per standing policy: turned out all 6 partially-tagged series
  (Farseer Trilogy, Foundation, Villains, Monk and Robot, A Song of Ice
  and Fire, Kingkiller Chronicle) are actually fully tagged at the
  individual-book level already -- the "missing" row in each is either
  an omnibus/compilation duplicate of an already-tagged book (4 of them
  -- see book-dna.md's new "omnibus/compilation editions" future-fields
  entry, a real schema gap, not yet built) or a currently-unpublished
  book (Winds of Winter, Doors of Stone -- nothing to tag yet). **Skip
  all 6, and any future entry matching the same pattern** (a book row
  duplicating an already-tagged book at the same series position, or a
  book with no real publication yet) -- don't force-tag these, and
  don't count them as real gaps when checking series completion. The
  other ~39 untagged books are standalones or in series with zero
  tagged books yet -- still open, not yet re-surveyed this session.
- [ ] **`series.status`/`book_count` is systemically wrong catalog-wide
  -- ~200 of 343 series rows affected, root cause found 2026-09-08.**
  `status` defaults to `'ongoing'` whenever Hardcover's `is_completed`
  flag isn't explicitly `true` (including simply missing data);
  `book_count` is Hardcover's raw per-series edition/omnibus/box-set
  count, not a curated mainline-installment number. Doesn't affect
  scoring at all (neither field is read by `scripts/recommend.py`) --
  purely a `tools/catalog-review/` display bug, so no urgency pressure,
  but real and visible to anyone browsing the tool. 5 specifically-
  flagged series already fixed (see project-log.md's 2026-09-08 entry)
  -- the other ~195+ would need real per-series verification (publication
  status, a curated book count), which doesn't scale to a single
  session. Options for whoever picks this up: (a) manually verify+fix
  the most-viewed/highest-profile series first rather than the whole
  table at once, (b) find a better Hardcover field/endpoint for a
  curated count if one exists, (c) at minimum, stop displaying
  `book_count`/`status` in the catalog tool until re-sourced, so wrong
  data isn't worse than no data. No option chosen yet.
- [x] **Cosmere universe linking -- FIXED 2026-09-08.** Only 3 of
  Sanderson's real Cosmere books were actually linked to the existing
  "The Cosmere" universe row (a duplicate "Cosmere" *series* row also
  existed, holding 2 misplaced books). Fixed: 22 more books linked
  (Mistborn both eras, full Stormlight Archive, Elantris novellas,
  Secret Projects' 2 real Cosmere entries -- The Frugal Wizard's
  Handbook deliberately excluded, it's not actually Cosmere despite
  the series grouping), duplicate series row deleted. See
  project-log.md. This was low-risk enough to fix immediately (unlike
  First Law/Mark Lawrence below) because the universe already existed
  with an official name -- no naming-policy decision needed.
- [ ] **Catalog-wide shared-universe linking audit -- not urgent, but
  needs to be done properly rather than one series at a time.** Only 2
  `universe` rows exist (Cosmere, Middle-earth), but the First Law case
  below is confirmed NOT to be the only gap (Cosmere itself had the
  same gap, just fixed above, see checked item) -- the repo owner also
  flagged (2026-09-08) that Mark Lawrence's books share one continuity
  across FOUR of his series in this catalog: `The Broken Empire`
  (Prince/King/Emperor of Thorns), `The Red Queen's War` (Prince of
  Fools and sequels), `Book of the Ancestor` (Red Sister and sequels),
  and `The Library Trilogy` (only book 1, *The Book That Wouldn't
  Burn*, is in our catalog so far). Confirmed via direct query: none of
  these 10 books have `universe_id` set. Unlike Cosmere/Middle-earth,
  **there's no single official name for this shared world** (Lawrence
  hasn't branded it the way Sanderson branded Cosmere) -- that's a real
  wrinkle this audit needs a policy for, not just a data-entry task:
  either find/confirm an informal name the author or fandom actually
  uses, or accept a repo-chosen descriptive name (e.g. "The Broken
  Empire World") and document that it's an internal label, not an
  official one. Also surfaced in passing: at least one connected book
  (*The Girl and the Stars*, Library Trilogy book 2) isn't in our
  catalog yet at all -- same "real-world connection outruns our
  ingestion" pattern as Sharp Ends below.

  **This needs a real audit, not a one-off fix**: group the catalog by
  author (or by known cross-author shared settings, if any exist) and
  check each author with 2+ series for whether they're actually
  connected continuities vs. genuinely separate settings -- don't
  assume connection just because it's the same author. Two known
  starting cases below; there are very likely more not yet found.
  Nothing here affects scoring (Series DNA/aggregation already works
  off each book's own `series_id` directly, confirmed for First Law) --
  this is a real-world-accuracy/display gap, hence not urgent, but a
  genuine one worth doing right rather than patching individual
  examples as they get noticed.

  - **First Law**: a `universe` ("The First Law World") should contain
    `The First Law` (real series) plus `The Age of Madness` (real
    series) plus the 3-in-catalog-of-4-real standalones (Best Served
    Cold, The Heroes, Red Country, and Sharp Ends -- a short story
    collection not yet in our catalog) linking to the universe directly
    with no series. Matches book-dna.md's own "universe/series/book"
    design doc exactly -- just never implemented. Doesn't cross-
    contaminate The First Law/Age of Madness's own correct series_ids.
    **Sharp Ends should be ingested normally** (resolved 2026-09-08,
    was flagged as a possible scope question) -- confirmed Arcanum
    Unbounded and The Last Wish/Sword of Destiny (the same kind of
    continuity-forward short-story collection) are already in our
    catalog, already fully tagged as regular novels. This project has
    already been treating this category as in-scope; add it via
    normal ingestion, same as any other book.
  - **Mark Lawrence**: see above -- 4 series (10 in-catalog books),
    no official shared-world name, one known missing book (*The Girl
    and the Stars*).

  Real fix for both: create the `universe` row(s), set `universe_id` on
  every book in the continuity (standalones get `universe_id` with no
  `series_id`, per the design doc), matching the Cosmere/Middle-earth
  pattern already in use. Not done here -- flagged, not attempted.

## P3 (blocked or parked -- check the blocker before picking up)

- [ ] **Graduated dealbreaker veto** (`_apply_dealbreaker_veto_
  graduated()` in recommend.py) -- built and structurally verified
  2026-09-07, but can't be proven against real data because
  `validated_dealbreaker_fields()` is currently EMPTY for all 4 real
  raters. Blocked on more real per-rater rating data, not on more
  engineering. Revisit once a field/user pair actually validates.
- [ ] **Series-aware field-conditional dedup** -- parked 2026-09-06.
  One real lead not yet built: protect the minority subgroup within a
  series split (not just validated-dealbreaker fields, which was tried
  and found to be a no-op since nothing currently validates). See
  scoring-test-protocol.md's dedup entries for the full trajectory.
- [ ] Schema-field ideas (protagonist gender, protagonist competence
  trajectory, narrative sympathy between co-leads, `message_themes`/
  `anti_militarist_message` probe) -- tracked in full in
  `docs/schema/book-dna.md`'s "Future fields backlog", not duplicated
  here. All explicitly waiting on more real rating evidence before
  committing to vocabulary.
