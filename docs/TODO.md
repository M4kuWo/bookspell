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

**Token-economy note (2026-09-07)**: a heavy session today -- pace
future work accordingly. Cheap/quick items are ordered first within
each tier on purpose; the genuinely taxing ones (marked below) are
worth deferring to a later session rather than batching in for
"efficiency," which just concentrates cost instead of reducing it.

## P0

- [x] **Gate `book_length`/`audiobook_length` by listener format
  preference.** LANDED 2026-09-07 -- see scoring-test-protocol.md.
  Mathias's own `_meta.format_preference` set to `"audiobook"` per his
  direct statement.
- [x] **Push today's commits** -- confirmed 2026-09-07: `main` is up to
  date with `origin/main`, working tree clean, README refresh
  (e18576a) is the latest commit on both.

## P1

- [ ] **Audiobook edition data -- ready to hand off to the other Claude
  session, see `.claude/skills/tag-audiobook-editions/SKILL.md`**
  (written 2026-09-07, updated with explicit bounded-session
  discipline). Runs on a SEPARATE session's token budget, not this
  one -- fine to kick off any time regardless of this session's own
  economizing. Expect this to take many sessions end-to-end; that's
  by design, not a problem to fix. In order:
  1. Step A1a: pull GraphicAudio's catalog listing (own session), then
     BBC Audio's (another session).
  2. Step A1b: cross-reference each list against ours (own session
     per producer), report the real match count.
  3. Step A2: research + insert confirmed matches, capped at 10-15 per
     session.
  4. Sub-task B (Audible Originals, audio-only new entries,
     `work_type = 'audio_original'`): candidate discovery as its own
     session, then ingestion+tagging in normal 15-20/session batches.
  - Open sub-question, not yet checked: whether Hardcover's API exposes
    standard-edition narrator data as a contributor role (same source
    already used for author verification) -- possibly near-bulk-
    fetchable, cheaper than the dramatized-edition path. Check this
    before starting Step A1a if whoever picks this up has a spare cheap
    session for it.
- [ ] **(Taxing -- defer) Promote `romance_tone`/`worldbuilding_
  delivery` from trope pairs to real scalar fields.** Both pairs show
  ZERO overlap in the actual data (confirmed 2026-09-07) -- genuinely
  one-axis spectrums, not independent tags. Deliberately built as
  tropes first as a cheap validation probe before committing to schema
  -- see book-dna.md's "Romance TONE/execution-quality" entry and
  scoring-test-protocol.md's 2026-09-05 "Execution-DNA validation
  probes" entry; the probe already validated (correctly-signed
  weights, confirmed in production). Converting needs a migration +
  backfill + `recommend.py` field-handling changes + removing the old
  trope pair -- real, multi-step engineering work, not urgent. Good
  candidate for a session with a fresh token budget.

## P2 (ongoing/routine, not new decisions)

- [ ] **Continue the romance_tone/worldbuilding_delivery tagging
  sweep** -- as of 2026-09-07 end-of-session: romance_tone batch 19,
  worldbuilding-delivery batch 16 done (~136 romance_tone candidates
  and ~399 worldbuilding candidates remain). Remember the mandatory
  density self-check (CLAUDE.md) before ending any batch session.
  **For romance_tone specifically, default to a broad search + targeted
  follow-up per candidate (not a single search)** -- see
  project-log.md's 2026-09-07 session-wrap-up entry: the easy,
  heavily-reviewed candidate pool is depleting, single searches are
  increasingly landing nothing usable or (once, caught) misattributing
  a quote to the wrong romance pairing in a book with more than one.
  worldbuilding-delivery isn't showing this depletion yet -- single
  searches there are still landing 5-6 clean tags routinely, no process
  change needed for that pool for now.
- [ ] **Catalog tagging completion** -- 873 books total, 45 untagged as
  of 2026-09-07. Checked the "finish partially-tagged series" angle
  first per standing policy: turned out all 6 partially-tagged series
  (Farseer Trilogy, Foundation, Villains, Monk and Robot, A Song of Ice
  and Fire, Kingkiller Chronicle) are actually fully tagged at the
  individual-book level already -- the "missing" row in each is either
  an omnibus/compilation duplicate of an already-tagged book (4 of them
  -- see book-dna.md's new "omnibus/compilation editions" future-fields
  entry, a real schema gap, not yet built) or a currently-unpublished
  book (Winds of Winter, Doors of Stone -- nothing to tag yet). **Skip
  all 6, and any future entry matching the same pattern** (a book row
  duplicating an already-tagged book at the same series position, or a
  book with no real publication yet) -- don't force-tag these, and
  don't count them as real gaps when checking series completion. The
  other ~39 untagged books are standalones or in series with zero
  tagged books yet -- still open, not yet re-surveyed this session.

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
