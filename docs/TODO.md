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
- [ ] **Audiobook edition data -- ready to hand off, see
  `.claude/skills/tag-audiobook-editions/SKILL.md`** (written
  2026-09-07). Only Wind and Truth (GraphicAudio) has a populated
  `audiobook_editions` row. Two sub-tasks, deliberately NOT combined
  with the romance_tone/worldbuilding batches (different research
  modality, different candidate-list source -- see the skill's own
  "why not combined" section for the full reasoning):
  - Sub-task A: dramatized full-cast editions (GraphicAudio, BBC Audio)
    on EXISTING catalog books -- cross-reference each producer's own
    catalog against ours FIRST (cheap), only deep-research real
    matches. Can run in large batches, it's a lookup, not a judgment
    call.
    - Note (2026-09-07): also worth checking whether Hardcover's API
      exposes standard-edition narrator data as a contributor role
      (same source already used for author verification) -- possibly
      near-bulk-fetchable, cheaper than the dramatized-edition path.
      Not yet checked; add as a Sub-task A0 if it pans out.
  - Sub-task B: Audible Originals (audio-only, no print counterpart) --
    genuinely NEW catalog entries, `books.work_type = 'audio_original'`
    (migration `20260907140000_work_type_audio_original.sql`, already
    landed). Full ingestion+tagging, same batch-size discipline as
    `tag-catalog-batch` (15-20/session), `book_length`/`page_count`
    left NULL, `audiobook_length` the real length signal.

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
