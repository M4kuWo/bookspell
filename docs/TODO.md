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
- [ ] **Bookspell v1 web app -- IN PROGRESS, started 2026-09-12.** Real
  accounts, login, per-genre (fantasy/sci-fi) recommendations, manual
  rating with edit, Goodreads/Fable-CSV import, persistent "none of
  X"/"less of X" filters -- responsive, live online without the repo
  owner's PC running. Full architecture in the approved plan
  (`~/.claude/plans/jaunty-chasing-eclipse.md`, or see
  `docs/project-log.md`'s 2026-09-12 "Bookspell v1 web app" entry for
  the same content committed to project history). Key decisions,
  already made, don't re-litigate: static multi-page frontend (no
  React/Next.js) using `supabase-js` via CDN, deployed via the existing
  GitHub Pages setup; Supabase Auth + 3 new RLS-scoped tables
  (`profiles`/`ratings`/`user_rules`) for everything except live
  scoring; a small FastAPI backend (new `api/` dir) wrapping
  `recommend.py` unmodified, deployed to Render's free tier (repo owner
  chose cold starts over a $7/mo always-on tier -- ship a "waking up"
  loading state in the UI, don't silently hide the delay). Existing
  `data/ratings/*.json` raters are deliberately NOT auto-migrated --
  those stay `scoring_tests.py`'s fixture, untouched.
  **Build order**: (1) migration for the 3 new tables + RLS, (2) real
  Supabase Auth config (site URL/redirects on the HOSTED project, not
  just local `config.toml`), (3) backend endpoints
  (`/rule-targets` -> `/recommendations` -> `/import/goodreads`,
  deployed to Render early to validate cold-start behavior for real),
  (4) frontend pages in rater-journey order (auth -> manual rating ->
  recommendations -> import -> filters), (5) a real mobile-viewport
  pass on every page before calling this done -- fixing exactly the
  mobile-display failure the `tools/dogfood` Streamlit prototype had is
  a named goal here, not incidental.
  **Progress as of 2026-09-13** (full detail in project-log.md's two
  2026-09-13 entries): **(1) done** -- `profiles`/`ratings`/`user_rules`
  tables + RLS, tested/applied/verified both sides. **(2) HALF-DONE,
  still needs the repo owner** -- `config.toml`'s auth URLs updated
  locally but deliberately NOT pushed to hosted (`supabase config push`
  pushes the ENTIRE config file, not just `[auth]` -- too broad a blast
  radius for this session to risk without checking); apply the 2 auth
  fields via the Supabase dashboard directly, or say the full-file push
  is fine. **(3) DONE, deployed to Render and verified live** -- `api/`
  is running at `https://bookspell-api.onrender.com`
  (`GET /rule-targets` returns real catalog data, `GET /recommendations`
  correctly 401s with no token). Two real deploy-time bugs hit and
  fixed (see project-log.md): Supabase's direct-connection host is
  IPv6-only and unreachable from Render (switched `DATABASE_URL` to the
  transaction pooler), and a stray copy-paste character broke DSN
  parsing on the first pooler attempt. Also caught and fixed a real
  wrong assumption before deploying: this project's Supabase Auth uses
  the newer asymmetric JWKS signing-key model, not the legacy shared
  HS256 secret `api/main.py` originally assumed -- confirmed directly
  against the real JWKS endpoint, not guessed. **(4) done** -- `app/`
  frontend (index/dashboard/rate/import.html), same visual convention
  as `tools/rate-books`; `shared.js`'s `API_BASE` already matched the
  real deployed URL by construction, no value change needed. **(5) NOT
  done** -- planned real-device/browser interactive testing hit a
  persistent Chrome-automation tooling error this session couldn't
  resolve; substituted a careful manual code re-review instead, which
  caught 2 real bugs (a magic-link redirect that Supabase would have
  silently rejected; a stray unused API query param) -- both fixed, but
  a genuine mobile-viewport click-through is still owed.
  **A real, separate gap found and fixed along the way**:
  `20260828040000`'s catalog-table SELECT grant only covered the `anon`
  Postgres role (the two pre-existing anon-key tools) -- a signed-in
  user's requests run as `authenticated`, a separate role with no such
  grant, so the app's catalog search would have hit permission-denied
  despite RLS allowing it. Fixed, migration
  `20260913020000_grant_catalog_select_to_authenticated.sql`.
  **A real credential-hygiene item, not a code task**: the repo owner
  pasted a live `SUPABASE_SECRET_KEY` into chat during this session --
  never used for anything, but should still be rotated from the
  Supabase dashboard as routine hygiene (the database password that was
  also pasted has already been rotated, as part of fixing the deploy
  bugs above).
  **Next real step for the repo owner**: (a) resolve (2) above, (b) do
  one real signup -> rate a few books -> get recommendations -> add a
  filter -> import a real Goodreads CSV pass personally before asking
  any real rater to try it (per the plan's own Verification section) --
  this also finally exercises `import_goodreads.py`'s matching logic
  against a genuine export file for the first time ever (it's only
  ever run against a synthetic fixture, per its own docstring), (c)
  rotate `SUPABASE_SECRET_KEY` per the hygiene note above, (d) a real
  mobile-viewport pass per (5) above.

## P1

- [ ] **CODX (Codex CLI, via the repo owner's ChatGPT Plus
  subscription) as a third working entity -- approach worked out
  2026-09-11, deliberately deferred, do later.** Persona name settled:
  **CODX** (matches CLDO/CLDA's 4-letter format, visually distinct).
  **Approach**: start it in a review/propose role only, no direct
  hosted-DB access or unsupervised commits at first -- earn trust the
  same way CLDA did (by being right repeatedly), not by assumption.
  The real value of a second model family is an independent
  perspective with no accumulated bias toward this codebase's history
  -- worth the most on review-type work, less on generative work that
  depends on deep project context.
  **Concrete tasks decided on**:
  - Code review/refactoring (repo owner's own idea, the strongest
    fit): periodic independent review of `scripts/recommend.py`/
    `scripts/scoring_tests.py`/tool scripts, hunting for the class of
    bug CLDO just found and fixed (untagged-nominal-field mismatch,
    the `ZeroDivisionError`) -- issues that show up to fresh eyes, not
    to someone who already knows how the code "should" behave.
    Auditing the pile of deferred/experimental functions (
    `build_profile_per_value`, `build_profile_trope_shrinkage`,
    `build_profile_trope_backoff`, `build_profile_series_field_dedup`)
    for whether they're still accurate/worth keeping. An independent
    QA pass on CLDA's own large migrations -- a genuine third opinion,
    not redundant with CLDO's own verification.
  - Mechanical/scriptable work: the still-open local-bootstrap gap
    (seed data can't rebuild the catalog from scratch), future
    data-source integrations shaped like `backfill-standard-
    narrators.js`, `tools/catalog-review/`/`tools/dogfood/` UI work.
  - Deliberately NOT handed over: Book DNA tagging (leans on hard-won
    evidence discipline -- `HIGH_RISK_FIELDS`, the romance_tone
    evidence standard) and scoring-algorithm design (re-deriving
    scoring-test-protocol.md's history of rejected ideas would cost
    more than it saves).
  **Token/budget relationship**: a genuinely separate, non-competing
  pool from Claude usage -- CODX work costs nothing against
  Claude/CLDO/CLDA's own budget, so this is additive capacity, not
  divided capacity. Checked directly (not guessed): Codex CLI usage is
  included in ChatGPT Plus (no separate API billing needed), metered
  on a rolling 5-hour window plus a separate weekly cap, token-based
  rather than a fixed message count; Pro tiers ($100/$200 per month)
  get 5x/20x more than Plus. Could not pin down an exact "X per week"
  number for Plus specifically from available sources -- check the
  account's own usage page rather than trust an estimate here.
  **Setup, when this gets picked up**: write an `AGENTS.md` that
  points back at `CLAUDE.md` for shared conventions (not a duplicate
  copy, to avoid drift) plus CODX-specific notes on its review-only
  starting scope; extend the persona system and
  `docs/PENDING_APPROVALS.md` gate to include it as a third named
  entity before giving it any write access.
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
- [x] **Promote `romance_tone`/`worldbuilding_delivery` from trope
  pairs to real scalar fields -- DONE, both schema and scoring halves
  complete 2026-09-11.** The probe already validated (correctly-signed
  weights,
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
  **Scoring-engine half done 2026-09-11** (commit `7646a1d`): both
  fields added as content-scoped `NOMINAL_FIELDS`, `mixed` getting
  partial credit against both poles (same bar as `drive`'s `balanced`).
  Found and fixed two real, previously-latent general bugs while
  testing (not specific to these two fields): `score_book()`/
  `explain_book()` scored an untagged nominal field as a full mismatch
  instead of skipping it; `build_profile()` could divide by zero when a
  field's evidence was entirely confidence-zeroed on one side. Checked
  via full A/B scorecard before landing: one real, exactly-traced
  regression (2 books flip -- Royal Assassin, Interview with the
  Vampire -- driven by thin per-rater coverage causing held-out-split
  mode instability), zero effect on 3 of 4 raters. Landed anyway per
  explicit repo-owner review of the exact size; expected to self-correct
  as tagging coverage grows. See scoring-test-protocol.md's 2026-09-11
  entry for full detail. **Item fully complete, nothing further queued
  here.**

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
- [ ] **Catalog expansion round 4 landed 2026-09-12 -- 378 new untagged
  books entered the queue, real tagging work again (see (a) above).**
  Catalog now 1256 books / 484 series (was 878/366) -- see
  project-log.md's 2026-09-12 entry for the full method and hosted-sync
  verification. **8 of the 378 are graphic novels, already identified --
  skip, don't tag, per the existing v1-scope policy** (same treatment as
  the 4 already-known cases above): *Monstress, Vol. 1: Awakening*,
  *Paper Girls, Vol. 1*, *Saga, Vol. 3*, *Saga, Vol. 4*, *The Walking
  Dead, Vol. 1: Days Gone Bye*, *Watchmen*, *White Sand, Vol. 1* (the
  Dynamite comic adaptation -- not Sanderson's own prose novels), *Y:
  The Last Man Vol, 1 Unmanned*. The rest were NOT pre-audited for
  scope (a popularity pull always nets some non-SFF leakage, e.g.
  literary fiction/thrillers/nonfiction -- expected, per this file's own
  documented pattern) -- catch those at tagging time as usual, flag
  anything with no real SFF content for the repo owner rather than
  silently tagging or silently skipping it.
  **56 of the 378 tagged 2026-09-13, across 3 batches** (CLDO session,
  following `tag-catalog-batch`, partial-series-first) -- see
  project-log.md's three 2026-09-13 "Catalog tagging batch" entries for
  full detail. Batch 1 (18 books) included one real catch: a candidate,
  "Red God," turned out to be unpublished -- correctly left untagged,
  not a tagging error. Batch 2 (20 books) found 2 more permanent-skip
  candidates on the same known patterns (The Doors of Stone unpublished,
  The Farseer Trilogy an omnibus duplicate). Batch 3 (18 books) found 3
  more confirmed omnibus duplicates (Monk and Robot, Villains Duology,
  Heir of Novron) and one genuine format-mismatch case handled
  transparently (Quidditch Through the Ages, a fake in-universe
  "textbook," not a normal narrative). Series now **fully
  tagged/complete** as a direct result: Discworld, The Mortal
  Instruments, Percy Jackson and the Olympians, Malazan Book of the
  Fallen, Robot, Imperial Radch, The Sun Eater. ~314 of the 378 remain
  (378 - 56 tagged - 8 flagged graphic novels), plus whatever
  non-SFF leakage tagging turns up along the way.
- [ ] **`series.status`/`book_count` is systemically wrong catalog-wide
  -- root cause found 2026-09-08, batch 1 done 2026-09-11, batches 2-6
  done 2026-09-12 (91 of ~484 series fixed so far: 14+14+17+17+15+14 across
  batches 1-6 -- the denominator grew a lot from the 2026-09-12
  378-book/118-series ingestion round, this isn't the catalog shrinking
  work).** `status` defaults to
  `'ongoing'` whenever Hardcover's `is_completed` flag isn't explicitly
  `true` (including simply missing data); `book_count` is Hardcover's
  raw per-series edition/omnibus/box-set count, not a curated
  mainline-installment number. Doesn't affect scoring at all (neither
  field is read by `scripts/recommend.py`) -- purely a
  `tools/catalog-review/` display bug, so no urgency pressure, but real
  and visible to anyone browsing the tool. **Approach**: manually
  verify+fix the most-viewed/highest-profile series first (real
  publication status via search, never a guess), in bounded batches,
  stop-and-report each time.
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
  entry.
  **Batch 2 (2026-09-12)**: same re-ranked-query approach, excluding
  batch 1's 20 checked names. 14 needed a real fix: Malazan Book of the
  Fallen, The Culture, Lightbringer, The Heroes of Olympus, Skyward,
  The Reckoners, Mars Trilogy, The Sun Eater, Imperial Radch
  (publication order), Percy Jackson and the Olympians, Shatter Me, The
  Witcher, Old Man's War, The Twilight Saga. 16 more checked and found
  already correct (list in the migration header and project-log entry,
  worth reading before re-researching them): Discworld, The Expanse,
  The Wheel of Time, Throne of Glass, Foundation, Harry Potter, The
  Chronicles of Narnia (Publication Order), The Dark Tower, Dune, The
  Mortal Instruments, Stormlight Archive Era One, Robot, Mistborn Era
  One, The Maze Runner, Hainish Cycle, The Hitchhiker's Guide to the
  Galaxy. Migration
  `20260912100000_fix_series_status_book_count_batch2.sql` -- applied
  to hosted directly by the agent (tested in a rolled-back transaction
  first, per CLAUDE.md's standard pattern) but **not yet pushed via
  `supabase db push` and the branch not yet merged to main** -- both
  left for CLDO to do serially, to avoid two sessions' `db push`/git
  operations racing on the same day. Two judgment calls flagged for
  visibility (not decisions that need re-litigating, just worth
  knowing): The Witcher and Percy Jackson and the Olympians moved to
  'ongoing' on a confirmed on-the-record author commitment to more
  books, while Old Man's War's book_count was fixed but its status was
  deliberately left 'completed' since the only evidence for a book 8 is
  a conditional "might write one" -- see project-log.md's 2026-09-12
  entry for the full reasoning and sourcing on all 14, plus a
  passing-flag note about the out-of-scope "Saga" series row (graphic
  novel, left untouched).

  **Batch 3 (2026-09-12)**: re-ran the ranking query excluding all 50
  names checked across batches 1-2. The catalog's growth since batch 2
  (the 378-book/118-series ingestion round, same day) meant almost
  every top candidate by this ranking now only has 3-4 books currently
  linked in our own catalog -- a much flatter tie than batches 1-2 saw,
  worked in the order the query returned them. 17 needed a real fix (10
  status fixes -- wrongly 'ongoing', confirmed completed with no
  evidence of more coming: Takeshi Kovacs, The Selection, Red Queen,
  The Scholomance, Themis Files, The Interdependency, The Infernal
  Devices, Fitz and the Fool, Star Wars: The Thrawn Trilogy, The
  Magicians; 7 book_count-only fixes, status already correct: Wayward
  Pines, The Old Kingdom, Cradle, All Souls, The Liveship Traders,
  Villains, A Series of Unfortunate Events). Zero already-correct
  candidates found this round. Migration
  `20260912400000_fix_series_status_book_count_batch3.sql` -- applied
  to hosted directly by the agent (tested in a rolled-back transaction
  first) but **not yet pushed via `supabase db push` and the branch not
  yet merged to main**, same handoff-to-CLDO pattern as batch 2. Three
  judgment calls flagged for visibility: Villains and All Souls both
  correctly kept 'ongoing' on a confirmed-announced-but-not-yet-
  published next book (Victorious, 2026-10-06; "The Falcon and the
  Rose", no date yet) rather than counting an unpublished book or
  wrongly flipping to 'completed'; The Old Kingdom kept 'ongoing' on
  *absence* of a completion statement plus Nix's history of returning
  to the series after multi-year gaps, not a positive "more confirmed"
  signal like the other two. See project-log.md's 2026-09-12 "batch 3"
  entry for full reasoning and sourcing on all 17, plus the candidates
  seen but deliberately left unresearched for batch 4 (including two --
  Hogwarts Library, The Roald Dahl Classic Collection -- flagged as
  possibly not real "series" in the status/book_count sense at all,
  worth a policy look before batch 4 touches them).

  **Batch 4 (2026-09-12)**: re-ran the ranking query excluding all 67
  names checked across batches 1-3 plus the 3 flagged-but-not-fixed
  names (Hogwarts Library, The Roald Dahl Classic Collection, The
  Riyria Revelations (Omnibus) -- still not touched, still needing the
  same policy call, not decided this batch either). Same flat-tie
  situation as batch 3. 17 needed a real fix: Shades of Magic, Night
  Angel, Gentleman Bastard (book_count only), Covenant of Steel (status
  only), The Locked Tomb (a reversal -- wrongly marked 'completed'/4
  when the 4th book isn't published yet), Southern Reach (status only),
  MaddAddam, Artemis Fowl, Monk and Robot, Time Master, Ash and Sand,
  Children of Time (book_count only), The Tawny Man, He Who Fights with
  Monsters (book_count only, was NULL), Earthsea Cycle (book_count
  only), Secret Projects (book_count only), The Empyrean (book_count
  only). 21 more checked and found already correct (full list in the
  migration header and project-log.md's 2026-09-12 "batch 4" entry).
  Migration `20260912600000_fix_series_status_book_count_batch4.sql` --
  applied to hosted directly by the agent (tested in a rolled-back
  transaction first) but **not yet pushed via `supabase db push` and
  the branch not yet merged to main**, same handoff-to-CLDO pattern as
  batches 2-3. New this batch: **2 series (Robert Langdon, The
  Inheritance Games) turned up in the ranking with real catalog rows
  but are NOT sci-fi/fantasy** (techno-thriller/mystery and
  contemporary YA mystery respectively) -- flagged as a likely
  Hardcover genre-search false positive akin to the prior
  Shogun/Screwtape removals, left untouched pending a scope call from
  the repo owner, not decided by this batch. Also flagged in passing (a
  different bug class, not fixed here): "The Lord of the Rings," "The
  Farseer Trilogy," and "Monk and Robot" each have a duplicate `books`
  row (an omnibus/series-titled edition alongside the individual
  volumes at the same `position_in_series`) -- a `books`-table
  duplicate-row question, not a `series.status`/`book_count` one. See
  project-log.md's 2026-09-12 "batch 4" entry for full reasoning and
  sourcing on all 17 fixes plus the 21 confirmed-correct checks.

  **Batch 5 (2026-09-12, background agent)**: **found and fixed a real
  bookkeeping gap first** -- this file's own "next batch" pointer (and
  project-log.md's batch-4 entry) said to exclude "84 checked names"
  (67 from batches 1-3 + batch 4's 17 fixes), but never folded in batch
  4's own 21 additional confirmed-already-correct names, so the running
  total was undercounting by 21 in both places. Reconstructed the
  accurate list by name straight from batches 1-4's project-log entries:
  15 (batch 1) + 30 (batch 2) + 17 (batch 3) + 38 (batch 4) = **100
  named series**, not 84 -- used that for this batch's exclusion, and
  the corrected running total is carried below so batch 6 doesn't
  inherit the same gap. Re-ran the ranking query excluding those 100
  plus the 5 flagged names. 15 needed a real fix: The Rain Wild
  Chronicles, Space Odyssey, Dirk Gently, The Book of the New Sun
  (book_count only), The Final Architecture, An Ember in the Ashes, The
  Kane Chronicles, Zones of Thought, The Atlas (book_count only), King
  of Scars, Ninth House (book_count only), Caraval, The Riftwar Saga
  (book_count only), The Shepherd King (book_count only), Cerulean
  Chronicles. 3 more checked and found already correct: The Dresden
  Files, The Vampire Chronicles, The Faithful and the Fallen. Migration
  `20260912800000_fix_series_status_book_count_batch5.sql` -- applied
  to hosted directly by the agent (tested in a rolled-back transaction
  first) but **not yet pushed via `supabase db push` and the branch not
  yet merged to main**, same handoff-to-CLDO pattern as batches 2-4. See
  project-log.md's 2026-09-12 "batch 5" entry for full reasoning and
  sourcing on all 18 checks.

  **New this batch -- 6 more names flagged as a DIFFERENT bug class**
  (not simple status/book_count errors, need a separate look, not fixed
  here): **Imperial Radch (publication order)** -- a duplicate series
  row holding all 5 real books, while the "Imperial Radch" row batch 2
  already fixed now has zero books linked (a duplicate-series-row
  problem, the series-level mirror of batch 4's duplicate-`books`-row
  flag). **Enderverse: Publication Order / The Shadow Series** -- the
  4-book "Shadow" sub-saga is split across these two series rows
  (2 books under each), violating the leaf-series convention in this
  file's "Catalog scope & series hierarchy" section. **Middle Earth** --
  holds only an omnibus and "The Silmarillion," not a real leaf series,
  same pattern as the already-flagged Hogwarts Library/Roald Dahl
  Classic Collection. **American Gods** -- groups a loosely-connected
  companion novel ("Anansi Boys") as if it were a numbered sequel, a
  scope/grouping question in the same family as the omnibus flags.
  **Forward Collection** -- a one-time 2019 anthology of 6 unrelated
  novellas by 6 different authors, not a normal single-author series;
  whether "book_count" even applies to a multi-author anthology brand
  is a policy question. These 6 are now added to the flagged-name list
  below so future batches' ranking queries stop re-surfacing them.
  **'Saga'** (the already-known out-of-scope graphic novel) was also
  seen again in the ranked list -- it had never actually been added to
  the exclude list despite being noted back in batch 2, so every batch
  since has re-encountered it for nothing; added now.

  **Batch 6 (2026-09-12, background agent)**: re-ran the ranking query
  excluding the accurate 118-name total from batches 1-5 plus the 12
  flagged names (including using the DB's actual stored name for
  "Enderverse:  Publication Order" -- a double space after the colon,
  confirmed by direct query, needed so the exclusion filter actually
  matched it; the single-space version in this file's own prior text
  was silently not excluding it). 14 needed a real fix: Lock In
  (book_count only), The Captive's War (book_count only), Uglies,
  Miss Peregrine's Peculiar Children, The Vagrant, The Daevabad
  Trilogy, Emily Wilde (book_count only), Wayward Children (book_count
  only), Commonwealth Saga, Daemon, Bloodsworn Saga, Crowns of Nyaxia
  (book_count only), The Handmaid's Tale, Teixcalaan (book_count only).
  3 more checked and found already correct: Skyward Flight, The Age of
  Madness, The Giver ("The Giver Quartet"). Migration
  `20260912900000_fix_series_status_book_count_batch6.sql` -- tested in
  a rolled-back transaction first (all 14 names matched exactly once,
  post-update values verified), then applied for real to hosted via a
  normal autocommit connection; **not yet pushed via `supabase db push`
  and the branch not yet merged to main**, same handoff-to-CLDO pattern
  as batches 2-5. `series` table total row count unchanged (484).
  **Stopped at 14 fixes (short of the ~15 target) because this
  session's live web-search budget ran out (200/200 calls used)
  partway through the ranked list** -- a genuine research wall per this
  task's own stopping rule, not a candidate-quality problem. Two
  judgment calls flagged for visibility: Teixcalaan's book_count was
  fixed but its status deliberately left 'ongoing' on genuinely mixed,
  unresolved evidence (one source frames it as book 1 of a trilogy,
  others call it a completed duology) rather than guess with no search
  budget left to settle it; Crowns of Nyaxia's book_count reflects 5 of
  a planned 6 mainline installments, excluding two standalone/novella
  titles. See project-log.md's 2026-09-12 "batch 6" entry for full
  reasoning and sourcing on all 17 checks.

  **Two new likely-out-of-scope names surfaced, not decided, same shape
  as batch 4's Robert Langdon/The Inheritance Games flag**: Kingsbridge
  (Ken Follett -- historical fiction, not SFF) and Holly Gibney (Stephen
  King -- crime/thriller, already separately flagged in the
  shared-universe audit's batch 6 for the same reason). Both added to
  the flagged-name list below rather than fixed.

  **New data-quality issue noticed in passing, not fixed (a different
  bug class -- author-field contamination, not status/book_count)**:
  the "Threshold" series row's author field mixes Peter Clines with what
  look like a translator ("Jean-Pierre Pugi") and an audiobook narrator
  ("Ray Porter"), the same contamination pattern CLAUDE.md's "Data
  quality / tagging" section already tracks. Left "Threshold" itself
  completely unresearched for status/book_count too (its own identity
  wasn't pinned down this batch) -- available for batch 7.

  **Next (batch 7)**: re-rank remaining series by catalog book count,
  excluding all **135** now-checked names across batches 1-6 (118 from
  batches 1-5 + this batch's 14 fixed + this batch's 3 confirmed-correct
  -- keep this running total accurate going forward) plus the **14**
  still-unsettled flagged names: Hogwarts Library, The Roald Dahl
  Classic Collection, The Riyria Revelations (Omnibus), Robert Langdon,
  The Inheritance Games, Imperial Radch (publication order), Enderverse:
  Publication Order (DB name has a double space -- "Enderverse:
  Publication Order" -- match the real string, not the single-space
  version), The Shadow Series, Middle Earth, American Gods, Forward
  Collection, Saga (pre-existing 12) + Kingsbridge, Holly Gibney (this
  batch's 2 new scope flags) -- don't reuse any prior batch's candidate
  list, all are now stale. Un-researched candidates seen this batch,
  available as batch 7's first candidates (this session's search budget
  ran out before reaching them, no assumption made either way):
  Revelation Space (Alastair Reynolds), Outlander (Diana Gabaldon),
  Legend (Marie Lu), Six of Crows (Leigh Bardugo), Legends & Lattes
  (Travis Baldree), The Founders Trilogy (Robert Jackson Bennett),
  Earthseed (Octavia Butler), Blood and Ash (Jennifer L. Armentrout),
  Ready Player One (Ernest Cline), Ana and Din Mysteries (Robert Jackson
  Bennett), The Roots of Chaos (Samantha Shannon), Oxford Time Travel
  (Connie Willis), Elantris (Brandon Sanderson -- check carefully, looks
  like it may be a companion-grouping question rather than a plain
  miscount), Before the Coffee Gets Cold (Toshikazu Kawaguchi), Once
  Upon a Broken Heart (Stephanie Garber -- book count genuinely unclear
  from available sources so far), Sword of Truth (Terry Goodkind), Kate
  Daniels (Ilona Andrews), Threshold (Peter Clines -- resolve the
  author-field contamination noted above before or while checking this
  one).
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
  needs to be done properly rather than one series at a time -- First
  Law and Mark Lawrence's two universes both DONE 2026-09-11, and the
  audit's own first step found the real scope is 51 authors, not 2.**

  **First Law -- DONE.** Built "The First Law World" as a real
  `universe` row (docs/schema/book-dna.md's own design doc example,
  never actually implemented until now): `The First Law` and `The Age
  of Madness` both link via `series.universe_id`; the 3 in-catalog
  standalones (Best Served Cold, The Heroes, Red Country) link directly
  (`series_id = null`) instead of living in the old ad-hoc pseudo-
  series, which was deleted. **Sharp Ends ingested** (bibliographic
  data only -- tagging is a separate follow-up, not done yet).
  Migrations `20260911200000_first_law_universe.sql` and
  `20260911210000_ingest_sharp_ends.sql`.

  **Mark Lawrence -- DONE, but as TWO separate universes, not one --
  a real correction the repo owner caught in this session's own
  premise.** The original 2026-09-08 note (and this session's initial
  assumption) wrongly grouped all 4 Lawrence series into one shared
  world. Corrected: **The Broken Empire + The Red Queen's War** are
  genuinely the same world (concurrent, same planet, confirmed via
  search) -- linked as "The Broken Empire World" (the real press/
  fandom name, "the Broken Empire," would collide with the existing
  series name of the same name, so used the "World"-suffixed fallback
  instead). **Book of the Ancestor's real connection is to Book of the
  Ice** (a different, separate series, NOT to The Broken Empire or The
  Library Trilogy) -- both set on the planet Abeth, no official branded
  name beyond that (confirmed via search), so the universe is named
  "Abeth" directly. Book of the Ice (3 books) wasn't in the catalog at
  all -- **ingested AND fully tagged** (Book DNA, tropes, content
  warnings, per tag-catalog-batch/SKILL.md's process; a HIGH_RISK_FIELD
  catch along the way -- an initial search wrongly claimed book 1 was
  first-person, a targeted follow-up search corrected it to third-
  limited). Also corrected a second error: *The Girl and the Stars* is
  Book of the Ice book 1, not Library Trilogy book 2 as the original
  note assumed -- the Library Trilogy's real book 2 remains
  unidentified. Migrations `20260911220000_broken_empire_universe.sql`,
  `20260911230000_ingest_book_of_the_ice_and_abeth_universe.sql`,
  `20260911240000_tag_book_of_the_ice.sql`. Full detail across two
  2026-09-11 project-log.md entries.

  **The audit's own first step (done 2026-09-11) found the real
  scope**: grouped the whole catalog by author and checked every
  author with 2+ series not yet linked to a universe -- **51 authors**
  qualified originally, not just the 2 known starting cases.

  **Batch 2 (2026-09-11, same day)**: repo owner asked to continue,
  applying the Book of the Ancestor lesson explicitly -- verify with
  specific, well-corroborated evidence, not a vague "shares a
  universe" summary. Researched 6 candidates individually. Result: the
  caution was warranted again -- **3 of them looked like obvious same-
  author connections and were confirmed NOT connected** (Brandon
  Sanderson's Skyward/The Reckoners -- explicitly separate from the
  Cosmere per Sanderson's own FAQ; all 3 of N.K. Jemisin's major series
  -- Broken Earth/Inheritance Trilogy/Great Cities, confirmed
  independent; Ursula K. Le Guin's Earthsea/Hainish Cycle -- confirmed
  via Le Guin's own words). **1 confirmed connected but judged too thin
  to model**: Neil Gaiman's American Gods/Neverwhere -- real but
  informal per Gaiman's own admission ("share a car park"), same tier
  as Stephen King's Man in Black motif recurring across his catalog
  without those books being "the same universe" as The Dark Tower (the
  repo owner's own analogy, confirmed correct). **This is now a
  standing policy for the rest of this audit: a cameo/thematic
  reference isn't enough, it needs an actual structural connection**
  (explicit merged continuity, or a recurring protagonist/plot across
  books). **1 confirmed connected with strong evidence, built**: Isaac
  Asimov's Foundation + Robot (explicitly merged by Asimov himself via
  R. Daneel Olivaw, referenced directly in Foundation's Edge) --
  "Foundation universe" (the real encyclopedic term). Also fixed a real
  leftover gap: the `Elantris` series row itself never got
  `universe_id` set despite its books already being correctly
  Cosmere-tagged individually (confirmed safe -- unlike "Secret
  Projects," which is genuinely mixed and correctly has no series-level
  universe_id). Migrations `20260911250000_elantris_series_cosmere_
  link.sql` and `20260911260000_foundation_universe.sql`. Full detail
  in project-log.md's 2026-09-11 "shared-universe audit, batch 2"
  entry.

  **Stephen King checked 2026-09-11, confirmed NOT connected -- no
  action.** Holly Gibney's continuity (Mr. Mercedes -> The Outsider ->
  If It Bleeds -> Holly) is real but explicitly a SEPARATE, smaller
  branch of King's mythology from the Dark Tower; The Green Mile's Dark
  Tower connection is confirmed purely thematic/symbolic, no shared
  characters; and Holly Gibney's own connected books (The Outsider, Mr.
  Mercedes) aren't in our catalog at all regardless.

  **George R.R. Martin checked 2026-09-11, confirmed connected --
  built as "Westeros."** A Song of Ice and Fire, A Targaryen History
  (Fire & Blood), and The Tales of Dunk and Egg (A Knight of the Seven
  Kingdoms) are all officially the same Westeros continuity -- the
  clearest, most explicit case checked in this whole audit. Named
  after the in-world place itself (matching Middle-earth/Abeth), not a
  flagship series title. Migration `20260911270000_westeros_universe.sql`.

  **Robert Jackson Bennett checked 2026-09-11, confirmed NOT
  connected.** Divine Cities and Founders Trilogy are explicitly
  "entirely separate worlds and narratives"; Ana and Din Mysteries is
  "a wholly original fantasy world" with no connection to either.

  **Tracking note**: the raw "authors with 2+ series, universe_id
  null" query does NOT shrink cleanly as authors get checked --
  confirmed-negative authors correctly keep `universe_id: null`
  forever, so they keep reappearing in that query (66 authors as of
  2026-09-12, up from 51/49 -- catalog growth plus accumulating
  negatives, not a bug). **Don't use a single "N remain" count as a
  progress tracker -- use this explicit list instead**:
  - **Confirmed connected (built)**: Mark Lawrence (Broken Empire
    World, Abeth), Isaac Asimov (Foundation universe), George R.R.
    Martin (Westeros), Robin Hobb (Realm of the Elderlings), Leigh
    Bardugo (Grishaverse -- Ninth House excluded, see below), Orson
    Scott Card (Enderverse), Sarah J. Maas (Maasverse -- see resolution
    below), Rick Riordan (Riordanverse -- batch 4), Michael J. Sullivan
    (Elan -- batch 5), Cassandra Clare (The Shadowhunter Chronicles --
    batch 5), T. Kingfisher (The World of the White Rat -- batch 5,
    Sworn Soldier excluded, see below), Philip Pullman (Lyra's World --
    batch 5, naming flag, see below), J.K. Rowling (Wizarding World --
    batch 7, Harry Potter + Hogwarts Library), V.E. Schwab (The
    Four Londons -- batch 4, Shades of Magic + Threads of Power only,
    see below), Brandon Sanderson (Cosmere series-level gap fix, batch
    4 -- see below; his Skyward/Reckoners are still separately confirmed
    NOT connected to the Cosmere, see the negatives list).
  - **Batch 4 (2026-09-12)**: 8 authors checked.
    - **Rick Riordan -- built as "Riordanverse."** Percy Jackson and the
      Olympians, The Heroes of Olympus, The Kane Chronicles, Magnus
      Chase and the Gods of Asgard, and The Trials of Apollo all link.
      Not a thematic guess -- real structural crossovers: three official
      published crossover novellas (The Son of Sobek, The Staff of
      Serapis, The Crown of Ptolemy, collected in Demigods & Magicians)
      put Percy/Annabeth and Carter/Sadie Kane in scenes together;
      Magnus Chase is Annabeth's own cousin with Percy appearing
      directly in his books; Trials of Apollo is a direct continuation
      at Camp Half-Blood with the same cast. No official umbrella name
      exists, so per the naming policy: "Riordanverse" confirmed as a
      real, widely-used fan term (TV Tropes' own "Riordanverse
      (Franchise)" page, multiple independent fan reading-order guides
      and wikis) -- used directly, not invented.
    - **V.E. Schwab -- built as "The Four Londons"** (Shades of Magic +
      Threads of Power only). Threads of Power is explicitly the direct
      sequel trilogy to Shades of Magic -- set 7 years after A Conjuring
      of Light, same protagonists (Kell, Lila, Alucard) returning, same
      setting. Named after the real in-world/fandom term for the
      four parallel-world Londons (Red/White/Grey/Black) -- matches the
      established place-name pattern (Westeros/Abeth/Middle-earth), no
      naming-policy question this time. **Checked and confirmed NOT
      part of this universe or connected to each other**: Schwab's
      Monsters of Verity duology and Villains trilogy -- no structural
      connection found to Four Londons or between each other (distinct
      settings, casts, genres; no crossovers identified in any source
      checked).
    - **Brandon Sanderson -- Cosmere series-level gap fix, same shape as
      batch 2's Elantris fix, not a new connection judgment.** Two
      series rows never got `series.universe_id` set despite their
      book(s) already being individually Cosmere-tagged at the book
      level: "Hoid's Travails" (Yumi and the Nightmare Painter) and "The
      Mistborn Saga" (Allomancer Jak and the Pits of Eltania, confirmed
      Cosmere/Mistborn Era Two content via Coppermind/17th Shard/
      Sanderson's own official Cosmere-collections page). Both now
      linked to the existing Cosmere universe row. **Not touched**:
      "Legion" (standalone thriller, correctly unlinked) and "Secret
      Projects" (genuinely mixed -- 2 of 3 books are Cosmere, 1 isn't --
      correctly left without a series-level link, per the existing
      batch-2 note).
    - **Joe Abercrombie -- Shattered Sea vs. The Devils, confirmed NOT
      connected** (a new pairing, distinct from the already-built First
      Law World). The Devils is explicitly a new, separate series/world
      ("a magic-riddled Europe... elves"), unconnected to either
      Shattered Sea or the First Law.
    - **N.K. Jemisin -- Dreamblood vs. Forward Collection, confirmed NOT
      connected** (a new pairing, distinct from the already-checked
      Broken Earth/Inheritance Trilogy/Great Cities trio). The
      Dreamblood duology (The Killing Moon/The Shadowed Sun) is
      self-contained in its own Gujaareh setting; "Forward Collection"
      turns out to be a multi-author sci-fi novella anthology (not even
      a single-author Jemisin series) -- her contribution to it
      ("Emergency Skin") has no connection to Gujaareh.
    - **Peter F. Hamilton -- Night's Dawn, Commonwealth Saga, and
      Salvation Sequence, confirmed NOT connected.** Three explicitly
      separate fictional universes per multiple sources, each with its
      own distinct setting/timeline.
    - **Adrian Tchaikovsky -- Children of Time, Elder Race, Service
      Model, The Final Architecture, and The Tyrant Philosophers,
      confirmed NOT connected.** Each is a distinct, separate
      continuity; no shared setting or characters found across any
      pairing.
    - **Neil Gaiman -- re-surfaced by the refreshed candidate query,
      resolved without new research.** "London Below" is just this
      catalog's series name for Neverwhere -- same already-resolved
      American Gods/Neverwhere pairing (real but too thin to model, see
      above), no new action. "The Sandman TPBs" is a graphic
      novel/comic -- out of v1 scope per CLAUDE.md's catalog-scope
      policy, skipped and flagged, not linked (consistent with the
      existing Saga/Sandman precedent, not treated as a universe
      candidate at all).
    Migration `20260912500000_riordanverse_four_londons_cosmere_gaps.sql`,
    tested in a rolled-back transaction with a genuine idempotency
    re-run, applied via a normal autocommit connection (not `supabase db
    push` -- left for the primary session per this task's standard
    handoff), verified live on hosted. `universe` now has 13 rows.
  - **Naming-policy gap RESOLVED 2026-09-12 for both cases that hit
    it.** Repo owner's general policy, now established for future
    no-official-name cases: check for a real, widely-used common fan
    term first (via web search, not a single source); if a genuine one
    exists, use it even if not author/publisher-coined (same standing
    as "Enderverse" itself, which Card didn't coin either); only invent
    a name if no real fan term exists at all, and revisit later on user
    feedback if a chosen name reads wrong once seen in the app.
    - **Sarah J. Maas -- built as "Maasverse"** (A Court of Thorns and
      Roses/Throne of Glass/Crescent City). "Maasverse" confirmed as a
      genuine, widely-used fan term (fan wikis, reading-order guides,
      book blogs), not a one-off coinage -- used directly rather than
      inventing something new. Migration `20260912300000_maasverse_
      universe.sql`.
    - **Orson Scott Card's "Enderverse" naming independently confirmed
      correct** (repo owner has read Ender's Game + the first Shadow
      book, asked for verification rather than a naming decision here):
      "Enderverse" really is the umbrella term for Card's whole
      Ender-universe body of work, not just Ender's own line -- Card
      didn't coin it (originated as book-jacket copy) but it's the
      real, consistently used term regardless. Confirmed via search:
      Ender's Saga follows Ender, The Shadow Series follows Bean (the
      repo owner's own recollection, correct), both same universe. No
      separate series follows a Wiggin sibling (Valentine or Peter) --
      Peter's arc is told within The Shadow Series itself, not as its
      own series; checked live and confirmed no Formic Wars/Children of
      the Fleet sub-series exist in our catalog under Card's author
      field currently, so nothing further to link. No migration needed
      -- existing linkage from batch 3 stands, now confirmed.
  - **Confirmed NOT connected (don't re-research)**: Brandon Sanderson
    (his Skyward/Reckoners vs. his own Cosmere -- note his Cosmere
    series-level gap fix above is a different, unrelated finding for
    the SAME author), N.K. Jemisin (all 3 major series against each
    other, AND Dreamblood vs. Forward Collection -- batch 4), Ursula K.
    Le Guin, Neil Gaiman, Stephen King, Robert Jackson Bennett, Jim
    Butcher (Codex Alera/Cinder Spires/Dresden Files -- 3 distinct
    unconnected worlds), James S. A. Corey (The Captive's War/The
    Expanse -- explicitly not the same universe per the authors
    themselves, only a shared TV production team), Leigh Bardugo's
    Ninth House specifically (separate from her own Grishaverse, which
    IS connected -- see above), Timothy Zahn (Star Wars: The Thrawn
    Trilogy vs. Star Wars: Thrawn -- same protagonist but officially
    split, mutually incompatible Legends-vs-Canon continuities, not a
    true merge; flagged as a genuinely different case shape worth a
    second look if the repo owner disagrees with treating a non-merged
    reboot relationship as "not connected"), Joe Abercrombie (Shattered
    Sea vs. The Devils -- batch 4, a different pairing from the
    already-built First Law World), Peter F. Hamilton (Night's Dawn/
    Commonwealth Saga/Salvation Sequence -- batch 4), Adrian Tchaikovsky
    (Children of Time/Elder Race/Service Model/The Final Architecture/
    The Tyrant Philosophers -- batch 4), V.E. Schwab's Monsters of
    Verity and Villains specifically (separate from her own Four
    Londons, which IS connected -- see above, batch 4).
  - **Resolved, no connection, no naming question**: Mark Lawrence's
    `Impossible Times` vs. `The Library Trilogy` (checked against EACH
    OTHER specifically, 2026-09-12) -- confirmed NOT connected. Lawrence's
    own "Guide to Lawrence" post lists only Broken Empire/Red Queen's War
    and Book of the Ancestor/Book of the Ice as connected pairs; The
    Library Trilogy is explicitly "a wholly original tale... no
    connection to his other work" per a Grimdark Magazine interview.
  - **A new data-quality issue found and flagged, not fixed (needs a
    repo-owner judgment call, not a universe-linking action)**: Orson
    Scott Card's Shadow Saga (Ender's Shadow, Shadow of the Hegemon,
    Shadow Puppets, Shadow of the Giant) is split across TWO series rows
    in this catalog -- `The Shadow Series` (2 books) and `Enderverse:
    Publication Order` (2 books) -- looks like one real series
    mis-represented as two rows. Out of this audit's scope to
    restructure; both rows were linked to the new Enderverse universe so
    the book-level connection isn't lost either way, but the underlying
    series-table duplication is still there.
  - **Batch 5 (2026-09-12)**: 8 authors checked.
    - **Michael J. Sullivan -- built as "Elan."** Legends of the First
      Empire + The Riyria Revelations, same world (Elan) ~3,000 years
      apart per the author's own site ("The Elan Saga"/"World of
      Elan"); real structural link, not just shared geography --
      characters who are only historical/legendary figures in Riyria
      are met directly, in person, in Legends. Named after the real
      in-world place itself, no naming question.
    - **Cassandra Clare -- built as "The Shadowhunter Chronicles."**
      The Infernal Devices + The Mortal Instruments, explicit prequel/
      sequel (~130 years apart, same Shadowhunter/Downworlder world),
      direct named ancestor/descendant links between the casts. Named
      after the real official franchise umbrella term, not invented.
    - **T. Kingfisher -- built as "The World of the White Rat."** The
      Saint of Steel + Swordheart, explicit shared setting (Temple of
      the White Rat) with recurring characters crossing over. Named
      after the real in-world institution and matching fandom usage
      (Goodreads' own series grouping, a dedicated fan wiki). **Checked
      and confirmed NOT part of this universe**: "Sworn Soldier" (the
      What Moves the Dead novellas) -- separate cast/setting; the only
      link is a reused pronoun-by-caste linguistic concept, not a
      shared world. Left unlinked.
    - **Philip Pullman -- built as "Lyra's World." NAMING FLAG for the
      repo owner, unlike the other three built this batch.** His Dark
      Materials + The Book of Dust are genuinely connected (Pullman's
      own "equel" framing, same world, same protagonist Lyra Belacqua)
      -- the connection isn't in question, only the name. No official
      umbrella name and no single widely-used fan term turned up
      across multiple independent sources (checked "Dustverse"/
      "Pullman multiverse" specifically -- neither is actually
      established). "Lyra's World" is a real in-world term (used
      within the books to distinguish Lyra's home world from Will's
      and the multiverse's other worlds) echoed loosely by press/fan
      writeups, but it's this session's own naming call, not a
      confirmed brand the way Elan/Shadowhunter Chronicles/
      Riordanverse/Maasverse are -- please sanity-check, easy to
      rename later.
    - **Naomi Novik -- Temeraire vs. The Scholomance, confirmed NOT
      connected.** Entirely separate worlds, no crossover.
    - **Arthur C. Clarke -- Rama vs. Space Odyssey, confirmed NOT
      connected.** Clarke's own Author's Note to 2061 states the
      Odyssey books aren't "necessarily happening in the same
      universe" as each other, let alone Rama, which has no crossover
      identified anywhere.
    - **William Gibson -- Blue Ant/Jackpot/Sprawl, confirmed NOT
      connected (3 separate continuities).** No shared characters or
      setting across any pairing.
    Migration `20260912700000_shared_universe_audit_batch5.sql`,
    tested in a rolled-back transaction with a genuine idempotency
    re-run, applied via a normal autocommit connection (not `supabase
    db push` -- left for the primary session per this task's standard
    handoff), verified live on hosted. `universe` now has 17 rows.
  - **New data-quality issue found and flagged, not fixed (needs a
    repo-owner judgment call, same shape as the Card Shadow Saga note
    above)**: R. A. Salvatore's "The Dark Elf Trilogy" (1 book in
    catalog: Homeland) and "The Legend of Drizzt" (1 book in catalog:
    Exile) look like the SAME real trilogy fragmented across two
    series rows, not two genuinely separate series sharing a universe
    -- Homeland/Exile/Sojourn are canonically all 3 books of the Dark
    Elf Trilogy, itself explicitly books 1-3 of the "Legend of Drizzt"
    reading-order umbrella. Both rows also carry obviously-wrong
    `book_count` values (33 and 180) unrelated to their actual 1-book
    contents, likely the same stale data the separate
    `series.status`/`book_count` fix P2 task is already working
    through. Not linked as a universe (would misrepresent a same-
    series duplication as a two-series connection); not restructured
    either -- out of this audit's scope.
  - **Confirmed NOT connected (don't re-research), batch-5 additions**:
    Naomi Novik (Temeraire vs. The Scholomance), Arthur C. Clarke (Rama
    vs. Space Odyssey), William Gibson (Blue Ant/Jackpot/Sprawl, 3
    separate continuities).
  - **Batch 6 (2026-09-12)**: 8 authors checked, ALL confirmed NOT
    connected -- no universe built, no migration this batch (see
    project-log.md's 2026-09-12 "shared-universe audit batch 6" entry
    for full evidence per pairing). Checked: **John Scalzi** (Old Man's
    War/The Interdependency/Lock In/The Dispatcher -- 4 separate
    universes, all pairings checked; The Dispatcher's similarity to
    Lock In is thematic/structural-echo only, not a shared setting).
    **Robert A. Heinlein** (Heinlein's Juveniles vs. Stranger in a
    Strange Land -- our catalog's "Heinlein's Juveniles" row is just
    Starship Troopers, not tied to Future History at all; Stranger's
    only tie to Heinlein's wider "World As Myth" multiverse is a
    walk-on cameo reference in later, not-in-catalog novels, the same
    cameo/thematic tier already ruled insufficient for Gaiman/King).
    **C. S. Lewis** (Chronicles of Narnia vs. The Space Trilogy --
    confirmed separate worlds by multiple sources). **Douglas Adams**
    (Dirk Gently vs. The Hitchhiker's Guide to the Galaxy -- real
    Easter eggs/title reuse exist, but Adams treated them as separate,
    idea-recyclable series rather than one continuity; no
    recurring-protagonist or merged-plot link). **Michael Crichton**
    (Jurassic Park vs. The Andromeda Strain -- separate standalone
    novels, no universe link found anywhere). **Dan Simmons** (Hyperion
    Cantos vs. Ilium -- confirmed separate story-worlds). **Martha
    Wells** (Murderbot Diaries vs. "The Rising World" -- the latter is
    just Witch King in our catalog, a standalone fantasy unconnected to
    Murderbot; NOT the Books of the Raksura, which isn't part of this
    pairing). **Lois McMaster Bujold** (Vorkosigan Saga vs. World of
    the Five Gods -- confirmed separate SF/fantasy universes).
  - **Batch 7 (2026-09-12, background agent)**: 8 authors checked, 1
    confirmed connected and built, 7 confirmed NOT connected (see
    project-log.md's 2026-09-12 "shared-universe audit batch 7" entry
    for full evidence per pairing). **J.K. Rowling -- built as
    "Wizarding World"** (Harry Potter + Hogwarts Library): the
    strongest-evidence case this audit has found so far -- Hogwarts
    Library's 3 books (Fantastic Beasts and Where to Find Them,
    Quidditch Through the Ages, The Tales of Beedle the Bard) are
    presented as genuine in-universe Hogwarts texts (Dumbledore's own
    foreword calls Fantastic Beasts an "approved textbook at Hogwarts,"
    both it and Quidditch Through the Ages are referenced as books
    Hogwarts students use within the main 7-book series, and Beedle the
    Bard is the specific book Dumbledore bequeaths to Hermione in
    Deathly Hallows). Named after the real official franchise term
    (harrypotter.com's own "Wizarding World" branding), no naming
    question. Migration `20260913000000_shared_universe_audit_batch7.sql`,
    tested in a rolled-back transaction with a genuine idempotency
    re-run, applied via a normal autocommit connection (not `supabase
    db push` -- left for the primary session), verified live on hosted.
    `universe` now has 18 rows. Checked and confirmed NOT connected:
    **Amie Kaufman & Jay Kristoff** (The Aurora Cycle vs. The Illuminae
    Files -- same co-writing duo, explicitly different casts/universes
    per their own description). **Jay Kristoff solo** (Empire of the
    Vampire vs. The Nevernight Chronicle -- Kristoff's own words: "not
    tied in with my other fantasy work... a completely new thing").
    **Ilona Andrews** (Kate Daniels vs. Innkeeper Chronicles -- the
    author's own site states Innkeeper is "not part of Kate Daniels
    story"). **Neal Shusterman** (Arc of a Scythe vs. Unwind Dystology
    -- Shusterman has explicitly rejected fan theories of a shared
    "Shusterverse"). **Holly Black** (The Folk of the Air vs. The
    Charlatan Duology/Book of Night -- Book of Night is its own
    shadow-magic world, not the Faerie of Folk of the Air). **Christopher
    Paolini** (Fractalverse/To Sleep in a Sea of Stars vs. The
    Inheritance Cycle -- Paolini's own description of Fractalverse as
    his first work "outside of the Eragon universe"; real Easter eggs
    exist but are authorial in-jokes, not merged canon, same
    cameo/reference tier already ruled insufficient elsewhere).
    **Margaret Atwood** (MaddAddam vs. The Handmaid's Tale -- no
    corroborated source treats these as one universe; incompatible
    histories/settings with no shared characters).
    **Bookkeeping fix made in passing**: the top-level "Confirmed
    connected (built)" list above had never folded in batch 5's 4 new
    universes (Elan, The Shadowhunter Chronicles, The World of the
    White Rat, Lyra's World) -- added now so it stays accurate; no
    change to the underlying data, only to this summary list.
  - **Everyone else from the refreshed candidate list**: not yet
    checked. Full detail across nine 2026-09-11/2026-09-12
    project-log.md audit entries. This audit's real hit rate so far: 13
    of 47 checked candidate-author-groupings confirmed genuinely
    connected (built or gap-fixed), 32 confirmed NOT connected, 2
    flagged as series-table data-quality issues rather than true
    universe questions -- treat every remaining candidate as more
    likely a false positive than not until checked. Re-running the
    candidate query after batch 7 (57 authors with 2+ unlinked series
    before this batch ran, one fewer expected after Harry Potter's
    series drop out of the "universe_id is null" pool) is the starting
    point for batch 8; the untouched leftover pool (non-exhaustive) is
    now: Anthony Ryan, Becky Chambers, Brent Weeks, Carissa Broadbent,
    Danielle L. Jensen, James Islington, Jennifer Lynn Barnes, John
    Gwynne, Laini Taylor, Marie Lu, Marissa Meyer, Mira Grant, Octavia
    E. Butler, Rachel Gillig, Rebecca Roanhorse, Rebecca Ross, S. A.
    Chakraborty, Samantha Shannon, Stephanie Garber, Stephen Graham
    Jones, Tahereh
    Mafi, TJ Klune, Veronica Roth.

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
  engineering. **Rechecked 2026-09-12 (Mathias now at 143 ratings) --
  still empty for all 4**, see project-log.md's 2026-09-12 entry.
  Revisit once a field/user pair actually validates.
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
