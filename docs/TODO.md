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
- [x] **Database backup policy -- DECIDED and set up 2026-09-11.**
  Checked first: no real backup existed (Supabase's automatic backups
  are a paid-tier feature this project doesn't use; the one prior
  manual backup from 2026-09-05 was never committed and is now gone).
  Ruled out S3 (12-month free-tier limit, not the future-proof fit the
  repo owner wanted) and a `db_backups/` folder in this repo (repo
  bloat from accumulating dump history over time). **Landed on a
  separate, permanently-free repo**:
  [`bookspell-backups`](https://github.com/M4kuWo/bookspell-backups) --
  see CLAUDE.md's new "Database backups" section for the process. The
  2026-09-11 snapshot moved there from this repo's now-removed
  `db_backups/`. No fixed cadence yet -- manual, run when meaningful
  new data has landed or before anything risky.

## P1

- [ ] **Consider bringing in Codex CLI (repo owner's existing ChatGPT
  subscription) as a third working entity, alongside CLDO/CLDA --
  raised 2026-09-11, needs real thought before building anything.**
  Codex CLI is a real, viable tool for this -- it natively reads an
  `AGENTS.md` file the same way this project relies on `CLAUDE.md`, so
  the convention-following pattern would transfer reasonably well.
  **Not a quick add -- two real open questions before any setup work
  starts**:
  1. **Concrete division of labor, not just "give it what it's good
     at."** Needs actual task-type examples, not an abstract split.
     One plausible shape floated in discussion: mechanical/scriptable
     work (e.g. something like CLDA's Hardcover-API narrator-backfill
     script) as a good fit, versus the nuanced literary-judgment
     tagging work (which leans on a lot of hard-won, very specific
     discipline -- the `HIGH_RISK_FIELDS` caution, the evidence
     standards in CLAUDE.md) staying with the persona that already has
     that context baked in. Not decided, just one candidate framing.
  2. **A third entity re-opens the exact coordination problem CLAUDE.md
     itself exists to solve, for a new kind of session.** The persona
     system and the `PENDING_APPROVALS.md` gate would both need to
     extend to it (a third name, a third set of "does it actually
     respect this project's conventions" questions) -- not just point
     it at CLAUDE.md and assume it onboards as cleanly as a fresh
     Claude session does.
  Work through both before building any integration -- this is a
  bigger decision than it looks, don't rush it in alongside other work.
- [x] **Bulk-populate `audiobook_editions` standard-edition narrator
  data via Hardcover's API -- DONE 2026-09-11. Final: 1026 `standard`
  rows across 786 of 869 books with a `hardcover_id`.** Confirmed
  Hardcover's API exposes narrator data as a `contribution: "Narrator"`
  role, genuinely bulk-fetchable. **Repo owner flagged a real risk
  before this was built**: some books (Wheel of Time named as the
  example) have MULTIPLE genuinely different narrations (Kramer/
  Reading's classic narration vs. Rosamund Pike's 2021 re-recording)
  that must not get conflated into one row -- confirmed real on the
  first test book (The Eye of the World returned 15 raw Hardcover
  edition records: the classic narration in ~7 near-duplicate
  reprints, a genuinely separate Pike solo re-recording, and a
  Spanish-language edition). `scripts/backfill-standard-narrators.js`
  groups each book's audio editions by narrator-SET IDENTITY (not
  publisher/date, which vary across reprints of the same real
  performance) rather than a naive one-row-per-book insert.
  **Six batches total** (migrations `20260911120000` through
  `20260911180000`), each tested in a rolled-back transaction with an
  idempotency re-run, applied via `supabase db push`, zero
  migration-tracking mismatches throughout:
  - Batch 1 (605 rows/578 books): filtered likely-dramatized editions
    (large casts, GraphicAudio-style publishers).
  - Batches 2-6 (421 more rows/208 more books): repo owner asked to
    review the flagged/skipped books rather than leave them. Verified
    ~20 cases via live web search across several rounds -- every
    single one was a genuine distinct edition (UK vs US market,
    abridged vs unabridged, an older historical release), never noise
    from low Hardcover popularity alone. **Five real content-leakage
    categories found and fixed, each verified via search before
    excluding**: (1) a TYPO variant of the same narrator's name
    (Mistborn's "Michael Krammer" vs "Michael Kramer" -- fixed with
    Levenshtein-distance group merging), (2) Penguin's 2022+ full-cast
    Discworld re-recording (Bill Nighy/Peter Serafinowicz recurring
    across ~20 Pratchett titles, credited under the generic "Penguin
    Audio" imprint), (3) Hardcover placeholder values ("full cast",
    "Ensemble Cast") mistaken for real narrator names, (4) Phil
    Dragash's unofficial free fan recording of Lord of the Rings, (5)
    BBC/Tyndale radio dramatisations under generic publisher names
    (BBC's 2+-narrator classic-lit credits are almost always full-cast
    dramas; "David Suchet, Paul Scofield" is Tyndale's Narnia "Radio
    Theatre" production). Also fixed a real infrastructure bug:
    Hardcover's rate limit (60 req/min, burst 10) got exceeded by
    running an interactive test batch concurrently with this session's
    own background analysis, crashing 76/291 books with a malformed
    response instead of a clean 429 -- added retry-with-backoff.
    **Recalibrated the flagging threshold** from >2 to >4 groups once
    the evidence was clear that 2-4 distinct named groups are the
    normal case for a well-adapted book, not an anomaly, plus a rule
    dropping only genuinely unverifiable single entries (zero users,
    no publisher, one edition record).
  - Final 3 genuinely extreme cases (Frankenstein: 12 real historical
    narrator groups, The Strange Case of Dr Jekyll and Mr Hyde: 8,
    Fahrenheit 451: 6) hand-picked rather than bulk-inserted or left
    empty -- top 3 most-corroborated narrators per book inserted,
    migration `20260911180000_backfill_standard_narrators_final3_
    classics.sql`.
  Full detail across three 2026-09-11 project-log.md entries ("built
  and ran the standard-edition narrator backfill", "fixed the
  narrator-backfill flagging heuristic and ran batch 2", "cleared the
  64-book flagged backlog").
  **Remaining 83 books (65 no narrator data in Hardcover at all, 18 no
  audio edition listed) have nothing to add** -- not actionable
  without a different data source, not a gap in this work.
- [ ] **DEMOTED to P3, 2026-09-11 (see P3 below for the current entry
  and the repo owner's reasoning) -- dramatized-audio edition data
  (GraphicAudio/BBC Audio/Sub-task B Audible Originals), see
  `.claude/skills/tag-audiobook-editions/SKILL.md`.** Full history kept
  under P3, not deleted -- this pointer exists so a P1 skim doesn't
  miss that the item moved.
- [ ] **Promote `romance_tone`/`worldbuilding_delivery` from trope
  pairs to real scalar fields -- split in two, schema half ready to
  hand off.** The probe already validated (correctly-signed weights,
  confirmed in production) -- see book-dna.md's "Romance TONE/
  execution-quality" entry and scoring-test-protocol.md's 2026-09-05
  "Execution-DNA validation probes" entry.
  **Schema + backfill migration**: fully specified and verified end-
  to-end (not just designed) in
  `.claude/skills/convert-romance-worldbuilding-fields/SKILL.md`,
  ready for the other Claude session -- delegate this the same way as
  `tag-audiobook-editions`. **Real finding while writing it (2026-09-09):
  the "zero overlap" fact this item used to cite is no longer true** --
  5 books now carry both tropes in a pair (real evidence found both
  ways as the sweep's easy candidates depleted). Changed the schema
  decision: both new fields need a real 3rd `mixed` value for genuine
  confidence ties, not just 2 clean values. Full resolution rule and a
  fresh-recheck requirement (don't trust this snapshot, the sweep is
  still running) are in the skill doc.
  **`recommend.py`/`scoring_tests.py` changes stay in the main
  conversation, NOT delegated** -- explicit decision 2026-09-09,
  matching this project's consistent pattern (every scoring-engine
  change so far has happened in the primary session, not on the
  tagging machine). Do this once the schema migration is confirmed
  done and reported back.
  **Step 1 done 2026-09-09** -- `romance_tone`/`worldbuilding_delivery`
  columns added to `book_dna` (nullable, 3-value check constraints incl.
  `mixed`), applied and verified on hosted. Local not synced -- this
  sandbox's local Supabase stack has never bootstrapped at all (a real,
  separate, structural gap: ~840 non-pilot catalog books were never
  captured in any tracked migration or seed file, so a from-scratch
  local bootstrap fails regardless of this migration -- see
  project-log.md's two 2026-09-09 entries on this). Accepted as a known
  gap for this migration; not blocking.
  **Steps 2-3 done 2026-09-11** -- fresh overlap re-check found the same
  5 dual-tagged books as the 2026-09-09 snapshot (no new ones appeared),
  backfill applied and verified on hosted: `romance_tone` 160/864
  non-null (80 understated, 79 melodramatic, 1 mixed), `worldbuilding_
  delivery` 117/864 non-null (66 woven, 50 exposition_dump, 1 mixed).
  `book_field_confidence` backfilled for every touched book.
  **Step 4 done 2026-09-11, schema+backfill half now FULLY COMPLETE**
  -- old `book_tropes` rows (282 across the 4 trope IDs) and the 4
  `tropes` vocabulary entries deleted from hosted, only after a live,
  direct go-ahead from the repo owner (not just the project's
  file-based PENDING_APPROVALS.md gate). Every deleted row was backed
  up first to a permanent, git-tracked manifest
  (`20260911110000_delete_old_romance_worldbuilding_tropes_manifest.tsv`)
  so it's fully reinstatable if ever needed. Verified on hosted: 0
  rows remain for the 4 trope IDs in both tables;
  `romance_tone`/`worldbuilding_delivery` counts unchanged. A real
  process slip happened and was caught/fixed in the same session: the
  delete was applied directly via psycopg2 instead of `supabase db
  push`, desyncing hosted's migration-tracking table (exactly the
  anti-pattern CLAUDE.md documents as a recurring issue) -- caught via
  `supabase migration list`, data confirmed correct first, then fixed
  with `supabase migration repair --status applied`. See
  project-log.md's 2026-09-11 "Step 4" entry for full detail.
  **Next**: the `recommend.py`/`scoring_tests.py` scoring-engine
  changes that make these fields actually participate in
  recommendations -- separate, main-conversation work, not started.

## P2 (ongoing/routine, not new decisions)

- [ ] **MOVED to P3, 2026-09-11** -- folded into the demoted
  dramatized-audio-edition item there (Throne of Glass 2-9, Dresden
  Files 6-14, Murderbot's 2 prequels -- same "wait for the producer"
  shape, no reason to track separately anymore).
- [ ] **SUPERSEDED 2026-09-11 -- the mechanism this item describes no
  longer exists, read before touching.** This item used to track
  continuing to tag books with the `understated_romance`/
  `melodramatic_romance_subplot`/`worldbuilding_woven_into_narrative`/
  `worldbuilding_via_exposition_dump` trope pairs (a ~136/~395-candidate
  backlog as of 2026-09-09, see history below). **Those 4 trope IDs and
  all their `book_tropes` rows were permanently deleted 2026-09-11**
  (Step 4 of `convert-romance-worldbuilding-fields`, see
  project-log.md's 2026-09-11 "Step 4" entry and the main TODO's P1
  entry above) -- the probe validated, the data was converted into real
  `book_dna.romance_tone`/`worldbuilding_delivery` scalar columns, and
  the old trope-tagging path is gone by design (re-tagging either trope
  would fail: the vocabulary entries don't exist anymore).
  **Any future sweep continuing this work must write directly to the
  scalar columns** (values: `understated`/`melodramatic`/`mixed` for
  romance_tone, `woven`/`exposition_dump`/`mixed` for
  worldbuilding_delivery -- see the skill doc's schema decision and
  resolution rule for ties) via a new, small migration per batch, not
  `book_tropes` inserts. The old ~136/~395 candidate-pool estimates
  below are stale too -- they were sized against trope-tagging
  candidates and haven't been re-evaluated against the scalar-field
  target. Whoever picks this up should re-scope it as a fresh item
  before resuming, not just swap the target column in the old process.
  **Original history, kept for candidate-research context only (search
  findings/quotes already gathered may still be reusable)**: as of
  2026-09-07 end-of-session, romance_tone batch 19, worldbuilding-
  delivery batch 16 done (~136 romance_tone candidates and ~399
  worldbuilding candidates remained under the old trope process).
  Worldbuilding-delivery batch 19 (2026-09-09) tagged 5 more (3 woven, 2
  exposition_dump) before hitting that session's web search cap: 395
  remained. Batch 20 (2026-09-09) made zero progress -- session's web
  search budget was already exhausted before a single candidate could
  be researched; a prepared 40-title candidate list (Clockwork Angel
  through Feet of Clay) was left ready for the next session, along with
  two author-contamination/exact-title-string notes (Doomsday Book's
  stored author includes cover illustrator Daniel Dos Santos; "Dawn "
  has a trailing space and Emily Wilde's Map of the Otherlands uses a
  curly apostrophe in its stored title) that remain valid regardless of
  which mechanism tags them. For romance_tone specifically, a broad
  search + targeted follow-up per candidate (not a single search) was
  the working approach -- see project-log.md's 2026-09-07 session-wrap-
  up entry: the easy, heavily-reviewed candidate pool was already
  depleting, single searches were increasingly landing nothing usable.
- [x] **Catalog tagging completion -- FULLY DONE as of 2026-09-09.** 871
  books total (2 down from 873 -- see next paragraph), **861 tagged,
  10 untagged and all 10 are confirmed permanent exceptions** -- no
  real gap remains. See project-log.md's 2026-09-09 "catalog tagging
  batch 2" entry (15 standalones: Turton, Erlick, Nayler, Ende, Poston,
  Hendrix, Jimenez, Cutter, Young, Mandanna, Chambers, Klune, Crouch,
  Hart, McAllister) and the later "tag final 3 untagged standalones"
  entry (A Wizard's Guide to Defensive Baking, Emily Wilde's Map of the
  Otherlands, The Handmaid's Tale -- the last 3 real gaps, closed the
  same day). **All 10 remaining untagged rows are documented
  permanent-skip cases, not a real backlog**: 4 omnibus/compilation
  duplicates (Farseer Trilogy, Foundation, Villains, Monk and Robot --
  see book-dna.md's "omnibus/compilation editions" future-fields
  entry, a real schema gap not yet built), 2 unpublished sequels
  (Winds of Winter, Doors of Stone -- nothing to tag yet), and 4
  graphic novels (Nimona, Saga Vol. 1-2, The Sandman Vol. 1 -- out of
  v1 scope per CLAUDE.md).
  **Shōgun and The Screwtape Letters deleted 2026-09-09** -- the repo
  owner confirmed both are genuinely out of scope (historical fiction;
  theological satire, neither sci-fi/fantasy) and asked for deletion.
  Checked all dependent tables first (zero rows in book_dna/
  book_tropes/book_content_warnings/book_field_confidence/
  audiobook_editions for either), also deleted Shōgun's now-empty
  "Asian Saga: Chronological Order" series row. `books` 873 -> 871,
  `series` 367 -> 366. See project-log.md's 2026-09-09 "Shogun and The
  Screwtape Letters deleted" entry, which also documents a real
  migration-tracking gap caught and repaired during this (two
  background agents' migrations were applied via raw psycopg2 instead
  of `supabase db push`, same anti-pattern CLAUDE.md already
  documents -- fixed via `supabase migration repair`, verified data
  matched first).
  **Don't pick this item back up as an ordinary tagging task** --
  there is no untagged, in-scope, standalone SFF book left to select.
  Future tagging work should instead watch for (a) newly-ingested
  books entering the untagged queue, and (b) the vocabulary-growth
  sweeps already tracked elsewhere in this file (romance_tone,
  worldbuilding delivery).
- [ ] **`series.status`/`book_count` is systemically wrong catalog-wide
  -- root cause found 2026-09-08, batch 1 done 2026-09-11 (19 of ~200
  series fixed so far).** `status` defaults to `'ongoing'` whenever
  Hardcover's `is_completed` flag isn't explicitly `true` (including
  simply missing data); `book_count` is Hardcover's raw per-series
  edition/omnibus/box-set count, not a curated mainline-installment
  number. Doesn't affect scoring at all (neither field is read by
  `scripts/recommend.py`) -- purely a `tools/catalog-review/` display
  bug, so no urgency pressure, but real and visible to anyone browsing
  the tool. **Approach**: manually verify+fix the most-viewed/
  highest-profile series first (real publication status via search,
  never a guess), in bounded batches, stop-and-report each time.
  **Batch 1 (2026-09-11)**: ranked candidates by our own catalog's
  book-count-per-series (the available proxy for "highest-profile,"
  since no direct popularity metric exists on `series` or via
  Hardcover) -- top 15 by that ranking, all 15 verified via live search
  before any value was written. 14 needed a real fix (6 completed
  series wrongly marked ongoing: The Demon Cycle, Powder Mage, The
  Lunar Chronicles, The Licanius Trilogy, The Red Queen's War, Arc of a
  Scythe, Ender's Saga; 7 wrong `book_count` on genuinely-ongoing
  series: Bobiverse, Red Rising Saga, The Murderbot Diaries, A Song of
  Ice and Fire, The Kingkiller Chronicle, Crescent City, Dungeon
  Crawler Carl). 1 (A Court of Thorns and Roses) was already correct.
  Migration `20260911190000_fix_series_status_book_count_batch1.sql`.
  Full detail, including one real search-reliability catch (an initial
  Ender's Saga search returned internally contradictory/unreliable
  results, re-verified with a cleaner query before trusting it), in
  project-log.md's 2026-09-11 "series.status/book_count fix, batch 1"
  entry. **Next**: re-rank remaining ~181 series by catalog book count
  (excluding all 19 now-fixed) for batch 2 -- don't reuse this
  session's candidate list, it's now stale.
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

- [ ] **DEMOTED from P1 to P3, 2026-09-11 -- dramatized-audio edition
  data (GraphicAudio/BBC Audio/Sub-task B Audible Originals), see
  `.claude/skills/tag-audiobook-editions/SKILL.md`.** Repo owner's
  reasoning: every currently-KNOWN candidate pool for this work is
  genuinely exhausted (not paused, not under-resourced -- actually
  exhausted, see the history below), so what's left is exclusively
  "wait for an external producer/creator to release something new,"
  which is a maintenance/freshness concern, not core product-building
  work. We're in a research-and-building phase right now, so tracking
  external release calendars isn't a priority -- revisit either as a
  P2 routine checkup once the product is stable, or better, build a
  real alerting mechanism (notify on a new release rather than
  re-researching on a schedule) -- both are the repo owner's own
  suggested paths, neither built yet, logged here for whoever picks
  this back up. **Folds in the former separate P2 "periodically
  re-check GraphicAudio's in-progress productions" item** (Throne of
  Glass books 2-9, Dresden Files 6-14, Murderbot's 2 short prequels --
  same "wait for the producer" shape, no reason to track it separately
  from this item anymore).
  **Iain Banks / BBC Audio Culture-novel question, the last open BBC
  Audio thread, RESOLVED 2026-09-11 -- negative, not a match.**
  Checked directly: "Iain Banks: A BBC Radio Collection" (Audible/
  Penguin, 2026) contains exactly 3 dramas -- The Wasp Factory, The
  State of the Art, and Espedair Street. None of the three are our
  catalog's 3 Iain M. Banks Culture novels (Consider Phlebas, The
  Player of Games, Use of Weapons) -- The State of the Art IS a real
  Culture novella, but it's a different work, not currently in our
  catalog at all (and if added later, it'd be a normal ingestion +
  dramatized-audio-edition case, not an Audible-Original/no-print-
  counterpart case, since it's a published Banks novella). This closes
  the BBC Audio A1b pool for real -- no open threads remain there.
  **Sub-task B (Audible Originals) status, re-confirmed 2026-09-11**:
  candidate pool exhausted, no new unadded-but-known candidates exist
  right now (last discovery pass was 2026-09-09, 2 passes, ~20
  candidates checked, all 3 real finds already ingested+tagged -- see
  history below). This is the concrete basis for the P1->P3 demotion
  above: there genuinely is nothing left to add today, only future
  releases to watch for.
  **Full history kept below, not deleted** (moved here from P1
  2026-09-11):
  **Progress as of 2026-09-08: Steps A1a + A1b done for GraphicAudio,
  Step A2 batches 1-2 done (17 editions inserted, 2 series fully
  complete).** Full detail in project-log.md's five 2026-09-08
  "audiobook-editions skill" entries.
  **Also landed a real schema fix**: `audiobook_editions` had no unique
  constraint to make `on conflict do nothing` actually idempotent --
  added `unique (book_id, source_url)` (migration
  `20260908070000_audiobook_editions_unique_constraint.sql`), verified
  twice (batch 1 and batch 2 each re-ran their own insert file inside
  the test transaction and confirmed no duplicate rows).
  **Batches 1-2 done, 2 series fully complete**: A Court of Thorns and
  Roses (all 5 books) and Kate Daniels (both books, via Magic Bites/
  Magic Burns) are now fully covered. Also done: Sweep of the Heart,
  Age of Myth (completes The Legends of the First Empire, our only
  tagged book in it), Too Like the Lightning (completes Terra Ignota,
  same reason), Zodiac Academy: The Awakening, Elantris, The Hope of
  Elantris, The Emperor's Soul, Warbreaker (16 `fully_released` total),
  plus Empire of Silence correctly recorded as `announced` (a real
  pre-order catch -- GraphicAudio's own "Pre-Order Announcement!" post,
  Part 1 ships 2026-10-30, Part 2 2027-01-07, both still in the
  future). Howling Dark (Sun Eater #2) checked and skipped -- no
  confirmed GraphicAudio listing exists yet, consistent with book 1
  not being out; The Sun Eater series has nothing else insertable right
  now as a result.
  **Real gaps flagged for a future Step A2 session, not silently
  skipped**: Elantris and Warbreaker EACH have a second real
  GraphicAudio edition (a "Tenth Anniversary" re-recording alongside
  the original) that wasn't inserted due to incomplete runtime/
  completion data -- add as a genuine second row per book (the schema
  now supports this cleanly via the new unique constraint) once that
  data is confirmed.
  **Batch 2 was cut short by this session's web search budget cap
  (200/200)** partway into Crescent City -- same call as the
  2026-09-07 "romance_tone batch 10" precedent: stopped rather than
  guessing. **Whoever picks this up next needs a fresh/raised
  `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`** -- that's the repo
  owner's call.
  **Progress as of 2026-09-08 (later): Step A2 batch 3 done -- 10 more
  editions inserted (18 -> 28 total), Crescent City now fully covered
  and the Mistborn trilogy proper (Final Empire/Well of Ascension/Hero
  of Ages) plus its Secret History/Eleventh Metal companion bundle now
  covered.** Also done: The Frugal Wizard's Handbook for Surviving
  Medieval England, The Sunlit Man. Isles of the Emberdark checked --
  no confirmed GraphicAudio edition exists yet (published 2025-07-01,
  plausibly just not produced yet) -- worth a re-check later, not
  permanently closed. Full detail in project-log.md's 2026-09-08 "Step
  A2 batch 3" entry, including the Secret History/Eleventh Metal
  bundled-release judgment call (same shape as the still-open Riyria
  case below).
  **Progress as of 2026-09-09: Step A2 batch 4 done -- 10 more editions
  inserted (28 -> 38 total). Mistborn Era Two/Wax and Wayne now fully
  covered (The Alloy of Law, Shadows of Self, The Bands of Mourning,
  The Lost Metal) and Stormlight Archive Era One now fully covered**
  (The Way of Kings, Words of Radiance, Oathbringer, Rhythm of War,
  Edgedancer, Dawnshard, plus Wind and Truth which already had an
  edition from the 2026-09-05 seed row). The Way of Kings and
  Oathbringer have no cast list recorded (existence + part count only,
  nothing individually-named reliably found). Full detail in
  project-log.md's 2026-09-09 "Step A2 batch 4" entry, including a
  cast-list cross-contamination near-miss that was caught before
  inserting (a search result mixed in a different GraphicAudio
  production's credits).
  **Progress as of 2026-09-09 (later): Step A2 batch 5 done -- 11 more
  editions inserted (49 total). The Demon Cycle now fully covered**
  (The Warded Man, The Desert Spear, The Daylight War, The Skull
  Throne, The Core) **and Red Rising Saga now fully covered** (Red
  Rising, Golden Son, Morning Star, Iron Gold, Dark Age, Light
  Bringer). Full detail in project-log.md's 2026-09-09 "Step A2 batch
  5" entry, including the two books (Red Rising, Golden Son) where
  BOTH parts' runtimes were independently confirmed and genuinely
  summed to a total, distinct from the usual "leave NULL" case where
  only one part is confirmed.
  **Progress as of 2026-09-09 (later still): Step A2 batch 6 done -- 9
  more editions inserted (58 total).** Throne of Glass: only 1 of 9
  books confirmed (the series opener) -- GraphicAudio has said it's
  "starting production" on the series but no book-specific
  release/pre-order page exists yet for the other 8; a real, thin
  finding, not a research gap -- re-check in a later session as that
  production continues. The Murderbot Diaries: 8 of 10 confirmed (All
  Systems Red through Platform Decay); Compulsory and Home: Habitat,
  Range, Niche, Territory (both very short prequel/companion pieces)
  have no confirmed edition. Full detail in project-log.md's
  2026-09-09 "Step A2 batch 6" entry, including a runtime-format
  ambiguity (Network Effect's "8.22 hours" could mean two different
  things) correctly left NULL rather than guessed.
  **Progress as of 2026-09-09 (later still): Step A2 batch 7 done -- 5
  more editions inserted (63 total). Dresden Files: only 5 of 14 books
  confirmed** (Storm Front, Fool Moon, Grave Peril, Summer Knight,
  Death Masks) -- GraphicAudio only started this series in August 2025
  and is still releasing it sequentially; book 6 (Blood Rites) onward
  has no confirmed release yet. Real finding, not a research gap --
  same shape as Throne of Glass in batch 6. Full detail in
  project-log.md's 2026-09-09 "Step A2 batch 7" entry, including a
  real author-field contamination fix caught along the way: "White
  Night"'s author field had the series' cover illustrator (Chris
  McGrath) appended -- fixed via a scoped migration, confirmed
  isolated to that one row (checked all 14 Dresden Files books).
  **Still-open confirmed matches from Step A1b, not yet researched**:
  Dresden Files books 6-14 (9 books, blocked on GraphicAudio's own
  release pace -- re-check periodically, don't re-research every
  session). The remaining 8 Throne of Glass books and Murderbot's 2
  short prequel pieces are open leads but too thin for their own
  batch. **Flagged, needs a deliberate judgment call rather than a
  silent match**: GraphicAudio's "Riyria Revelations" only matches our
  omnibus row ("The Riyria Revelations (Omnibus)") -- decide whether a
  dramatized-edition record belongs on an omnibus row before
  inserting; "Riyria Chronicles" and "Kate Daniels: Wilmington Years"
  (GA) have no matching row in our catalog at all, not a match.
  Remaining steps, in order:
  1. **Demoted to P2, not active P1 work (clarified 2026-09-09)**:
     periodically re-check GraphicAudio's Dresden Files 6-14/Throne of
     Glass 2-9/Murderbot prequel production progress for newly-released
     books. This is a low-effort, infrequent "has anything shipped"
     check on an external producer's own release calendar, not
     ongoing research effort -- see the P2 entry below for the real
     priority-level version of this. Of the three, only **Throne of
     Glass has a real series-level "in production" announcement**
     (GraphicAudio's own public statement) -- Dresden Files 6-14 is
     just an inference from release cadence, not an actual
     announcement, and Murderbot's 2 prequels have neither. None of the
     three currently have anything book-specific enough to record via
     `audiobook_editions.release_status: 'announced'` (that field
     already exists and is already used correctly for Empire of
     Silence's real pre-order case -- not a schema gap, just nothing
     concrete enough yet for these three to attach a row to).
  2. **Step A1a + A1b for BBC Audio done 2026-09-09.** A1a pulled 39
     candidate titles (Pratchett/Discworld, Neil Gaiman, Pullman's His
     Dark Materials, Douglas Adams's Hitchhiker's Guide radio series,
     Le Guin, Asimov's Foundation Trilogy, Wyndham, Susan Cooper, Ray
     Bradbury, plus 8 classic/public-domain SF titles). A1b
     cross-referenced against `books`: **31 confirmed real matches**
     (see project-log.md's 2026-09-09 "Step A1b for BBC Audio" entry
     for the full list by author) -- Pratchett/Discworld (6), Good
     Omens (1), Neverwhere (1), His Dark Materials (3, "Northern
     Lights" = our "The Golden Compass"), Hitchhiker's Guide series
     (5), Le Guin (4), Asimov's Foundation Trilogy (3), Wyndham's Day
     of the Triffids (1), Bradbury (2), classic SF (5). **Real false
     positive caught**: our catalog's "The Lost World" is Michael
     Crichton's book, NOT Arthur Conan Doyle's -- not a match, title
     collision only. 10 titles confirmed genuinely not in our catalog.
     Iain Banks follow-up (unclear if Culture novels are dramatised)
     still unresolved.
  3. **Step A2 for BBC Audio, batch 1 done 2026-09-09** -- 11 more
     editions inserted (74 total): the Pratchett/Discworld group
     (Guards! Guards!, Wyrd Sisters, Mort, Small Gods, Night Watch,
     Eric), Good Omens, Neverwhere, and all 3 His Dark Materials books.
     Full detail in project-log.md's 2026-09-09 "Step A2 for BBC
     Audio, batch 1" entry.
     **Batch 2 done 2026-09-09** -- 13 more editions inserted (87
     total): all 5 Hitchhiker's Guide radio phases, all 3 Earthsea
     books + The Left Hand of Darkness, all 3 Foundation books, and
     The Day of the Triffids. Two bundled-release judgment calls
     (Earthsea, Foundation Trilogy -- each ONE combined dramatisation
     covering multiple catalog books with different actors per book as
     characters age/generations pass) -- narrators AND runtime left
     NULL for those 6 rows rather than misattribute a book-specific
     actor to the wrong book. Full detail in project-log.md's
     2026-09-09 "Step A2 for BBC Audio, batch 2" entry.
     **Batch 3 done 2026-09-09 -- clears the full 31-match pool.** 7
     more editions inserted (94 total): Fahrenheit 451, The Martian
     Chronicles, Frankenstein, The Time Machine (correctly recorded as
     BBC Radio 3, not Radio 4), The War of the Worlds, Journey to the
     Center of the Earth, Solaris. Every confirmed BBC Audio match
     from this session's A1b cross-reference now has an
     `audiobook_editions` row. Full detail in project-log.md's
     2026-09-09 "Step A2 for BBC Audio, batch 3" entry.
  3. **Sub-task B candidate discovery done 2026-09-09 (two passes)** --
     3 real candidates found, each with an open scope question rather
     than a clean pass: **The Salvation** (2023, Justin Lockey, 8-part
     time-travel sci-fi audio drama -- no flags, cleanest of the
     three), **Zero G** (2018, Dan Wells, sci-fi -- explicitly
     middle-grade, a real age-category judgment call since CLAUDE.md's
     v1 scope is genre-only), and **The Left Right Game** (2020,
     QCode/Legion M -- billed as "sci-fi horror" so genre fit is a
     judgment call, AND it originated as a published Reddit
     r/NoSleep short story before being expanded into the audio drama,
     a gray area on "no print edition exists anywhere"). Checked ~20
     candidates total across both passes; 8 disqualified with specific
     recorded reasons (has a real print/ebook/comic counterpart:
     Steal the Stars, Alien: River of Pain, Impact Winter, The Vela,
     The Bright Sessions, Voyage to the Stars; not a real Audible
     Original: Midst; wrong genre despite fantasy trappings: Heads
     Will Roll; wrong age-category/format: I'm From the Sun) plus
     Worlds Beyond Number flagged as a structurally different format
     (actual-play, not scripted drama) needing its own policy call. See
     project-log.md's two 2026-09-09 "Sub-task B candidate discovery"
     entries for full detail on each -- a future session should NOT
     re-research any of the 8 disqualified names.
     **Repo owner resolved both flagged scope questions 2026-09-09:
     Zero G is IN** (`age_category: middle_grade` at tagging time --
     v1 scope is genre-only, no age floor, and this catalog can hold
     an MG title fine) **and The Left Right Game is IN** (real sci-fi
     core clears the genre bar, same precedent as Horns/NOS4A2's dark-
     fantasy/horror inclusion; a Reddit short story predecessor doesn't
     count as a disqualifying "print edition" -- the audio drama is a
     substantially expanded, different work, unlike Steal the Stars'
     real Tor novelization). **The Salvation was already clean.** All
     3 candidates are now confirmed IN, ready for ingestion+tagging --
     no more open scope questions blocking this pool.
     **All 3 ingested and tagged 2026-09-09** -- The Salvation, Zero G,
     and The Left Right Game are now real catalog entries with full
     Book DNA, tropes, content warnings, and their own
     `audiobook_editions` row (`edition_type: dramatized_full_cast` --
     the skill doc's suggested `'audio_original'` value turned out not
     to be in the actual check constraint, caught by testing before
     applying). Real correction found during research: Zero G has 2
     sequels (Dragon Planet, Stargazer) not surfaced during discovery,
     so it's `narrative_closure: requires_series`. `books` 871 -> 874,
     `book_dna` 861 -> 864, `audiobook_editions` 94 -> 97. Full detail
     in project-log.md's "ingested the 3 confirmed Audible Originals"
     entry.
  Also flagged, needs a deliberate judgment call rather than a silent
  match: GraphicAudio's "Riyria Revelations" only matches our omnibus
  row ("The Riyria Revelations (Omnibus)") -- decide whether a
  dramatized-edition record belongs on an omnibus row before inserting;
  "Riyria Chronicles" and "Kate Daniels: Wilmington Years" (GA) have no
  matching row in our catalog at all, not a match. Still not resolved
  as of the 2026-09-11 demotion -- low stakes, revisit whenever this
  item gets picked back up.
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
