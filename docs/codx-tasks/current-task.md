# CODX current task

**Assigned**: 2026-09-26, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 23 — review a concrete "route by task class" proposal (per the structural-change review gate)

This is your own idea, from Task 21's report ("Additional ideas grounded
in this repo" section): "Route by task class. A tiny map can direct
scoring work to its protocol and engine contracts, tagging to full
vocabulary/evidence guidance and the active gap tracker, audiobook/UI
work to edition contracts and relevant skills, and infrastructure-only
work to infrastructure rules... This gives larger savings than
permanently requiring a somewhat shorter schema for every task." Your
Task 22 review of the `book-dna.md` split also explicitly said this
needs its own separate, deliberate review, not to be folded into that
split: "Defer the larger change to global reading obligations by task
class... Measure it and review it explicitly; don't smuggle it into a
relocation." This task is that separate review.

**Real context you should know**: after the `book-dna.md` split landed
(and was measured — 26/26 acceptance-test checklist items, zero
regressions), CLDO closed out `docs/TODO.md`'s tracking item and
described "route by task class" as an unscoped follow-up, without
flagging at the time that it was a genuinely unfinished piece of the
same effort. The repo owner caught this the next session and asked for
a standing rule against it — see CLAUDE.md's new "Multi-phase task
closure" section (2026-09-26) for the full incident. This task is that
follow-up now actually being picked up, not dropped.

Same posture as Tasks 21/22: review/ideation only for the tiered
question below, but see "What to actually do" -- some review-only,
some genuine can-implement-if-you're-confident territory, spelled out.

### The real, measured opportunity (verified 2026-09-26)

`CLAUDE.md` is 914 lines. Its sections split into two real categories:

**Universal (every session needs these regardless of task)**: `Persona
system`, `Cross-session destructive-action gate`, `Structural/
methodology-change review gate`, `Safety / credentials`, `Multi-phase
task closure`, `Agent/token efficiency`, `Logging`.

**Task-specific (~530 of 914 lines, ~58%) — genuinely irrelevant to
many real task types**: `Database & migrations` (294-444), `Database
backups` (445-473), `Data quality / tagging` (474-606), `Catalog scope
& series hierarchy` (607-676), `Recommendation engine` (677-755), `v1
web app` (756-826). A pure CI-infrastructure task (like your own Tasks
18-19) or a frontend-only CSS tweak currently pays the full cost of
reading migration rules, tagging evidence standards, and catalog-scope
policy that have nothing to do with the actual work.

### Two tiers, deliberately not decided yet -- this is the actual review question

**Tier 1 (proposed default, lower risk): a purely additive routing
table.** Add a new short section near the top of `CLAUDE.md` (right
after the existing always-read instructions) that's just a map: task
class -> which of CLAUDE.md's OWN sections are relevant, plus which
external files (skills, schema companions, `scoring-test-protocol.md`)
round it out. Nothing gets removed, hidden, or gated behind search --
every section stays exactly where it is, always fully readable by
anyone who wants to be thorough. This only adds a fast, explicit
shortcut for a session with a narrowly-scoped task; it doesn't change
what a maximally-careful session would already do. Candidate task
classes (not final, critique these too): tagging a batch / vocabulary
gap sweep / proposing a new scalar field / scoring-engine change /
audiobook-table or UI work / infrastructure-only (CI, workflows,
deploy) / migration-and-DB work.

**Tier 2 (bigger, NOT proposed as this session's default): actually
split CLAUDE.md** the way `book-dna.md` was split -- move the
task-specific sections into companion files, leave only a slim routing
core as the mandatory always-read. Real, structurally-similar risk to
the book-dna.md split (CLAUDE.md is referenced by `AGENTS.md`,
`docs/persona-workflow.md`, and implicitly by every skill file and every
session's own operating assumptions) -- likely MORE cross-file risk
given CLAUDE.md's centrality, not less. Per your own Task 22 finding
("never move permission boundaries, credentials restrictions,
destructive-action gates... behind optional search"), the two safety
gates and the credentials section can NEVER move out of the always-read
core regardless of which tier gets built.

### What to actually do

1. **Critique the task-specific/universal classification above.** Is
   anything mis-classified? (E.g., is `Database backups` really
   task-specific, or universal enough — "before anything genuinely
   risky" — that it should stay in core regardless?)
2. **If Tier 1 looks right, design it concretely**: propose the actual
   routing table's rows/columns, and where exactly it should live
   (CLAUDE.md itself vs. a separate small file, given the same
   "shrink routing before shrinking evidence" principle from Task 21).
   You may write this table yourself as a proposal (a diff, not applied)
   in your report -- this is squarely "implementing a proposed design
   and validating it in your own sandbox," which your existing scope
   already covers, not a bypass of "review only."
3. **Answer directly: is Tier 2 worth doing at all, and if so, when
   relative to Tier 1?** Your own words already leaned toward "measure
   Tier 1 first" -- confirm or revise that view now that you can see the
   real section sizes.
4. **Say whether `AGENTS.md`/`docs/persona-workflow.md` need equivalent
   treatment** -- they have their own "read CLAUDE.md in full" pointers;
   would a task-class map in CLAUDE.md automatically help you (CODX) and
   CLDA too, or does each persona's own entry file need its own routing
   note?
5. Don't implement Tier 2 or touch any file's actual content beyond a
   proposed diff in your report for Tier 1, if you get that far.

### Deliverable

A report at `docs/codx-reports/<date>-task-class-routing-review.md`:
your verdict on the classification, a concrete Tier 1 proposal (or a
reasoned alternative if you think this framing is wrong), your Tier 2
recommendation, and the AGENTS.md/persona-workflow.md question answered.
CLDO implements after reading this, independently re-verifying it the
same way every other CODX output gets verified before being trusted --
and will explicitly ask before moving on to anything else if a genuine
piece of this is still unfinished when this task's own conversation
turn ends, per the new "Multi-phase task closure" rule.
