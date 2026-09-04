# Working conventions for this repo

Read this before doing anything else in this project. It exists because
this project has been worked on from multiple machines and Claude
accounts, and a few real mistakes have already happened from one session
not knowing what another had already established. This file is the fix.

Also read the tail of `docs/project-log.md` (the running history) and
`docs/schema/book-dna.md` (the schema, including its "Future fields
backlog" of deferred ideas) before making non-trivial changes — don't
re-litigate decisions already made there.

## Database & migrations

- **Every schema or data change is a versioned file in
  `supabase/migrations/`, timestamp-prefixed** (`YYYYMMDDHHMMSS_description.sql`),
  never a one-off change applied and left untracked. If you changed
  hosted data and there's no corresponding migration file, that's a bug
  to fix, not a shortcut you get to take.
- **Apply to BOTH local and hosted, and verify they match afterward**
  (row counts on the affected tables at minimum). Don't assume a change
  applied to one side also happened on the other.
- **Local**: `supabase db query --file` rejects multi-statement files.
  For anything beyond a single INSERT, apply via a raw Python script:
  ```python
  import psycopg2
  conn = psycopg2.connect('postgresql://postgres:postgres@127.0.0.1:54322/postgres')
  conn.autocommit = True
  conn.cursor().execute(open('supabase/migrations/<file>.sql').read())
  ```
- **Hosted**: use `supabase db push` (handles multi-statement files
  fine, and updates hosted's own migration-tracking table correctly —
  this matters, see next point).
- **Never apply a hosted-bound migration via a raw direct Postgres
  connection instead of `supabase db push`.** If you do (or inherit a
  situation where someone else did), hosted's migration-tracking table
  won't know that file was applied, and the next `supabase db push` will
  try to re-run it — which fails loudly if it contains a non-idempotent
  statement (e.g. `CREATE POLICY` with no existence guard). Real,
  already-happened example: a Claude Code session on a different
  machine tagged books directly against hosted's Postgres connection,
  and a later `db push` from another machine tried to redo all of it.
  **The fix is `supabase migration repair --status applied --linked
  <version...>`** (marks the version as applied without re-executing
  it) — never force through the resulting error, never skip/bypass it.
  **Before repairing, confirm the data actually matches on both sides**
  (row counts on the affected tables, or spot-check one specific row) —
  repair only records that a version is applied, it doesn't apply
  anything, so repairing a version whose data ISN'T really on hosted
  yet just hides a real gap instead of fixing it. This has recurred
  more than once (not a one-off), so check for it routinely via
  `supabase migration list --linked` (entries with a `local` timestamp
  but no matching `remote` one), not just when something breaks loudly.
- **Write idempotent SQL**: `insert ... on conflict do nothing` for
  inserts, so a migration can be safely reapplied without duplicating
  data if something goes wrong partway through.
- **Before pushing, check for duplicate migration timestamps** —
  `ls supabase/migrations/ | sort | uniq -c -w14 | awk '$1>1'` (or just
  eyeball it after a merge). Real, already-happened example: two
  sessions working the same calendar day each independently wrote a
  migration timestamped `20260904020000` (one a single-book retag, one
  a batch audit) — a plain filename collision, caught during a `git
  merge` conflict on `docs/project-log.md`. Supabase's migration
  tracking table keys on the numeric timestamp prefix, not the full
  filename, so pushing both as-is would have had the second one either
  error or (worse) silently no-op against an already-recorded version.
  Fixed by renaming the not-yet-pushed-to-hosted one to a free
  timestamp before running `supabase db push` — safe to rename freely
  as long as `supabase migration list --linked` shows it has no
  `remote` entry yet; never rename one that's already applied to
  hosted. Two people (or two Claude sessions) working the same day
  makes this collision more likely, not less — check for it as routine
  merge hygiene, not just when a push errors.
- **Reference books via a title subselect, never a raw UUID**:
  `select id from books where title = '...'` — local and hosted (and
  anyone else's clone) have different row UUIDs for the same logical
  book. A migration with a hardcoded UUID only works in the one database
  it was copied from.
- **Never a blanket UPDATE/DELETE with no row-scoping WHERE clause**
  against the hosted database — Claude Code's own safety classifier
  will actually block this, and it's correct to. If you need a
  catalog-wide change, generate individually-scoped statements (one per
  row/book), not one unscoped statement.
- **Before deleting anything, check for dependent rows in other tables
  first** (e.g. a book's `book_dna`/`book_tropes`/`book_content_warnings`/
  `book_field_confidence` rows) — don't assume "should be empty," verify it.

## Data quality / tagging

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
  it deleted — see "catalog scope" below).
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
  `humor_level` (see `HIGH_RISK_FIELDS` in `scripts/recommend.py`, and
  this list is expected to keep growing) — deserve a quick check
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

## Catalog scope & series hierarchy

- v1 scope is **sci-fi/fantasy only**. Hardcover's genre search
  sometimes pulls in off-genre books; these get left untagged and
  flagged, then deleted from `books` entirely once confirmed
  out-of-scope with the repo owner (don't leave them as permanent
  dangling untagged rows once that's confirmed).
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

## Recommendation engine (`scripts/recommend.py`)

- **Read `docs/scoring-test-protocol.md` before changing any scoring
  logic** (`build_profile`, `score_book`, `explain_book`, or anything
  that computes a weight). It has a running table of every idea tried
  so far — landed, rejected, and deferred — and why. Several ideas that
  looked like clear wins under an incomplete test turned out not to be;
  don't re-litigate a rejected idea, or claim a win, without checking
  that table first.
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
  looked completely invisible under the flawed test. **Verify with
  `import scripts.recommend as R; import scripts.scoring_tests as T; R
  is T.R` (should be `True`) before trusting any monkeypatch-based A/B
  result against `scoring_tests.py`** — or avoid the whole class of bug
  by editing `scoring_tests.py`'s own `_full_score()` directly to call
  the experimental variant, the way the series-trajectory-penalty
  experiment (tested successfully) did it.

## Safety / credentials

- **Never commit the hosted database password/connection string**, or
  paste it into chat. Share it out-of-band (a message, a password
  manager) between the humans involved.
- If a second person is working from **the same directory** as the repo
  owner (not a separate clone), don't have them edit the shared `.env`
  to point at a different database — that risks a silent collision if
  both people are working at the same time. Use an exported shell
  variable scoped to their own terminal session instead
  (`export DATABASE_URL=...`), which takes precedence without touching
  the shared file.
- Test example SQL/code in a rolled-back transaction before trusting it
  enough to put in a skill, doc, or migration — "it looks right" isn't
  the same as "it actually runs against the real schema." This caught 3
  real bugs in the `tag-catalog-batch` skill before it was ever used for
  real (a required column silently omitted from an example, a
  content-warning ID that doesn't exist, and a NOT NULL column that
  would have failed every insert).

## Agent/token efficiency

- For large batch work (tagging many books, checking a trope across the
  whole catalog), use **non-forked background agents**, each with the
  DB connection string and any needed definitions given inline in the
  prompt — don't have every agent re-read the schema files from scratch,
  and don't fork from a long conversation (forked agents inherit the
  whole parent context, which costs far more per agent for this kind of
  work).
- For a small, well-defined fix (one book, one field), just do it
  directly — spawning an agent for a single trivial change costs more in
  fixed overhead than it saves.

## Logging

- Every real change (schema, data, engine logic, a design decision) gets
  a dated entry in `docs/project-log.md` — append-only, never rewritten
  after the fact. Deferred ideas and schema-specific backlog items go in
  `docs/schema/book-dna.md`'s "Future fields backlog" instead.
- Migration file comments should explain **why**, not just restate what
  the SQL does.
