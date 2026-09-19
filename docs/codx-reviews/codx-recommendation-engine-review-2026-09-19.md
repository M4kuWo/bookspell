# Task 13 — independent recommendation-engine review

2026-09-19 · CODX · **Review complete; no implementation changes.**

Synced from `16d09c9` to `2904c41` and reviewed `fcf8f65` and `e8281c2` against the pre-fix implementation. The task and matching documentation are dated 2026-09-20; the session date and commits' author dates are 2026-09-19. This report uses the session date. The refreshed assignment is current despite its embedded `e8281c2` baseline preceding the task-file commit.

**Verdict: keep both optimizations. No scoring-math difference or successful-response regression found. Restore per-genre failure isolation in a bounded follow-up.** The all-or-nothing endpoint is a real resilience regression, independently reproduced through both HTTP routes and the actual dashboard click handler. There is also a small change in missing-title validation order. Neither warrants reverting the performance work.

## Findings, ordered by impact

### P2 — one genre failure now suppresses healthy genres

**Locations:** `api/main.py:236`–239 and `app/dashboard.html:306`–312.

The dictionary literal in `/recommendations/all` evaluates three `_score_genre` calls sequentially without isolating exceptions. Any one failure discards the entire response, including lists already computed successfully. Dashboard clears its previous results before fetching and receives no successful lists on the resulting HTTP 500.

Independent reproduction, using real TestClient routes with a fault injected only into `api.recommend` for one selected genre:

| Injected failure | Separate `''`, fantasy, sci-fi HTTP statuses | `/recommendations/all` |
| --- | --- | --- |
| Unfiltered | 500, 200, 200 | 500 |
| Fantasy | 200, 500, 200 | 500 |
| Sci-fi | 200, 200, 500 | 500 |

The two healthy individual requests execute the real scorer. This is not three mocked response bodies being compared. [partial-failure.json](2026-09-19-recommendation-engine-review-evidence/partial-failure.json) preserves the responses.

Also executed the **actual old and new dashboard click-handler source** in Node's VM with deterministic HTTP/DOM boundaries. With fantasy currently selected and sci-fi returning HTTP 500, the old handler renders fantasy; the new handler displays the error state with no genre results. Successful unfiltered/filtered fetch behavior remains equivalent. Five before/after scenarios cover success, filtered success, another genre failing, the selected genre failing, and rejected network fetches; see [dashboard-results.json](2026-09-19-recommendation-engine-review-evidence/dashboard-results.json).

**My judgment: worth fixing, as a normal-priority resilience follow-up, not an emergency rollback.** Sharing ratings/rules does not guarantee failures are correlated: different genre weights and candidate pools execute different data-dependent paths. The consolidation removes a working fault boundary. The costs of preserving that boundary are modest compared with losing all recommendations for a recoverable single-view problem.

Do not overstate the observed frequency: **no naturally occurring genre-only exception was found** in the real-catalog sample or thin-profile tests. Empty ratings, neutral-only/positive-only/negative-only ratings, invalid labels/missing rating titles, and an empty catalog all returned successful consolidated responses. `build_prevalence_lookup` guards empty-pool division with `len(pool) or 1`, calibration falls back if either side is absent, and profile resolution falls back to the unscoped rating pool. “Too little data” by itself is not a demonstrated crash cause. The fault injection proves changed isolation, not a currently broken catalog row.

The old implementation was not resilient to every failure either: a rejected network promise made its `Promise.all` reject before processing any responses. The regression specifically concerns failures represented by an individual HTTP error response, such as a genre-only server exception.

**Concrete proposed follow-up, not applied:**

- Keep authentication and shared data acquisition outside the per-genre exception boundary; those failures should still fail the request normally.
- Score each genre independently, log exceptions server-side, and preserve successful lists. Return partial success when at least one genre succeeds; retain an error response if none succeeds.
- Use an explicit envelope such as `{"results_by_genre": {...}, "errors_by_genre": {"sci_fi": "temporarily_unavailable"}}`, with no exception details exposed to clients. Update this endpoint's dashboard consumer in the same change.
- Assign **only** the lists dictionary to `resultsByGenre`. Do not add an `errors` object alongside the genre arrays: `attachThumbnails()` uses `Object.values(byGenre).flat()` and later `.forEach()` on every value, and would treat that metadata as recommendation data.
- Keep healthy tabs usable even when the selected tab failed; show a retry/error state for the failed tab. Do not represent or cache a failed genre as a successful empty recommendation list. Test all three failure positions and shared-loader/all-genre failures.

This needs an explicit API/UI error contract, so I have proposed it rather than silently choosing and landing a response-shape change in a review task. No source patch was created.

### P3 — missing titles no longer fail before profile preparation

**Location:** `scripts/scoring/api.py:302`–303; title validation now occurs in `explain_match_with_profile`, after `resolve_explain_profile` completes.

Before `fcf8f65`, `explain_match` validated the requested title first. Afterward it resolves the full bundle first. With a valid ratings dictionary containing an unknown rating title and a missing target, both versions raise the same target `ValueError`, but only the new version first prints the unrelated rating warning. Even a clean missing-title call now pays for profile/series/prevalence/calibration work.

A deliberately out-of-contract `ratings=None` example illustrates the changed exception precedence: old raises target `ValueError`; new raises `AttributeError` from ratings resolution before checking the target. This is not a claim that `None` is a supported ratings input. The supported-input warning/work-order change is enough to qualify the documentation's blanket “behavior and cost unchanged” claim.

[validation-order.json](2026-09-19-recommendation-engine-review-evidence/validation-order.json) contains all three concrete cases, including the unchanged empty-dict missing-title exception. Successful explanation outputs are unaffected. Existing endpoint callers select real catalog titles, so this is a small public-helper contract issue rather than a dashboard outage.

Suggested fix: check title membership at the start of the public `explain_match` wrapper, before resolving the bundle. Keep the prepared helper's own validation for independent callers. Avoid broadening this into scoring changes; a small validation test for missing target + missing rating title is sufficient.

## Independent correctness evidence

The harness was written for this review, not copied from CLDO's verification. It loads the actual pre-`fcf8f65` source as a separate module inside the `scoring` package and compares it against current code. Explicit assertions confirm separate orchestrator modules with identical unchanged dependency functions (`_resolve_profile` and `score_candidate`); no monkeypatch accidentally compares a module with itself.

A fresh snapshot was loaded via **`CODX_READONLY_DATABASE_URL`**, using only the authorized catalog loader: **1,059 scored rows**, 868,584 bytes, SHA-256 `631e8f5e87ab531f7a501f7630d5d70c6a9040309dd4f66b75599b6e13ba87f7`. The harness then uses that one frozen catalog throughout. No user tables or local database were queried.

### Explanation comparisons

**1,350 successful cases:** 3 real rating files (`gabriel`, `dandan`, `mathias_goodreads`) × 6 genre/format/fatigue contexts × 5 `top_n` values (`-1`, `0`, `1`, `7`, `None`) × 15 titles.

Twelve titles are deterministically selected by SHA-256 sorting, rather than catalog row order, plus The Traitor God, Cursed Bunny and Quidditch Through the Ages. The complete sample is in [sample.json](2026-09-19-recommendation-engine-review-evidence/sample.json). Contexts include all three normal genres, print/audiobook/mixed/default format preferences, and both field/trope fatigue overrides.

CLDO's writeup does not name its exact four raters or forty titles, so I cannot certify disjoint raters/titles. This independently selected grid demonstrably differs in its five explanation limits, format/fatigue dimensions and endpoint limit boundaries; it also includes the Goodreads rating file rather than only relying on the canonical four-person roster.

| Comparison | Cases | Unexpected mismatches |
| --- | ---: | ---: |
| Old vs current `explain_match` returned object | 1,350 | 0 |
| Old vs current successful-call stdout | 1,350 | 0 |
| Old vs prepared helper, manually resolved bundle without title map | 1,350 | 0 |
| Old vs prepared helper, manual bundle with title map | 1,350 | 0 |
| Bundle remains unchanged after reuse | 18 bundles | 0 |
| Empty/thin/invalid rating cases, absent genre, empty catalog | 40 result comparisons | 0 |

Manual preparation calls `profile._resolve_profile`, `pipeline.validated_dealbreaker_fields`, `series.compute_series_dna`, `prevalence.build_prevalence_lookup` and `pipeline.user_calibrated_poor_threshold` directly; it never calls the new resolver being reviewed. Comparisons preserve dictionary order, tuple/list distinctions and binary64 float bytes. A separate success check confirms all 1,350 ordinary cases actually return explanation dictionaries, ruling out identical-exception false positives. The missing-title warning/exception-order differences above are recorded separately, not silently counted as successful-call matches.

### HTTP endpoint comparisons

Real FastAPI **TestClient/httpx** requests run against three route modules: before the first fix, after the first fix/before consolidation, and current HEAD. Auth and `_load_user_*` are patched at their module attributes, as required for these plain function calls; catalog acquisition returns the snapshot. Scoring and HTTP route parsing/serialization are real. No `dependency_overrides` shortcut or real user-data access is used.

Three real rating files × three genres × `top_n=-5,1,7,101` produce **36 HTTP comparisons** for each baseline/intermediate and baseline/current pair, all byte-identical. **12 consolidated responses** exactly match their three separate current genre lists. Inputs include mixed/audiobook/print formats, actual exclusion/reduction rules, and invalid `genre:*` rule keys to check existing normalization behavior (those keys are unsupported and ignored with the pre-existing warning; they are not claimed to exclude every book).

Additional checks: 10 thin/empty-catalog consolidated requests succeed, invalid/empty genre yields 400, noninteger `top_n` yields 422, and both routes return 401 without authorization. Boundary limits exercise clamping below 1 and above 100. No authenticated production request is claimed.

Instrumented call counts confirm the intended work reduction:

| Work | Three current single-genre requests | One consolidated request |
| --- | ---: | ---: |
| Authentication | 3 | 1 |
| Catalog acquisition function | 3 | 1 |
| `_load_user_ratings` | 3 | 1 |
| `_load_user_rules` | 3 | 1 |
| `_load_format_preference` | 3 | 1 |

These are function-call counts, not measured network traffic. Each user-data helper still opens its own connection, so consolidation removes **six of nine user-data connections/queries**, leaving three—not one shared connection. Catalog acquisition is already cached and does not necessarily query Postgres on every call.

### Unchanged math, CLI and canonical suite

Every scoring implementation file except `scripts/scoring/api.py` byte-matches Task 12. Inside api.py, `recommend` and `series_dnf_outlook` have identical ASTs. An independent AST comparison confirms `_score_genre` contains the intermediate route's exact statements from its `results` assignment through list construction; only the final return wrapper differs.

The actual unchanged CLI source was executed against the frozen catalog with old and current engine modules; complete stdout is byte-identical. The full canonical suite was run against hosted read-only data, then against the frozen catalog with old/current orchestrators. All three outputs are byte-identical: **29,599 bytes**, SHA-256 `d9be87888e89b6c89d2539e0e32468e90f16a344211c8a419ed904c9add330ff`. The canonical suite remains collateral coverage because it does not call `explain_match`; the independent comparisons above provide that coverage.

Full results: [review-output.txt](2026-09-19-recommendation-engine-review-evidence/review-output.txt), [stats.json](2026-09-19-recommendation-engine-review-evidence/stats.json), [mismatches.json](2026-09-19-recommendation-engine-review-evidence/mismatches.json), [call-counts.json](2026-09-19-recommendation-engine-review-evidence/call-counts.json). Aggregate comparison digest: `2c88f0e768002fff035b8c12558db5c3701b8db28fada2d24f9bf00cf7f0bfcd`.

## Callers and code-quality judgment

Searched `explain_match\(` and `\.recommend\(` across api/, app/, scripts/, tools/ and docs/, including historical review evidence; retained the raw results in `caller-search.txt`. An AST scan distinguishes active code from documentary examples. [active-callers.json](2026-09-19-recommendation-engine-review-evidence/active-callers.json) lists eleven qualified call sites:

- `api/main.py`: recommend, resolve the explanation bundle, prepared explanation.
- `scripts/recommend.py`: one recommend call and three explain calls.
- `scripts/scoring_tests.py`: three recommend calls in rule tests.
- `tools/dogfood/app.py`: one recommend call; its audit path calls the separate audit module, which is unchanged.

The new wrapper calls resolver/helper internally. There are no other active external callers of the new functions or series outlook in tracked runtime Python. Historical reports contain many examples, not additional production consumers. No caller requiring a migration was missed. The CLI's three explanations, not merely its import, were exercised.

**Nine-key dictionary vs dataclass:** keep the dict for this patch. It is request-local, constructed in one place, and unpacked into an explicit function signature; keyword mismatches fail clearly. A dataclass would organize names, but would not by itself prevent mixing a catalog/profile/genre context or mutating nested dictionaries. The real invariant is reuse only within the same catalog/ratings/genre/format/fatigue context. That is satisfied at the current call site. If more consumers grow, a typed shared context is reasonable; I would not add one solely to polish this narrowly scoped optimization. `resolve_explain_context` would be a slightly more accurate name than “profile” because this bundle includes catalog-derived series/prevalence/title indices, but renaming is not necessary.

**`_score_genre` location:** api/main.py is appropriate. It builds the HTTP response shape and coordinates already-existing engine functions without adding web concepts to scoring code. No new service abstraction is warranted for one shared route helper.

**Small optional simplification:** return `[]` immediately when `api.recommend` returns no results, before preparing explanations. The old per-result loop did zero explanation preparation in that case; the new helper prepares an unused bundle. This saves work for fully filtered/empty candidate sets. It is separate from correctness and lower priority than failure isolation.

**Remaining duplication:** measured `_resolve_profile` calls are **2 per single-genre endpoint, 6 per all-genres request**, confirming the identified residual redundancy. I agree with deferring its removal from these fixes. Illustrative offline timings with Gabriel's ratings across three genres and top_n 7/100 put the second preparation at **11.3–13.9 ms**, versus approximately **70–156 ms** for ranking. These are six single-sample CPU-side observations, not a production latency benchmark or stable speedup estimate; raw timings are in [remaining-cost.json](2026-09-19-recommendation-engine-review-evidence/remaining-cost.json).

However, changing recommend's **return contract is not required** to reach one preparation later. A private prepared-ranking helper could accept a common request context while the existing public `recommend(...)` wrapper retains its current arguments and return list. The route could prepare once, call that helper, then prepared explanations. This would require threading ranking's `matches_genre`, cold-start state, normalized rules/history and the shared base bundle explicitly, with equivalence tests across all ranking options; it is a separate real refactor, not a trivial cache toggle.

Do **not** simply reuse ranking's final score/label as the explanation result: ranking includes cold-start/diversity/user-rule behavior which the explanation policy intentionally omits. That would change existing semantics. Avoid process-global/lru caching of mutable user bundles; the current request-local scope is the correct boundary.

## Documentation observations

The task asks for two corresponding scoring-test-protocol entries. Only the first exists: `docs/scoring-test-protocol.md:3366` documents the profile-resolution fix and ends by saying the dashboard change remains open. The consolidation is documented in project-log.md and TODO.md, but there is no matching protocol entry in current HEAD. This is a minor documentation omission; I read both other accounts and verified the code independently. The first entry should also qualify its unchanged error-behavior/cost assertion per the missing-title finding.

The later log/TODO claim that consolidation removes duplicated reads is supported by measured call counts. No claim here that three formerly parallel requests necessarily add their network latencies serially; production wall-clock improvement depends on connection/server behavior. Work reduction and latency reduction are distinct measurements.

## Reproduction, limits and handoff

All new files are under `docs/codx-reports/2026-09-19-recommendation-engine-review-evidence/`; no tracked source was edited. The harness records old sources, sample selection, exact results, fault cases, complete suite/CLI stdout and dependency versions. The catalog snapshot contains only fields from the authorized catalog loader. Rater fixtures are existing local JSON files; no hosted ratings/rules/profiles or credentials appear in the evidence.

Substantive executed commands (`E` abbreviates the evidence directory):

```sh
git pull --ff-only
E=docs/codx-reports/2026-09-19-recommendation-engine-review-evidence
python3 "$E/live.py"
/private/tmp/codx-task12-api-venv/bin/python -m pip install httpx
PYTHONHASHSEED=0 /private/tmp/codx-task12-api-venv/bin/python "$E/review.py" > "$E/review-run.log" 2>&1
node "$E/dashboard_check.cjs"
PYTHONHASHSEED=0 /private/tmp/codx-task12-api-venv/bin/python "$E/success_and_cost.py" > "$E/success-and-cost.txt" 2>&1
```

The existing isolated API venv has the repo's declared API dependencies; httpx 0.28.1 was added for TestClient. Its versions are recorded in `python-environment.txt`. Live reads needed the authorized network escalation. The launcher reads only CODX_READONLY_DATABASE_URL from .env and scopes DATABASE_URL to its child commands, never printing the credential. Both live commands exited 0; the review and supplementary success checks exited 0. Node v26.7.0 ran the handler checks. The browser check stubs HTTP/DOM/thumbnail/filter boundaries; it is not a full browser/deployment test. No wall-clock production performance guarantee is claimed.

`review.py` can be rerun offline once the snapshot exists. `live.py` refreshes the catalog and live suite through the read-only role. Tests execute current reviewed source without editing it. Proposed fixes are written recommendations only; there is no unapplied implementation patch to find. Final integrity check: all **443 tracked files** SHA-256 match HEAD; working tree/index contain no tracked changes. See `integrity.txt` and recursive `SHA256SUMS` in the evidence directory.
