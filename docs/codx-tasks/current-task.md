# CODX current task

**Assigned**: 2026-09-25, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 20 — HIGH_RISK_FIELDS confidence QA, round 3

Resumes `docs/TODO.md`'s P3 "Recurring HIGH_RISK_FIELDS confidence QA
pass" item -- paused 2026-09-17 for budget pacing after rounds 1-2
(Tasks 9-10, `docs/codx-reviews/codx-highrisk-confidence-qa-pass-
2026-09-17.md` and `...-round2-2026-09-17.md`), not because it stopped
being worth doing. **Read both of those reports first** -- same
methodology, same evidence standard, same output format. Their
`HIGH_RISK_FIELDS` definitions/POV-count thresholds/etc. are unchanged;
don't re-derive them.

**Same scope/gate as before**: this is a proposal-only review, same as
every CODX task. No catalog, confidence, scoring, or migration changes
-- findings go in your report for CLDO to independently review and
apply (rounds 1-2's proposals both landed this way, via
`20260917020000_task9_highrisk_confidence_qa_corrections.sql` and
`20260917030000_task10_highrisk_confidence_qa_round2_corrections.sql`
-- confirm that pattern if useful context, don't just assume).

### Why this needs a fresh assignment, not "just query for more"

The catalog grew significantly since rounds 1-2 (round-5 ingestion +
ordinary batch tagging), so the low-confidence pool is no longer the
same 125 rows the TODO item's stale count describes -- it's 240 rows
as of 2026-09-25 (queried fresh, confidence < 0.6, `HIGH_RISK_FIELDS`
columns only, excluding archived books). The 22 pairs below were
selected from that live query, explicitly excluding every pair rounds
1-2 already reviewed (whether corrected or left "genuinely
inconclusive"/"schema-format-mismatch" -- re-reviewing those would
just reach the same conclusion), and capped at 2 fields per book so
this batch spans 20 different books rather than clustering on a few.

### Assigned pairs (22, current value / confidence shown for reference -- verify against hosted yourself, don't trust this table blindly)

| Book | Author | Field | Current value | Confidence |
|---|---|---|---|---|
| Exile | R. A. Salvatore | magic_system_hardness | hard | 0.4 |
| Gone | Michael Grant | stakes_scope | regional | 0.4 |
| Gone | Michael Grant | magic_system_hardness | na | 0.4 |
| How to Become the Dark Lord and Die Trying | Django Wexler | stakes_scope | regional | 0.4 |
| How to Become the Dark Lord and Die Trying | Django Wexler | magic_system_hardness | hard | 0.4 |
| Provenance | Ann Leckie | person | first | 0.4 |
| The Bone Ships | RJ Barker | magic_system_hardness | soft | 0.4 |
| The Eye of the Bedlam Bride | Matt Dinniman | pov_count | dual | 0.4 |
| The Historian | Elizabeth Kostova | magic_system_hardness | soft | 0.4 |
| The Knight and the Moth | Rachel Gillig | narrator_reliability | ambiguous | 0.4 |
| The Knight and the Moth | Rachel Gillig | romance_heat_intensity | low | 0.4 |
| The Prison Healer | Lynette Noni | magic_system_hardness | soft | 0.4 |
| The Queen of the Tearling | Erika Johansen | romance_heat_intensity | low | 0.4 |
| The Raven Scholar | Antonia Hodgson | romance_heat_intensity | low | 0.4 |
| The Raven Scholar | Antonia Hodgson | magic_system_hardness | soft | 0.4 |
| The Redemption of Time | Baoshu, Ken Liu | stakes_scope | cosmic | 0.4 |
| The Rise and Fall of D.O.D.O. | Neal Stephenson, Nicole Galland | stakes_scope | regional | 0.4 |
| The Rise and Fall of D.O.D.O. | Neal Stephenson, Nicole Galland | narrative_closure | requires_series | 0.4 |
| The River Has Roots | Amal El-Mohtar | person | third_limited | 0.4 |
| The River Has Roots | Amal El-Mohtar | romance_heat_intensity | closed_door | 0.4 |
| The Salvation | Justin Lockey | humor_level | light | 0.4 |
| The Tommyknockers | Stephen King | romance_heat_intensity | low | 0.4 |

### Validation bar (same as rounds 1-2)

- Identity-check each book against hosted (title/author/Hardcover
  ID/ISBN/year) before researching it -- round 1's Shroud
  disambiguation is the template for why this matters.
- Real, findable evidence (reviews, excerpts, synopses) per pair, not
  genre pattern-matching -- this is exactly the failure mode
  `HIGH_RISK_FIELDS` exists to catch (see CLAUDE.md's "Data quality /
  tagging" section on this).
- Same output categories as before: confirmed-correct (propose a
  confidence increase), likely-wrong (propose a new value +
  confidence), genuinely-inconclusive (unchanged), schema/format
  mismatch if one turns up (unchanged, flagged).

### Deliverable

A report at `docs/codx-reports/<date>-highrisk-confidence-qa-round3.md`,
same shape as rounds 1-2's (identity table, recommendations-at-a-glance
table, individual findings with sources). No commits, pushes, or
hosted writes -- proposal only, for CLDO to review and land as a
migration the same way rounds 1-2 landed.
