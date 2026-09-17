# CODX current task

**Status**: nothing actively assigned right now — Task 9 landed
2026-09-17 (see `docs/project-log.md`'s "CODX's Task 9 QA pass landed"
entry, and `docs/TODO.md`'s P2 "Recurring HIGH_RISK_FIELDS confidence
QA pass" entry). 3 tag corrections and 8 confidence increases applied,
all independently re-verified against primary sources before landing.

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

- **Round 2 of the recurring HIGH_RISK_FIELDS confidence QA pass**
  (established after Task 9's success) — 85 rows remain below 0.6
  catalog-wide as of 2026-09-17; the next batch of 15-20 would be
  pulled fresh from a live query, not reused from Task 9's list.
- Phase B of the `recommend.py` refactor (extracting into
  `scripts/scoring/` submodules) per `docs/TODO.md`'s plan.
- Something else entirely, at CLDO's discretion.
