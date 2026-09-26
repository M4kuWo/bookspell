# Book DNA split — acceptance test methodology

**Verdict: shipped 2026-09-25.** 26/26 checklist items passed both
before and after, zero regressions, real reading-volume drops (12-54%
depending on scenario) -- and the methodology caught a real content-loss
bug before it shipped silently. Full results in `docs/project-log.md`'s
2026-09-25 "after results" entry. This file remains the fixed
methodology (unchanged since it was written), kept for anyone re-running
these scenarios after a future schema-doc change.

Written 2026-09-25, before implementing the `book-dna.md` restructuring
(`docs/codx-reports/2026-09-25-book-dna-split-review.md`, CODX's Task
22 review), per the repo owner's explicit requirement: a way to
measure whether the split actually helped, and a way to know if it
regressed something, not just an assumption that smaller files are
better. Directly operationalizes CODX's own proposed acceptance
criteria (that report's "Task 21 follow-through and acceptance
criteria" section, points 1 and 4).

**Mechanism**: each scenario is a realistic task prompt handed to a
genuinely fresh Claude Code agent (via the `Agent` tool,
`subagent_type: general-purpose` — NOT a fork, which would inherit
this session's own knowledge of the old file layout and defeat the
point). The agent has full read access to the repo and is told to
investigate however it normally would, then answer the task question
AND report exactly which files/sections it read and roughly how much.
Its answer is graded against the checklist below, written BEFORE any
agent runs, so grading can't drift to match whatever an agent happens
to say.

Run twice: once now, against the current (pre-split) `book-dna.md`, as
a baseline. Once again after implementing the split, same prompts,
same checklists. Compare: did anything regress (an agent now misses a
requirement it used to find), and did real reading volume actually
drop (not just the core file's own word count — whether a realistic
task can be answered correctly with less actually read).

## Scenario 1 — ordinary tagging batch

**Prompt given to the agent**: "You're about to tag 3 new sci-fi/
fantasy books for the Bookspell catalog via the `tag-catalog-batch`
skill. Before starting, what do you need to read and know? Specifically:
where does the authoritative, current trope/content-warning vocabulary
live, what's the bar for adding a new value if a book's defining trope
doesn't fit anything existing, and what do you do differently if a
field is in `HIGH_RISK_FIELDS`? Don't actually tag anything — describe
your process and cite exactly where each piece of information came
from (file + section)."

**Required to find/state** (checklist):
- [ ] Identifies `docs/schema/book-dna.schema.yaml` (not the Markdown
      alone) as the exact, exhaustive current vocabulary.
- [ ] States the real bar for a new value: "does this predict a
      different recommendation," not "is it a real term."
- [ ] Finds and describes the vocabulary-gap tracker (the "Open"
      list) and the second-occurrence promotion rule.
- [ ] Mentions verifying uncertain HIGH_RISK_FIELDS values against
      real research even when confident (the "confidently wrong on a
      specific detail" failure mode), not just "if uncertain, check."
- [ ] Mentions Step 1.5 — verifying the skill's mandatory column list
      against the table's LIVE columns before tagging a batch, not
      trusting a possibly-stale list.

## Scenario 2 — vocabulary-gap second occurrence

**Prompt**: "While running a gap sweep, you tag a book and realize it's
the SECOND book you've now seen hit an already-open single-occurrence
vocabulary gap in the tracker. What do you do, step by step?"

**Required to find/state**:
- [ ] Finds the vocabulary-gap tracker and its "Open" list.
- [ ] States that a second independent occurrence is exactly the
      trigger to propose the real vocabulary addition (not defer a
      third time).
- [ ] Mentions moving the entry to "Promoted / resolved" once the real
      addition lands.
- [ ] Mentions logging the reasoning in `docs/project-log.md`.

## Scenario 3 — audiobook UI/data task

**Prompt**: "You're building a UI element that shows a book's audiobook
edition info (narrator, edition type, runtime). What table and columns
do you actually need, what are the real current `edition_type` values,
and what data-quality caveats should the UI account for before trusting
`edition_type` at face value?"

**Required to find/state**:
- [ ] Identifies `audiobook_editions` (not a column on `book_dna`) as
      the real source table.
- [ ] Lists the real current `edition_type` values: `standard`,
      `dramatized_full_cast`, `abridged`, `other` -- and correctly does
      NOT include `audio_original` (that's a separate, real value on
      `books.work_type`, a different table/column -- this checklist
      itself originally claimed `audio_original` belonged here, a stale
      claim from before this exact correction landed 2026-09-25; fixed
      2026-09-26 after CODX's Task 23 review caught the rubric itself
      hadn't been updated to match).
- [ ] States `narrators` is a flat name array, no character-role
      mapping (a known gap, not a bug).
- [ ] Mentions the GraphicAudio episodic-release caveat
      (`release_status`/part counts — a lookup mid-release can
      misrepresent availability).
- [ ] Correctly states the CURRENT status of the GraphicAudio-
      mislabeling concern: a 2026-09-18 sweep found zero confirmed
      mislabeled rows catalog-wide -- a clean one-time result, not a
      standing guarantee, worth a light re-check after future batches
      but not an active, unfixed issue (fixed wording 2026-09-26; this
      item previously read as if it were still confirmed/unfixed).

## Scenario 4 — new scalar field proposal

**Prompt**: "You've now seen the same recommendation failure pattern
twice, on two different books, and you think a new scalar `book_dna`
field might explain it. What do you need to check and clear before
actually proposing it?"

**Required to find/state**:
- [ ] Finds "The bar for a new scalar `book_dna` field" gate
      specifically (distinct from the ordinary trope/CW bar).
- [ ] States the repeated-failure-class requirement (not one book).
- [ ] States checking no existing field/trope combination already
      covers the concept.
- [ ] Mentions pre-registering what an ablation-style check
      (`run_ablation_study()`) would need to show before building it.
- [ ] Mentions this ALSO has to clear `docs/scoring-test-protocol.md`'s
      Q1-Q10 gate — the two aren't redundant (concept-is-real vs.
      engineering-response-is-right).

## Scenario 5 — confidence/source layer task

**Prompt**: "You're about to run a HIGH_RISK_FIELDS confidence QA pass
like the ones CODX has done before. Before starting: what does a
missing `book_field_confidence` row actually mean for a field, what's
the default, and does that default apply the same way to every field?"

**Required to find/state**:
- [ ] Finds the confidence/source layer's real semantics (not just
      `HIGH_RISK_FIELDS`'s definition in CLAUDE.md/`constants.py`).
- [ ] States that absence of a row generally means full trust (1.0),
      NOT low confidence.
- [ ] States this default is DIFFERENT for `HIGH_RISK_FIELDS`
      specifically (a lower default), and correctly explains why.
- [ ] Mentions `MIN_CONFIDENCE_TO_COUNT` — a tag below this is
      excluded from scoring entirely, not just discounted.

## Scenario 6 — omnibus/compilation + work_type

**Prompt**: "A newly-ingested book turns out to be an omnibus/
compilation of books already in the catalog. What's the correct
handling? Separately: does `work_type` matter here, and what are its
real, current possible values?"

**Required to find/state**:
- [ ] States the operational rule: skip/flag duplicate compilations
      rather than tagging them as new independent entries (links to
      the archiving/scope policy, not just a vague "future idea").
- [ ] Identifies `work_type` as a REAL, BUILT column (not a future
      idea) — a correct answer must not describe it as unbuilt.
- [ ] States its current values include `audio_original` (3 values),
      not just the original "novella/novel" 2-value set the Markdown
      prose still describes — this is the single sharpest test of
      whether the split fixed the stale-enum problem CODX found, since
      an agent reading only the old prose (not the YAML/migration)
      will get this wrong.

## Grading and comparison

For each scenario, record: which checklist items were satisfied
(pass/fail per item, not just an overall verdict), which files/
sections the agent reports having read, and an approximate word count
of what was actually read to reach its answer. A regression is any
checklist item that passes in the "before" run and fails "after," or
any scenario whose reported reading volume goes UP after the split
(would mean the new structure is harder to navigate, not easier).

Full "before" and "after" results, and the final verdict (ship /
revert / fix and re-test), belong in a dated `docs/project-log.md`
entry once both runs are complete — this file is the fixed methodology,
not the results.
