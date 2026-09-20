# CODX current task

**Assigned**: 2026-09-20, by CLDO.
**Status**: ready to start. **Deliberately small** -- the repo owner
flagged you're low on budget until tomorrow's reset, so this is scoped
to fit comfortably rather than the usual depth. If you're already
running low partway through, stop and report what you have rather than
pushing to finish everything below.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 15 — a minimal CI workflow (no DB, no service containers)

`main` is at commit `4b233d2`. Confirmed via `ls .github/` — this repo
has **no CI at all**, a real gap the 2026-09-14 external-AI-consultation
review flagged (see `docs/TODO.md`'s "External AI consultation" entry,
"CI (its 12)"), rated higher priority than the review itself implied:
this project now has multiple semi-autonomous sessions (CLDA's
batches, your own reviews) pushing real changes without a live human
reviewing every one in real time.

**Deliberately scoped to need zero database/service setup** -- a full
`scripts/scoring_tests.py` run in CI (spinning up local Supabase,
applying every migration, seeding data) is real, valuable future work,
but far too much for this budget window. This task is the cheap,
high-value slice: catch the two mistake classes this project has
actually, repeatedly hit by hand.

### What to build

One new file, `.github/workflows/ci.yml`, running on every push and
pull request to `main`. Three checks, each a separate step (so a
failure names exactly which check failed, not just "CI failed"):

1. **Python syntax check** across `scripts/` and `api/` -- every
   `.py` file must at least parse. `python3 -m py_compile` per file,
   or `python3 -m compileall -q scripts api` (check which gives
   clearer failure output in Actions' log and pick that one -- your
   call, just say which and why in your report).
2. **JS syntax check** across every `app/*.html` file's inline
   `<script>` block -- reuse the exact technique this session has
   already used repeatedly for the same purpose (extract the
   `<script>...</script>` block right before `</body>` with a regex,
   run it through `new Function(...)` under Node, per file). Write
   this as a small standalone Node script (e.g.
   `.github/scripts/check-inline-js.cjs`) the workflow calls, not an
   inline shell one-liner -- keeps it readable and testable on its own.
3. **Duplicate migration timestamp check** -- the exact command
   CLAUDE.md's "Database & migrations" section already documents for
   this by hand: `ls supabase/migrations/ | sort | uniq -c -w14 | awk
   '$1>1'`. Fail the step (nonzero exit) if that command's output is
   non-empty. Note the ONE known pre-existing collision from this
   project's real history (`20260911110000` -- a `.sql` and a `.tsv`
   sharing a timestamp prefix, real and harmless since Supabase only
   tracks `.sql` files) -- confirm your check doesn't false-positive on
   it (it shouldn't, since both files start with the same 14 characters
   and the count-based check would still flag it as `count > 1`
   regardless of extension -- decide whether to special-case this one
   known-safe pair or accept it as an expected/documented false
   positive, and say which you chose and why).

Use a pinned Python version (3.11 or 3.12 -- check what this repo's
own scripts assume, if anything pins one already) and Node version
(check `package.json`/existing CI-adjacent config, or default to a
recent LTS) via `actions/setup-python`/`actions/setup-node`. Install
only what's needed for the syntax checks themselves (no `pip install
-r api/requirements.txt` needed -- `py_compile`/`compileall` don't
execute the code, just parse it, so FastAPI/psycopg2 etc. don't need
to be importable for this).

### What NOT to build (out of scope for this task specifically)

- No `scripts/scoring_tests.py` run, no local Supabase spin-up, no
  Postgres service container -- real, valuable future work, explicitly
  NOT this task.
- No linting (flake8/eslint/etc.) -- this project has no established
  lint config, and picking one is a real style decision, not a
  mechanical CI-scaffolding task.
- No auto-fix/auto-format step.
- No branch-protection-rule change (requiring this check to pass
  before merge) -- that's the repo owner's own GitHub settings, not
  something a workflow file itself does.

### Validation bar

- Confirm the workflow file itself is valid YAML and matches GitHub
  Actions' schema (a syntax check on the YAML, plus reasoning through
  the job/step structure by hand since you can't actually trigger a
  real Actions run from your own clone).
- Actually run all three checks LOCALLY against the current repo state
  first, by hand, before trusting the workflow file would pass -- the
  Python/JS syntax checks should both pass clean (nothing here should
  be broken today), and the duplicate-timestamp check should report
  exactly the one known `20260911110000` case and nothing else.
- Deliberately break something small in your own clone (introduce a
  real Python syntax error in a throwaway copy of one file, or a real
  JS syntax error in a throwaway copy of one `app/*.html`, or a
  throwaway duplicate migration timestamp) and confirm each check's
  logic actually catches it when run by hand -- don't just trust that
  a check "should" fail without seeing it fail once.

### Deliverable

A report at `docs/codx-reports/<date>-ci-workflow.md` with the new
file's full contents, your reasoning on the two judgment calls above
(compileall vs py_compile; how you handled the known `20260911110000`
pair), and the by-hand validation evidence per the bar above. Proposal
only, as always -- implement and validate in your own clone,
uncommitted, no commit/push.
