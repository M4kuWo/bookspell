# Context-load measurement protocol

Written 2026-09-26, immediately after landing CODX Task 24, to answer a
direct question the repo owner asked: after this session's methodology
overhaul (the `book-dna.md` split + the task-class routing policy),
what did we actually gain? CLAUDE.md's own routing-policy section says
not to claim context savings from the table alone — "measure content
actually loaded/read in representative sessions." This doc is that
measurement, in two parts: a static baseline computed just now (Part 1,
done), and a behavioral validation still to run (Part 2, queued for the
next fresh terminal/session — this is the actual "test" the repo owner
asked to have prepared).

## Part 1 — static baseline (done, 2026-09-26)

This measures *required reading* per the routing table, not what an
agent actually reads in practice (that's Part 2). Word counts via
`wc -w`, computed directly from real files, not estimated.

**OLD baseline** — the pre-overhaul convention was "read CLAUDE.md in
full, `docs/TODO.md` in full, `docs/schema/book-dna.md` in full" every
session, regardless of task. Sourced from the `pre-book-dna-split` git
tag (the last commit before either the split or the routing table
existed):

| File | Words |
|---|---|
| `CLAUDE.md` | 7,657 |
| `docs/TODO.md` | 4,626 |
| `docs/schema/book-dna.md` (monolithic) | 19,578 |
| **Total, every session** | **31,861** |

**NEW state** — current `CLAUDE.md` section word counts (universal
sections read every time, plus the conditional sections the routing
table adds per task type):

| Section | Words | Universal? |
|---|---|---|
| Preamble | 629 | yes |
| Startup reading and task routes | 645 | yes |
| Persona system | 1,105 | yes |
| Cross-session destructive-action gate | 396 | yes |
| Structural/methodology-change review gate | 526 | yes |
| Safety / credentials | 174 | yes |
| Multi-phase task closure | 243 | yes |
| Agent/token efficiency | 104 | yes |
| Logging | 302 | yes |
| **Universal subtotal** | **4,124** | |
| Database & migrations | 1,423 | conditional |
| Database backups | 247 | conditional |
| Data quality / tagging | 1,256 | conditional |
| Catalog scope & series hierarchy | 643 | conditional |
| Recommendation engine | 626 | conditional |
| v1 web app | 574 | conditional |

Schema companions: `book-dna.md` (core, 5,395 words, read for
"substantive catalog, schema or scoring work"), `book-dna-vocabulary-gaps.md`
(3,001), `book-dna-tables.md` (1,732), `book-dna-decisions.md` (11,192,
by far the biggest single file — only read for schema-design or
decision-history work).

**Required reading by representative route** (universal CLAUDE.md +
`docs/TODO.md` [4,716 words, current] + route-specific sections +
schema files the route's table row calls for):

| Route | New total (words) | Old total | Reduction |
|---|---|---|---|
| Tagging / ingestion / confidence QA | 17,557 | 31,861 | 44.9% |
| Scoring behavior change | 15,504 | 31,861 | 51.3% |
| CI / workflows / tooling only | 8,840 | 31,861 | 72.3% |
| v1 web app, UI-only (no catalog/scoring) | 9,414 | 31,861 | 70.5% |
| New scalar field / schema design (heaviest route) | 29,375 | 31,861 | 7.8% |

**Honest reading of this table**: the routing policy is a real, large
win for narrow/bounded tasks (CI-only, UI-only, a single-field tagging
correction) — 70%+ less required reading. It is a near-non-event for
the heaviest route (proposing a new scalar field), which legitimately
needs almost everything (tagging conventions, catalog scope, the
scoring protocol, migration conventions, the schema core, AND the full
decisions history to avoid re-litigating a rejected idea) — that route
was never going to shrink much, and claiming otherwise would be the
kind of unmeasured overclaim the routing section itself warns against.
The real gain there isn't reading volume, it's that *irrelevant*
sections (`v1 web app`, `Database backups`) are no longer read on a
schema-design task, freeing roughly one section's worth of margin even
in the worst case.

Also worth flagging honestly: the 4-file schema split alone, read in
full with no routing at all, is now 34,929 words combined — *more* than
the old single 19,578-word file. The split's benefit only exists
because of the routing table sitting on top of it (reading only the
companions a given route calls for); the split by itself, without
routing, would have been a net loss. This is worth remembering if
either piece is ever changed independently of the other.

## Part 2 — behavioral validation (queued, run this in the new terminal)

Part 1 measures what the policy *asks* a session to read. It does not
prove a real fresh session actually reads only that — a session could
over-read (falling back to "read all of CLAUDE.md" out of caution) or
under-read (missing a route the table should have caught, the same
failure class the 12-scenario acceptance test already checked for
correctness rather than volume). This part measures actual behavior.

**Run this as the very first thing in the new terminal**, before doing
anything else, so the fresh-session state is genuinely untouched (no
prior tool calls, no warmed-up file cache from this same conversation).

### Method

For each of the 5 representative routes in Part 1's table, launch a
genuinely fresh, non-forked `Agent` (a new session with no inherited
context — do not fork this conversation, that would inherit everything
and defeat the point) with one of the task prompts below. Each agent's
prompt ends with an explicit instruction to self-report every file it
read and each file's word count, before doing any actual work, so the
report reflects real startup reading rather than reading spread across
the whole task.

Grade each result against Part 1's table:
- **Match**: the files/sections actually read line up with what that
  route's row prescribes (allow reading one section *more* than
  prescribed if the agent's own judgment call was defensible given
  ambiguity — note it, don't fail it outright).
- **Over-read**: read meaningfully more than the route calls for
  (e.g. read all 4 schema files for a UI-only task).
- **Under-read**: missed a section or schema file the route's own
  table row requires — this is the more serious failure, same
  category the 12-scenario correctness test already covers, but seeing
  it here would mean the routing table's reading requirements aren't
  actually being followed in practice even when the routing itself is
  right.

### Task prompts (paste one per fresh agent)

**Route 1 — Tagging/ingestion/confidence QA:**
> You're picking up a task in the Bookspell repo
> (`/Users/mathiaskurin/Documents/bookspell`). Read whatever CLAUDE.md
> and other files it points you to that this task requires, following
> its own stated policy exactly. The task: three books in the catalog
> have a `person` field you suspect may be miscategorized (first vs.
> third person) based on a reader complaint. Before touching anything,
> report back: every file you read (path) and each file's word count
> (`wc -w`), in the order you read them, with no other work done yet.

**Route 2 — Scoring behavior change:**
> Same repo. The task: a rater's negative-cluster count for
> `stakes_scope` seems to be getting diluted by unrelated agreeing
> fields in `score_book()`. Before writing any code, read whatever
> CLAUDE.md and other files it points you to that this task requires.
> Report back every file you read (path) and each file's word count,
> in order, before any other work.

**Route 3 — CI/workflows/tooling only:**
> Same repo. The task: `.github/workflows/backup-reminder.yml` needs
> its cron schedule changed from daily to every 12 hours; no other
> behavior changes. Before editing anything, read whatever CLAUDE.md
> and other files it points you to that this task requires. Report
> back every file you read (path) and each file's word count, in
> order, before any other work.

**Route 4 — v1 web app UI-only:**
> Same repo. The task: the dark-mode toggle in `app/` doesn't visibly
> change the membership badge color; no catalog or scoring behavior is
> involved. Before touching anything, read whatever CLAUDE.md and other
> files it points you to that this task requires. Report back every
> file you read (path) and each file's word count, in order, before
> any other work.

**Route 5 — New scalar field / schema design:**
> Same repo. The task: propose a new `book_dna` scalar field capturing
> whether a book's magic system is "soft" vs "hard" at a finer grain
> than the existing `magic_system_hardness` field already provides.
> Before proposing anything, read whatever CLAUDE.md and other files it
> points you to that this task requires. Report back every file you
> read (path) and each file's word count, in order, before any other
> work.

### Recording results

Sum each agent's self-reported word counts, compare to Part 1's
prescribed total for that route, and log the outcome (match/over-read/
under-read per route, with the actual numbers) as a dated
`docs/project-log.md` entry — not just in this file, per this project's
own logging convention. Update this doc's Part 2 with a "Results
(dated)" subsection once run, rather than leaving Part 2 as a
standing TODO forever.

If a route under-reads, that's a real routing-table bug (a route not
actually triggering the reading it's supposed to) and should be fixed
in CLAUDE.md directly, then re-tested. If a route over-reads
consistently, that's more likely an agent being cautious than a policy
bug — worth noting but not necessarily a fix, per the routing policy's
own "if the scope is unclear, read all of CLAUDE.md" allowance.
