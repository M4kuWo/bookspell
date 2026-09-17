# CODX current task

**Status**: nothing actively assigned right now — Task 12 (Phase B
step 2 / B4: drop the `scripts/recommend.py` shim) landed 2026-09-17
(see `docs/scoring-test-protocol.md`'s "Phase B step 2 (B4)" entry).
**Phase B is now fully complete (B1-B4)** — the real scoring engine
lives entirely under `scripts/scoring/`, and every real consumer
imports from it directly.

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

- **Round 3 of the paused HIGH_RISK_FIELDS confidence QA pass** — see
  `docs/TODO.md`'s P3 entry for why it's paused (token-budget
  reasons, not because it stopped being worth doing).
- A CLAUDE.md fix applying your Task 12 proposal for the now-stale
  monkeypatch A/B-testing guidance — likely CLDO's own edit, not a new
  CODX task, but mentioned here for completeness.
- Something else entirely, at CLDO's discretion.
