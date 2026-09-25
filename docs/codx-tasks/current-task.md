# CODX current task

**Assigned**: 2026-09-25, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 22 — review a concrete `book-dna.md` split proposal (per the new structural-change review gate)

This task exists because of CLAUDE.md's new "Structural/methodology-change
review gate" section (added 2026-09-25, right after your own Task 21
review). That gate requires an independent review before implementing a
"big" structural change — and specifically calls out this exact
situation as its worked example: Task 21 blessed the GENERAL direction
of splitting `book-dna.md`, but flagged that a mechanical single-heading
cut would break real things. This task is CLDO's attempt at a CONCRETE
split plan that accounts for what Task 21 found. **Review this plan
critically before it's implemented — this is a genuine ask, not a
formality. Find flaws, boundary cases that are mis-assigned, or propose
a different structure entirely if you think this one is wrong.**

Same posture as Task 21: review/ideation only, no file changes, no
implementation, no commits.

### What CLDO found digging into the actual content (beyond Task 21's own findings)

Task 21 established that "Future fields backlog" contains real
operational material (the vocabulary-gap tracker `tag-catalog-batch`
requires, and `audiobook_editions`' rationale for an already-shipped
table) mixed with genuinely speculative content. Digging further to
build this concrete plan surfaced two more entanglements:

1. **The `audiobook_editions` backlog entry literally contains the line
   "UPDATE (2026-09-05): table BUILT"** (book-dna.md:1563) while the
   whole entry still lives under "Future fields backlog" — an even more
   direct confirmation than Task 21's already found: this isn't
   ambiguous filing, it's a stale header on live content.
2. **"Vocabulary growth process" (book-dna.md:526-940, 3,425 words) has
   the exact same shape as the backlog problem**: it opens with a real,
   current, always-needed rule (~270 words — "does this predict a
   different recommendation, not just 'is it a real term'"), then the
   remaining ~3,150 words are a chronological history of 7 past
   "growth rounds," dated and closed. Same mixed-content pattern Task 21
   found in the backlog, just under a different heading CLDO hadn't
   checked yet when writing Task 21's assignment.

### Proposed file structure (4 files, from 1)

| File | Contents | Read when |
|---|---|---|
| `book-dna.md` (core, ~5,600 words / ~7,300 tokens — down from 19,578/25,451, a ~71% cut) | `Scope`, `Categories` (the actual field/trope vocabulary+definitions), `Known limitations`, `Spoiler gating`, `Series & universe` note, and ONLY the opening rule of `Vocabulary growth process` (trimmed to the ~270-word current standard, not the 7 growth-round history) | Every session, unconditionally (per CLAUDE.md's existing instruction) |
| `book-dna-vocabulary-gaps.md` (operational tracker, ~2,241 words) | The full "Flagged single-occurrence vocabulary gaps" section (book-dna.md:1208-1457) verbatim, Open + Promoted/resolved both — it's explicitly already "a running tracker, not a one-off list," not history | Before `tag-catalog-batch`/gap-sweep work (already the case today, just relocated) |
| `book-dna-tables.md` (discoverable current-table contracts) | The `audiobook_editions` entry (book-dna.md:1544 onward) EXTRACTED from the backlog and rewritten as current documentation (not "a deferred idea that got built" — just what the table is and why), since it describes a real, live, 1000+-row table | Whenever touching `audiobook_editions` or building UI against it — linked prominently from `book-dna.md`'s core AND from `.claude/skills/tag-audiobook-editions/SKILL.md` |
| `book-dna-history.md` (rationale/history) | `Resolved during review`, `Vocabulary growth process`'s 7-round chronology, the remaining genuinely-deferred "Future fields backlog" entries (everything except the vocab-gap tracker and the audiobook_editions entry, both moved above), `Open for review`, `Next step`, and — open question, see below — possibly "The bar for a new scalar field" gate | When proposing a new field, revisiting a past decision, or a current rule explicitly points here |

**Open question CLDO is genuinely unsure about, wants your read on**:
"The bar for a new scalar `book_dna` field" (book-dna.md:1169-1206, 344
words, currently the first thing under "Future fields backlog") is a
CURRENT, standing rule — anyone ever proposing a new field must clear
it, not just people looking at old history. Does it belong in the core
file (short enough to justify always-reading it) or in
`book-dna-history.md` with a one-line pointer left in core (matching
the pattern for everything else in that file)? CLDO leans toward the
pointer-in-core approach (most sessions never propose a new field, so
paying 344 words every session for a rule almost nobody needs that
session is the same mistake as reading the whole vocab-gap tracker
every time), but this is exactly the kind of boundary call Task 21
warned CLDO's own judgment can miss.

### Every file that references `book-dna.md`'s current structure — must be updated together, not just `CLAUDE.md`

Confirmed via direct grep before writing this (exact lines, so you
don't need to re-derive them, only re-verify if useful):

- `CLAUDE.md`: "always read `docs/schema/book-dna.md`" instruction
  needs to point at the new core file instead.
- `AGENTS.md:14`: same instruction, forwarded from CLAUDE.md's wording.
- `.claude/skills/tag-catalog-batch/SKILL.md:69`: explicitly requires
  the vocabulary-gap tracker "before tagging" — needs to point at
  `book-dna-vocabulary-gaps.md` once it exists.
- `.claude/skills/catalog-trope-gap-sweep/SKILL.md`: lines 13, 33, 49,
  62, 179, 185, 199 all reference book-dna.md's structure, including
  line 33's explicit "`docs/schema/book-dna.md` in full (not just the
  backlog section" — this line's whole PREMISE (that there's a
  meaningful "backlog section" distinct from the rest) needs rewriting
  once the split exists, not just a path swap.
- `.claude/skills/convert-romance-worldbuilding-fields/SKILL.md`: lines
  14, 70.
- `.claude/skills/tag-audiobook-editions/SKILL.md:73`: currently says
  "book-dna.md's audiobook_editions backlog entry" — needs to become a
  pointer to `book-dna-tables.md` instead, and the word "backlog" needs
  to go since that table isn't backlog anymore under this plan.

### What to actually do

1. **Critique the file structure and the specific content-mapping
   above.** Is 4 files the right number (too many, too few)? Is
   anything mis-assigned? Does the `book-dna-tables.md` idea make sense
   as a NEW file, or should `audiobook_editions`' contract live
   somewhere that already exists / makes more sense?
2. **Answer the open question** about where "The bar for a new scalar
   field" belongs, with your reasoning.
3. **Check CLDO's cross-file reference list for completeness** — did a
   search of your own (across CLAUDE.md, AGENTS.md, `.claude/skills/`,
   and anywhere else book-dna.md might be referenced, e.g.
   `docs/scoring-test-protocol.md` or other docs) turn up anything
   CLDO's grep missed?
4. **Flag anything else Task 21's own "additional ideas" section
   implied but this plan doesn't yet address** — e.g. "route by task
   class" was Task 21's own idea and isn't reflected in this plan at
   all yet; say whether it should be folded into this pass or stay a
   separate, later piece of work.
5. Don't restructure any files. This is a plan review, not
   implementation — even if you're confident the plan is right, no file
   changes, no commits.

### Deliverable

A report at `docs/codx-reports/<date>-book-dna-split-review.md`: your
verdict on the proposed structure (keep as-is / modify / reject and
propose an alternative), your answer to the open question, confirmation
or correction of the cross-file reference list, and anything from
point 4 above worth flagging. CLDO implements after reading this,
independently re-verifying it the same way every other CODX output gets
verified before being trusted.
