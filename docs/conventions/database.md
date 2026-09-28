# Database & migrations

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*


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
