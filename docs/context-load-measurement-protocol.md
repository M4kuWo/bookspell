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

> **Correction (2026-09-26, from Part 2):** these totals leave out
> external files the routing rows require, most importantly
> `scoring-test-protocol.md` (30,830 words) for the scoring and
> scalar-field routes. Correcting for it, the scoring route's reduction is
> ~24%, not 51.3%. See Part 2's Results section for the corrected
> figures. The table above is left as originally computed.

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

## Part 2 — behavioral validation (run 2026-09-26 — see Results below)

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

### Results (2026-09-26, run by CLDO in a fresh terminal)

Run as the first action of a new session. There were 5 non-forked `general-purpose`
agents, launched concurrently, each given its route's prompt above. Two
adaptations: (a) "Same repo." was replaced with the full repo path,
because a fresh agent has no "same" to refer back to. (b) Each prompt got a short
reporting addendum: list which CLAUDE.md sections were relied on vs.
skimmed, say whether CLAUDE.md came from the system prompt or disk, give
approximate words for partial reads, and do no DB access or task work.
All numbers below are the agents' own self-reports, cross-checked
against `wc -w` of the named files.

**Headline: no route under-read. No routing-table bug was found, and
CLAUDE.md was not changed.** Every agent picked the correct route
(Route 3 also added Database backups, a defensible call per the table's
"backup jobs add Database backups" clause, since the task touches the
backup-reminder workflow). Every agent read or targeted every file its
row requires. The real findings are about Part 1's accounting, not the
routing.

| Route | Agent's actual read | Part 1 prescribed | Corrected prescription (see below) | Grade |
|---|---|---|---|---|
| 1 Tagging/correction | ~20,650 | 17,557 | ~18,800 + relevant YAML/contract/skill slices | **Match** |
| 2 Scoring change | ~44,900 disk + ~3,950 universal from prompt copy | 15,504 | ~47,580 | **Match** |
| 3 CI/tooling | ~15,300 | 8,840 | ~10,330 (incl. Database backups) | **Over-read (mild)**, cause below |
| 4 UI-only | ~10,720 | 9,414 | ~10,660 | **Match** |
| 5 New scalar field | ~19,000 disk + CLAUDE.md from prompt (~28,000 effective) | 29,375 | not a single number: "relevant" slices of 4 large files | **Match**, with a depth note |

**Part 1 was incomplete. Its totals are not a faithful rendering of the
routing rows.** It counted only CLAUDE.md sections, TODO.md, and the
`docs/schema/*.md` files. It left out things the rows explicitly list:
- `docs/scoring-test-protocol.md` (30,830 words), required by the scoring
  row, the scalar-field row, the Recommendation engine section, and
  step 4 of the schema core's scalar-field gate. This is the biggest error:
  Route 2's real prescription is ~3x Part 1's figure.
- `book-dna.schema.yaml` (11,239), the applicable skill
  (`tag-catalog-batch`, 7,949), and `book-dna-tables.md` (1,732) for the
  tagging and scalar-field rows. The rows say "exact YAML vocabulary" /
  "relevant table contract" / "affected skills", and agents correctly read
  the relevant slices (a few hundred words each), not whole files.
- The bounded project-log read (~1,093 words today, cap 1,500), which every
  route requires.
- TODO.md drift: 4,716 → 4,868 since Part 1 was computed.

In the other direction, Part 1 counted `book-dna-decisions.md` in full
(11,192) for Route 5. The row only says "relevant decisions", and the
schema core says to read it to check for a prior rejection.

**Corrected old-vs-new for the scoring route.** The old
(`pre-book-dna-split`) CLAUDE.md already required
`scoring-test-protocol.md` before any scoring change (its line 660,
30,803 words at that tag), so the protocol belongs on both sides. Old
≈ 31,861 + 30,803 = 62,664. New ≈ 47,580. That is a **~24% reduction,
not the 51.3% Part 1 claimed.** The narrow-route figures (CI, UI) hold
up well against real behavior. Route 4's actual read landed within ~60
words of the corrected prescription.

**Structural confound: CLAUDE.md is always fully in context.** Claude
Code auto-injects the whole of CLAUDE.md (8,893 words) into every
session's and sub-agent's system prompt. Section-level routing therefore
reduces what a session *relies on and re-reads*, not what is *loaded*.
The real context floor for any route is 8,893 (not 4,124) + TODO + the
bounded log ≈ 14,850 words. The genuine loading savings come entirely
from external files the routing lets a session skip (the schema
companions, the scoring protocol, the YAML). Measured against the old
31,861, the narrow routes are still ~53% lower on that honest basis.

**Why Route 3 over-read.** It re-read all of CLAUDE.md from disk because of
the preamble's stale-snapshot warning ("`grep`/`Read` it directly from
disk"), so ~8.9k words were in context twice. The other 4 agents
handled the same warning more cheaply: they compared `grep '^## '`
headings and/or `wc -w` against the snapshot, then re-read only the
sections they relied on. The stale-snapshot problem is real
(12/12 earlier), so the cheap check is only safe if it would actually
catch staleness. Headings plus word count would catch an added or removed
section, but not an in-place wording edit. **Not changed.** Tightening that
preamble is a CLAUDE.md change, so it needs the structural-review gate. It is
not an under-read fix. Queued as a proposal in `docs/TODO.md`.

**Depth ambiguity for large reference files (Route 5 note).** Route 2 read
`scoring-test-protocol.md` in full (correct: "read before changing any
scoring logic"). Route 5 read ~3,300 of its words: the 10-question gate,
the two scenarios, the "What's been tried" table, and the "would validation
detect a new field" section. Route 5 also read `book-dna-decisions.md` by
grep plus the Rejected/superseded section, not the full chronology the
schema core suggests ("read it before proposing a new value"). Both are
defensible for a scalar-field proposal, since the task stops at gate step 1
anyway. But the rows don't say how deep to read, so two sessions on
different scalar-field tasks could reasonably differ by ~25k words. This is
not graded as an under-read because nothing required was skipped. It is
flagged for the same structural-review proposal.

**Route 1 note.** It skipped `book-dna-vocabulary-gaps.md`. The row says
"gap tracker before tagging", and the task was a single-scalar correction
that adds no vocabulary. Defensible, and not graded as an under-read.
