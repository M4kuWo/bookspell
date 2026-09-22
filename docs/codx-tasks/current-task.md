# CODX current task

**Assigned**: 2026-09-22, by CLDO.
**Status**: ready to start. Task 15 (the CI workflow) landed cleanly --
see `docs/codx-reports/2026-09-22-ci-workflow.md` in your own clone and
`docs/project-log.md`'s 2026-09-22 "CODX Task 15 landed" entry. This
task has two parts; do them in order, and if you run low on budget
partway through, stop after finishing Part A and report what you got
through on Part B rather than leaving both half-done.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet. Report to `docs/codx-reports/<date>-<slug>.md` in your own
clone as always -- one report covering both parts is fine.

---

## Part A -- housekeeping: a stale, forgotten file in your own clone

There's an untracked file sitting in your clone,
`docs/codx-recommend-review-2026-09-14.md`, with a last-modified date of
2026-09-14 -- over a week old, and it never got landed, referenced in a
report, or cleaned up. Nobody currently knows what state it's in.

Read it, figure out what it actually is (an old review draft? a
half-finished task? leftover scratch from an abandoned attempt?), and
do ONE of: (a) if it's a real, still-relevant finding nobody acted on,
say so clearly in your report so CLDO can review and land it properly,
(b) if it's superseded by later work (e.g. the actual `recommend.py`
refactor that happened via Tasks 4-12) or otherwise no longer useful,
delete it from your own clone and say so, (c) if you genuinely can't
tell, quote the relevant parts in your report and say what's unclear.
Don't just leave it sitting there for another week.

## Part B -- independent QA pass on recent work

A lot has landed without a second set of eyes since your last QA-style
task (the HIGH_RISK_FIELDS confidence passes, paused 2026-09-17 --
`docs/codx-reviews/codx-highrisk-confidence-qa-pass-2026-09-17.md` and
the round-2 file are your own methodology reference if useful). Two
things to check, both real, neither reviewed by anyone but the session
that wrote it:

### B1 -- the 6 migrations CLDO wrote and landed solo on 2026-09-22

Files: `supabase/migrations/20260922000000_fix_remote_control_series_and_archive_thorn_of_emberlain.sql`
through `20260922060000_backfill_round5_covers.sql` (6 files total, all
dated 2026-09-22 -- `ls supabase/migrations/ | grep 20260922` lists
them). Full narrative in `docs/project-log.md`'s two matching
2026-09-22 entries if you want the reasoning behind each, but verify
the *result* independently rather than just trusting the writeup:

- `20260922000000`: confirm "Remote Control" (Nnedi Okorafor) has
  `series_id IS NULL` and is no longer sharing a series with "Who Fears
  Death"; confirm "The Thorn of Emberlain" is `archived = true`,
  `archived_reason = 'unpublished'`.
- `20260922010000`: confirm "Ruin" (John Gwynne) exists in `books` with
  `hardcover_id = 1235599`, `series_id` pointing at the real "The
  Faithful and the Fallen" series row, `position_in_series = 3`, and
  that series now shows all 4 books (Malice/Valor/Ruin/Wrath) --
  independently re-check the hardcover_id and series position against
  Hardcover's own API rather than trusting the migration file's claim.
- `20260922030000`/`20260922040000`: confirm "Holly" (Stephen King) is
  archived (`non_sff_genre_leakage`); confirm the standalone "The Egg"
  row is gone and "The Egg and Other Stories" (hardcover_id 839124)
  exists instead, with `author = 'Andy Weir'` only -- independently
  verify via Hardcover's own API that the other 3 names on that
  edition (Christy Romano, R.C. Bray, Jonathan Davis) really are
  narrators (`contribution` = "Reading"), not co-authors, the same way
  you'd check any other author-contamination case.
- `20260922050000`: confirm "The Lottery" (Shirley Jackson) is
  archived (`non_sff_genre_leakage`).
- `20260922060000`: this one touches 226 rows (`cover_url` repointed
  to this project's own Storage bucket for the round-5 catalog-
  expansion books). Don't re-check all 226 by hand -- pull a real
  random sample of ~15-20 `hardcover_id`s from the migration file, and
  for each: confirm the row's current `cover_url` actually resolves
  (a real HTTP fetch, not just "it's a supabase.co URL so it must be
  fine") and that the image it returns is plausibly a real book cover
  (not a broken/placeholder image).

Report any discrepancy as a real finding, not just "looks fine" --
this is the first independent check any of this has had.

### B2 -- a bounded spot-check across CLDA's round-5 tagging batches (6-14)

Not a full re-tag -- a sampling QA pass, same spirit as your
HIGH_RISK_FIELDS work. Pick a real random sample of ~15 books tagged
across migrations `20260920010000` through `20260921090000` (batches
6-14, ~156 books tagged total -- `docs/TODO.md`'s P2 section has the
batch list and migration filenames if you want the exact set to sample
from). For each sampled book, check:

- Any `HIGH_RISK_FIELDS` value (per `scripts/recommend.py` or wherever
  that list now lives post-refactor -- check `scripts/scoring/`) against
  a real source (synopsis, review, or the book itself if you know it)
  -- this is the specific failure mode CLAUDE.md's "Data quality /
  tagging" section warns about (confidently wrong on a checkable
  detail, not "I don't know this book").
- The `author` field for contamination (translator/narrator/illustrator
  names that shouldn't be there) -- cross-check against Hardcover's
  `cached_contributors` the same way every prior audit in this project
  has.

If your sample turns up zero real issues, that's a real, useful
result too (say so plainly, with what you checked) -- don't manufacture
findings to justify the pass.

### What NOT to do

No DB writes, no commits, no pushes -- same as always. If B1 finds a
real discrepancy, describe it precisely in your report; CLDO will apply
any fix, not you.

### Deliverable

One report, `docs/codx-reports/<date>-post-round5-qa.md`, covering both
parts: what Part A's file turned out to be and what you did with it,
and Part B's full checklist with pass/fail per item and your sample
list (which `hardcover_id`s/books you actually checked, so it's
reproducible).
