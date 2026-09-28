# CODX current task

**Assigned**: 2026-09-28, by CLDO.
**Status**: ready to start.
**Baseline**: sync to the commit that added this file (`git log -1 -- docs/codx-tasks/current-task.md`).

Report to `docs/codx-reports/<date>-read-cost-without-relaxing.md` in your own
clone, as always. Review/propose only.

---

## Task 26 — make C's full-read requirements cheaper *without relaxing them*

Your Task 25 levers A, C and D all landed on 2026-09-28 and were measured
before/after from sub-agent transcripts. Read these first:
- `docs/context-load-measurement-protocol.md` Part 3 (the table, confounds,
  interpretation);
- `docs/codx-reviews/context-load-e/` (prompts, pre-registered checklists,
  raw per-event counts in `e-before-results.json` / `e-after-results.json`);
- `scripts/measure_context_load.py` (the counter).

**Result.** Quality was 7/7 in both arms. Narrow routes got 11–26% cheaper.
Heavy routes got 19–104% costlier, because C's explicit "full" rules made
agents read what their routes require:
- the scalar-field agent read the full YAML (691 → 12,918 words) and the full
  tagging skill (0 → 5,567);
- the scoring agent read the schema core (0 → 6,444), which it had skipped
  before.

**The repo owner's decision: do not relax these requirements.** The
compliance is wanted. Your job is to make compliance cheaper, so the same
required information reaches the session with fewer delivered words.

### Constraints (settled; don't re-litigate)
- Every "full" requirement in C stays a requirement to *see all the
  information* it covers. A proposal may change the **form** that
  information takes (split, deduplicated, generated index, reordering),
  not the **obligation**.
- No lossy summaries standing in for authoritative text. A generated
  artifact must be mechanically derived from the source, with a CI or
  script check that it can't drift.
- A, B, C and D stay as landed. Both safety gates and the persona rules
  stay universal.
- The `pre-conventions-split` tag and the after-arm raw data are the
  baseline for measurements.

### Candidate levers (verdict each; add your own; "don't" is valid)
1. **YAML.** It's 11,239 words. Is a lot of it comments or evidence prose that
   duplicates `book-dna.md` or the decisions file? Could a generated compact
   vocabulary (IDs + allowed values + one-line definitions + distinctions),
   produced from the YAML by a script and CI-checked, satisfy "check whether
   the concept is already represented", while the complete per-entry text
   stays required for the touched definitions? Quantify the cost and what
   would be lost.
2. **`tag-catalog-batch/SKILL.md`** (~8k words). You found 1,481 words of
   DONE/reference sections in Task 25, and noted that Step 0 reuses their
   calibration method. Can the reference material move to a companion file
   without breaking that dependency? What must a batch invocation still read?
3. **Duplication between the schema core, the YAML and the conventions
   files.** Measure genuine overlap (the same rule or value definition stated
   in several places). Propose single-source-of-truth moves only where every
   route still reaches the text.
4. **Project-log bounded read.** It rose on some routes (up to ~4.9k words
   for R2, which read extra history per the Reading contract). Check whether
   that's the contract working as intended or a sign the contract should
   point at the protocol's own entries first.
5. **TODO reads dropped to ~0** for R2, R3 and T2 after D. Determine from
   the raw events whether that's a real under-read of the universal "read
   TODO before non-trivial work" rule, or an artifact of how the counter
   attributes combined commands. If it's real, propose a fix that keeps D's
   saving.
6. **Counter accuracy.** `per_source` attributes a combined Bash command to
   the first path it mentions, and persisted-output files show up as
   `tool-results/...`. Propose (as a diff) better attribution, e.g.
   splitting `sed`/`cat` segments, or mapping persisted outputs back to their
   originating call.

### For every recommendation
- give before/after `wc -w` per route, using the same 7 prompts;
- state what information could be lost or made harder to find, and the
  mechanical check that prevents it;
- list the files that would change, with a proposed diff where practical.

Also give a re-test spec CLDO can run. Use the same 7 prompts, but **keep
prompts and checklists outside the repo until every arm has run**: after-arm
agents found them in `docs/codx-reviews/context-load-e/` and read the
checklist. Launch the re-test from a fresh session, so sub-agents don't
inherit a stale CLAUDE.md injection.

### What NOT to do
Don't edit tracked files, run `scripts/scoring_tests.py`, or touch any DB.
Proposals only.
