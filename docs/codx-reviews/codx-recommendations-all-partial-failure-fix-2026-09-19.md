# Task 14 — partial-failure isolation for consolidated recommendations

2026-09-19 · CODX · **Implemented and validated as a proposal.**

Synced to `bf345d0f2a97bc2fb4f8447d00d5939e37817245`, read the refreshed assignment and the committed Task 13 review. The task's embedded baseline `d112a96` precedes the assignment commit; the actual synced HEAD above is the patch base.

[Complete two-file patch](2026-09-19-recommendations-all-partial-failure-fix-evidence/proposal.patch): `api/main.py` and `app/dashboard.html`, 61 insertions / 26 deletions. Source files have been restored after validation: **all 477 tracked files SHA-256 match HEAD**, index clean, patch applies with `git apply --check`. No commit, push, hosted write or user-data query occurred. Existing untracked reports were preserved.

## Behavior and design choices

`/recommendations/all` now catches and logs each genre's scoring exception separately. Authentication and catalog/ratings/rules/format-preference acquisition remain outside that boundary. Every genre appears in exactly one of `results_by_genre` or `errors_by_genre`; errors expose only `temporarily_unavailable`.

- **HTTP 200** when at least one genre succeeds, including a successful empty list. Healthy result lists are unchanged.
- **HTTP 500** when all three fail, with the **same envelope**, an empty results dictionary and three safe error markers. This is a server-side scoring failure, not a successful empty recommendation set. There is no evidence that every possible exception is temporary service overload, so 500 is more accurate than asserting 503 semantics.
- `JSONResponse` preserves that exact all-failed envelope rather than wrapping it inside FastAPI's `detail` field.
- Python standard-library logging records one exception/traceback per failed genre server-side. There was no existing API print/logger convention to reuse. No exception text or traceback is returned to clients.
- The single-genre `/recommendations` route and `_score_genre` remain unchanged, as do all scoring modules.

The dashboard reads the new envelope into **separate** `resultsByGenre` and `errorsByGenre` objects. It processes thumbnails and filters for every healthy list even when the currently selected tab failed. Tab rendering uses one shared helper: healthy tabs render their normal results, failed tabs show a genre-specific error with an instruction to click the existing “Get recommendations” button, and all-three-failed shows an overall error/retry message. No new button or UI framework was introduced.

`apiFetch()` is a thin wrapper around fetch and returns non-2xx responses without throwing. The consumer explicitly parses the safe HTTP-500 envelope as well as HTTP-200 envelopes. Shared/auth errors without that envelope remain request-level errors; non-JSON bodies are handled by the existing generic catch message.

## Cache behavior

The session cache now saves `errorsByGenre` alongside the successful lists. The actual reload initializer restores both and renders the selected tab through the same helper used for tab switches. Failure is never represented as an empty successful list. Successful empty lists remain distinguishable from failed genres.

A new `clearRecsState()` resets both dictionaries and removes their persisted cache. It is used at fetch start and the two existing rule-change invalidation sites, preventing old errors or previous successes from being resurrected after invalidation or a failed retry. Successful retries replace the old errors with an empty error dictionary.

Legacy success caches without `errorsByGenre` still load with `{}` as their errors map. The existing user-ID check remains intact. Storage exceptions remain nonfatal. Both failures and successes use the existing session lifetime; no persistent/global user-profile cache was added.

These are implementation details within the prescribed design, not deviations. The only status/body choice left open by the task was all-three-failed; the justification is above. Backend and dashboard must be reviewed/applied together because this intentionally changes `/recommendations/all`'s response contract. `/recommendations` keeps its old contract.

## Validation

The API harness uses real FastAPI TestClient/httpx and unchanged scoring functions, with fixture-backed authentication and user-data loaders. Catalog input is the fresh read-only Task 13 snapshot already available in this clone: **1,059 scored rows**, SHA-256 **`631e8f5e87ab531f7a501f7630d5d70c6a9040309dd4f66b75599b6e13ba87f7`**. No new database access was needed for this call-wiring/UI change. The harness reads `docs/codx-reports/2026-09-19-recommendation-engine-review-evidence/catalog.pickle`; that evidence is local rather than a new tracked fixture. The earlier task's read-only loader can reproduce it if needed, although a later live snapshot can differ.

### Backend

Real before/proposal comparisons use Gabriel, Dandan and Mathias-Goodreads rating files, three genres, top_n -5/1/7/101, print/mixed/audiobook preferences and an exclusion/reduction rule variant:

```text
PASS 36 single-genre HTTP responses byte-identical; SHA256 dbd6105c9106a08bab1b76de71d71c0ab6d7beca9cea477bc2e7710284d5caba; 3 all-success envelopes preserve original lists
PASS all 8 genre-failure subsets: surviving real lists exact, status 200/500 correct, shared inputs loaded once, one server log per failure, no exception text in responses
PASS empty successful list plus two failures returns HTTP 200
PASS shared-load failures remain HTTP 500 before scoring; auth 401, bad genre 400, invalid limit 422 and single-genre error propagation preserved
PASS every other API function AST unchanged, including single-genre route and scoring helper
```

All eight combinations include each one-genre failure position, each two-genre failure, all success and all failure. The healthy lists are computed by the real scorer and compared with the same profile's unfaulted results. The harness asserts three scoring attempts despite failures, one call to every shared loader, and disjoint results/error dictionaries. An exception containing a synthetic sensitive marker verifies that server logging occurs while the marker is absent from the response.

Shared catalog/ratings/rules/format loading failures each return 500 **before any scoring call**. Missing authorization remains 401. Single-route scoring exceptions still propagate as 500. API result evidence: [api-results.txt](2026-09-19-recommendations-all-partial-failure-fix-evidence/api-results.txt), [api-faults.json](2026-09-19-recommendations-all-partial-failure-fix-evidence/api-faults.json), and complete `api-run.log`. The log includes intentional server-side tracebacks from fault injection; the process exited 0 and every assertion passed.

### Dashboard and actual cache round trips

Extended Task 13's Node VM technique rather than substituting a reimplementation of the handler. The test executes the real source for the fetch handler, tab handlers, save/load functions, reload initializer, thumbnail attachment and audiobook/series filtering. HTTP, DOM elements, storage and catalog-query boundaries are deterministic fixtures; no full browser/deployment test is claimed.

```text
PASS 17 dashboard scenarios; 9 partial-failure cache round-trips; actual fetch/tab/cache/reload/thumbnail/filter code; healthy lists never contain error metadata
```

Coverage:

- All-success, both with and without filters, compares before/proposal rendered data and successful lists exactly. Requests retain top_n 10/50 and display truncation to ten.
- Each failing genre × each initially selected genre: nine combinations. Healthy tabs render, failed tabs display an error, and switching between them works.
- Each of those nine cases selects the failed tab, saves through the actual tab handler, then constructs a **fresh VM** using the saved sessionStorage and executes the actual page initializer. The failed genre remains absent from successful lists and present in the restored error map; it renders its error rather than zero recommendations. Healthy tab switching still works after reload.
- A subsequent successful retry clears errors and restores all three results keys.
- All-three-failed shows an overall error before and after reload.
- Successful empty lists render the normal empty-success state, with no error marker.
- Network rejection, auth HTTP error and shared HTTP-500/non-envelope error show a request-level message and do not leave a cache behind.
- Legacy success cache, cross-user isolation and cache invalidation pass.

The full inline dashboard script also parses successfully. The actual thumbnail/filter code receives only arrays, exercising the metadata-leak concern directly. Evidence: [dashboard-results.json](2026-09-19-recommendations-all-partial-failure-fix-evidence/dashboard-results.json) and [dashboard_check.cjs](2026-09-19-recommendations-all-partial-failure-fix-evidence/dashboard_check.cjs).

No scoring-suite rerun was necessary: scoring modules were not changed, every other API function's AST was verified unchanged, and real endpoint comparisons exercise the changed integration path directly. This task's required validation is complete.

## Commands and handoff

The substantive validation commands, from the clone root (`E` abbreviates the evidence directory):

```sh
git pull --ff-only
E=docs/codx-reports/2026-09-19-recommendations-all-partial-failure-fix-evidence
PYTHONHASHSEED=0 /private/tmp/codx-task12-api-venv/bin/python "$E/test_api.py" > "$E/api-run.log" 2>&1
node "$E/dashboard_check.cjs"
git diff --check
git diff -- api/main.py app/dashboard.html
```

The API test continued running across the conversation interruption; its completed process returned exit 0 when polled afterward. Dashboard tests then passed. The final backend docstring clarification did not change executable behavior. Both files were saved in `before/` before editing. The final patch and proposed-file hashes were captured, originals restored from HEAD after verifying against those backups, and every tracked file hashed against its git blob.

To reproduce in this clone, apply the saved proposal locally first (after `git apply --check`), then run the two test commands above using the existing isolated API venv and snapshot. API tests require the repo's declared API requirements plus httpx 0.28.1; Node v26.7.0 was used for the dashboard test. Nothing requires a write-capable credential. No dependency manifests were modified.

Final state: patch applies cleanly to `bf345d0f2a97bc2fb4f8447d00d5939e37817245`; working tree/index have no tracked changes; **477 tracked files match HEAD**. See [restoration.txt](2026-09-19-recommendations-all-partial-failure-fix-evidence/restoration.txt), [facts.json](2026-09-19-recommendations-all-partial-failure-fix-evidence/facts.json) and recursive `SHA256SUMS`. No pending approval entry or immediate hosted action is needed. Ready for CLDO's independent review.
