# Working conventions for this repo

Read this before doing anything else in this project. It exists because
this project has been worked on from multiple machines and Claude
accounts, and a few real mistakes have already happened from one session
not knowing what another had already established. This file is the fix.

Also read the tail of `docs/project-log.md` (the running history),
`docs/schema/book-dna.md` (the schema, including its "Future fields
backlog" of deferred ideas), and `docs/TODO.md` (the prioritized,
cross-cutting task backlog — mutable, not append-only) before making
non-trivial changes — don't re-litigate decisions already made there,
and check `docs/TODO.md` before picking your own next task.

**Also check `.claude/skills/` for anything relevant to a table/feature
you're about to build on, before you build on it.** Real,
already-happened example (2026-09-13): the v1 app's book-info modal was
built to show audiobook data, but `audiobook_editions` (a real,
1000+-row table with narrators/cast/production data) was never checked
for — it exists specifically because `.claude/skills/
tag-audiobook-editions/SKILL.md` had been populating it in a separate
effort, and that skill file (plus the design-rationale entry it points
to in `docs/schema/book-dna.md`) would have surfaced this immediately.
A table existing with no docs/schema/ entry of its own and no mention
in CLAUDE.md is not evidence it's unused — check the skills directory,
not just the two doc files above, before assuming a feature starts from
nothing.

**If you're going to use or verify anything against local Postgres this
session, run `python3 scripts/check_db_sync.py` first.** Local silently
falling behind hosted's real data (not a tracking-table issue — the
actual rows) has recurred three times in three days; see the "Database
& migrations" section below for the full incident history and why this
is no longer safe to assume away.

## Persona system

Three named, standing personas exist for this project (CLDO/CLDA added
2026-09-10, CODX added 2026-09-13), one per machine/environment/tool
this repo runs from. **This section is about who each persona is and
what it's trusted to do — for the mechanics of how a task actually gets
from one persona to another (trigger phrases, where each one reads its
next task from, where its output lands, who reviews it), see
`docs/persona-workflow.md`, the single source of truth for that. Don't
re-derive or re-explain those mechanics here or anywhere else — a
session already got this wrong once (2026-09-16) by generalizing
CODX's copy-paste-a-prompt handoff to CLDA, who has never worked that
way.**

- **CLDO** — the primary session, worked directly with the repo owner.
  Owns `scripts/recommend.py`/`scripts/scoring_tests.py` (all
  scoring-engine changes happen here, never delegated — see the
  `convert-romance-worldbuilding-fields` skill's explicit scope
  boundary for why), repo-wide coordination (syncing the other
  machine's work, repairing hosted's migration tracking), and reviews
  requests in `docs/PENDING_APPROVALS.md`.
- **CLDA** — the tagging/data session, runs the batch skills
  (`tag-catalog-batch`, `tag-audiobook-editions`,
  `convert-romance-worldbuilding-fields`'s schema+backfill half).
  Requests approval per the gate below before anything destructive that
  isn't already spelled out step-by-step in the skill it's following.
- **CODX** — Codex CLI (a different model/tool entirely, via the repo
  owner's ChatGPT Plus subscription — a genuinely separate token/budget
  pool from Claude usage, additive capacity rather than divided
  capacity; see `docs/TODO.md`'s original CODX entry for the full
  reasoning). Reads `AGENTS.md` at the repo root (its own tool's
  convention file, the same role CLAUDE.md plays for Claude Code) —
  that file points back here for every shared convention rather than
  duplicating any of it. **Starts in review/propose-only scope, on
  purpose, the same way CLDA had to earn broader trust before being
  handed batch-tagging work**: no direct hosted-DB access and no
  unsupervised commits AT ALL yet, not even non-destructive ones — see
  `AGENTS.md` for its current concrete task list (independent code
  review of `scripts/recommend.py`/tool scripts, auditing deferred
  experimental functions, a third-opinion QA pass on CLDA's migrations,
  mechanical/scriptable work) and what's deliberately NOT handed to it
  (Book DNA tagging, scoring-algorithm design). Every finding or change
  CODX produces is a proposal (a review comment, a diff, a suggested
  migration file) for CLDO or the repo owner to actually apply — not
  something it applies itself. **"Applies itself" specifically means
  landing something in the shared repo or hosted DB (a commit, a push,
  a hosted write) — it does NOT mean CODX must hand-write an unrun diff
  and never execute it** (clarified 2026-09-16, after the repo owner
  asked directly whether this distinction held): implementing a
  proposed scoring-engine change and actually running it — editing
  `scripts/recommend.py` in its own clone, uncommitted, and running
  `scripts/scoring_tests.py` against it via its read-only role — is
  real verification work squarely in scope, since none of that touches
  a hosted write or a commit/push. The design judgment for WHAT the
  change should be still comes from CLDO (a scoring-engine change is
  never delegated in that sense), but CODX implementing and validating
  a CLDO-specified design, in its own sandbox, uncommitted, is
  execution of a proposal, not a bypass of "never delegated." This is a
  starting posture, not a permanent one: revisit once it's built a real
  track record, the same way CLDA's own scope grew over time.

  **Runs from its own real clone, `~/Documents/bookspell-codex` (set up
  2026-09-13), never inside the repo owner's own `~/Documents/bookspell`
  or a subdirectory of it.** That clone's real safeguard against an
  accidental push is a `pre-push` git hook that unconditionally blocks
  before any auth is even attempted — **not** a `git config
  credential.helper`/`core.askPass` override, which was the first thing
  tried and, confirmed by actually testing it live, does NOT work: an
  inherited `GIT_ASKPASS` environment variable (in this case, VS Code's
  own git integration, present in the same terminal session) supplies
  push credentials through a separate channel that overrides both of
  those settings regardless of what's configured in the repo itself.
  Being in a different folder under the same login isn't sufficient on
  its own either, for the same reason. **Setup for a new CODX clone
  (this machine or any other) is one command**, `bash
  scripts/setup-codx-clone.sh [target-dir]`, run from any existing
  checkout — the hook itself lives as a tracked file at
  `.githooks/pre-push`, wired in via `git config core.hooksPath
  .githooks`, so it travels with the repo and can't drift or need
  manual recreation the way a plain `.git/hooks/` file would. See
  `AGENTS.md`'s "Your environment" section for the exact mechanics, why
  the two config-based attempts failed (verified directly, including
  one real test push that landed on `main` and was cleanly reverted the
  same session — see `docs/project-log.md`'s 2026-09-13 entries), and
  why the hook is the one approach that's actually reliable regardless
  of environment.
  Reads hosted
  Supabase data via the same public anon key `app/shared.js` already
  ships client-side (real, RLS-enforced read-only — verified its write
  policies are all `authenticated`-only, not just assumed) rather than
  the `supabase db query --linked` CLI method CLDO uses, which is
  full-access and NOT safe to hand it. For running the real
  `scripts/scoring_tests.py` suite specifically (needs a direct
  Postgres connection the anon key can't provide), it instead has a
  genuinely read-only Postgres role, `codx_readonly` (added
  2026-09-15) — `SELECT`-only on exactly the 5 tables
  `load_catalog()` needs, verified directly (a real `UPDATE`/a
  `SELECT` on a user-data table both fail with permission denied), no
  access to any user-data table at all. Its connection string lives
  only in CODX's own gitignored `.env`, never in a tracked file. See
  `AGENTS.md`'s "Your environment"/"Reading hosted Supabase data"/
  "Running the real scoring test suite"/"Handing off your work"
  sections for the full mechanics, including the local-testing
  limitation (this repo's own not-yet-bootstrapped local Supabase gap)
  and how its output actually reaches CLDO with no push access.

**Which one are you?** Check for `.claude/PERSONA.local` in the repo
root (a plain local file, deliberately gitignored — see `.gitignore`'s
comment on it — so each machine keeps its own value and one machine's
sync never overwrites the other's identity). If it exists, its content
is your persona for this entire session, regardless of which terminal
or how many times the conversation has been cleared — adopt it
silently, don't re-ask. If it doesn't exist yet, this is a new
environment: ask the user which persona applies, then write their
answer to that file (just the bare word, `CLDO`/`CLDA`/`CODX`) so
future sessions on this same machine never have to ask again. (CODX
specifically: if you're Codex CLI reading this via `AGENTS.md`, your
persona is simply `CODX` — no need to check `.claude/PERSONA.local` at
all, since that file's whole purpose is disambiguating between CLDO and
CLDA on a shared Claude Code setup, a question that doesn't apply to a
different tool entirely.)

## Cross-session destructive-action gate

**CLDA must stop and request approval in `docs/PENDING_APPROVALS.md`
before any destructive or irreversible action that isn't already
written out, step-by-step, in a skill file it's currently following.**
This is narrower than it sounds: a skill's own pre-specified,
already-tested steps (e.g. `convert-romance-worldbuilding-fields`'s
Step 4 deletes) do NOT need a fresh ask each time — those already went
through review when the skill was written. What needs a fresh ask is
anything CLDA improvises beyond that: an unexpected DELETE/DROP/
TRUNCATE, a fix for a problem the skill didn't anticipate, rolling back
a prior migration, or any other irreversible move that's genuinely a
judgment call in the moment, not a pre-written instruction.

**CODX's gate is stricter, per its review-only starting scope above:
request approval before ANY hosted-DB write or unsupervised commit at
all, not just destructive ones** — even a real, correct, non-destructive
INSERT/UPDATE it's confident in still goes into
`docs/PENDING_APPROVALS.md` (or is simply handed back as a proposed
migration file/diff for CLDO to apply) rather than applied directly.
This isn't a comment on trust so much as sequencing: CLDA earned
broader write access by being right repeatedly on bounded, reviewed
work first, and CODX hasn't had that track record built yet. Read-only
research, review, and proposing changes (in a report, a diff, a draft
migration file the repo owner or CLDO then applies) need no approval at
all — this gate is specifically about CODX itself executing a write
against hosted or pushing a commit, not about the work of finding
something worth changing.

There is no live channel between the two sessions/machines — this is a
file-based, asynchronous gate, not a real-time one. When CLDA hits this
situation: stop (don't execute the action, don't decide it's "probably
fine" and proceed anyway), add an entry to `docs/PENDING_APPROVALS.md`
describing exactly what and why, and tell the user directly so they
know to bring it to CLDO. CLDO checks that file for open requests at
the start of every repo sync and answers there.

This doesn't relax any of the existing safety rules below (dependent-row
checks, no blanket UPDATE/DELETE, rolled-back-transaction testing,
CLAUDE Code's own destructive-action classifier) — it's an additional
human-in-the-loop-via-CLDO checkpoint on top of those, specifically for
the cross-session case where CLDA's environment may have a thinner
safety net than usual (e.g. a sandbox with no working local Supabase
stack to dry-run against, discovered 2026-09-09).

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
- **A separate, equally recurring drift: local Postgres's actual DATA
  falling behind hosted's, even when every migration file is correctly
  tracked on both sides.** Different failure mode than the one above —
  this isn't about hosted's tracking table, it's about a migration that
  landed on hosted (correctly) never actually being executed against
  local Postgres. `git pull` only fetches the migration FILE; nothing
  runs it against local. This recurred three times in three days
  (2026-09-13, then twice on 2026-09-17 — see `docs/project-log.md`'s
  entries) before the root cause was found: `tag-catalog-batch/SKILL.md`
  used to tell whoever ran it that local Postgres would "pick it up
  next time [the repo owner] re-syncs," which is false and left nobody
  actually responsible for the local-apply step. **It is now CLDO's
  explicit responsibility, every sync, not an assumption**: run `python3
  scripts/check_db_sync.py` (compares row counts on the tables tagging
  touches most between local and hosted) at the start of any session
  that will do non-trivial work, and always right after a tagging batch
  lands. It's a heuristic, not a real tracking mechanism — a pure-UPDATE
  migration with no net row-count change won't be caught by it, so a
  MISMATCH is trustworthy but a clean pass isn't an absolute guarantee.
  If it reports a mismatch, find the specific migration file(s) or rows
  responsible (diff per-table or per-book counts, not just the totals)
  and apply them locally via the documented raw-psycopg2 method before
  trusting any local-only query result.
- **Write idempotent SQL**: `insert ... on conflict do nothing` for
  inserts, so a migration can be safely reapplied without duplicating
  data if something goes wrong partway through.
- **Escape an apostrophe in a string literal with a doubled quote
  (`'Lyra''s World'`), never Postgres's `E'...'` backslash-escape
  syntax (`E'Lyra\'s World'`).** Real, already-happened example
  (2026-09-12): an `E''`-escaped name applied fine via a direct
  psycopg2 connection (which uses the simple query protocol) but broke
  `supabase db push` outright — its migration runner uses prepared
  statements and mis-split the file at that escape, erroring
  "cannot insert multiple commands into a prepared statement." Caught
  before it caused a tracking-table desync (data was already correct on
  hosted from the direct-apply test step; only the file needed fixing),
  but the same order of operations without that direct-apply check
  first would have looked like `db push` silently failing on a
  perfectly valid piece of data.
- **A title-scoped `where title = '...'` migration must match the
  EXACT characters stored in the database, including which apostrophe
  it is** — some titles use a Unicode curly quote (’, U+2019), not a
  plain straight one ('), and these are different bytes to a SQL string
  literal. Real, already-happened example (2026-09-13): hand-retyping a
  script-generated migration introduced a wrong-apostrophe-type bug in 2
  of 40 titles (`A Wizard's Guide to Defensive Baking`, `The Handmaid's
  Tale`), which wouldn't have errored — the subselect would have just
  silently matched zero rows, a no-op `UPDATE` with no warning. Caught
  by diffing the hand-typed file against the already-tested
  generator-script output before applying, not by the migration failing.
  **Generate title-scoped SQL programmatically from the real stored
  title string (a Python script writing the file) rather than hand-
  transcribing a title you read off a query result** — this class of
  bug is invisible to a rolled-back-transaction test too, since a
  no-op UPDATE "succeeds" just as cleanly as a real one; only comparing
  row counts before/after (or diffing against source data) would catch
  it.
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
- **A new public-catalog-style table needs RLS enabled + a permissive
  read policy + an explicit grant to BOTH `anon` and `authenticated`, in
  the same migration that creates it** — don't leave "wire it into
  something that reads it" for later, because a table with none of this
  looks *silently identical to an empty table* from any client's
  perspective (no error, just zero rows), which is indistinguishable
  from a real data gap. Real, already-happened example (2026-09-13):
  `audiobook_editions` (created 2026-09-05, populated to 1000+ rows by
  `.claude/skills/tag-audiobook-editions/SKILL.md`) had RLS disabled
  and no grant to either role at all. The v1 app's book-info modal was
  built against it and would have silently shown "no data" for every
  book — indistinguishable from the real, separate Tier-B tagging gap
  it was built to explain — had the grants not been checked before
  shipping. Compounding the same bug: the follow-up fix granted only
  `authenticated` (matching the app's login flow) and initially missed
  `anon`, breaking a *different* consumer (`tools/catalog-review`, which
  queries as `anon` with no login) that had been silently broken for the
  same underlying reason. **Check `books`/`book_dna`'s existing grants
  as the reference pattern** (`select grantee, table_name from
  information_schema.role_table_grants where table_name = '...' and
  privilege_type = 'SELECT'`) and match both roles, not just whichever
  one the specific feature you're building happens to use.

## Database backups

Supabase's own automatic backups/PITR are a paid-tier feature this
project doesn't use (checked 2026-09-11: `pitr_enabled: false`, empty
backup list on the free tier). A separate repo,
[`bookspell-backups`](https://github.com/M4kuWo/bookspell-backups)
(cloned locally as a sibling to this repo, e.g.
`../bookspell-backups`), holds periodic manual snapshots instead — see
its own README for the exact `supabase db dump` commands and restore
notes. **Deliberately a separate repo, not a `db_backups/` folder in
this one** — a real backup was lost once already (2026-09-05) because
it only ever lived on one local disk and nothing forced it to be
pushed anywhere; a second repo makes "did this get committed and
pushed" the only thing that matters, same discipline as every other
change in this project.

No fixed cadence yet — take a new snapshot whenever a meaningful
amount of new data has landed or before anything genuinely risky, and
note it in this repo's `docs/project-log.md` (not just in the backups
repo) so it's discoverable from either side.

## Data quality / tagging

- **A `book_dna` schema change (new/removed/changed column) is not done
  until `docs/schema/book-dna.schema.yaml`, `docs/schema/book-dna.md`,
  AND `.claude/skills/tag-catalog-batch/SKILL.md` (its mandatory-column
  list, example INSERT, and any field-specific tagging guidance) are all
  updated in the same session as the migration** — not left for someone
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
  `docs/schema/book-dna.md`'s Future fields backlog. The 3 existing
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

## Catalog scope & series hierarchy

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
  case (`docs/schema/book-dna.md`'s "omnibus/compilation editions"
  future-fields entry — one edition of the same book represented
  twice), not the same problem wearing a different face.

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

## v1 web app (`app/`, `api/`)

Static multi-page frontend (no build step, `supabase-js` from a CDN
`<script>` tag) on GitHub Pages, talking directly to hosted Supabase
(Auth + RLS-scoped tables) plus a small FastAPI backend (`api/`,
deployed to Render) for the actual `recommend()`/`explain_match()`
calls. See `~/.claude/plans/jaunty-chasing-eclipse.md` (or its
successor if superseded) for the original build plan.

- **`supabase config push` pushes the ENTIRE local `config.toml` to
  hosted, not just the section you meant to change.** Real,
  already-happened example (2026-09-13): pushing a `site_url`/
  `additional_redirect_urls` change also silently flipped hosted's
  `enable_confirmations`/`otp_length`/`max_frequency`/MFA settings to
  this file's stock local-dev defaults (email confirmation off, an
  effectively unthrottled 1-second email rate limit) for the few
  minutes between two pushes, until the diff `config push` itself
  prints was actually read and the values restored. **Always read
  the diff `config push` prints before/after** — don't just run it and
  move on — and expect this any time `config.toml` has drifted from
  hosted's real values for reasons unrelated to what you're changing.
- **An element toggled via the `hidden` IDL/content attribute must not
  have its `display` property set unconditionally in CSS** — an author
  stylesheet declaration always overrides the browser's own
  `[hidden] { display: none }` default for the same property, REGARDLESS
  of specificity (origin beats specificity in the cascade), so
  `el.hidden = true` silently does nothing if some rule elsewhere sets
  `display` on that element without excluding the hidden state. Real,
  already-happened example (2026-09-13): the book-info modal's
  `.modal-overlay { display: flex }` meant its close button visibly did
  nothing — the modal was already permanently "on," just usually
  unnoticed because `overlay.hidden` started `true` before the element
  was ever inserted. Fix: scope the rule to `:not([hidden])`
  (`.modal-overlay:not([hidden]) { display: flex; ... }`), never set
  `display` on a hideable element outside that guard.
- **Dark/light theming uses CSS custom-property tokens, not selector
  overrides** (`shared.css`'s `--paper`/`--ink`/`--accent`/etc., plus
  the `--gold`/`--gold-bg`/`--gold-border` set added 2026-09-13) —
  define every themed value as a token in the bare `:root` block, redefine
  the SAME tokens inside `@media (prefers-color-scheme: dark)` (guarded
  `:root:not([data-theme="light"])`) and again under
  `:root[data-theme="dark"]`, and have components reference `var(--x)`
  only. **Never write a component-specific dark-mode override directly
  on a class selector outside those two blocks** — caught myself about
  to do exactly that while building the gold membership badge (a
  `:root:not([data-theme="light"]) .membership-badge {...}` rule placed
  OUTSIDE the `@media` block, which would have applied the dark color to
  every viewer by default regardless of their actual theme, since almost
  every root element matches `:not([data-theme="light"])` unless the
  user explicitly chose light) — fixed before it shipped by switching to
  the token pattern instead.
- **`audiobook_editions`** (real per-edition narrator/cast/production
  data, distinct from `book_dna`'s own Tier B "listening quality"
  fields, which remain genuinely untagged catalog-wide) is populated by
  `.claude/skills/tag-audiobook-editions/SKILL.md`, with its full design
  rationale in `docs/schema/book-dna.md`'s "Future fields backlog"
  entry — read both before touching this table. `edition_type` values:
  `standard`, `dramatized_full_cast`, `abridged`, `audio_original`,
  `other`. `narrators` is a flat name array (no character-role
  mapping — a known, documented future gap, not a bug). A known,
  flagged-not-fixed data-quality issue: some GraphicAudio full-cast
  productions are mislabeled `edition_type = 'standard'` in the current
  data (see `docs/TODO.md`) — don't treat `edition_type` as fully
  reliable without cross-checking narrator count/production company
  for genuinely ambiguous-looking rows.

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
- **A `docs/TODO.md` item is a short pointer, never a second copy of the
  narrative.** When work on an item finishes (or a session makes real
  progress on it), write the real story — what happened, why, what was
  verified — as a dated `docs/project-log.md` entry as normal, then go
  back to the TODO.md item and update it to a line or two: current
  status, and `see docs/project-log.md's <date> "<title>" entry for
  detail`. Don't leave the full account sitting in TODO.md too. This
  was already the stated design (TODO.md is meant to be forward-looking
  and scannable, project-log.md is the append-only history) but wasn't
  spelled out as a rule, and it drifted badly as a result — real,
  already-happened example (2026-09-22): a single P0 item (the v1 web
  app) had accumulated 370 lines of inline "UPDATE" narrative across
  many sessions, duplicating what was already fully recorded in
  project-log.md, making the file too long to skim for its actual
  purpose (deciding what to work on next). Not just a CLDA habit — CLDO
  sessions did this too. Fixed with a full TODO.md rewrite the same
  day; keep it from recurring by applying this rule every time you
  touch an item, not just during the next cleanup pass.
