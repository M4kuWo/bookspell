# Task 21 — context-load review

CODX, 2026-09-25; reviewed synced commit `1c02f1c`. Review/proposals only. No documentation restructuring, source changes, DB access, or commits. Task 20 remains deferred. This report is the sole new deliverable; CLDO owns the resulting project-log decision entry.

## Assessment

**Keep the objective, modify all three proposals.** The immediate win is an explicit, bounded startup procedure with task-dependent reading. A schema split helps substantially, but a mechanical backlog split and an always-read chronological index would leave a large fixed tax and introduce missed-rule risks. Retain every historical detail; change what gets loaded and how authoritative material is found.

Local measurements support the assignment's diagnosis. These are whitespace-separated word counts, not model-tokenizer measurements; token estimates use the assignment's rough 1.3 multiplier.

| File / section | Words | Approximate tokens |
|---|---:|---:|
| CLAUDE.md | 6,870 | 8,931 |
| AGENTS.md, additional CODX instructions | 2,989 | 3,886 |
| TODO.md | 4,383 | 5,698 |
| book-dna.md | 19,578 | 25,451 |
| Its Future fields backlog section | 9,880 | 12,844 |
| Everything left after removing that section | 9,698 | 12,607 |
| scoring-test-protocol.md | 30,803 | 40,044 |
| project-log.md | 185,627 | 241,315 |
| All 358 project-log H2 headings alone | 5,213 | 6,777 |

CLAUDE + TODO + schema total approximately **40,080 tokens before history**. CODX additionally reads AGENTS. The exact CLAUDE wording is “before making non-trivial changes,” rather than literally before every trivial action; its broad scope still imposes the reported burden on nearly all substantial tasks. This review does not assume that tools inject these files identically or that word counts equal billable input tokens.

## 1. Schema core versus backlog/rationale — MODIFY, high value

Removing Future fields backlog alone halves the schema document, but leaves about 12,600 estimated tokens. `Categories` is 3,945 words, `Vocabulary growth process` 3,425, and `Resolved during review` 827. Thus substantial historical narrative exists outside the proposed cut. A split at one heading is neither a complete reduction nor a sound division of current versus optional knowledge.

More importantly, the backlog contains **operational material**, not just speculative fields:

- The “Flagged single-occurrence vocabulary gaps” tracker is an active pre-tagging checklist. `.claude/skills/tag-catalog-batch/SKILL.md:69` explicitly requires it before tagging, not merely before proposing a new field.
- The backlog's `audiobook_editions` entry documents an already-built table and its rationale (`book-dna.md:1544` onward). The audiobook skill points there. Making it discoverable only to schema designers would recreate the exact “table exists but the UI implementer missed it” failure documented in CLAUDE.md.
- Built confidence/source, Series DNA, and other mechanisms also appear under “Future” headings. Location currently does not reliably encode lifecycle status.

Recommended boundaries, with provisional filenames rather than an implementation prescription:

| Material | Treatment and readers |
|---|---|
| Current values, definitions, distinctions, applicable evidence rules | Compact schema reference. Read the relevant field families for bounded work; tagging and vocabulary sweeps still need the full applicable vocabulary. |
| Open vocabulary-gap tracker and promotion criteria | Separate operational tracker, required for tagging/gap sweeps. Link prominently from the core reference and relevant skills. |
| Current contracts for implemented related tables | Discoverable table/reference pages, linked by a small schema map. An audiobook UI task must reach edition semantics without guessing that they live in a backlog. |
| Deferred proposals, resolved decisions, chronology | Preserved rationale/history, read when revisiting or changing that topic, or when a current rule points there. |

Do not reproduce a current rule independently in three new places. Give each rule one authoritative home; other files link to it. Keep a short rationale or rationale link beside subtle constraints: removing all “why” text would encourage the same mistakes to be rediscovered. Historical rationale usually needs a superseding decision appended or linked, not continual rewriting to resemble the current implementation.

Updating CLAUDE alone is insufficient. `AGENTS.md:14`, the persona workflow, tagging skill, gap-sweep skill (explicit full-schema read), conversion skill, and audiobook skill contain overlapping instructions or section references. Inventory and update those references together. Preserve existing anchors with forwarding pointers where practical; use a link check or explicit reference audit for moved headings. The existing schema YAML/Markdown/skill synchronization convention must survive the split with its exact authoritative targets clarified.

Keep append-only history untouched. For current reference reorganization, preserve all source passages and a verifiable old-section-to-new-location mapping; no lossy summarization should substitute for archival content. Any move of immutable historical material should remain a proposal until its preservation semantics are explicit.

## 2. Chronological project-log index — MODIFY; reject an always-read full index

A separate index is preferable to embedding it atop the log: it leaves historical bytes unchanged, is cheap to open independently, and separates generated navigation from human-written evidence. But **358 headings already cost about 6,800 estimated tokens**. Reading the whole index every startup simply creates another linearly growing tax.

Use the index as a searchable navigation artifact, not mandatory reading. Prefer deterministic extraction of existing headings over hand-written summaries. Existing headings currently have no exact duplicates, but future entries should not rely on that accident: generated records should distinguish duplicate headings deterministically. Store source path, exact heading, and a generated line/anchor locator. Include the source content hash so stale locators can be detected. Line numbers are conveniences, not durable cross-references across edits; verify the heading at the destination.

Two reasonable implementation sizes:

- **First:** an on-demand, local heading search. `rg -n '^## ' docs/project-log.md` already provides the navigational substrate with zero second file to maintain. Filter its output before displaying it. Search body text too: a heading is not an exhaustive description of its entry.
- **Later, if useful:** a committed generated `project-log-index.md` plus a small stdlib generator and CI `--check`. Do not ask each persona to remember to hand-update a second chronology. Generation after a merge and CI freshness checking address drift and merge collisions without a service.

An index misses concepts not named in headings and has recall limits even if perfectly fresh. It cannot replace the task's governing rules or a targeted read of the relevant full entry. Do not treat “not found in heading index” as “never discussed.”

## 3. Search instead of linear reads — KEEP, with a retrieval procedure

Make this explicit, but scope it carefully. Search is excellent for locating evidence; it is not a substitute for reading mandatory safety/authorization rules or a whole applicable procedure. Grepping only for the anticipated answer can miss exceptions, negations, renamed concepts, and later reversals.

Proposed procedure:

1. Read the compact global rules and current assignment/task selection source.
2. Identify touched systems from paths/tables/functions; follow their routing links to current contracts and applicable skills.
3. Search exact identifiers plus human names/known synonyms across current docs and history. When a hit matters, read its complete containing section, including caveats.
4. Search later entries for reversals, supersession, or rejected variants. For scoring changes, retain the protocol's full pre-change obligation and ten-question gate until CLDO explicitly revises it; this proposal does not waive it.
5. If output is truncated or a result set hits a limit, narrow and continue. Truncation is incomplete retrieval, not successful reading. If evidence remains ambiguous, broaden the search or report uncertainty.

Useful existing-tool patterns, not new tooling dependencies:

```sh
rg -n '^## ' docs/project-log.md
rg -n -i 'audiobook_editions|narrator_cast' docs .claude/skills CLAUDE.md
git diff <last-reviewed-commit> HEAD -- CLAUDE.md AGENTS.md docs/codx-tasks/current-task.md
```

The first command is a candidate locator; do not dump its full output into every session. The third is valid only when the session genuinely retains the earlier content. A fresh session cannot claim to know a baseline merely because a checkpoint records its hash.

## Additional ideas grounded in this repo

**Bound startup by purpose, not by “last N lines.”** A proposed default is the three most recent complete log entries, capped at 1,500 words total. If an entry exceeds the remaining cap, read its heading and retrieve that whole entry only when relevant; disclose the omission. The current last three happen to total 530 words, but a count-only rule can explode when one entry is a large batch report. A line-only tail can begin halfway through a caveat. This bounded window gives orientation, not proof that all relevant history was reviewed. Assignment links and topic searches supply older context.

**Use the assignment as the retrieval starting point.** CODX already receives a versioned, bounded task file. Future assignments could include a short “required current references / relevant decisions / out of scope” list. This is task-specific navigation, not another summary of all project history. CLDA's TODO-driven selection and CLDO's broader coordination still need their own routing; do not assume all personas receive CODX-style assignments.

**Shrink routing instructions before shrinking evidence.** CLAUDE's persona section is 1,105 words, migrations 1,423, and tagging 1,181. Many rules have long incident histories attached. A later pass can retain the imperative, applicability condition, and rationale pointer in startup context while preserving the entire incident account in linked reference/history. Never move permission boundaries, credentials restrictions, destructive-action gates, or required task routing behind optional search. AGENTS also repeats long environment incidents; slimming only CLAUDE leaves CODX a separate fixed burden.

**Route by task class.** A tiny map can direct scoring work to its protocol and engine contracts, tagging to full vocabulary/evidence guidance and the active gap tracker, audiobook/UI work to edition contracts and relevant skills, and infrastructure-only work to infrastructure rules. A CI fixture task does not need every proposed future Book DNA field. Generic work must still load global constraints. This gives larger savings than permanently requiring a somewhat shorter schema for every task.

**Separate live state from historical evidence without duplicating both.** TODO is the mutable priority source; current task files are assignments; schema references are contracts; project-log is evidence. Add an owning path and status link rather than copying whole histories into TODO or a new “context summary.” A new manually maintained universal session summary would become another drift source, so I would not add one now.

**Measure retrieval success as well as size.** Before and after any restructuring, run several cold-start exercises: Task 19-style fixtures, one tagging batch, an audiobook modal change, a scoring proposal, and a migration task. Record loaded words/estimated tokens, required constraints found, and time to reach the relevant evidence. Require the active gap tracker, edition table contract, rejected-scoring history, and permissions to remain discoverable. Re-run with different personas/tools where available; one tool's success does not establish another's behavior.

**Defer heavier approaches.** I do not recommend external RAG/vector infrastructure now. Its freshness, indexing, access, and evaluation machinery are harder to justify than local search over a small number of Markdown files, and semantic similarity alone does not establish the current authoritative rule. ADR-style durable decision pages may help future decisions, but retroactively converting every log entry would be substantial clerical work with little immediate startup benefit. Monthly log sharding also does not solve retrieval by itself and risks existing links; leave the append-only log in place first.

## Prioritized next steps

1. **First, agree and implement the bounded startup/routing contract.** Define the history window, distinguish always-needed constraints from task-specific reference reads, and update overlapping instructions in CLAUDE, AGENTS, persona workflow, and relevant skills together. Retain all underlying detail. This is worthwhile even if no files are split and no index is built: it directly removes undefined loading obligations rather than relocating them. The exact 3-entry/1,500-word limit is a proposed starting budget, not a measured optimum.
2. **Then classify and split the schema by current contract, active tracker, and rationale/history.** Preserve text and links, and prove the five retrieval exercises still find the required constraints. Use the measured section sizes to target both backlog and growth chronology. Add a generated searchable log index only if heading/body search remains an actual bottleneck; never add it to the fixed read list.

Potential savings are estimates, not a verified implementation result. The backlog-only split could remove about 12,844 estimated tokens per broad-schema read but leaves roughly 27,236 across CLAUDE, TODO, and the residual schema. Task routing can avoid most schema loading entirely for unrelated work without sacrificing thorough schema reading for tagging.

## Evidence and limits

Counts were produced locally with Python `Path.read_text().split()` and `splitlines()`; H2 sections were delimited by `re.split(r'(?=^## )', text, flags=re.M)`. Log headings were extracted with `re.findall(r'^## (.+)$', text, re.M)`, giving 358 entries, 5,213 heading words, and no exact duplicate headings. Current sections, skill entry points, AGENTS, persona workflow, log tail, and changed TODO were inspected directly; `git diff` confirmed CLAUDE/schema were unchanged from the preceding reviewed task. Reported line references are for `1c02f1c`.

No external research was necessary for these recommendations: the decisive examples and constraints are in this repository. I have not measured actual tokenizer usage, tool-specific automatic context injection, model recall after a split, or retrieval accuracy across the three personas. Those are the acceptance experiments proposed above, not established benefits.
