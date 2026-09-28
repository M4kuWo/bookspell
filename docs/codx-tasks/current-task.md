# CODX current task

**Assigned**: 2026-09-28, by CLDO.
**Status**: ready to start.
**Baseline**: sync to the commit that added this file (`git log -1 -- docs/codx-tasks/current-task.md`).

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-context-load-improvements.md` in your own
clone as always.

---

## Task 25 — find further ways to cut fresh-session context load, using the Part 2 measurement

This task continues your own Task 21 (bounded log read, `book-dna.md`
split) and Task 23 (task-class routing) reviews. Your posture is
review/propose only, as always. This task **is** the independent review
that CLAUDE.md's structural/methodology-change gate requires before any
of the proposals below can be implemented. So give a real review: find
the flaws, reject whatever doesn't hold up, and propose alternatives.
Don't rubber-stamp.

### Where things stand (read these first; don't re-derive them)

- `docs/context-load-measurement-protocol.md` — all of it, especially
  Part 2's **"Results (2026-09-26)"** subsection. That is the evidence
  base for this task.
- `docs/project-log.md`'s 2026-09-26 entry "Context-load measurement
  Part 2 run: no route under-reads, Part 1's totals corrected" (the
  summary).
- For history, `docs/codx-reports/2026-09-25-context-load-review.md` (your
  Task 21 report) and the project-log's 2026-09-26 "CODX Task 23 landed"
  entry.

**Already settled; don't re-litigate:**
- The routing table routes correctly: 43/43 on the 12-scenario test,
  and 5/5 fresh agents picked the right route with no under-reads.
- Both safety gates stay universal.
- The 4-file `book-dna` split stays.

**What the measurement actually found** (CLDO's summary; verify it
before building on it):

1. **Real gains are smaller than first claimed for heavy routes.** The
   narrow routes (CI, UI) are ~53% below the old 31,861-word baseline.
   Tagging is roughly a third lower. Scoring is ~24% lower, not the 51%
   Part 1 claimed, because Part 1 omitted `docs/scoring-test-protocol.md`
   (30,830 words, required by both old and new conventions). Schema design
   is roughly break-even.
2. **Section routing inside CLAUDE.md saves ~0 on *loading*.** Claude
   Code auto-injects all of CLAUDE.md (8,893 words) into every session
   and sub-agent's system prompt, regardless of which sections the
   routing says to "read". The honest floor for any route is ~14.85k
   words: full CLAUDE.md + `docs/TODO.md` (4,871) + the bounded log
   (~1.1k). Every real saving so far comes from external files a route
   lets a session skip.
3. **The stale-snapshot warning in CLAUDE.md's preamble caused
   duplicate loading.** One of 5 agents obeyed it by re-reading all of
   CLAUDE.md from disk, putting ~8.9k words in context twice. The other 4
   compared `grep '^## '` and `wc -w` against the snapshot, then re-read
   only the sections they used. But that cheap check can't catch an
   in-place wording edit, and the staleness problem is real (12/12 test
   agents saw it on 2026-09-26).
4. **Read depth for very large reference files is unspecified.** Two
   scalar-field-style sessions could plausibly differ by ~25k words. One
   agent read `scoring-test-protocol.md` in full (30.8k). Another read
   ~3.3k of it (the 10-question gate, the scenarios, the "What's been
   tried" table, one relevant section) and read `book-dna-decisions.md`
   (11.2k) by grep plus the Rejected section only. Both were defensible,
   but the rules don't say which is right.
5. **`docs/TODO.md` is read in full every session, and half of it is
   closed work.** Of 4,871 words, ~2,437 are in 30 `- [x]` done items and
   ~1,801 are in 18 open items.

### What to actually do

Propose concrete improvements, ranked by words saved × confidence that
nothing required gets lost. At minimum, give a verdict on each of these
candidate levers. You're free to add others, and to reject any of these:

- **A. Tier 2: move conditional content out of the auto-loaded
  CLAUDE.md** (e.g. into `docs/conventions/*.md` files the routing table
  points to). This was deferred on 2026-09-26 on your own advice: "measure
  Tier 1's real effect first." Finding 2 is now that measurement.
  - Decide whether it justifies Tier 2, and in what shape.
  - Which sections could safely move, and which must stay auto-loaded?
    Consider the safety gates, persona rules, and anything a session
    needs *before* it knows its route.
  - Grep every file that references each candidate section (skills,
    `AGENTS.md`, `docs/persona-workflow.md`, other docs), so the move
    doesn't recreate the discoverability failure CLAUDE.md's
    structural-review gate example describes.
- **B. The stale-snapshot check** (finding 3): design a check that is
  both cheap and actually catches in-place edits. For example, a content
  hash / `git log -1 --format=%H -- CLAUDE.md` compared against something
  the snapshot carries, or a version line at the top of the file that
  every edit must bump. Say whether each option is enforceable or just
  hopeful. Note: if A shrinks CLAUDE.md a lot, B's cost shrinks with it.
  Treat them together.
- **C. Read-depth guidance** for `scoring-test-protocol.md`,
  `book-dna-decisions.md`, `book-dna.schema.yaml` and
  `tag-catalog-batch/SKILL.md` (finding 4). Say which parts are
  mandatory in full, per route, and which are targeted lookups. Consider
  whether `scoring-test-protocol.md` needs a short always-read front
  section (the gate and scenarios are ~2k words) with the 28k-word dated
  history marked as search-don't-read. Check what CLAUDE.md's
  Recommendation engine section and the schema core's scalar-field gate
  step 4 literally require before proposing to relax either.
- **D. `docs/TODO.md` done items** (finding 5): consider moving closed
  items to an archive file, or collapsing each to one line. Check what
  (if anything) relies on done items being in TODO.md, including the
  multi-phase-closure rule, which uses TODO.md to notice an unfinished
  phase.
- **E. The measurement method itself.** It used one run per route,
  self-reported word counts, and agents that knew they were being
  measured (a likely Hawthorne effect). Propose a better re-test that
  CLDO can run after changes land (e.g. parsing sub-agent transcripts for
  the actual Read/Bash calls instead of trusting self-reports). You can't
  launch Claude Code agents yourself, so specify it for CLDO to execute.

For every proposal you recommend:
- give real `wc -w` numbers for the before/after words saved, per route;
- name the specific requirement or incident-driven rule that could be
  lost or made less discoverable, and how the proposal prevents that;
- list the files that would need to change;
- say whether it depends on or conflicts with another proposal.

### What NOT to do

- Don't edit CLAUDE.md, AGENTS.md, TODO.md, the protocol doc or any
  skill. You can include proposed diffs or text in your report, and that
  is encouraged.
- Don't run `scripts/scoring_tests.py`. It's not relevant here, and it's
  CLDO's territory.
- Don't treat any lever above as pre-approved just because it's listed.
  "Don't do X" is a valid verdict.

### Deliverable

A report at `docs/codx-reports/<date>-context-load-improvements.md`
containing:
- a verdict on the findings above (flag any you couldn't reproduce);
- a verdict on each of A–E plus anything you add, ranked;
- proposed text or diffs for anything you recommend;
- a re-test spec for CLDO.

CLDO re-verifies every claim, brings the recommendations to the repo
owner, and implements whatever is agreed, then re-runs the behavioral
measurement to confirm.
