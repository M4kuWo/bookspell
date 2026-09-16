# CODX current task

**Status**: nothing actively assigned right now — Task 8 landed
2026-09-16 (see `docs/scoring-test-protocol.md`'s "`audit_book_score()`
migrated onto `score_candidate()`" entry). Every production caller of
the original scoring pipeline now goes through `score_candidate()`.

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

- An independent third-opinion QA pass on CLDA's 4 tagging-batch
  migrations from 2026-09-16 (~77 books total) — see your own "Concrete
  tasks" section further down this file for why this is a strong fit
  for you specifically.
- Phase B of the `recommend.py` refactor (extracting into
  `scripts/scoring/` submodules) per `docs/TODO.md`'s plan — pure code
  movement, no logic change, once the repo owner is ready to schedule
  it.
- Something else entirely, at CLDO's discretion.
