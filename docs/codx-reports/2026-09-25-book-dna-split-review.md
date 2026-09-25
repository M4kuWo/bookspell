# Task 22 — review of the concrete Book DNA split proposal

CODX · 2026-09-25 · reviewed commit `e032a76`. Review only. This report is the sole new deliverable; no restructuring, implementation, schema/data changes, commits or pushes. Line references below refer to this revision.

## Verdict: modify before implementation

**Keep the four-file approach, but correct the boundaries and explicitly separate current contracts from historical text inside the destinations.** The plan addresses the two Task 21 examples, but still treats too much remaining material as history by location. It also has a concrete extraction error: the proposed vocabulary-gap range excludes the entire resolved list and its closing operational instruction.

Keep the scalar-field gate in core for this pass. Keep a small routing map in core as part of the split; changing the global always-read obligation by task class should be a separately reviewed follow-up. A table-contract file is useful and has no existing equivalent under `docs/schema/`; neither a migration nor a writing skill alone replaces a reference for UI/read consumers.

## Findings that change the plan

### 1. The proposed gap range drops precisely the material it promises to preserve

The assignment says to move the full tracker, including Open and Promoted/resolved, but specifies **1208–1457 / 2,241 words**. Those numbers cover only the heading, introduction and Open entries. Actual boundaries in [book-dna.md](../schema/book-dna.md):

| Material | Existing lines | Words |
|---|---:|---:|
| Proposed tracker range | 1208–1457 | 2,241 |
| Promoted/resolved plus closing process note | 1458–1530 | 514 |
| Full operational tracker | **1208–1530** | **2,755** |

The process note starts at 1522 and explicitly binds the tracker to the next tagging invocation. Cutting at 1457 loses both the promotion record and that instruction. Extract by the actual semantic boundary before “Deliberately deferred, not in v0.1” at 1531, not the assignment's line range. Preserve both lists and the process note.

“Verbatim” needs a qualification: preserve the source evidence, but repair relative navigation. The tracker repeatedly says “Vocabulary growth process above,” “Seventh growth round above,” and “Deliberately deferred ... below” (1464–1520); those targets leave the file. Replace those references with explicit destination links. Preserve originals in the historical copy/mapping if exact text retention is required.

Also surface, rather than silently reproduce as current truth, its already-existing status contradiction: the natural-disaster warning is under Open at 1228, recorded as promoted at 1470, and then called still Open again at 1504. Its vocabulary entry exists in YAML. This is a documentation-status conflict visible without any new catalog research. The gap-sweep skill still hardcodes “two Open entries” and the same old candidates at lines 60–90. Its required rewrite should tell readers to use the tracker's current Open list, with historical observations clearly dated. Do not turn this into a fresh sweep or quietly resolve genuinely uncertain gaps.

### 2. The remainder of the backlog is not all genuinely deferred

These passages remain after removing the tracker and audiobook entry:

| Existing location in book-dna.md | What must remain reachable as current information |
|---|---|
| 1628–1661, omnibus proposal | The proposed data model is deferred, but the current instruction to skip duplicate compilations is operational (1652); unpublished-book exclusions follow it. Preserve the rule in current scope guidance, linked to CLAUDE's archiving/scope policy, and archive the original proposal. |
| 1740 onward, `books.work_type` | An explicitly built bibliographic field with a rule against deriving it blindly from page count. Its current enum also includes `audio_original`, per `20260907140000_work_type_audio_original.sql`; the older two-value narrative cannot become the current contract unchanged. |
| 1904 onward, Series DNA | Built aggregation and leaf-series semantics, plus functions whose locations have since changed. Keep a short current discoverability pointer in core's series section; preserve the full dated reasoning in decisions/history. |
| 1942 onward, confidence/source layer | A built `book_field_confidence` table and `book_tropes` columns, source meanings and missing-row semantics. These are current data contracts used by tagging and QA, not optional future ideas. Put current contracts in the tables reference and retain their original account separately. |
| 1997 onward, post-read/DNF feedback | Explicitly built behavior with a subtle distinction between trope and field overrides. Preserve the historical explanation and provide a route for feedback/scoring work; do not relabel it an unbuilt proposal. |

This was already partly identified in Task 21's “Built confidence/source, Series DNA, and other mechanisms” finding. Fixing only audiobook editions leaves the broader classification problem intact.

The dated growth rounds also contain more than completed chronology. For example, the Foundation `prophecy` issue at 665–674 was explicitly left for a future tagging review, and cannibalism at 928–939 remains a rejected decision with a later owner-reconsideration request. Preserve their recorded status and routes. This review does not establish whether that Foundation tag was subsequently fixed; do not mark it resolved or reopen it without checking later history/live data in its own task.

### 3. “Categories” is not currently a complete, consistent vocabulary reference

At line 37 Markdown still lists `pov_count` as `single, multiple`; YAML at 72 has `single, dual, few, several, ensemble`. Markdown at 265 omits `multi_narrator` although its own later update and YAML at 506 include it. The trope header at 334 says 141 while the actual YAML contains 152 trope IDs and the document's closing dated count also says 152.

A literal identifier comparison finds **46 of YAML's 152 trope IDs absent from the pre-growth Categories/Scope text**. Examples include `cosmic_horror`, `infiltration_or_undercover_plot`, `predictive_social_science` and `secret_magical_bureaucracy`; some current definitions are instead embedded in the dated growth rounds. This is a pre-existing documentation problem, not a claim that the split deletes those vocabulary values. YAML already contains detailed comments for the checked examples, and the skills already require it.

Therefore do not describe the retained Categories text as the complete vocabulary without qualification. For this split, explicitly identify YAML as the exact exhaustive vocabulary and retain its mandatory read for tagging/sweeps. Correct known enum-summary discrepancies from established YAML/migrations, or explicitly label incomplete lists as examples instead of current enumerations. Keep current conceptual distinctions or direct links beside the field/group; historical per-book evidence can move. Do not force every tagger to read all growth chronology merely to recover current vocabulary, and do not remove YAML's definitions as supposedly duplicate history.

Other legacy text should remain visibly a proposal/history rather than acquire authority through relocation: core's spoiler-horizon design at 1006–1012 is not the shipped UI behavior described in TODO, and the First Law “not implemented” update at 1052 is superseded by the tracked `20260911200000_first_law_universe.sql`. A structural move need not audit every catalog fact, but it must not label every retained paragraph “current contract.” Annotate known supersession and link to the existing implementation record.

### 4. Rewriting the audiobook entry requires both preservation and a contract check

Keep `book-dna-tables.md` if it also houses the related current confidence and work-type contracts above. If the implementation deliberately limits it to one table, **`docs/schema/audiobook-editions.md` is a clearer name**. Either is reasonable; file count is less important than an obvious route from the core's Audiobook-native section and schema map. There is currently no other table-reference page in `docs/schema/`. Putting this only in the tagging skill would make read/UI consumers hunt through a write workflow again.

Do not replace the old account with a summary and discard the original. Archive the complete dated entry, then write a short current contract with links back to that rationale. The new reference needs:

- One-to-many edition identity, actual current `edition_type` values, and distinction between standard multi-narrator readings and dramatized productions.
- Flat narrator names, **not** character-role assignments; that richer cast model remains deferred.
- Runtime units/null meaning; release status and part counts; verification date and source URL.
- `release_date_start`/`release_date_end` semantics, including equal dates for one release and unknown end dates for unfinished releases. Distinguish a documented sourcing rule from a database-enforced constraint: the range migration adds nullable columns and comments, not a CHECK enforcing the policy.
- Explicit links to Tier A derivation and its mixed-edition ambiguity, Tier B's different evidence requirements, read access/RLS migrations, the research skill, and current consumers.

Use the create-table migration **plus subsequent alterations and access-policy migrations**, not the original entry alone. For example, the original create-table enum has only four values while the current skill/CLAUDE also describe audio originals. Verification of the complete final contract belongs to implementation acceptance; I did not query hosted schema in this review. Do not carry old counts such as “94 rows,” “backfill future,” or “every release date null” into timeless contract claims.

## Scalar-field gate: keep it in core

The full gate is **344 words** (1169–1207). Keep it next to the vocabulary-growth rule, with its existing link to the scoring protocol's ten-question gate. It applies **before proposing** a field, including when an ordinary tagging task discovers a possible new dimension; routing only declared schema-design tasks to history risks missing that transition.

Conditional loading is defensible in principle, and CLDO's cost argument is valid. In this concrete four-file plan, however, putting a normative gate in a file called history repeats the current problem, while a separate rules file for 344 words adds unnecessary indirection. Keeping it in core is a small, bounded cost and makes the change easier to verify. If a later task-class routing design moves it, require an explicit “before proposing any new scalar field, read and satisfy ...” link from both core and scoring protocol, with a stable anchor; an optional background pointer is insufficient.

Measured from existing text, the proposed retained core ranges contain 5,514 words before this gate; adding it makes **5,858**, still **70.1% below 19,578**. These figures exclude new routing links, corrected definitions and any current contract summaries; they are not final-file or tokenizer measurements. At the prior rough 1.3 multiplier the gate costs about 447 estimated tokens. Its retention does not undermine the main savings.

## Recommended four-file map

| Destination | Content and required readers |
|---|---|
| `book-dna.md` | Scope, field distinctions/current summaries, exact-vocabulary YAML link, known boundaries, actual spoiler/series guidance distinguished from proposals, current vocabulary-growth rule, scalar-field gate, small schema/task map. Preserve the existing global read obligation for this pass. |
| `book-dna-vocabulary-gaps.md` | Entire tracker through the process note, with navigable links and explicit current versus historical status. Required before tagging/gap sweeps and when assessing a suspected vocabulary gap. |
| `book-dna-tables.md` | Current related-table contracts: audiobook editions, confidence/source, and bibliographic `work_type` distinction; links to migrations, consumers, skills and retained rationale. Required for work touching those contracts, including UI/read paths. Avoid turning it into an unrelated all-database handbook. |
| `book-dna-decisions.md` | Prefer this name over `book-dna-history.md`: separate **deferred/open proposals**, **rejected/superseded decisions**, and **dated implementation/review history** within it. Preserve all original reasoning, including the complete audiobook entry. Read the relevant complete sections when revisiting/proposing a concept; vocabulary proposals must check prior rejections. |

Four files are enough. A fifth separate backlog file could make sense if the decisions document becomes difficult to navigate, but is unnecessary for this pass. A file called history can still work if its title, sections and all routes explicitly disclose its active deferred-proposal role; the name alone must not imply immutable or irrelevant content. Current rules belong in current references, not among proposals.

Opening growth prose is actually **194 words at 526–547**, before the first numbered historical entry at 548, not approximately 270. The following 548–940 span is 3,231 words. Retain the rule and its links; preserve the pilot precedent as history if desired. Whole-section dates alone are insufficient classification.

## Cross-file reference audit

CLDO's list identifies the four affected skills, but is incomplete both by file and by occurrence. These are edits/checks for the eventual implementation, **not applied here**:

| File / existing lines | Required treatment |
|---|---|
| `CLAUDE.md:8` | Keep the same core path; change its description and explicitly define required conditional routes. There is no path rename necessary for core. |
| `CLAUDE.md:45,561,654,792,841` | Update audiobook-discoverability, cover-variants, omnibus, audiobook contract, and future-idea logging destinations. The logging destination at 841 is especially important: otherwise new proposals keep accumulating in the supposedly compact core. |
| `CLAUDE.md:469` | Preserve same-session YAML/core/skill synchronization and specify the additional owning reference when a tracker/table contract changes. Do not require rewriting unrelated history on every new value. |
| `CLAUDE.md:235–249` | Historical worked example: preserve its meaning; optionally add a present-location pointer instead of rewriting the incident as if it happened under the new layout. |
| `AGENTS.md:16,302` | Core read pointer remains valid; avoid introducing an independent contradictory routing rule. The structural-review example is historical. |
| `tag-catalog-batch/SKILL.md:51,63,69,126,147,678,867` | Update tracker prerequisite and rationale claim; retain full YAML/evidence/mandatory-column checks. Section 3 field reference can remain if kept. Route Tier B rationale at 678 appropriately. The content-warning reference in the SQL comment at 867 must remain discoverable. |
| `catalog-trope-gap-sweep/SKILL.md:13,33,49,62,179,185,199` | Replace the monolithic full-read requirement with explicit core + full YAML + tracker + relevant rejected/deferred decisions. Update both reading **and writing** destinations; replace the stale fixed two-gap instruction. The existing rejection examples are still part of required proposal discipline. |
| `convert-romance-worldbuilding-fields/SKILL.md:14,70` | Original probe rationale goes to decisions; current field definitions remain core. Do not use this reference update to rerun the completed conversion. |
| `tag-audiobook-editions/SKILL.md:73` | Link the table contract and its retained rationale, replacing “backlog entry.” |
| **`docs/scoring-test-protocol.md:72`** | Critical missed operational reference: scalar-field gate currently addressed through Future fields backlog. Point directly to the gate in core. Line 1258 is dated history; retain it with navigation support. |
| **`docs/schema/book-dna.schema.yaml:3`** | Missed reference to “Open for review,” which moves. Preserve machine data, identify any status-comment correction separately; don't change `schema_version` as a side effect of splitting prose. General references at 210/285/292 remain valid if definitions stay core. Deferred comments at 850 onward should route to current decision status, especially cannibalism. |
| **`docs/TODO.md:13,19,52,88,92,121,122`** | Update current ownership of ideas/tracker and contextual pointers. At 52, bounded log reading is already implemented; update the stale next step. Historical completed-item narration need not be rewritten, but its live tracker links should work. |
| **`README.md:145,321`** | Core schema link still works; update the layout description that currently promises “schema spec + roadmap backlog,” and list the new references. |
| **`scripts/scoring/api.py:107`, `scripts/scoring/constants.py:183`** | Rationale references for diversity/fatigue move to decisions. Comment/docstring-only navigation updates; no scoring redesign or behavior changes. |
| `scripts/recommend.py:11` | General neutral-data reference remains core; no relocation edit inherently required. |

The code references above point to existing rationale; I am not evaluating or proposing the underlying scoring design. Some comments themselves are dated/stale and need care before being described as present behavior.

**Historical references should not trigger blanket rewrites.** Migration comments, project-log entries, prior CODX reports, pilot/remaining-catalog findings and `docs/recommendation-engine/v1-findings.md:20,111` also mention the old document. Preserve append-only history and already-applied migrations. A short old-heading forwarding section/schema map can keep such references useful; where real fragment links exist, retain their anchors with forwarding links. The original raw passages remain verifiable in the decisions archive and git history. Current assignment text is also an immutable input to this review, not an instruction to edit its historical description.

**Correction to my Task 21 wording:** `docs/persona-workflow.md` has no literal `book-dna.md` reference at this revision. It matters for broad routing policy, not as a schema-split path replacement. Its line 38 still says project-log “tail”; the gap-sweep prerequisite does too. Those are bounded-read consistency follow-ups, not reasons to invent a nonexistent schema link.

Also audit **internal prose navigation**, not just filename matches: “above,” “below,” “section 3,” and references to “Resolved during review” or “Vocabulary growth process” can silently become wrong while every Markdown URL still resolves.

## Task 21 follow-through and acceptance criteria

Fold the **small discovery/routing map** into this split: tagging → exact YAML + tracker + evidence skill; vocabulary proposals → relevant rejected/deferred decisions; new scalar proposals → gate + scoring protocol; audiobook/UI work → edition contract + relevant skill; confidence work → source/absence semantics. These routes are necessary to make the moved content discoverable.

Defer the **larger change to global reading obligations by task class**. Removing the requirement to read core for infrastructure-only tasks is a separate methodology change affecting CLAUDE, AGENTS and persona workflow. Measure it and review it explicitly; don't smuggle it into a relocation. Global authorization, credential, migration and review gates stay mandatory. Likewise, do not add an always-read chronological index or retrieval infrastructure to this pass.

Before landing implementation, require these bounded checks:

1. An old-section/paragraph-to-destination manifest accounts for all 2,306 original lines. Preserve full rationale before rewriting current summaries. Treat stale wrapper headings separately; do not silently discard paragraphs based on a “future” heading.
2. Repeat the tracked-file and hidden-skill reference audit. Classify remaining references as valid core, updated destination, or intentionally historical with a working route. Check internal above/below pointers and retained fragment anchors.
3. Verify current enums/contract summaries against YAML and relevant migration chains; consult hosted read-only schema/data only where a present-state claim needs it. Don't use historical counts as current guarantees. Do not relax existing schema/skill synchronization checks.
4. Run fresh-context retrieval walkthroughs for an ordinary tagging batch, a gap promotion/rejected proposal, an audiobook modal, a scalar-field proposal, and a confidence QA task. Each must reach its required rules and evidence without reading all history. Include a compilation/unpublished candidate and a multi-edition narrator ambiguity as boundary cases.
5. Record actual loaded words/estimated tokens and which required constraints were found. The savings calculation alone is not proof of retrieval success; the new files do not yet exist, so these acceptance exercises have **not** been run here.

The broader Task 21 suggestions—slimming CLAUDE/AGENTS incident narratives, routing from assignments, and measuring across personas—remain worthwhile follow-ups. Keep append-only project-log history intact and leave CLDO to record the implementation decision. No additional schema or scoring change is needed to perform this split.

## Evidence and commands

Synced `0794845` → `e032a76` with `git pull --ff-only`. The initial attempt correctly refused to overwrite the previous untracked round-3 report/evidence, now tracked upstream. Preserved the local originals at `/private/tmp/codx-round3-before-sync`, then the retry fast-forwarded successfully. Hook configuration remains `.githooks`.

Read the schema in contiguous chunks, the current assignment, Task 21 report, TODO, governing instructions and relevant skill/reference sections. Read the newest three complete project-log entries: 769 words, under the 1,500-word cap. Used local repository evidence only; no web research, database access or scoring tests were needed. Truncated read/search outputs were followed by narrower reads and a tracked-file scan.

Key repeatable searches:

```sh
rg -n '^#|^Deliberately|^\*\*Second|^\*\*Promoted|^\*\*Process' docs/schema/book-dna.md
rg -n --hidden 'book-dna\.md|Future fields backlog|Flagged single-occurrence|Vocabulary growth process' README.md CLAUDE.md AGENTS.md docs/persona-workflow.md docs/scoring-test-protocol.md scripts .claude/skills
rg -n 'book-dna|human-readable|Future fields|backlog' docs/schema/book-dna.schema.yaml
git config --get core.hooksPath
git diff --exit-code HEAD --
```

A Python scan of UTF-8-readable paths from `git ls-files`, testing literal `book-dna.md`, found **47 tracked files** (including historical migrations/log/reports). This supplements `rg`'s normal ignore handling and found the historical v1 findings reference too. Word counts used `len('\n'.join(lines[start-1:end]).split())`; core spans were 1–547 and 941–1065, plus the optional gate at 1169–1207. Actual output:

```text
whole 1-2306 19578
growth_intro 526-547 194
growth_rounds 548-940 3231
scalar_gate 1169-1207 344
proposed_gap_range 1208-1457 2241
full_gap_tracker 1208-1530 2755
omitted_tracker_tail 1458-1530 514
CORE_OLD_TEXT 5514 WITH_GATE 5858 reduction 70.1
YAML_TROPE_IDS 152
ABSENT_FROM_CATEGORIES_AND_SCOPE 46
```

The trope comparison extracted IDs with `r'\{id: ([a-z_]+), group:'` and searched each as an identifier in text before `## Vocabulary growth process`; it measures textual coverage, not semantic equivalence or live DB validity. Final tracked diff was empty. This report is a critique and a bounded implementation checklist, not a claim that the new structure has already passed validation.
