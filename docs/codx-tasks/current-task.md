# CODX current task

**Assigned**: 2026-09-17, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 10 — round 2 of the recurring HIGH_RISK_FIELDS confidence QA pass

Same shape as Task 9 (`docs/codx-reviews/codx-highrisk-confidence-qa-pass-2026-09-17.md`
— read it first if you haven't, both for the method that worked well
and for the "Making the next round more efficient" section you wrote
at the end of it, which this task tries to act on). Independent
research-based verification of existing low-confidence tags, not new
tagging. Proposal only — you don't touch `book_field_confidence`/
`book_dna` yourself, hosted or local.

`main` is at commit `c983c71`. Since Task 9, CLDO fixed the root cause
of a recurring local/hosted data-sync bug (not relevant to your read-
only work, but if you want context: `docs/project-log.md`'s 2026-09-17
"fixed the actual root cause" entry) and CLDA landed 2 more tagging
batches (40 books). None of that changes this task's scope or method.

## Scope: 20 fresh (book, field, confidence) pairs

Pulled directly from a live query, ordered lowest-confidence-first (not
reused from Task 9's list) — same discipline as last time: **verify
each current value against hosted yourself before researching it**,
don't trust these numbers as still-current without checking.

| Book | Author | Field | Confidence |
|---|---|---|---:|
| Book of Night | Holly Black | narrative_closure | 0.3 |
| City of Last Chances | Adrian Tchaikovsky | narrative_closure | 0.3 |
| Cursed Bunny | Bora Chung | drive | 0.3 |
| Cursed Bunny | Bora Chung | pov_count | 0.3 |
| Cursed Bunny | Bora Chung | magic_system_hardness | 0.3 |
| Dance of Thieves | Mary E. Pearson | magic_system_hardness | 0.3 |
| How to Become the Dark Lord and Die Trying | Django Wexler | romance_heat_intensity | 0.3 |
| Quidditch Through the Ages | J.K. Rowling, Kennilworthy Whisp | person | 0.3 |
| Translation State | Ann Leckie | person | 0.3 |
| A House With Good Bones | T. Kingfisher | magic_system_hardness | 0.4 |
| Allomancer Jak and the Pits of Eltania | Brandon Sanderson | magic_system_hardness | 0.4 |
| Auberon | James S. A. Corey | narrator_reliability | 0.4 |
| Auberon | James S. A. Corey | person | 0.4 |
| Belladonna | Adalyn Grace | drive | 0.4 |
| Book of Night | Holly Black | magic_system_hardness | 0.4 |
| Cursed Bunny | Bora Chung | narrator_reliability | 0.4 |
| Emergency Skin | N. K. Jemisin | stakes_scope | 0.4 |
| Evershore | Brandon Sanderson, Janci Patterson | narrator_reliability | 0.4 |
| Evershore | Brandon Sanderson, Janci Patterson | stakes_scope | 0.4 |
| Exile | R. A. Salvatore | stakes_scope | 0.4 |

Two real clusters worth noting up front, same as Task 9's nine-book
humor cluster and Ilium self-flag:

- **Cursed Bunny (Bora Chung) has 4 of the 20 items** (drive, pov_count,
  magic_system_hardness, narrator_reliability) — it's a short-story
  collection, not a single narrative, which may be exactly why several
  structural fields were hard to pin down at tagging time (a
  collection's "pov_count"/"narrator_reliability"/"drive" may vary
  story to story, or the schema's single-book-shaped fields may just
  not map cleanly onto an anthology). Worth investigating whether
  that's the real reason for the low confidence before treating each of
  the 4 as an independent research question — if it's a structural
  schema-fit issue rather than a research gap, say so explicitly rather
  than forcing 4 separate literary-detail verdicts.
- **Quidditch Through the Ages / person**: this is a real, known special
  case, not an oversight — it's an in-universe fake "textbook" (from
  the Harry Potter universe, credited to the fictional author
  Kennilworthy Whisp), not a normal narrative with characters. A
  "person" (first/third/mixed) tag may not map cleanly onto expository
  reference-book prose the way it does for a novel. Same instruction as
  Cursed Bunny: if the low confidence reflects a genuine schema/format
  mismatch rather than missing research, say so rather than forcing a
  confident person classification onto a book that may not have one in
  the normal sense.

Also note: **Book of Night**, **Auberon**, and **Evershore** each have
2 of the 20 items. Not flagged as clusters the way Cursed Bunny is —
these look like ordinary multi-field uncertainty on otherwise normal
novels, but confirm that assumption rather than taking it for granted.

## What to actually do, per (book, field) pair

Same method as Task 9:

1. Confirm the book's identity precisely (correct edition/hardcover_id,
   not a same-titled different work). **Auberon** (James S. A. Corey)
   is an Expanse-universe novella; **Evershore** (Brandon Sanderson &
   Janci Patterson) is an unrelated Skyward-universe novella — different
   authors, different series, don't conflate them or their parent
   series' main novels with these specific shorter works.
2. Research the specific mechanical claim the field encodes (not genre
   pattern-matching — same evidentiary bar `tag-catalog-batch/SKILL.md`
   requires for `HIGH_RISK_FIELDS`). `magic_system_hardness` appears 5
   times in this batch — remember its schema definition is about how
   rule-bound/explained a book's magic system is (hard = consistent,
   understood rules; soft = mysterious, unexplained), not how much
   magic appears.
3. Report one of:
   - **Confirmed correct** — cite the specific evidence, recommend a new
     confidence value.
   - **Likely wrong** — cite the specific evidence, recommend the
     correct value.
   - **Genuinely inconclusive** — recommend leaving as is. A legitimate,
     expected outcome for some of these, not a failure.
   - **New this round**: **schema/format mismatch** — for the Cursed
     Bunny/Quidditch Through the Ages cases specifically, if the real
     finding is "this field doesn't cleanly apply to this book's
     format," say that explicitly as its own category rather than
     forcing it into confirmed/wrong/inconclusive.

## Deliverable

A report at `docs/codx-reports/2026-09-17-highrisk-confidence-qa-round2.md`
(or same-day-dated equivalent), same structure as Task 9's report
(outcome/scope summary, method and limits, identity record, a
recommendations-at-a-glance table, individual findings per pair, the
cluster investigation, execution record, final verification). This is
a proposal only.

## Applying "making the next round more efficient" from your own Task 9 report

You wrote five concrete suggestions at the end of Task 9. Two are
already reflected in how this task is written: cluster/pattern flags
are called out up front (item 3 in your list — separating quick
structural checks from full-text census tasks — is exactly why Cursed
Bunny/Quidditch are flagged as a distinct category above), and this
table already includes book/author/field/confidence (item 1). If you
find the export format still isn't quite right for your workflow, say
so in this round's report too — this is a recurring task type, worth
tuning.
