# Task 26 — cheaper full reads without relaxing them

2026-09-28 · CODX · review/proposal only · synced assignment baseline `764076b`.

Recommend fixing the measurement counter first, then testing lossless bounded delivery. There is a small, mechanically provable convention-notice deduplication opportunity. Do not replace the full YAML with a compact vocabulary, or count moving DONE material as a saving. All full-read obligations, A/B/C/D, universal safety gates, and persona rules remain unchanged.

Two premises in the assignment need correction: the scalar agent did not receive the entire tagging skill, and the possession-trope agent's attempted full-YAML command returned only a persisted-output preview. Checklist quality passed 7/7, but that is not proof of full-read compliance. Increasing genuine compliance may increase measured cost even after these optimizations.

All implementation proposals, reproducible scripts, counts, and candidate documents are in `docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/`. No tracked file was edited, no database accessed, no scoring suite run, and no commit or push performed.

## Baselines and interpretation

The source snapshots are before `ec00669` and after `65cbe69`, matching the recorded experiment; the assignment was read at `764076b`. Counts below use the experiment snapshots rather than silently substituting today's files. For example after-arm TODO is 3,017 words, versus 3,063 at current HEAD. The protocol's approximately 3,012-word description is not the exact after snapshot.

Recounting all 14 actual JSONL transcripts preserves every original `total_words`. The counter corrections change attribution, not delivered cost:

| Same prompt | Before actual | After actual | After with fresh injection, arithmetic only |
|---|---:|---:|---:|
| R1 tagging | 24,435 | 24,820 | 20,478 |
| R2 scoring | 24,147 | 38,841 | 34,499 |
| R3 CI | 10,370 | 12,020 | 7,678 |
| R4 UI | 10,485 | 13,665 | 9,323 |
| R5 scalar | 27,754 | 60,972 | 56,630 |
| T1 audiobook panel | 18,952 | 26,897 | 22,555 |
| T2 possession trope | 21,552 | 35,375 | 31,033 |

The last column subtracts the known stale-injection difference of 4,342 words. It is **not a fresh-session rerun** or a prediction of the proposed reader's performance. These historical runs also have prompt/checklist contamination, repeated reads, and incomplete reads. Do not subtract the static savings below from these totals and call the result a compliant experiment.

## 1. YAML compact vocabulary: do not substitute it for a full read

The after YAML is 11,239 `wc -w` words across 877 lines. It has 472 full comment lines containing 4,062 prose words after comment markers, plus approximately 5,025 inline-comment prose words: 9,087 words, about 81% of the file. These lexical counts do not establish redundancy. The comments carry distinctions, evidence standards, examples, and caveats; a one-line definition cannot mechanically preserve all of them.

A generated IDs/values index can help navigation, but making untouched entries' complete text optional would relax the settled obligation. Reject that substitution. Removing only the standalone full-line comment markers saves 472 words, but would produce a different reading format and still leave almost all the prose. No such transformation is recommended here. The comment audit is a textual count, not a YAML parser proving that every `#` has semantic comment status.

The useful alternative is preserving the complete source while eliminating repeated searches and line-number overhead. See the bounded-reader proposal below. No YAML authority or schema entry changes. There is no claimed content saving for this lever on any of the seven routes.

## 2. Tagging skill DONE companion: possible navigation change, not a saving

The two historical Step 0 sections total 1,481 words. Their calibration method is reused by active Step 0, so moving them requires an explicit pointer and preserved anchors. Any invocation subject to the current full-skill obligation must still read **both files completely**, including historical SQL and calibration examples; it cannot read only the touched example.

The supplied candidate split measures:

| Form | Words |
|---|---:|
| Original skill | 8,025 |
| Candidate main, including full-read pointer | 6,567 |
| Companion, including heading | 1,485 |
| Combined candidate | 8,052 |
| Change | +27 |

The split therefore saves zero mandatory information and adds navigation overhead. Do not adopt it as a cost optimization. If adopted later for maintainability, require a byte-preserving extraction/reconstruction check, verify links and calibration reachability, and count both reads. The prototype candidates demonstrate extraction, not an approved production link migration.

For the same seven routes, keeping the skill intact means before/after costs are unchanged. A full-skill route such as R5 would be 8,025 → 8,052 if the candidate split were adopted; any other route that invokes the full skill has the same +27, never −1,481. Other routes get no saving from this lever.

The recorded R5 skill total of 5,567 is not a full 8,025-word delivery: its commands read lines 1–200, 200–310, and 679–1060, plus headings. Lines 311–678 include active material, not only DONE history. Exact matched coverage is 601 of 918 nonblank lines. Do not optimize against that under-read as if it were compliant.

## 3. Genuine duplication: only deduplicate exact, scoped text

The six conventions files repeat the same 70-word moved-convention notice. That is demonstrable overlap, including the notice's scoping language. Inspection of normalized paragraphs of at least 15 words across the schema core, YAML, relevant conventions, and skill did not establish another equally safe cross-file extraction. This is not a claim that conceptual repetition is absent.

Some superficially similar definitions are not interchangeable: older POV descriptions and the expanded allowed vocabulary differ; narrator-count descriptions do not all express the newer `multi_narrator` distinction; romance evidence instructions contain different qualifications. Do not collapse those passages without a separate semantic review and route-reachability proof.

The optional generated route bundles preserve each complete convention body and include the identical notice once, explicitly applying it to every bundled source. Authorities stay in their original files. The generator asserts identical notice bytes and verifies source reconstruction. Source SHA-256 values and the removed notice's insertion offsets are in each manifest. If any notice differs, generation fails instead of discarding it.

These are exact static `wc -w` comparisons for convention components of the same routes, **not whole-task forecasts**:

| Route | Original convention inputs | Bundle | Saving | Bundle with page receipts |
|---|---:|---:|---:|---:|
| R1 tagging | 3,533 | 3,415 | 118 | 3,447 |
| R2 scoring | 1,439 | 1,388 | 51 | 1,404 |
| R3 CI | 317 | 317 | 0 | 325 |
| R4 UI | 644 | 644 | 0 | 652 |
| R5 scalar | 4,259 | 4,074 | 185 | 4,114 |
| T1 audiobook panel | 4,177 | 3,992 | 185 | 4,032 |
| T2 possession trope | 2,040 | 1,989 | 51 | 2,005 |

The route inputs are recorded in `measure_forms.py`: R1 tagging/database/catalog; R2 scoring/catalog; R3 backups; R4 web; R5 tagging/database/catalog/scoring; T1 tagging/database/catalog/web; T2 tagging/catalog. These describe the tested components, not a replacement routing contract. Additional applicable conventions must still be read.

Risk: a shared banner can appear detached from its source, or a stale bundle can omit a newly applicable file. Keep explicit source headings, generate from the current revision at invocation, fail on hash mismatch, and validate the resolved route's complete source set. The prototype is deliberately pinned to the after snapshot for measurement; it must not be shipped as a permanent frozen reading authority. Production work would add a generator/check command and generated manifests, plus reader-routing documentation. No source-of-truth move is warranted yet. Given savings of only 0–185 words, test whether this extra machinery is worth maintaining before adopting it.

## 4. Project log: the 4.9k figure is mostly misattributed TODO

R2's old log bucket was 4,934 words. Its combined command included `cat docs/TODO.md | head -144`, which delivered the entire 144-line TODO. Those 3,017 words were attributed to the first mentioned path, the project log.

Subtracting TODO leaves an upper bound of 1,917 words of log-related/other command output, not 4,934 words of history. Exact source matching proves 1,531 log words: 1,268 from the bounded three complete recent entries and 263 from a targeted passage. The remaining 386 words are counts, headings, search output, or other unattributed output; do not relabel all of them history.

There is no evidence here that the contract's bounded-read requirement needs narrowing. Reading a directly relevant protocol first may improve navigation, but it must not replace the required recent entries or relevant reversal history. Recommend no rule change and claim **zero word savings on all seven routes**. Separate bounded baseline history from additional targeted searches in future measurements. A navigation-order experiment would require its own actual rerun before assigning a saving.

## 5. TODO: two attribution artifacts and a real under-read

| After route | Raw evidence | Verdict |
|---|---|---|
| R2 | `cat docs/TODO.md \| head -144` in 3,083-word combined output; all 3,017 TODO words match snapshot | Full TODO, old bucket wrong |
| R3 | Daily/backup searches and limited matching lines | Incomplete TODO |
| T2 | `sed -n 60,200p docs/conventions/catalog.md; cat docs/TODO.md`, 3,181-word output | Full TODO; 3,017 words wrongly assigned to catalog |

R5 also delivered full TODO. R1 delivered fragments; R4 has no TODO delivery; T1 has release-date search fragments. Before-arm runs also fail the conservative complete-source coverage check, so these data do not establish that D caused omissions. Exact matching is a lower bound for transformed output, but the actual commands corroborate the specific missing-read findings above.

Keep D's shorter TODO. Reinforce the existing obligation operationally: deliver that current complete file once, check output completeness, and reuse the retained content rather than grep as a substitute. No new permission gate or larger backlog file is needed. At the pinned snapshot a plain full TODO costs 3,017 words on **each of the seven routes**; after this correction it still costs 3,017. A receipt-paginated form costs 3,049. A line-numbered form costs 3,161. Restoring a skipped read adds real delivered words; it is not a saving. Prefer a single unnumbered read when the tool demonstrably returns the entire file.

## 6. Counter: proposed diff and limits

`counter.patch` proposes changes to `scripts/measure_context_load.py`. It does not execute recorded shell commands. It gathers candidate paths, including simple `cd` plus relative `cat`/`sed` operands, and matches returned lines against explicitly pinned git source text. A combined command is no longer assigned wholesale to its first path. Complete command inputs are retained, rather than cutting them at 160 characters.

A persisted-output marker records its originating tool ID and source candidates. Only a later actual Read result counts as additional delivered text; the counter never opens a saved output file on the agent's behalf. Read line prefixes are counted separately as delivery overhead. Ambiguous shared lines, unmatched text, and complex shell output remain explicitly unattributed. Error output is separate. Repeated reads still count repeatedly. Repeated instruction attachments are accumulated rather than overwriting earlier injections.

The output records source line spans, full-source matches, origin IDs, persistence markers, and per-event word partitions. Every partition sums to that event's actual returned words. All 14 recorded totals remain identical (table above): before/after cost savings for this recommendation are **zero for every route**.

Limitations: this is conservative exact-text attribution, not a general shell interpreter, semantic reader, or proof of comprehension. Small fragments below the match threshold, grep prefixes, dirty source content, changed paths, and complex pipelines may remain unknown. A wrong reference revision must not be treated as proof of omission. Source-span unions establish delivered nonblank text, not retention. The existing token-usage aggregation is retained, not independently validated as a billing counter. The original repository-path normalization remains specialized to these transcripts.

The raw events correct two other misleading labels:

- R5 and T2 core reads were first persisted, then actually Read back. Each delivered the 5,430-word core. The approximately 6,093-word Read result includes numbered lines, so its attribution to `tool-results/...` hid both source identity and formatting overhead.
- T2's attempted full YAML used `cut -c1-260 ... | sed -n 1,877p`. The result was a 329-word preview, and the saved output was never Read. Other YAML commands covered fragments and sometimes truncated characters. Exact matched coverage is only 146/858 nonblank lines. R5, by contrast, covered all 858 through its combined ranges, despite repeats and a gap between its two large Reads that an earlier command filled.

## Additional recommendation: lossless bounded delivery

`reader.patch` proposes `scripts/read_full.py`; the standalone prototype is also supplied. It emits one byte-bounded UTF-8 page with source name, whole-file SHA-256, part count, and byte interval. It preserves every source byte, splits at whitespace rather than clipping characters, and fails if an unbroken token exceeds the configured budget. Later pages can require the first page's hash. Read **all advertised pages**, and restart if the source changes. A failed, previewed, or truncated page is not a completed read.

The prototype uses a 7,000-byte body budget. This is a test choice, not a guarantee of any tool's output limit; validate actual returned bodies and reduce the page size if necessary. Empty files have no body pages. The helper prints receipts but does not itself maintain a cross-call completion ledger: the retest harness must verify contiguous byte coverage and hashes. Do not infer completion from an agent's claim.

Static measurements of equivalent full source information:

| Source | Plain words | Numbered form | Receipt pages | Paged words | Saving vs numbered |
|---|---:|---:|---:|---:|---:|
| YAML | 11,239 | 12,116 | 14 | 11,351 | 765 |
| Schema core | 5,430 | 6,092 | 6 | 5,478 | 614 |
| Tagging skill | 8,025 | 9,061 | 9 | 8,097 | 964 |
| TODO | 3,017 | 3,161 | 4 | 3,049 | 112 |

The modeled core has 662 numbered lines; the actual tool added an extra numbered empty line in its 6,093-word result. This explains the one-word difference. Plain complete output is cheaper than receipts; use paging for oversized output, not indiscriminately for small files.

For the same seven prompts, the following **selected full-read component model** compares numbered source delivery to paged delivery. It includes TODO on every route, core on R1/R2/R5/T1/T2, YAML on R5/T2, and full skill on R5. Other applicable material remains required and is outside this component table; neither column is a complete route budget.

| Route | Numbered components | Paged components | Formatting saving |
|---|---:|---:|---:|
| R1 | 9,253 | 8,527 | 726 |
| R2 | 9,253 | 8,527 | 726 |
| R3 | 3,161 | 3,049 | 112 |
| R4 | 3,161 | 3,049 | 112 |
| R5 | 30,430 | 27,975 | 2,455 |
| T1 | 9,253 | 8,527 | 726 |
| T2 | 21,369 | 19,878 | 1,491 |

These are conditional formatting savings, not savings against each actual run's mixture of Bash, Read, repeats, and omissions. Page headers and extra calls can offset word/token savings. The actual retest must measure those effects and task quality. No content is intentionally lost. Verify byte reconstruction, source hashes, every page receipt, and actual tool returns; never use `cut -c` to fit the output.

## Validation and reproduction

Run from this clone. All commands operate on proposals and read-only transcript/git evidence:

```sh
python3 docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/test_proposals.py
python3 docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/audit_transcripts.py
python3 docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/measure_forms.py
git apply --check docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/counter.patch
git apply --check docs/codx-reports/2026-09-28-read-cost-without-relaxing-evidence/reader.patch
git diff --exit-code
```

Results: eight unit tests pass; all 14 original total-word counts are preserved; both proposed patches pass applicability checks. `measure_forms.py` invokes real `wc -w`, generates the candidate forms and manifests, and checks byte reconstruction during generation. Unit coverage includes multi-source attribution, numbered overhead, ambiguous/missing sources, long commands and relative paths, persistence lineage, errors, repeated injections, UTF-8 page reconstruction, oversized-token failure, and stale-hash rejection. See `test-output.txt`, `audit-output.txt`, `audit-summary.json`, and `form-measurements.json` for real output. Raw transcripts are read from the exact paths already recorded in the experiment evidence; no full private transcripts are copied into this report.

## CLDO retest specification

1. Freeze identical task source revisions for control and treatment. Keep A/B/C/D and all full-read obligations identical. First validate the counter against both arms; then test the bounded reader alone. Test convention bundling separately if its small saving justifies the complexity. Do not mix skill/YAML content omissions into treatment.
2. Use the exact same seven task prompts and pre-registered quality checks. Store harness prompts, checklists, expected outputs, and new measurements outside the agent-visible repository **until all arms finish**. Existing committed `docs/codx-reviews/context-load-e/` prompts/checklists are also contamination sources: exclude them from both evaluation fixtures, and prevent agents from retrieving them through git history or sibling checkouts. An isolated exported fixture with identical legitimate task files is preferable to a working tree whose history still exposes answers. Give the agent its own task prompt, never the grading checklist.
3. Start a genuinely fresh parent/session for each independent run, not a child of the old experiment session. Record the exact injected CLAUDE.md and memory hashes/word counts. Reject stale injection; do not merely subtract 4,342 afterward. Keep model, tools, permissions, and source content matched between arms.
4. Record every actual tool return, tool ID, full input, error, persisted preview, subsequent saved-output read, and injected attachment. Record tool/runtime versions and pinned source revision. Use the revised counter for both arms, reporting total words, proven source words, overhead, unknown words, repeated reads, and token/context metrics separately.
5. Check compliance independently of answer quality. TODO must arrive completely on every applicable nontrivial route. The complete core, YAML, skill, and conventions must arrive whenever the existing route requires them. For reader pages, verify hashes and contiguous byte intervals from zero to file length, and compare the returned body bytes to the source. A receipt without its body does not pass. For bundles, reconstruct each source and verify the applicable source set. Count all headers/tool output in cost.
6. Negative controls: omit a middle page, change a source between pages, exceed the tool output budget, return a persisted preview without reading it, introduce a long line, and make two candidate sources share text. The harness must reject incomplete reading, while the counter must preserve ambiguity and total returned words. These are harness checks, not extra user approval gates.
7. Grade the original quality checklist blind to treatment and separately grade full-read compliance. Report each of the seven routes, not only an average. Repeat both arms if budget permits (three independent runs per route gives 42 runs); a single paired pass is exploratory. A cheaper incomplete run is not a successful treatment. Do not promise lower whole-task totals until measured, particularly where the old run omitted mandatory information.
8. After every arm is finished, publish prompts/checklists, hashes, counters, outcomes, and the complete comparison. Apply any production change only after CLDO review; this task supplies proposals, not authority to alter the reading contract.
