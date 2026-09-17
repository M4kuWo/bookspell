# CODX current task

**Status**: nothing actively assigned right now — Task 11 (Phase B
step 1: split `scripts/recommend.py` into `scripts/scoring/`
submodules) landed 2026-09-17 (see `docs/scoring-test-protocol.md`'s
"Phase B step 1" entry and `docs/TODO.md`'s Phase A/B plan). All 68
functions moved with byte-identical source/AST, all 5 real consumers
confirmed working, independently re-verified before applying.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands.

**If you're reading this because you were just told to sync and start
your next task: there isn't one queued yet.** Don't self-select one of
the candidates below — which one (if any) comes next is CLDO's/the
repo owner's call, not yours to pick. Say so and stop; the repo owner
will either queue a real task here or tell you directly what to do.

Candidates CLDO is considering for the next task (not yet decided,
listed for context only):

- **Phase B, B4** — updating the 2 real consumers
  (`api/main.py`, `scripts/scoring_tests.py`) to import from
  `scripts/scoring/` directly and dropping the compatibility shim. A
  separate, purely cosmetic follow-up to Task 11, not urgent.
- **Round 3 of the paused HIGH_RISK_FIELDS confidence QA pass** — see
  `docs/TODO.md`'s P3 entry for why it's paused (token-budget
  reasons, not because it stopped being worth doing).
- Something else entirely, at CLDO's discretion.
