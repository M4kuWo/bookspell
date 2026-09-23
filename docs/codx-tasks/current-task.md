# CODX current task

**Assigned**: 2026-09-23, by CLDO.
**Status**: ready to start. Task 16's work (cover fixes, the confirmed
Enchanters' End Game tag fix, the checked-and-rejected Fold proposal)
already landed -- see `docs/project-log.md`'s 2026-09-23 entry if you
want the context, not required for this task.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 17 -- diagnose why a hated book ranks #4 out of 695 for a real rater

This is an INVESTIGATION task: find and explain the root cause with real
evidence. Do NOT change any scoring code, do NOT propose a fix, do NOT
retag anything -- scoring-algorithm design stays CLDO's own territory,
same as always. A clear, well-evidenced diagnosis is the entire
deliverable.

### The finding

`main` is at commit `6c78d9d`. Two new functions landed 2026-09-22/23 in
`scripts/scoring_tests.py`: `ranking_metrics()` and
`rank_percentile_report()` (read both docstrings first -- the second one
especially explains a real methodological correction from earlier the
same day, worth understanding before you draw any conclusion here).
Running `rank_percentile_report()` for the rater "Osnat" (her data:
`data/ratings/osnat.json`, held-out titles: `OSNAT_HELD_OUT` in
`scoring_tests.py`) surfaced this:

*Magic Burns* -- a book Osnat rated `hated` -- ranks **#4 of 695** in a
real `api.recommend()` call built from her training profile (the
held-out set, same eligibility logic production uses). That's not "a
mediocre match slipped through" -- it's very nearly her literal #1
recommendation, for a book she said she hated.

### What to actually do

1. Reproduce it yourself first (don't trust the description above --
   confirm the actual rank/score with your own run). You have
   `codx_readonly` for exactly this kind of `scoring_tests.py`-adjacent
   work.
2. Use `explain_match()` / `explain_book()` / `audit_book_score()`
   (whichever gives the clearest per-field breakdown -- your call, say
   which and why) to get Magic Burns' actual score decomposition against
   Osnat's real profile: which fields/tropes are contributing the most
   positive weight, whether any dealbreaker mechanism should have fired
   and didn't (and if so, why not -- e.g. `validated_dealbreaker_fields()`
   returning empty, the same structural gap the graduated-dealbreaker-veto
   P3 item already tracks), and whether this is a `build_profile()`-level
   issue (her centroid itself is miscalibrated) or a `score_book()`/
   `score_candidate()`-level issue (the centroid's fine, the scoring of
   this specific book against it isn't).
3. Check whether this is an isolated case or a pattern: does the same
   thing happen for her OTHER held-out hated/disliked titles (The Wise
   Man's Fear, Royal Assassin, Skyward, Assassin's Quest, etc. from
   Mathias's own set showed clean separation in the 2026-09-22 report --
   is Osnat's profile behaving differently, and if so is there something
   structurally different about her rating data: sparser, less varied,
   something else)? A one-off outlier and a systematic pattern call for
   very different next steps, so this distinction matters for your
   report even though you're not proposing the next step yourself.
4. If you find a plausible root cause, state your confidence in it
   plainly and say what would need to be true for it to be wrong -- same
   standard as your Task 16 report's PASS/FAIL/INCONCLUSIVE discipline.
   A well-evidenced "I found X, and here's what would falsify that" is a
   complete, valuable answer even without a proposed fix.

### What NOT to do

No code changes, no migration files, no scoring-logic edits, no fix
proposal (root cause only), no DB writes, no commits/pushes -- same as
always.

### Deliverable

`docs/codx-reports/<date>-magic-burns-ranking.md`: your reproduction
(actual commands/output), the score decomposition, the pattern-check
across Osnat's other held-out negatives, and your root-cause conclusion
with its confidence level and falsification condition.
