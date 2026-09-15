# CODX Task 2: recommend.py structural audit and refactor proposal

Date of original audit: 2026-09-15.
Report reconstructed: 2026-09-15, from the actual conversation and retained tool output.
Status: proposal for CLDO review; not implemented.

## 1. Purpose, scope, provenance, and handoff

The repo owner asked CODX to improve maintainability incrementally without changing recommendation behavior absent clear evidence. Task 2 had three phases: audit the current scoring paths, run the canonical scoring suite through the new codx_readonly Postgres connection, then propose at most three changes anchored to the existing Phase A refactor plan. The owner explicitly prohibited implementation and file modifications during that task. CODX delivered the result in chat but did not create a report. This file repairs that handoff omission under the updated AGENTS.md convention.

The original audit examined commit `bf480b7d373a4db29a7bbf28a9dfd3ef02743d9f`. Line numbers below refer to that revision. The reconstruction task subsequently ran `git pull --ff-only`, advancing this clone to `8ee6740`; the fast-forward changed AGENTS.md, docs/TODO.md, and docs/project-log.md only. It did not change the audited engine or tests. No database requests were made during reconstruction.

Task 2 read root AGENTS.md, CLAUDE.md, the prior report at docs/codx-reviews/codx-recommend-review-2026-09-14.md, the September 14 fix writeups in docs/scoring-test-protocol.md, the GPT/Astra review and Phase A/B plan in docs/TODO.md, project-log history, and relevant schema/skill references. The first review's four bugs were already fixed by CLDO and are not claimed as new findings here.

The earlier review found the neutral-rating audit crash, confidence-zeroed dealbreaker evidence, confidence-zeroed series endpoints, and zero-division errors in four experimental builders. CLDO's protocol entry describes targeted synthetic reproductions and real-data checks, but explicitly says a full multi-rater A/B scorecard was not run for those fixes. Task 2's baseline is a current-state measurement, not a retrospective before/after proof for those fixes.

No engine edits, test edits, commits, or pushes occurred in Task 2. Its only hosted access was the authorized canonical read-only suite. No credentials are reproduced here. At both the start and end of Task 2, git status showed the same pre-existing untracked file:

```text
?? docs/codx-recommend-review-2026-09-14.md
```

This report is uncommitted working output in CODX's own clone, for CLDO to read directly and independently verify. It does not assert that CLDO's reported filesystem access problem has been resolved.

## 2. Existing plan this work feeds

The existing docs/TODO.md plan separates consolidation from file movement:

- A1: enumerate every scoring call site and its stage order.
- A2: define a canonical scorer and rich result, in place.
- A3: migrate recommend() first, checking scorecard equivalence.
- A4: migrate explanation consumers.
- A5: migrate _full_score() and other test-side reconstructions.
- A6: full multi-rater regression gate.
- B1–B4: only after A is stable, move groups into scripts/scoring/, retain a compatibility shim, verify imports and scorecard, and later update external imports.

Task 2 endorses starting with A1/A2. It does not authorize A3–A6 implementation or Phase B file movement. The audit identifies where the plan's shorthand needs clarification before consolidation can actually preserve behavior.

## 3. Phase 1: current production pipeline and A1 call-site inventory

There is no single complete production scoring function today. score_book() computes the base score; recommend() assembles the ranking pipeline. The base includes confidence, per-book redundancy adjustments, and prevalence discounts when supplied.

| File and function | Actual stage sequence | Scope, output, and exceptions |
|---|---|---|
| scripts/recommend.py:3257, recommend | Base → series repeat → dealbreaker veto → series trajectory → diversity → cold start → user rules | Before scoring: excludes rated books, wrong-genre candidates, discovery-only author/series matches, and series-position-ineligible books. After rules: drops excluded books, sorts by final score, truncates. Returns score/title/author/base contributions, no label. |
| scripts/recommend.py:3353, explain_match | Base → series repeat → veto → trajectory → calibrated label | No diversity, cold-start blend, user rules, or candidate eligibility filtering. Recomputes matches, mismatches, flags, phrases, and series note. Works for any catalog book, including books ranking would exclude. |
| scripts/recommend.py:3627, audit_book_score | Base → series repeat → veto → trajectory → cold start → user rules → calibrated label | No diversity or candidate eligibility filtering. Returns rounded stage scores and separately reconstructed attribution. Excluded-by-rule books remain auditable. |
| scripts/scoring_tests.py:201, _full_score | Base → series repeat → veto → trajectory | Omits cold start, diversity, rules, and eligibility. Uses module-global series-DNA and prevalence caches. Returns a float. |
| scripts/recommend.py:466, user_calibrated_poor_threshold | Rescore training books with Base only → positive/negative means → midpoint → clamp | Deliberately base-only calibration, not a miniature complete ranking pipeline. Uses the supplied prevalence lookup. Its raw-score basis must not change silently during consolidation. |
| scripts/recommend.py:701, series_dnf_outlook | Base for each series book → compare adjacent scores | Shorter, distinct series-outlook path; accepts genre/fatigue but no format preference. Uses a 0.05 comparison margin. |
| scripts/recommend.py:2114, explain_book | Reconstruct base similarities and effective weights → matches/mismatches → threshold/sort/truncate | Also consumed by dealbreaker_flags and _series_trajectory_penalty_factor. It is a scoring dependency as well as presentation logic. |
| scripts/scoring_tests.py:147, run_leave_one_out_diagnostic | Resolve profile → calibration and validation → _full_score → label/verdict | Repeats preparation and labeling for each held-out book. |
| scripts/scoring_tests.py:266, run_held_out_test | Resolve profile → calibration and validation → _full_score → label/verdict | Used by ordinary and isolated held-out tests, learning curves, and diversity curves. |
| scripts/scoring_tests.py:643, run_ablation_held_out | Resolve profile → alter weights → recalibrate/validate → _full_score → label/verdict | Intentional experimental input modification; must retain recalibration after ablation. |
| scripts/scoring_tests.py:761, run_threshold_diagnostic | Resolve profile/validate → _full_score → multiple threshold/label views | Scores once, then compares threshold policies; intentionally does not use a single fixed final label. |
| scripts/scoring_tests.py:1391, check_contrastive_pair_ranking | Resolve profile excluding both books → validate → _full_score twice → ranking comparison | Calls the test-side pipeline, not recommend's ranking loop. |
| scripts/scoring_tests.py:415, run_weight_cap_check | Build profile → explain_book mismatch magnitudes | Component diagnostic, not end-to-end ranking. Prints person/POV mismatch and maximum trope weight. |
| scripts/scoring_tests.py:831 and :872, check_dealbreaker_flags and run_leave_one_out_flags_check | Resolve profile → optional validation → dealbreaker_flags → phrases/counts | Component diagnostics. No complete score is assembled. |
| api/main.py:147, recommendations | recommend → explain_match for each result | Combines recommend's score with explain_match's label and explanation, despite their different stage sets. |
| tools/dogfood/app.py:164–187, module rendering block | recommend → separately resolve profile/prevalence/calibration → label returned scores → audit selected result | A third external consumer, beyond the API and test module emphasized by the TODO refactor discussion. |
| scripts/recommend.py module demo near :3844 | Calls recommend and explain_match separately | No new arithmetic, but inherits their differences. |
| Experimental builders/scorers | Separate profile or scoring implementations | Five build_profile variants, per-value scoring/explanation, grouped prevalence, graduated veto. No executable references to the searched experimental entry points were found in scripts/, api/, or tools/ Python code. |

The shorter paths are not automatically defects. Calibration intentionally uses raw scores. Explanation intentionally supports books that are ineligible for recommendations. Existing experiments intentionally measure modified inputs. A1 must distinguish those contracts from accidental duplication.

### Modifier ordering is behavior, not incidental plumbing

The order currently lives in repeated sequences of calls. No shared function enforces it.

With an incoming score of 0.8, the existing veto cap of 0.549, and a trajectory factor of 0.7:

- Veto then trajectory: 0.549 × 0.7 = 0.3843.
- Trajectory then veto: min(0.8 × 0.7, 0.549) = 0.549.

Those are different scores even with identical constants. Diversity and cold-start blends happen after both stages and can lift a previously capped score. User rules happen last. The audit did not recommend moving the veto later or otherwise changing those semantics.

The A2 shorthand in TODO describes raw → series repeat → veto → trajectory → cold start, but recommend additionally has diversity before cold start and rules afterward. A canonical ranking scorer must cover those stages explicitly. It must also preserve shorter existing callers rather than silently applying every ranking modifier to them.

## 4. Detailed findings

Severity refers to maintenance/correctness risk within this audit's scope, not a claim that every scenario affects current users. Synthetic reproductions establish reachability, not live incidence.

### F1. Ranking and explanation assemble different scores, then the API combines them

Location: scripts/recommend.py:3257 recommend; :3353 explain_match; api/main.py:147 recommendations.
Severity: high.
Plan: A1, A2, A3, A4.
Behavior-preserving repair: consolidation can preserve existing scores; correcting displayed labels changes presentation and needs a decision.

recommend() includes cold start and rules, while explain_match() does not. api/main.py takes the numerical score from the former and the match_label from the latter. This is more than redundant work: it can present a label describing a different number.

The in-memory reproduction used a single unrated gateway book. recommend returned 1.0, while explain_match returned 0.0 and Poor match. The API composition was established by reading its real loop; no live API request was made. Rules create another route to different scores because they affect recommend but are not passed to explain_match.

The remedy is not to indiscriminately make explanations use every ranking stage: the existing explanation contract deliberately describes arbitrary books, not just eligible recommendations. A2 should expose both the base/adjusted values and the policy used, so the caller can choose the correct view without recalculating it.

Decision for CLDO/owner: which score should the recommendation card's label describe, and should explanation-only requests keep their present semantics? Preserve current contracts during extraction, then approve any presentation correction separately.

### F2. Explanation logic is a scoring dependency, so naive consolidation can recurse

Location: scripts/recommend.py:2027 score_book; :2114 explain_book; :2599 dealbreaker_flags; :2770 _series_trajectory_penalty_factor.
Severity: high.
Plan: A2 prerequisite, A4.
Behavior-preserving repair: yes, if arithmetic order, thresholds, and signed-weight semantics are retained.

score_book and explain_book separately compute ordinal/nominal similarity, effective weight, redundancy adjustment, confidence discount, and prevalence discount. The former accumulates score/denominator and truncated contributions; the latter accumulates match and mismatch magnitudes.

Those are distinct views of the same factors, but explain_book's output also determines whether veto and trajectory stages act. dealbreaker_flags calls explain_book, and trajectory calls it to identify strong matching fields. If A4 were implemented literally by making explain_book invoke a canonical full pipeline that itself invokes veto/trajectory, the dependency would cycle.

The safe extraction boundary is below both: compute base factors once, then derive score and explanation views from them, and let modifiers consume those views. Do not redefine a negative fatigue weight, normalize explanation magnitudes differently, or change which ties/thresholds survive under the guise of sharing code.

Decision for CLDO: retain a lower-level factor evaluator distinct from the canonical stage orchestrator.

### F3. Evaluation drops format metadata and does not cover genre-scoped quality behavior

Location: scripts/scoring_tests.py:29 load_rater; :147/:266 and related evaluation helpers; scripts/recommend.py:989 build_profile.
Severity: medium.
Plan: A1, A5, A6; A2 input/result contract.
Behavior-preserving repair: production can remain unchanged, but benchmark results may change if evaluation inputs are corrected.

load_rater returns only the ratings dictionary. Mathias's local file specifies _meta.format_preference='audiobook', confirmed by the inspection command below, but test helpers never pass it through _resolve_profile. The default is print, which excludes audiobook_length instead of book_length. Thus the suite's profile is not the audiobook profile used when production receives that preference.

The quality scenarios also run with genre=None, using unscoped prevalence. That is documented in the cache comment and is not inherently wrong, but it leaves the actual genre-filtered paths weakly characterized.

Changing metadata handling now would confound a behavior-preserving A/B refactor with changed test inputs. Freeze the existing default-print baseline and add separate explicitly named format/genre cases. Decide later whether the canonical benchmark definition itself should change.

### F4. Test caches retain data from the first catalog regardless of subsequent input

Location: scripts/scoring_tests.py:194 _get_prevalence_cache; :201 _full_score.
Severity: medium.
Plan: A2 context ownership, A5, A6.
Behavior-preserving repair: production recommendations need not change; multi-catalog evaluation behavior would be corrected.

_PREVALENCE_CACHE and _SERIES_DNA_CACHE initialize once and are not keyed to the catalog argument. A call using a different catalog in the same process reuses stale values. The synthetic check first cached a catalog with quest, then requested a catalog with found_family; the second lookup still returned quest, unlike a fresh direct production lookup.

The same lifetime pattern exists for series DNA by code inspection. The canonical suite loads one catalog per process, so this finding does not invalidate its ordinary two baseline runs. It matters for reusable tests, fixture sequences, and same-process A/B work.

An explicit per-catalog scoring context is a better ownership boundary than process-global mutable caches. New tests should use independent contexts rather than relying on invisible resets.

### F5. A successful process exit is not a sufficient test gate

Location: scripts/scoring_tests.py:915 run_user_rules_tests; :1014 run_all; :415 run_weight_cap_check; :556 print_scorecard.
Severity: medium.
Plan: A1 characterization, A3–A6 verification gates.
Behavior-preserving repair: yes for recommendations; test exit behavior would change.

run_user_rules_tests collects and returns failures, but run_all ignores that return. The scorecard prints unmet targets, and the domination check prints values without asserting a bound. Therefore exit 0 cannot establish either correctness-test success or quality-target success by itself.

In the actual baseline the user-rule checks all printed OK and the final success message, so no hidden rule failure was observed. Several quality targets were missed. Those facts must be reported separately instead of calling the entire scorecard a clean pass.

Required durable checks are missing around the four September 14 regressions, stage parity/order, cold start, diversity, series eligibility, format preference, genre scoping, fatigue combinations, cache isolation, and ties. Component diagnostics do not replace tests of the complete ranking path.

The proposal is to add enforceable characterization checks, not to turn all current aspirational quality targets into failing tests without a separate decision.

### F6. Audit attribution still reconstructs different evidence from the learned profile

Location: scripts/recommend.py:3569 _audit_attribute_nominal_or_trope; :3593 _audit_attribute_ordinal; :3627 audit_book_score.
Severity: medium.
Plan: A2 result/evidence shape, A4 audit/explanation consolidation.
Behavior-preserving repair: recommendation scores can remain identical; audit output would change.

The earlier neutral-rating crash is fixed. A separate discrepancy remains: attribution helper calculations do not apply profile confidence weighting/floor and do not reconstruct field-specific genre scoping. The audit passes a deduped full rating dictionary, then independently lists or summarizes evidence.

Reproduction: two positively rated books, fast pace at confidence 1.0 and slow pace at confidence 0.2. Production build_profile skips the below-floor slow tag and yields pace centroid 1.0. The audit helper still reports n=2 and mean_position=0.5. It can therefore explain a weight using evidence the profile did not use.

The nominal/trope support helper similarly tests tag equality/presence without consulting confidence; that extension is code inspection, while the numerical reproduction specifically exercises the ordinal helper.

Decision for CLDO: should the rich result carry profile evidence attribution, or should a shared evidence helper supply it? Do not silently change training semantics to match the existing display.

### F7. File size and mixed responsibilities amplify concrete coupling

Location: scripts/recommend.py overall; build_profile:989; audit_book_score:3627.
Severity: medium.
Plan: A1/A2 first; B1–B4 later.
Behavior-preserving repair: yes, with staged checks.

The AST inventory measured 3,895 lines and 66 top-level functions in recommend.py. build_profile spans 181 lines; audit_book_score spans 118. The file includes database access, profile construction, similarity, experiments, ranking, reporting, and feedback logging. scoring_tests.py has 1,435 lines and 37 top-level functions.

Line count alone is not a correctness finding. The concrete risk is that profile/scoring logic is copied into experiment and audit paths, while wrappers each orchestrate their own stages. The prior four bugs already demonstrated the propagation problem. In the API, explanation is also recomputed per returned result, rebuilding profile/context repeatedly rather than consuming a shared result.

The TODO notes emphasize two external consumers, but tools/dogfood/app.py is a third. A compatibility shim and consumer inventory should cover it before Phase B. No dependency updates or file moves were proposed in the first batch.

### F8. Repeated literals and duplicated blends should become named, purpose-specific policy

Location: scripts/recommend.py score_book:2027; explain_book:2114; trajectory helper:2770; audit:3627; calibration:466; recommend:3257.
Severity: low.
Plan: A2 supporting extraction; B field/constants organization later.
Behavior-preserving repair: yes, preserving exact values and comparisons.

The explanation floor 0.1 is hardcoded in explain_book while AUDIT_CONTRIBUTION_THRESHOLD separately declares the same number. Contribution inclusion and strong-field checks use 0.15 in different places. Calibration clamps to 0.20/0.54. Cold-start demand fallback 0.5 and blend arithmetic appear independently in recommend and audit. Top-N caps also carry practical behavior.

Centralization should use names based on policy purpose. Equal values are not proof that the policies should be coupled: a display floor and a scoring gate may need separate names even if both are currently 0.15. Preserve strict versus inclusive comparisons and preserve existing defaults, including Python's default-argument binding behavior, during any extraction.

This is maintenance work, not a request to tune thresholds.

### F9. Experimental entry points are dormant and some source comments are stale

Location: scripts/recommend.py build_profile variants:1192/:1299/:1499/:1644/:1780; per-value scoring/explanation:1874/:1933; grouped prevalence:2258; graduated veto:2947; trajectory header:2741.
Severity: low.
Plan: A1 inventory; B1 organization later.
Behavior-preserving repair: documentation yes; removal needs compatibility/research review.

An AST search found no executable references to the searched experimental entry points in scripts/, api/, or tools/. This establishes that the scanned checked-in Python code does not call them, not that no outside notebook/session ever could. The protocol deliberately retains several for future experiments, including rejected or unproven mechanisms. Do not mistake dormant research code for safe-to-delete code automatically.

The trajectory header says EXPERIMENTAL / NOT wired into recommend()/explain_match() despite actual calls in production and the protocol's landed entry. It should not be used as evidence of runtime scope.

The first batch does not remove experiments, revive per-value scoring, or retry rejected heuristics. Their inventory supports later organization after Phase A is stable.

### F10. Output determinism is not defined tightly enough for the plan's byte-identical gate

Location: scripts/recommend.py build_profile trope collection, explain_book sorting, load_catalog:755, recommend result sorting; scripts/scoring_tests.py flag reporting:831/:872.
Severity: medium.
Plan: A1 equivalence contract, A2 order preservation, A6.
Behavior-preserving repair: changing tie order is observable even if scores remain unchanged.

The two canonical runs returned identical printed numerical results but differed on two Golden Son explanation lines. Tied dystopia and rebellion-against-empire phrases swapped order. The code collects tropes through a set and later uses stable sorting without an explicit secondary key, leaving ties dependent on prior iteration order.

Catalog loading also has no explicit ORDER BY, and recommendation sorting uses final score alone. Those are additional potential ordering dependencies, not observed ranking changes in this baseline.

Decision for CLDO/owner: either characterize tied presentation groups separately while keeping scores/ranks exact, or approve a deterministic tie-order change as its own visible behavior change. Do not claim unqualified byte identity from these two runs. Printed numerical equality also does not prove unrounded floating-point equality.

## 5. Phase 2: canonical baseline

### Connection and exact execution

CODX_READONLY_DATABASE_URL existed in this clone's .env but was not exported in the process environment. Only that assignment was parsed into a child environment; no full .env sourcing or credential printing occurred. The child ran exactly:

```sh
DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py
```

The complete launcher used is reproduced in Appendix A from the retained command string, not rewritten as a suggested equivalent. It sets PYTHONDONTWRITEBYTECODE=1 to avoid bytecode files. The initial run failed on sandbox DNS before loading the catalog. The identical command was retried with network access and then repeated once, again with network access, to check reproducibility.

Both successful runs returned exit code 0. No test or data failure was fixed. These are two current-state runs against hosted catalog reads, not a frozen-snapshot before/after experiment. No catalog snapshot or unrounded score export was saved.

### Current metrics

| Scenario | Held-out n | Bucket accuracy | Pairwise accuracy | Loved recall | Hated rejection |
|---|---:|---:|---:|---:|---:|
| Mathias full (printed training count 132) | 11 | 73% | 84% | 80% | 80% |
| Mathias sparse (16 ratings) | 9 | 67% | 73% | 75% | 75% |
| Mathias series-isolated | 11 | 55% | 71% | 80% | 40% |
| Mathias author-isolated | 11 | 55% | 56% | 60% | 60% |
| Osnat full (30 ratings) | 7 | 43% | 61% | 100% | 0% |
| Osnat series-isolated | 7 | 57% | 67% | 100% | 0% |
| Dandan full (32 ratings) | 7 | 71% | 80% | 33% | 100% |
| Gabriel leave-one-out (7 ratings) | 7 | 43% | 20% | 40% | 0% |

All user-rule checks passed. The domination diagnostic printed person mismatch 0.299, pov_count mismatch 0.000, maximum trope weight 0.429. The explanation list is thresholded, so the displayed zero is not a claim that an unfiltered POV contribution is mathematically zero.

Contrastive pairs: Mathias 0/1 correctly ranked; Osnat 0/1; Dandan 16/17; Gabriel had no pairs. Full ablation tables, threshold diagnostics, learning/diversity curves, and per-book scores appear uncompressed in Appendix A.

The only warning in the successful runs was the expected invalid-rule fixture:
`WARNING: unrecognized user rule key(s), ignored: ['not_a_real_field:x']`.

Quality targets were not all met. In particular Mathias author-isolated loved recall, several Osnat metrics, Dandan loved recall, and all four Gabriel metrics were below their printed targets. Exit 0 is process completion, not a claim that these targets passed.

### Nondeterminism actually observed

Both captured successful outputs were 28,017 characters. Exactly two lines differed (183 and 204), both in Golden Son's flags:

First run:
`space opera; dystopia; rebellion against empire; major character death; underdog rising`

Second run:
`space opera; rebellion against empire; dystopia; major character death; underdog rising`

Everything else in the captured output matched. Therefore the justified claim is numerical repeatability at printed precision, not byte-identical output or unrounded equality. The repeated run was undertaken specifically because the existing plan requires equivalence checks.

## 6. Phase 3: proposed first implementation batch, maximum three changes

These are proposals for CLDO, not completed work. The first batch remains A1/A2 in place.

### Proposal 1 — A1: record call-site contracts and add characterization checks

Objective: make stage inclusion/order, calibration basis, candidate filtering, format/genre inputs, rounding, and output ordering explicit for every caller in section 3. Convert the important contracts into executable characterization checks.

Files affected: refactor documentation (the A1 table and decisions) and scripts/scoring_tests.py. No recommendation logic changes.

Expected risk: low. The primary risk is accidentally writing assertions for desired future behavior instead of current behavior.

Proof of no behavior change:
- Preserve today's existing outputs and intentional shorter paths.
- Add executable checks for stage order, the four already-fixed regression scenarios, and representative cold-start and user-rule cases.
- Compare numeric equality separately from tied presentation ordering.
- Make test failures actionable rather than relying solely on process exit 0.
- Do not silently change the baseline's format or genre policy.

This directly produces A1's promised artifact and prepares the A3–A6 gates. It is not a new metric project.

### Proposal 2 — A2 prerequisite: extract shared base-factor evaluation in place

Objective: compute similarities and effective weights once, below both score and explanation views. Make those shared factors available to modifier logic without routing explain_book through the full pipeline. Centralize the relevant purpose-specific constants without changing values.

Files affected: scripts/recommend.py and corresponding checks in scripts/scoring_tests.py.

Expected risk: medium. Arithmetic order, threshold boundaries, signed weights, and stable ordering can change outputs even when algebra looks equivalent.

Proof of no behavior change:
- Compare old and extracted unrounded base scores and denominators on the same catalog and profiles.
- Compare factor order, existing truncated contributions, matches, mismatches, and flags.
- Cover missing fields, confidence-floor boundaries, partial nominal similarity, redundancy triggers, prevalence discounts, zero evidence, negative fatigue weights, and ties.
- Preserve the current accumulation order and signed-weight semantics.
- Run the full unchanged canonical suite in addition to these direct comparisons.

This enables A2 and avoids the recursion risk in A4. It does not normalize explanations differently or redesign the score.

### Proposal 3 — A2: add a canonical scorer and explicit result alongside existing callers

Objective: define one ordered stage orchestrator with an explicit result: base score, per-stage intermediates, final score, calibration threshold and label, factors/contributions, mismatches, flags, exclusions, and series note. Explicitly encode current ranking versus explanation/evaluation stage policies, including diversity and user rules. Keep calibration's base-only computation separate.

Files affected: scripts/recommend.py and scripts/scoring_tests.py.

Expected risk: medium. A single entry point is helpful only if its input/context ownership and its stage policies preserve current caller contracts. Global caches and hidden defaults must not silently pick another catalog or profile mode.

Proof of no behavior change:
- Initially leave existing callers authoritative and compare the new result against them.
- Use the same in-memory catalog for both sides, all real raters, and explicitly named genre/format combinations.
- Include rules, exclusions, cold-start users, diversity/recent-history, and stage interactions.
- Compare ordered recommendations and complete results, not just aggregate metrics or rounded floats.
- Preserve intentional base-only calibration and shorter explanation/evaluation paths.
- Do not invent a new aggregate confidence score simply because the original broad ScoreResult suggestion mentioned confidence.
- Only after parity is demonstrated begin separately gated A3–A5 caller migrations, followed by A6.

No file moves are part of this proposal. Phase B remains later.

## 7. Options considered but not selected, and why

This section records alternatives actually discussed in Task 2. It does not invent a history of additional implementation attempts.

- Broad scripts/scoring/ package extraction now: deferred to B1–B4 because it would combine transcription/import risk with logic-consolidation risk. Stabilize A first.
- Route explain_book directly through the full canonical pipeline: rejected as an extraction shape because veto and trajectory already depend on explain_book. A lower-level factor evaluator is required to avoid recursion.
- Apply every ranking modifier to every caller: not accepted as a behavior-preserving refactor. Calibration, explanations of ineligible books, and component diagnostics currently have different contracts.
- Fix API score/label behavior in the extraction: separated for a CLDO/owner decision. The mismatch is demonstrated, but choosing a new displayed score/label contract is observable.
- Switch the existing benchmark to audiobook metadata immediately: deferred as a benchmark-input decision. It may be correct but could change scores independently of the refactor; preserve the current baseline and add separately named cases.
- Force deterministic tie sorting immediately: deferred because tie order is visible. First decide the equivalence contract.
- Remove all dormant experiments: deferred, not declared safe just because checked-in executable references are absent. Some are deliberately retained research artifacts.
- Revisit per-value scoring, adaptive vetoes, weight changes, latent dimensions, ML, or new DNA fields: outside the selected batch and contrary to this task's scope. Existing rejected/deferred history remains authoritative.
- Start top-K rejection or NDCG work in this batch: acknowledged as valid existing GPT/Astra-review backlog work, but not necessary to begin A1/A2. It would be a separate evaluation enhancement.
- Treat every existing unmet scorecard target as a newly introduced failure: rejected as an interpretation of the baseline. The task established current behavior and did not change it.
- Claim the two suite runs were byte-identical: rejected by the actual two-line output difference. No result was normalized or silently sorted to hide it.

## 8. Explicit decisions for CLDO / repo owner

1. Approve the A1/A2-only batch and its scope before implementation; A3–A6 and B1–B4 remain subsequent gated work.
2. Define the result/view contract for ranking, explanations, audit, calibration, and evaluation. Decide separately whether API labels must change to describe the ranking score.
3. Confirm the lower-level shared-factor boundary so explanation reuse cannot introduce a pipeline recursion.
4. Decide whether future canonical evaluation should honor rater format metadata, while retaining a named record of today's print-default baseline.
5. Decide how equivalence checks handle tied explanation ordering and potential ranking ties; deterministic tie-breaking is a separate visible change.
6. Decide whether audit evidence should come from the profile result or a shared evidence helper; the current mean/support display can disagree with actual training evidence.
7. Verify the findings independently before acting, as with Task 1. The report does not resolve CLDO's separate filesystem-access issue or authorize hosted writes.

## 9. Reconstruction task record

The reconstruction task synced this clone, re-read the updated AGENTS.md in full, checked the new TODO/log entries, and wrote this report with retained outputs. It did not rerun Phase 2, modify recommend.py, touch hosted Supabase, commit, or push.

The first sync attempt returned:
```text
?? docs/codx-recommend-review-2026-09-14.md
error: cannot open '.git/FETCH_HEAD': Operation not permitted
```

The approved retry of `git pull --ff-only` returned:
```text
From https://github.com/M4kuWo/bookspell
   bf480b7..8ee6740  main       -> origin/main
Updating bf480b7..8ee6740
Fast-forward
 AGENTS.md           | 39 +++++++++++++++++++++--
 docs/TODO.md        | 46 ++++++++++++++++++++++++++-
 docs/project-log.md | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 173 insertions(+), 3 deletions(-)
```

The instruction now requires every task to end with full written output in docs/codx-reports/. This file is both the delayed Task 2 handoff and the record of this documentation-only reconstruction.

## Appendix A. Exact canonical-suite launcher and complete captured output

### A1. Launcher (same command on all three attempts)

```sh
python3 - <<'PY'
import os,re,shlex,subprocess
from pathlib import Path
s=Path('.env').read_text()
m=re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$',s)
if not m: raise SystemExit('Missing CODX_READONLY_DATABASE_URL in .env')
parts=shlex.split(m.group(1),comments=True)
if len(parts)!=1 or not parts[0]: raise SystemExit('Read-only variable is empty or cannot be parsed safely')
e=os.environ.copy();e['CODX_READONLY_DATABASE_URL']=parts[0];e['PYTHONDONTWRITEBYTECODE']='1'
p=subprocess.run(['zsh','-f','-c','DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py'],env=e,capture_output=True,text=True)
print(p.stdout.replace(parts[0],'<redacted>'),end='');print(p.stderr.replace(parts[0],'<redacted>'),end='')
raise SystemExit(p.returncode)
PY
```

The first attempt used the ordinary sandbox. Retry 1 and the reproducibility repeat used network-enabled execution after approval. Each successful execution started a fresh Python process and loaded the catalog anew. Polling the running process did not invoke another test command.

### A2. Initial sandbox failure — exit 1

```text
Traceback (most recent call last):
  File "/Users/mathiaskurin/Documents/bookspell-codex/scripts/scoring_tests.py", line 1435, in <module>
    run_all()
    ~~~~~~~^^
  File "/Users/mathiaskurin/Documents/bookspell-codex/scripts/scoring_tests.py", line 1015, in run_all
    catalog = R.load_catalog()
  File "/Users/mathiaskurin/Documents/bookspell-codex/scripts/recommend.py", line 756, in load_catalog
    conn = psycopg2.connect(DATABASE_URL)
  File "/opt/homebrew/lib/python3.13/site-packages/psycopg2/__init__.py", line 122, in connect
    conn = _connect(dsn, connection_factory=connection_factory, **kwasync)
psycopg2.OperationalError: could not translate host name "aws-0-ap-southeast-1.pooler.supabase.com" to address: nodename nor servname provided, or not known

```

### A3. First successful run — exit 0

The following is the complete captured stdout/stderr text returned by the launcher, without summarization.

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.607 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.454 Poor match     OK
    Eragon                       it_was_okay  0.539 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.718 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.370 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.748 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.376 Mixed match    OK
    Words of Radiance            loved        0.471 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.439 Mixed match    OK
    The Hero of Ages             it_was_okay  0.230 Mixed match    OK
    Ender's Shadow               loved        0.728 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.650 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.516 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.617 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.446 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.561 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.553 Good match     OK
    Rhythm of War                loved        0.455 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.579 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.515 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.493 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.653 Good match     OK
    Iron Flame                   it_was_okay  0.550 Mixed match    OK
    Daughter of No Worlds        hated        0.575 Good match     MISS
    Magic Burns                  hated        0.855 Strong match   MISS
  Osnat, series-isolated: 4/7 correct, 2 wrong, 1 soft-miss

=== Benchmark scorecard ===
  Test                              n    Bucket acc.        Pairwise acc.      Loved recall       Hated reject.    
  -----------------------------------------------------------------------------------------------------------------
  Mathias -- full (132 ratings)     11   73% OK             84% OK             80% OK             80% OK           
  Mathias -- sparse (16 ratings)    9    67% OK             73% OK             75% OK             75% OK           
  Mathias -- series-isolated        11   55% OK             71% OK             80% OK             40% OK           
  Mathias -- author-isolated        11   55% OK             56% OK             60% (target 65%)   60% OK           
  Osnat -- full (30 ratings)        7    43% (target 55%)   61% (target 70%)   100% OK            0% (target 40%)  
  Osnat -- series-isolated          7    57% OK             67% OK             100% OK            0% (target 25%)  
  Dandan -- full (32 ratings)       7    71% OK             80% OK             33% (target 75%)   100% OK          
  Gabriel -- LOO (7 ratings)        7    43% (target 45%)   20% (target 60%)   40% (target 65%)   0% (target 30%)  

=== Scenario 6: DNA ablation (post-hoc field-group zeroing) ===
  Baseline (nothing removed):
    Mathias, full    bucket_accuracy=73%  pairwise_accuracy=84%  loved_recall=80%  hated_rejection=80%
    Mathias, sparse  bucket_accuracy=67%  pairwise_accuracy=73%  loved_recall=75%  hated_rejection=75%
    Osnat, full      bucket_accuracy=43%  pairwise_accuracy=61%  loved_recall=100%  hated_rejection=0%

  Group removed       Base              Bucket acc.      Pairwise acc.    Loved recall     Hated reject.  
  --------------------------------------------------------------------------------------------------------
  tropes              Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  tropes              Mathias, sparse   67% (+0pp)       83% (+10pp)      100% (+25pp)     50% (-25pp)    
  tropes              Osnat, full       43% (+0pp)       22% (-39pp)      100% (+0pp)      0% (+0pp)      
  pace                Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  pace                Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  pace                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  tone                Mathias, full     82% (+9pp)       87% (+2pp)       80% (+0pp)       100% (+20pp)   
  tone                Mathias, sparse   67% (+0pp)       80% (+7pp)       75% (+0pp)       75% (+0pp)     
  tone                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  pov_structure       Mathias, full     64% (-9pp)       82% (-2pp)       80% (+0pp)       60% (-20pp)    
  pov_structure       Mathias, sparse   56% (-11pp)      67% (-7pp)       75% (+0pp)       50% (-25pp)    
  pov_structure       Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  stakes_drive        Mathias, full     73% (+0pp)       87% (+2pp)       80% (+0pp)       80% (+0pp)     
  stakes_drive        Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  stakes_drive        Osnat, full       43% (+0pp)       72% (+11pp)      100% (+0pp)      0% (+0pp)      
  content_intensity   Mathias, full     82% (+9pp)       80% (-4pp)       80% (+0pp)       100% (+20pp)   
  content_intensity   Mathias, sparse   67% (+0pp)       73% (+0pp)       75% (+0pp)       75% (+0pp)     
  content_intensity   Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  craft_density       Mathias, full     73% (+0pp)       84% (+0pp)       80% (+0pp)       80% (+0pp)     
  craft_density       Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  craft_density       Osnat, full       43% (+0pp)       67% (+6pp)       100% (+0pp)      0% (+0pp)      
  magic_scifi         Mathias, full     73% (+0pp)       89% (+4pp)       80% (+0pp)       80% (+0pp)     
  magic_scifi         Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  magic_scifi         Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      

=== Scenario 7: Poor-match threshold diagnostic ===
  Base              Threshold variant             Bucket acc.    Pairwise acc.  Loved recall   Hated reject.
  ----------------------------------------------------------------------------------------------------------
  Mathias, full     fixed 0.35 (old default)      45%            84%            80%            0%           
  Mathias, full     fixed 0.40                    45%            84%            80%            0%           
  Mathias, full     fixed 0.45                    64%            84%            80%            40%          
  Mathias, full     fixed 0.50                    73%            84%            80%            60%          
  Mathias, full     fixed 0.54                    73%            84%            80%            80%          
  Mathias, full     calibrated (0.540) -- LANDED  73%            84%            80%            80%          

  Mathias, sparse   fixed 0.35 (old default)      44%            73%            75%            0%           
  Mathias, sparse   fixed 0.40                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.45                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.50                    56%            73%            75%            50%          
  Mathias, sparse   fixed 0.54                    67%            73%            75%            75%          
  Mathias, sparse   calibrated (0.540) -- LANDED  67%            73%            75%            75%          

  Osnat, full       fixed 0.35 (old default)      43%            61%            100%           0%           
  Osnat, full       fixed 0.40                    43%            61%            100%           0%           
  Osnat, full       fixed 0.45                    43%            61%            100%           0%           
  Osnat, full       fixed 0.50                    43%            61%            100%           0%           
  Osnat, full       fixed 0.54                    43%            61%            100%           0%           
  Osnat, full       calibrated (0.385) -- LANDED  43%            61%            100%           0%           

  No-negative-signal fallback check (repo owner's caveat):
    119 all-positive ratings (no disliked/hated) -> calibrated threshold = 0.350 (falls back to default, as intended)

=== Scenario 8: dealbreaker-flag sanity check (fixed threshold, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 9: dealbreaker-flag sanity check (statistically validated, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 10: learning curve (accuracy vs. rating-history size) ===
  Mathias (held-out set fixed at 11 books, up to 15 random samples per size):
    Train size   Pairwise acc.    Bucket acc.    Repeats
    10           69%              36%            15
    32           69%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.085
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6789) vs The True Bastards (hated, held-out score 0.6938)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8226) vs Magic Burns (hated, held-out score 0.8487)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0354) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0165) vs A Crown of Swords (it_was_okay, held-out score -0.0625)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0445) vs The Dragon Reborn (it_was_okay, held-out score -0.0219)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0547) vs Lord of Chaos (loved, held-out score -0.007)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.0597) vs The Path of Daggers (hated, held-out score 0.0224)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0368) vs A Crown of Swords (it_was_okay, held-out score -0.0632)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0363) vs The Fires of Heaven (disliked, held-out score -0.0525)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0227) vs The Shadow Rising (loved, held-out score -0.0165)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.055) vs Knife of Dreams (loved, held-out score 0.0159)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0655) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0552) vs The Gathering Storm (loved, held-out score 0.0547)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0278) vs Winter's Heart (liked, held-out score 0.089)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0635) vs Knife of Dreams (loved, held-out score -0.0127)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0072) vs The Path of Daggers (hated, held-out score 0.023)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0499) vs Winter's Heart (liked, held-out score -0.0115)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0636) vs The Gathering Storm (loved, held-out score 0.0253)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0445) vs A Crown of Swords (it_was_okay, held-out score -0.0609)  [OK]
      DNA similarity: 0.852
      Field differences: {'overall_pace': ('medium', 'slow'), 'darkness': ('moderate', 'dark'), 'book_length': ('long', 'epic'), 'pace_shape': ('consistent', 'uneven'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']
      Tropes only in 'A Crown of Swords': ['war_story']

  Dandan summary: model correctly ranked 16/17 contrastive pairs.
  Gabriel: 0 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

=== Scenario 13: user-adjustable rules (none of X / less of X) ===
  parse trope key: OK
  parse valid ordinal field:value: OK
  parse valid nominal field:value: OK
  reject invalid ordinal value: OK
  reject unknown field: OK
  normalize None is empty: OK
  normalize {} is empty: OK
WARNING: unrecognized user rule key(s), ignored: ['not_a_real_field:x']
  normalize drops bad keys, keeps good ones: OK
  normalize applies default strength: OK
  normalize respects explicit strength: OK
  no rules is a guaranteed no-op: OK
  no rules is a no-op even with {}: OK
  exclude exact-matches and flags excluded: OK
  exclude leaves non-matching book untouched: OK
  reduce applies correct multiplicative discount: OK
  reduce leaves non-matching book untouched: OK
  multiple matching reduce rules stack multiplicatively: OK
  target list non-empty: OK
  target list includes a known field_value: OK
  target list includes a known trope: OK
  target list never invents unused values: OK
  sanity: baseline top-20 fantasy contains at least one YA book: OK
  exclude age_category:ya removes all YA from real recommend() output: OK
  reduce drive:romance_driven lowers its representation in top-20 (2 -> 0): OK
  All user-rules tests passed.
```

### A4. Reproducibility repeat — exit 0

The following is the complete second captured output, including its two observed explanation-order differences.

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.607 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.454 Poor match     OK
    Eragon                       it_was_okay  0.539 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.718 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.370 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.748 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.376 Mixed match    OK
    Words of Radiance            loved        0.471 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.439 Mixed match    OK
    The Hero of Ages             it_was_okay  0.230 Mixed match    OK
    Ender's Shadow               loved        0.728 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.650 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.516 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.617 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.446 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.561 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.553 Good match     OK
    Rhythm of War                loved        0.455 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.579 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.515 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.493 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.653 Good match     OK
    Iron Flame                   it_was_okay  0.550 Mixed match    OK
    Daughter of No Worlds        hated        0.575 Good match     MISS
    Magic Burns                  hated        0.855 Strong match   MISS
  Osnat, series-isolated: 4/7 correct, 2 wrong, 1 soft-miss

=== Benchmark scorecard ===
  Test                              n    Bucket acc.        Pairwise acc.      Loved recall       Hated reject.    
  -----------------------------------------------------------------------------------------------------------------
  Mathias -- full (132 ratings)     11   73% OK             84% OK             80% OK             80% OK           
  Mathias -- sparse (16 ratings)    9    67% OK             73% OK             75% OK             75% OK           
  Mathias -- series-isolated        11   55% OK             71% OK             80% OK             40% OK           
  Mathias -- author-isolated        11   55% OK             56% OK             60% (target 65%)   60% OK           
  Osnat -- full (30 ratings)        7    43% (target 55%)   61% (target 70%)   100% OK            0% (target 40%)  
  Osnat -- series-isolated          7    57% OK             67% OK             100% OK            0% (target 25%)  
  Dandan -- full (32 ratings)       7    71% OK             80% OK             33% (target 75%)   100% OK          
  Gabriel -- LOO (7 ratings)        7    43% (target 45%)   20% (target 60%)   40% (target 65%)   0% (target 30%)  

=== Scenario 6: DNA ablation (post-hoc field-group zeroing) ===
  Baseline (nothing removed):
    Mathias, full    bucket_accuracy=73%  pairwise_accuracy=84%  loved_recall=80%  hated_rejection=80%
    Mathias, sparse  bucket_accuracy=67%  pairwise_accuracy=73%  loved_recall=75%  hated_rejection=75%
    Osnat, full      bucket_accuracy=43%  pairwise_accuracy=61%  loved_recall=100%  hated_rejection=0%

  Group removed       Base              Bucket acc.      Pairwise acc.    Loved recall     Hated reject.  
  --------------------------------------------------------------------------------------------------------
  tropes              Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  tropes              Mathias, sparse   67% (+0pp)       83% (+10pp)      100% (+25pp)     50% (-25pp)    
  tropes              Osnat, full       43% (+0pp)       22% (-39pp)      100% (+0pp)      0% (+0pp)      
  pace                Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  pace                Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  pace                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  tone                Mathias, full     82% (+9pp)       87% (+2pp)       80% (+0pp)       100% (+20pp)   
  tone                Mathias, sparse   67% (+0pp)       80% (+7pp)       75% (+0pp)       75% (+0pp)     
  tone                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  pov_structure       Mathias, full     64% (-9pp)       82% (-2pp)       80% (+0pp)       60% (-20pp)    
  pov_structure       Mathias, sparse   56% (-11pp)      67% (-7pp)       75% (+0pp)       50% (-25pp)    
  pov_structure       Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  stakes_drive        Mathias, full     73% (+0pp)       87% (+2pp)       80% (+0pp)       80% (+0pp)     
  stakes_drive        Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  stakes_drive        Osnat, full       43% (+0pp)       72% (+11pp)      100% (+0pp)      0% (+0pp)      
  content_intensity   Mathias, full     82% (+9pp)       80% (-4pp)       80% (+0pp)       100% (+20pp)   
  content_intensity   Mathias, sparse   67% (+0pp)       73% (+0pp)       75% (+0pp)       75% (+0pp)     
  content_intensity   Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  craft_density       Mathias, full     73% (+0pp)       84% (+0pp)       80% (+0pp)       80% (+0pp)     
  craft_density       Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  craft_density       Osnat, full       43% (+0pp)       67% (+6pp)       100% (+0pp)      0% (+0pp)      
  magic_scifi         Mathias, full     73% (+0pp)       89% (+4pp)       80% (+0pp)       80% (+0pp)     
  magic_scifi         Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  magic_scifi         Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      

=== Scenario 7: Poor-match threshold diagnostic ===
  Base              Threshold variant             Bucket acc.    Pairwise acc.  Loved recall   Hated reject.
  ----------------------------------------------------------------------------------------------------------
  Mathias, full     fixed 0.35 (old default)      45%            84%            80%            0%           
  Mathias, full     fixed 0.40                    45%            84%            80%            0%           
  Mathias, full     fixed 0.45                    64%            84%            80%            40%          
  Mathias, full     fixed 0.50                    73%            84%            80%            60%          
  Mathias, full     fixed 0.54                    73%            84%            80%            80%          
  Mathias, full     calibrated (0.540) -- LANDED  73%            84%            80%            80%          

  Mathias, sparse   fixed 0.35 (old default)      44%            73%            75%            0%           
  Mathias, sparse   fixed 0.40                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.45                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.50                    56%            73%            75%            50%          
  Mathias, sparse   fixed 0.54                    67%            73%            75%            75%          
  Mathias, sparse   calibrated (0.540) -- LANDED  67%            73%            75%            75%          

  Osnat, full       fixed 0.35 (old default)      43%            61%            100%           0%           
  Osnat, full       fixed 0.40                    43%            61%            100%           0%           
  Osnat, full       fixed 0.45                    43%            61%            100%           0%           
  Osnat, full       fixed 0.50                    43%            61%            100%           0%           
  Osnat, full       fixed 0.54                    43%            61%            100%           0%           
  Osnat, full       calibrated (0.385) -- LANDED  43%            61%            100%           0%           

  No-negative-signal fallback check (repo owner's caveat):
    119 all-positive ratings (no disliked/hated) -> calibrated threshold = 0.350 (falls back to default, as intended)

=== Scenario 8: dealbreaker-flag sanity check (fixed threshold, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; rebellion against empire; dystopia; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 9: dealbreaker-flag sanity check (statistically validated, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; rebellion against empire; dystopia; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 10: learning curve (accuracy vs. rating-history size) ===
  Mathias (held-out set fixed at 11 books, up to 15 random samples per size):
    Train size   Pairwise acc.    Bucket acc.    Repeats
    10           69%              36%            15
    32           69%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.085
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6789) vs The True Bastards (hated, held-out score 0.6938)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8226) vs Magic Burns (hated, held-out score 0.8487)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0354) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0165) vs A Crown of Swords (it_was_okay, held-out score -0.0625)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0445) vs The Dragon Reborn (it_was_okay, held-out score -0.0219)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0547) vs Lord of Chaos (loved, held-out score -0.007)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.0597) vs The Path of Daggers (hated, held-out score 0.0224)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0368) vs A Crown of Swords (it_was_okay, held-out score -0.0632)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0363) vs The Fires of Heaven (disliked, held-out score -0.0525)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0227) vs The Shadow Rising (loved, held-out score -0.0165)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.055) vs Knife of Dreams (loved, held-out score 0.0159)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0655) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0552) vs The Gathering Storm (loved, held-out score 0.0547)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0278) vs Winter's Heart (liked, held-out score 0.089)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0635) vs Knife of Dreams (loved, held-out score -0.0127)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0072) vs The Path of Daggers (hated, held-out score 0.023)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0499) vs Winter's Heart (liked, held-out score -0.0115)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0636) vs The Gathering Storm (loved, held-out score 0.0253)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0445) vs A Crown of Swords (it_was_okay, held-out score -0.0609)  [OK]
      DNA similarity: 0.852
      Field differences: {'overall_pace': ('medium', 'slow'), 'darkness': ('moderate', 'dark'), 'book_length': ('long', 'epic'), 'pace_shape': ('consistent', 'uneven'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']
      Tropes only in 'A Crown of Swords': ['war_story']

  Dandan summary: model correctly ranked 16/17 contrastive pairs.
  Gabriel: 0 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

=== Scenario 13: user-adjustable rules (none of X / less of X) ===
  parse trope key: OK
  parse valid ordinal field:value: OK
  parse valid nominal field:value: OK
  reject invalid ordinal value: OK
  reject unknown field: OK
  normalize None is empty: OK
  normalize {} is empty: OK
WARNING: unrecognized user rule key(s), ignored: ['not_a_real_field:x']
  normalize drops bad keys, keeps good ones: OK
  normalize applies default strength: OK
  normalize respects explicit strength: OK
  no rules is a guaranteed no-op: OK
  no rules is a no-op even with {}: OK
  exclude exact-matches and flags excluded: OK
  exclude leaves non-matching book untouched: OK
  reduce applies correct multiplicative discount: OK
  reduce leaves non-matching book untouched: OK
  multiple matching reduce rules stack multiplicatively: OK
  target list non-empty: OK
  target list includes a known field_value: OK
  target list includes a known trope: OK
  target list never invents unused values: OK
  sanity: baseline top-20 fantasy contains at least one YA book: OK
  exclude age_category:ya removes all YA from real recommend() output: OK
  reduce drive:romance_driven lowers its representation in top-20 (2 -> 0): OK
  All user-rules tests passed.
```

## Appendix B. Exact in-memory audit checks and output

These commands ran during Task 2. They import modules with -B, use synthetic dictionaries, and do not call load_catalog or connect to a database.

### B1. Reproduction, metadata, and experimental-reference checks

```sh
python3 -B - <<'PY'
import sys,json,ast
from pathlib import Path
sys.path.insert(0,'scripts');import recommend as R;import scoring_tests as T
cat={'x':{'id':'x','title':'Gateway','author':'A','genre_accessibility':'gateway'}}
print('Cold-start score:',R.recommend(cat,{},top_n=1)[0][0],'explanation:',R.explain_match(cat,{},'Gateway')['score'],R.explain_match(cat,{},'Gateway')['match_label'])
a={'a':{'id':'a','tropes':['quest']}};b={'b':{'id':'b','tropes':['found_family']}}
print('Cache A:',T._get_prevalence_cache(a)[1]);print('Cache B:',T._get_prevalence_cache(b)[1]);print('Fresh B:',R.build_prevalence_lookup(b)[1])
cat={k:{'id':k,'overall_pace':v,'_field_confidence':{'overall_pace':c}} for k,v,c in [('a','fast',1),('b','slow',0.2)]};ids={'a':1,'b':1}
print('Profile pace:',R.build_profile(cat,ids)[0]['overall_pace'],'audit:',R._audit_attribute_ordinal(cat,ids,'overall_pace'))
for p in sorted(Path('data/ratings').glob('*.json')):
 d=json.loads(p.read_text());print(p.name,'format_preference',d.get('_meta',{}).get('format_preference'))
# Identify all executable references to experimental functions, excluding their definitions.
names={'build_profile_trope_shrinkage','build_profile_trope_backoff','build_profile_series_field_dedup','build_profile_series_field_dedup_protected','build_profile_per_value','score_book_per_value','explain_book_per_value','build_prevalence_lookup_grouped','_apply_dealbreaker_veto_graduated'}
refs=[]
for folder in ['scripts','api','tools']:
 for p in Path(folder).rglob('*.py'):
  try:t=ast.parse(p.read_text())
  except (SyntaxError,UnicodeError):continue
  for n in ast.walk(t):
   name=n.id if isinstance(n,ast.Name) else n.attr if isinstance(n,ast.Attribute) else None
   if name in names:refs.append((str(p),n.lineno,name))
print('Executable experimental references:',refs)
PY
```

Actual output, exit 0:

```text
Cold-start score: 1.0 explanation: 0.0 Poor match
Cache A: {'quest': 1.0}
Cache B: {'quest': 1.0}
Fresh B: {'found_family': 1.0}
Profile pace: 1.0 audit: {'liked': {'n': 2, 'mean_position': 0.5}, 'disliked': None}
dandan.json format_preference None
gabriel.json format_preference None
mathias.json format_preference audiobook
mathias_goodreads.json format_preference None
osnat.json format_preference None
Executable experimental references: []
```

### B2. File/function size and credential-presence inspection

```sh
python3 - <<'PY'
import ast
from pathlib import Path
for p in ['scripts/recommend.py','scripts/scoring_tests.py']:
 t=ast.parse(Path(p).read_text());fs=[n for n in t.body if isinstance(n,ast.FunctionDef)]
 print(p,'lines',len(Path(p).read_text().splitlines()),'functions',len(fs))
 print(sorted([(n.end_lineno-n.lineno+1,n.name,n.lineno) for n in fs],reverse=True)[:10])
import os,re
s=Path('.env').read_text() if Path('.env').exists() else ''
print('Read-only variable in process environment:',bool(os.getenv('CODX_READONLY_DATABASE_URL')))
print('Read-only variable declared in .env:',bool(re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=',s)))
PY
```

Actual output, exit 0:

```text
scripts/recommend.py lines 3895 functions 66
[(181, 'build_profile', 989), (137, 'build_profile_trope_backoff', 1299), (118, 'audit_book_score', 3627), (113, 'build_profile_series_field_dedup_protected', 1644), (107, 'build_profile_series_field_dedup', 1499), (102, 'build_profile_trope_shrinkage', 1192), (94, 'recommend', 3257), (92, 'build_profile_per_value', 1780), (84, 'score_book', 2027), (80, 'explain_match', 3353)]
scripts/scoring_tests.py lines 1435 functions 37
[(97, 'run_user_rules_tests', 915), (62, 'run_all', 1014), (55, '_full_score', 201), (54, 'run_learning_curve', 1092), (47, 'run_held_out_test', 266), (45, 'run_diversity_curve', 1168), (40, 'build_scorecard', 514), (39, 'check_dealbreaker_flags', 831), (38, '_isolated_training_set', 365), (35, 'run_weight_cap_check', 415)]
Read-only variable in process environment: False
Read-only variable declared in .env: True
```

## Appendix C. Source-inspection command inventory

The following were the Task 2 source-reading/search commands. Their outputs were repository text or line-numbered search hits, not test results. The report cites the audited revision and relevant functions so those source outputs can be checked without presenting fresh file contents as historical observations. Some original tool displays were truncated; this appendix does not claim a complete raw transcript of every source-file read. Complete retained suite output and the behavioral-check output are provided above.

```sh
cat AGENTS.md
cat CLAUDE.md
cat docs/codx-reviews/codx-recommend-review-2026-09-14.md
rg -n 'Phase A|Phase B|A1|A2|Astra|structural refactor|2026-09-14' docs/TODO.md docs/scoring-test-protocol.md
git status --short
git rev-parse HEAD
tail -n 100 docs/project-log.md

sed -n '130,335p' docs/TODO.md
sed -n '2560,2700p' docs/scoring-test-protocol.md
rg -n '^def |__main__|assert |random|open\(|write\(' scripts/scoring_tests.py

sed -n '1,48p' scripts/scoring_tests.py
sed -n '147,314p' scripts/scoring_tests.py
sed -n '915,1080p' scripts/scoring_tests.py
rg -n 'score_book\(|_apply_series_repeat\(|_apply_dealbreaker_veto\(|_apply_series_trajectory_penalty\(|cold_start_weight\(|explain_match\(|audit_book_score\(' --glob '*.py' --glob '!recommend.py'
rg -n '^def |^[A-Z][A-Z_]+ =' scripts/recommend.py
rg --files .claude/skills
rg -n 'confidence|scoring|genre|Tier B' docs/schema/book-dna.md

sed -n '466,515p' scripts/recommend.py
sed -n '3300,3440p' scripts/recommend.py
sed -n '3627,3746p' scripts/recommend.py
sed -n '100,205p' api/main.py
sed -n '415,487p' scripts/scoring_tests.py
sed -n '643,674p' scripts/scoring_tests.py
sed -n '761,795p' scripts/scoring_tests.py
sed -n '1391,1410p' scripts/scoring_tests.py

rg -n 'R\.|import recommend|import scripts.recommend' tools/dogfood/app.py scripts/recommend.py | tail -n 65
sed -n '2027,2190p' scripts/recommend.py
rg -n 'format_preference|cold_start|series_position_ready|diversity=|confidence|audit_book_score|explain_match|MIN_CONFIDENCE|nominal_similarity' scripts/scoring_tests.py
rg -n 'score_book\(|_full_score\(|match_label\(' scripts/recommend.py scripts/scoring_tests.py
sed -n '3569,3626p' scripts/recommend.py
sed -n '2464,2598p' scripts/recommend.py
sed -n '755,795p' scripts/recommend.py

sed -n '3800,3895p' scripts/recommend.py
sed -n '514,580p' scripts/scoring_tests.py
sed -n '1092,1147p' scripts/scoring_tests.py
git status --short
rg -n 'explain_book\(|strong_fields|EXPERIMENTAL|NOT wired|UNDER TEST' scripts/recommend.py | tail -n 22
sed -n '831,914p' scripts/scoring_tests.py
```

Selected exact search output that establishes external consumers:

```text
api/main.py:171:        detail = R.explain_match(catalog, ratings, title, genre=genre, format_preference=format_preference)
scripts/scoring_tests.py:249:    score, _ = R.score_book(book, centroid, weights, field_prevalence, trope_prevalence)
scripts/scoring_tests.py:250:    score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
scripts/scoring_tests.py:251:    score = R._apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score,
scripts/scoring_tests.py:253:    score = R._apply_series_trajectory_penalty(_SERIES_DNA_CACHE, book, centroid, weights, score,
tools/dogfood/app.py:187:            audit = R.audit_book_score(catalog, ratings, title, genre=genre, user_rules=st.session_state.rules,
```

Selected exact search output that establishes the scoring/explanation dependency and stale trajectory header:

```text
2641:    _, mismatches = explain_book(book, centroid, weights, top_n=100,
2741:# --- Series-trajectory penalty (2026-09-04, EXPERIMENTAL -- UNDER TEST, --
2742:# NOT wired into recommend()/explain_match() yet) -----------------------
2803:    matches, _ = explain_book(book, centroid, weights, top_n=100,
2805:    strong_fields = {f: c for f, c in matches if c > 0.15 and not f.startswith("trope:")}
```

All findings and proposals above derive from these observed source paths, the in-memory checks, the actual suite runs, and the existing project decisions. No new scoring experiment was performed during reconstruction.

