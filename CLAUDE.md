# Working conventions for this repo

**If you're a sub-agent (launched by another Claude Code session),
read `CLAUDE.md` from disk once before acting — don't rely on the copy
in your system prompt.** That copy is a snapshot from when the parent
session started, and has been confirmed stale repeatedly (12/12 test
sub-agents on 2026-09-26) when this file changed during the parent's
session. Comparing headings or `wc -w` against the snapshot is not a
freshness check — an in-place wording edit passes both (demonstrated in
CODX Task 25). The task-specific rules in `docs/conventions/` are never
injected, so they are always read fresh; this re-read only concerns this
(deliberately short) file. **A top-level session** loads this file from
disk at startup and can use that copy — unless the file changes during
the session (you edited it, or a `git pull`/merge touched it), in which
case re-read it from disk before the next step that depends on it.

Read the startup policy below before doing anything else in this project.
It exists because
this project has been worked on from multiple machines and Claude
accounts, and a few real mistakes have already happened from one session
not knowing what another had already established. This file is the fix.

Read `docs/TODO.md` before non-trivial work and before choosing a task.
Read `docs/schema/book-dna.md` and its companions when required by
"Startup reading and task routes" below. Do not re-litigate decisions
already recorded in the applicable references.

For `docs/project-log.md` (the running, append-only history — tens of
thousands of lines and growing): **read the 3 most recent complete
entries** (each running from one dated `## ` heading to the next),
**capped at 1,500 words total.** If reading a complete entry would push
past that cap, stop there — read that entry's heading only, and say so,
rather than reading it partially (a half-read entry is worse than not
reading it at all, since a caveat or reversal near the end can change
what the first half implied). This gives orientation on what just
happened, not proof that all relevant history was reviewed. For
anything specific — a past decision, a rejected idea, an incident tied
to a file you're about to touch — search for it directly (`grep`/`rg`
for the term, a book title, a table/function name) rather than reading
further back linearly; a targeted search finds the exact entry, a
longer linear read just spends more tokens without more certainty of
finding it. (Adopted 2026-09-25, replacing a "read the tail" instruction
with no defined bound, which made the actual amount read vary
arbitrarily session to session — see `docs/project-log.md`'s 2026-09-25
"CODX Task 21 landed" entry and
`docs/codx-reports/2026-09-25-context-load-review.md` for the full
reasoning. The exact 3-entry/1,500-word figures are a starting budget
CODX proposed, not a measured optimum — revisit if it turns out too
tight or too loose in practice.)

**Also check `.claude/skills/` for anything relevant to a table/feature
you're about to build on, before you build on it.** Real,
already-happened example (2026-09-13): the v1 app's book-info modal was
built to show audiobook data, but `audiobook_editions` (a real,
1000+-row table with narrators/cast/production data) was never checked
for — it exists specifically because `.claude/skills/
tag-audiobook-editions/SKILL.md` had been populating it in a separate
effort, and that skill file (plus the current contract it points to in
`docs/schema/book-dna-tables.md`) would have surfaced this immediately.
A table existing with no docs/schema/ entry of its own and no mention
in CLAUDE.md is not evidence it's unused — check the skills directory,
not just the two doc files above, before assuming a feature starts from
nothing.

**If you're going to use or verify anything against local Postgres this
session, run `python3 scripts/check_db_sync.py` first.** Local silently
falling behind hosted's real data (not a tracking-table issue — the
actual rows) has recurred three times in three days; see
`docs/conventions/database.md` for the full incident history and why this
is no longer safe to assume away.

## Startup reading and task routes

Always read this preamble and routing policy, plus these complete
sections: Persona system; Cross-session destructive-action gate;
Structural/methodology-change review gate; Safety / credentials;
Multi-phase task closure; Agent/token efficiency; Logging. Persona
scope and authorization rules apply to every route. Routing grants no
write, commit, push or deployment permission.

Select routes from the actual behavior, data and operations involved,
not just filenames or the task's label. Read every matching convention
file in full and the external prerequisites below before acting.
Combine routes for mixed work; reroute before expanding scope. If the
scope is unclear, read all six `docs/conventions/` files and the schema
core. Search may locate a required section, but does not replace reading
its caveats.

The six task-specific sections below the table are forwarding pointers
to ordinary Markdown files in `docs/conventions/` (moved there 2026-09-28
so they stop being auto-loaded into every session). Read the linked file
in full for every matching route before acting. Do not auto-import those
files (`@` imports) or move them into an automatically loaded rules
directory — that would recreate the full-load cost this move removed.
The old section headings remain as valid entry points, not substitutes
for their targets.
Explicit assignment prerequisites and applicable skill steps still apply.

Before any DB access, schema/policy change or database configuration
operation, take the database route, including for a new UI table read.
Before genuinely risky persistent-data work or a restore, also read
Database backups. Before proposing any new scalar field, even one
noticed during another task, read the schema core's scalar-field gate
and the scoring protocol. Keep the local-Postgres sync check above.

For substantive catalog, schema or scoring work, read the schema core
in full and use its Schema map for companions. Pure infrastructure or
presentation-only work may omit it until its scope crosses that boundary.
Keep the TODO, bounded history, persona task-selection and skill-discovery
requirements above. This policy changes required reading, not the
applicability of any convention; every section, including the ones
moved to `docs/conventions/`, still applies.

| Trigger / task | Additional convention files (see map below) | External prerequisites |
|---|---|---|
| Tagging, ingestion, metadata corrections or confidence QA | Data quality / tagging; Catalog scope & series hierarchy; database route if accessing DB | Schema core; exact YAML vocabulary; applicable tagging skill; gap tracker before tagging; relevant table/confidence contract |
| Vocabulary-gap sweep or new trope/content-warning proposal | Data quality / tagging; Catalog scope & series hierarchy; database route if accessing DB | Schema core and full YAML; vocabulary-gap tracker; decisions/rejections; gap-sweep skill when running a sweep |
| New scalar field or schema design | Data quality / tagging; Catalog scope & series hierarchy; Recommendation engine; Database & migrations | Schema core including scalar-field gate; YAML; relevant decisions/table contracts; scoring-test-protocol.md; affected skills |
| Scoring behavior, scoring refactor or designing/changing tests that assert scoring semantics | Recommendation engine; Catalog scope & series hierarchy; database route if accessing DB | Schema core; scoring-test-protocol.md with its existing pre-change gate; applicable contracts and prior decisions |
| Audiobook data or an edition display | v1 web app for UI/API work; Data quality / tagging; Catalog scope & series hierarchy; database route if accessing DB | Schema core; book-dna-tables.md edition contract; tag-audiobook-editions skill; Tier A/B guidance as applicable |
| Frontend, API, auth/config or deployment | v1 web app; add catalog/data/scoring/database routes when those behaviors are involved | Relevant feature contracts and skills; schema core for catalog/scoring behavior, not isolated CSS |
| DB access, migration, schema, grants/RLS, restore or DB configuration | Database & migrations; Database backups for backup/restore or risky persistent-data work; other domain routes as applicable | Relevant schema/table contracts and migration history; persona-specific authorized connection method |
| CI/workflows/dependencies/tooling only | None beyond universal unless changing domain behavior or performing DB/deployment/backup operations; backup jobs add Database backups | Actual workflow/tool configuration; add engine route for scoring fixtures, web route for deployment, DB route for DB jobs |
| Documentation/process review | Sections governing the proposed change; structural-review gate remains universal | Referenced contracts, skills and decisions; no exemption merely because the patch is Markdown |

Convention file map: Database & migrations → `docs/conventions/database.md`;
Database backups → `backups.md`; Data quality / tagging → `tagging.md`;
Catalog scope & series hierarchy → `catalog.md`; Recommendation engine →
`scoring.md`; v1 web app → `web.md` (all in `docs/conventions/`).
External schema names above live in `docs/schema/`; the scoring protocol
is `docs/scoring-test-protocol.md`; skills live in `.claude/skills/`.
Briefly record the routes used and any later scope expansion in the work
report. Do not claim context savings solely from this table: measure
content actually loaded/read in representative sessions.

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

This doesn't relax any of the existing safety rules (in
`docs/conventions/database.md` and Safety / credentials below: dependent-row
checks, no blanket UPDATE/DELETE, rolled-back-transaction testing,
CLAUDE Code's own destructive-action classifier) — it's an additional
human-in-the-loop-via-CLDO checkpoint on top of those, specifically for
the cross-session case where CLDA's environment may have a thinner
safety net than usual (e.g. a sandbox with no working local Supabase
stack to dry-run against, discovered 2026-09-09).

## Structural/methodology-change review gate

Before implementing a "big" change — structural rather than routine,
and specifically one whose risk is hard to fully self-verify because it
depends on cross-file effects or blind spots in the proposing session's
own reasoning — get an independent review from CODX (or another
impartial reviewer) BEFORE implementing, not as an afterthought once
something's already landed.

**Real, already-happened example (2026-09-25)**: CLDO proposed splitting
`docs/schema/book-dna.md` into a "core" (always-read) file and a
"backlog" (read-only-when-relevant) file, to address a real, measured
fresh-session context-load problem (CLAUDE.md + `docs/TODO.md` +
`book-dna.md`, all read in full every session, totaled 40k+ tokens
before any task-specific work began). The proposal was sent to CODX for
review BEFORE being implemented. CODX's review found the split was
genuinely broken, not just suboptimal: `.claude/skills/
tag-catalog-batch/SKILL.md`'s mandatory pre-tagging check, and the
already-shipped `audiobook_editions` table's real design rationale,
both live inside the exact section ("Future fields backlog") the
proposal would have demoted to "read only when relevant" — which would
have broken a mandatory tagging step and recreated a discoverability
incident this project already has a documented postmortem for (see the
"new public-catalog-style table" rule in
`docs/conventions/database.md`). CLDO's own review before sending to CODX had not
caught this. See `docs/project-log.md`'s 2026-09-25 "CODX Task 21
landed" entry for the full story, including everything CODX
independently verified before it was trusted. (This example is itself
historical — the split it describes was subsequently implemented as a
4-file structure, `book-dna.md` + `book-dna-vocabulary-gaps.md` +
`book-dna-tables.md` + `book-dna-decisions.md`, per a follow-up review
in `docs/codx-reports/2026-09-25-book-dna-split-review.md`; this
paragraph is left describing the incident as it happened, not rewritten
to match the final layout.)

**What counts as "big" for this gate** — a judgment call, not an
exhaustive list, but concrete anchors:
- Any change to CLAUDE.md itself.
- Restructuring, splitting, or moving a document that other files
  (skills, AGENTS.md, other docs) reference or depend on.
- A new or changed convention/process every session/persona is expected
  to follow (e.g. how `project-log.md` is read, how tasks are handed
  off).
- Anything the person requesting it explicitly flags as risky or
  foundational.

**What does NOT need this gate** — this project already has its own
domain-specific review requirements; don't duplicate or weaken them by
routing everything through this new one instead. Scoring-engine changes
go through `docs/scoring-test-protocol.md`'s Q1-Q10 gate and the
two-failure-scenario check. Destructive DB actions go through the
Cross-session destructive-action gate above. Ordinary code/data/schema
work with a well-defined, bounded scope doesn't need a separate review
pass just because it's real work — see "Agent/token efficiency"
below's "for a small, well-defined fix, just do it directly," which
still applies.

The review itself should be a genuine ask, not a formality: describe
the actual problem with real data/evidence (not just the proposed
solution), state the proposal plainly, and explicitly invite the
reviewer to find flaws or propose their own alternative — not "does
this look okay," which invites a rubber stamp. Whoever receives the
review back must independently re-verify its concrete claims before
trusting them (same standing discipline as reviewing any other CODX
output — see the Persona system section above), not just accept "no
issues found" or apply proposed corrections blindly.

## Database & migrations

Moved to [`docs/conventions/database.md`](docs/conventions/database.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

## Database backups

Moved to [`docs/conventions/backups.md`](docs/conventions/backups.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

## Data quality / tagging

Moved to [`docs/conventions/tagging.md`](docs/conventions/tagging.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

## Catalog scope & series hierarchy

Moved to [`docs/conventions/catalog.md`](docs/conventions/catalog.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

## Recommendation engine (`scripts/recommend.py`)

Moved to [`docs/conventions/scoring.md`](docs/conventions/scoring.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

## v1 web app (`app/`, `api/`)

Moved to [`docs/conventions/web.md`](docs/conventions/web.md)
(2026-09-28). **Required in full whenever the routing table above
routes you here** — it is not auto-loaded, so read the file.

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

## Multi-phase task closure

Don't let one piece of a multi-phase effort quietly drop while the rest
gets marked done. Real, already-happened example (2026-09-25/26): CODX's
Task 21 review proposed three things together (a bounded project-log
read window, the `book-dna.md` split, and "route by task class"). The
first two were implemented and `docs/TODO.md`'s item was marked `[x]`
"both steps done," with the third noted only as "a real, unscoped
follow-up" inside the log entry. When the repo owner asked "what's
next" the following session, it got presented as one candidate task
among several unrelated options — not as "we still have a piece of the
thing we just closed left to do." The repo owner caught this and asked
for it not to recur.

**The fix**: before treating a multi-phase effort as closed, or before
moving on to something else while one is still genuinely open, say so
explicitly — something like "we still have X left from this effort,
are you sure you want to move on before finishing it?" — rather than
silently deferring it and letting it drift into looking like a fresh,
unrelated idea later. This doesn't mean a piece can never be shelved —
a real reason (token/time budget, a genuine external blocker, an
explicit call from the repo owner to deprioritize) is legitimate — but
that has to be a stated, explicit decision made in the moment, not
something that just happens by omission and gets rediscovered later.

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
  `docs/schema/book-dna-decisions.md`'s "Deferred / open proposals"
  section instead — **not** `book-dna.md` itself, which is the always-
  read core file (as of 2026-09-25's split) and must stay small; a new
  deferred idea logged there instead of in the decisions file recreates
  the exact bloat problem the split was meant to fix.
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
