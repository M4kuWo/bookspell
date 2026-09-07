# Project TODO

A prioritized, cross-cutting task backlog -- distinct from the two docs
that already exist and cover different ground:

- `docs/project-log.md` is append-only HISTORY (what already happened,
  dated, never rewritten).
- `docs/schema/book-dna.md`'s "Future fields backlog" is specifically
  SCHEMA/FIELD ideas (new DNA values, deferred vocabulary).
- **This file** is forward-looking and mutable: things we've decided
  are worth doing, ordered by priority, checked off or re-ordered as
  the project moves. Update it directly (not append-only) as work
  starts/finishes/gets reprioritized. Where an item is really a schema
  idea, it stays tracked in book-dna.md and this file just points to it
  rather than duplicating the writeup.

Priority is P0 (do next) / P1 (soon, real value) / P2 (ongoing/routine)
/ P3 (blocked or parked -- not actionable right now, don't pick these
up without checking whether the blocker cleared).

## P0

- [ ] **Push latest commits** (`43a14f3`, `6d98f29`) so the live GitHub
  Pages catalog tool and today's scoring investigation are actually on
  `main`. Trivial, just needs a go-ahead.
- [ ] **Gate `book_length`/`audiobook_length` by listener format
  preference.** Both are always-on `ORDINAL_FIELDS` today, learned and
  scored for every user regardless of whether they've ever listened to
  an audiobook -- a pure print reader can pick up a spurious
  `audiobook_length` preference from coincidental correlation and have
  it silently affect every candidate's score, and vice versa. Fix:
  default to `book_length` only; add a per-user format-preference
  setting (`data/ratings/{name}.json`, same convention as everything
  else per-user) that swaps in `audiobook_length` for a self-identified
  audiobook listener, keeps both for someone who does both. Small,
  self-contained, no new data needed. (Raised 2026-09-07.)

## P1

- [ ] **Promote `romance_tone` (`understated_romance`/
  `melodramatic_romance_subplot`) and `worldbuilding_delivery`
  (`worldbuilding_woven_into_narrative`/`worldbuilding_via_exposition_
  dump`) from trope pairs to real scalar fields.** Both pairs show ZERO
  overlap in the actual data (confirmed 2026-09-07) -- genuinely
  one-axis spectrums, not independent tags. They were deliberately
  built as tropes first as a cheap validation probe (reusing existing
  trope machinery) before committing to schema -- see book-dna.md's
  "Romance TONE/execution-quality" backlog entry and
  scoring-test-protocol.md's 2026-09-05 "Execution-DNA validation
  probes" entry. The probe validated (correctly-signed weights,
  confirmed in production). Converting needs: a migration adding the
  real columns + backfilling existing trope rows into them,
  `recommend.py` field-handling changes (ORDINAL_FIELDS/NOMINAL_FIELDS
  or wherever the right shape is), removing the old trope pair once
  ported. Scoring-side only, no new data fetching.
- [ ] **Audiobook edition data -- scoped pilot before full 824-book
  sweep.** Only Wind and Truth (GraphicAudio) has a populated
  `audiobook_editions` row. Two sub-problems of very different cost:
  standard-edition narrator data (check first whether Hardcover's API
  exposes narrator as a contributor role -- same source already used
  for author verification -- possibly near-bulk-fetchable) and
  dramatized/full-cast editions (GraphicAudio, BBC Audio/Radio drama,
  and to a lesser extent Audible Originals -- see 2026-09-07 chat for
  the market scan; expensive if checked book-by-book blind since most
  titles won't have one). Cheaper path for the dramatized side: pull
  each producer's own SFF catalog listing first, intersect against our
  825 titles, only deep-research the actual matches. Run a small pilot
  batch first to get a real per-book cost reading before committing to
  the full catalog.

## P2 (ongoing/routine, not new decisions)

- [ ] **Continue the romance_tone/worldbuilding_delivery tagging
  sweep** -- batch 8 of a planned ~20 done as of 2026-09-07. Remember
  the mandatory density self-check (CLAUDE.md) before ending any batch
  session.
- [ ] **Catalog tagging completion** -- check how many books remain
  untagged; prioritize finishing partially-tagged series (>= 2 tagged
  books needed for Series DNA to compute anything) over new
  standalones, per the standing CLAUDE.md policy.

## P3 (blocked or parked -- check the blocker before picking up)

- [ ] **Graduated dealbreaker veto** (`_apply_dealbreaker_veto_
  graduated()` in recommend.py) -- built and structurally verified
  2026-09-07, but can't be proven against real data because
  `validated_dealbreaker_fields()` is currently EMPTY for all 4 real
  raters. Blocked on more real per-rater rating data, not on more
  engineering. Revisit once a field/user pair actually validates.
- [ ] **Series-aware field-conditional dedup** -- parked 2026-09-06.
  One real lead not yet built: protect the minority subgroup within a
  series split (not just validated-dealbreaker fields, which was tried
  and found to be a no-op since nothing currently validates). See
  scoring-test-protocol.md's dedup entries for the full trajectory.
- [ ] Schema-field ideas (protagonist gender, protagonist competence
  trajectory, narrative sympathy between co-leads, `message_themes`/
  `anti_militarist_message` probe) -- tracked in full in
  `docs/schema/book-dna.md`'s "Future fields backlog", not duplicated
  here. All explicitly waiting on more real rating evidence before
  committing to vocabulary.
