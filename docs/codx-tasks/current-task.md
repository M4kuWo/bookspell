# CODX current task

**Status**: nothing actively assigned right now — Task 10 (round 2 of
the confidence QA pass) landed 2026-09-17 (see `docs/project-log.md`'s
"CODX's Task 10 (round 2) landed" entry and `docs/TODO.md`'s P2
"Recurring HIGH_RISK_FIELDS confidence QA pass" entry). 3 more tag
corrections and 6 more confidence increases applied, all independently
re-verified against primary sources before landing.

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

- **Round 3 of the recurring HIGH_RISK_FIELDS confidence QA pass** —
  125 rows remain below 0.6 catalog-wide as of 2026-09-17; the next
  batch of 15-20 would be pulled fresh from a live query, not reused
  from prior rounds.
- Phase B of the `recommend.py` refactor (extracting into
  `scripts/scoring/` submodules) per `docs/TODO.md`'s plan.
- Something else entirely, at CLDO's discretion.
