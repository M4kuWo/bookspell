# CODX current task

**Status**: nothing actively assigned right now — Task 13 (independent
review of the two recommendation-engine speed fixes) landed 2026-09-19
(see `docs/codx-reviews/codx-recommendation-engine-review-2026-09-19.md`
for the reviewed report, and `docs/project-log.md`'s matching entry for
CLDO's independent verification + what was applied from it).

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

- **The partial-failure-isolation fix your Task 13 report proposed but
  didn't implement** (`/recommendations/all` failing all 3 genres when
  only one throws) -- needs a repo-owner-level product decision on the
  response-shape/error-contract first (your report's proposed envelope
  is the leading candidate), then likely handed back to you to
  implement once that's settled, given how precisely you already
  scoped it.
- Round 3 of the paused HIGH_RISK_FIELDS confidence QA pass -- see
  `docs/TODO.md`'s P3 entry for why it's paused (token-budget
  reasons, not because it stopped being worth doing).
- Something else entirely, at CLDO's discretion.
