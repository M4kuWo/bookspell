# Task 11 — Phase B module split proposal

2026-09-17 · CODX · **Complete, implemented and verified locally; proposal only.**

Synced by fast-forward from `3621ecb` to `9d316308b8201ce68b59516b14ff8f50cccf6eb8`. Read the refreshed Task 11 assignment. Its embedded baseline `c706262` predates the actual synced task commit; the assignment itself is current and unambiguous. No scoring design changes were made.

The proposal moves all **68 functions**, with their complete source bytes and ASTs unchanged, into **15 implementation modules** plus an empty package initializer. It replaces the original 4,036-line `scripts/recommend.py` with a 439-line compatibility shim, including the unchanged original module documentation, CLI demo and historical comments. All **112 original function/constant definitions** remain explicitly exported, including private and dormant experimental helpers. All **821 original comment tokens** are retained.

**The proposed code is saved in [proposal.patch](2026-09-17-phase-b-module-split-evidence/proposal.patch).** The working implementation was then restored as the assignment requires: all **351 tracked files** hash-match HEAD, the index is clean, and the generated `scripts/scoring/` directory has been removed. Existing unrelated untracked reports were preserved. No commit, push, hosted write, local database operation, or user-data query occurred.

## Final module map

All paths below are under `scripts/scoring/`. The exact mapping of every definition and all module dependency edges is in [module-map.json](2026-09-17-phase-b-module-split-evidence/module-map.json).

| File | Contents and rationale |
| --- | --- |
| `__init__.py` | Package documentation only; no eager imports. |
| `constants.py` | All 44 original module-level assignments and their explanatory comments. One dependency-free source for defaults, field encodings, display vocabulary, policy constants and environment-derived configuration. |
| `encoding.py` | `nominal_similarity`, `ordinal_position`: shared low-level helpers missing from the starting map. |
| `pipeline.py` | All 16 proposed scoring/evaluation/veto/trajectory functions, plus `user_calibrated_poor_threshold`. |
| `series.py` | `compute_series_dna`, `describe_series_trajectory`, `book_similarity`, `series_repeat_worst_similarity`, `series_position_ready`. |
| `profile.py` | The four proposed profile functions, plus `_series_deduped` and `_series_deduped_id_to_magnitude`. |
| `calibration.py` | `get_confidence`, `scoring_confidence`, `match_label`. |
| `cold_start.py` | `reader_experience_fraction`, `cold_start_weight`. |
| `prevalence.py` | Both prevalence builders. |
| `explanations.py` | All six proposed phrase/description/sentence helpers. |
| `rules.py` | All five proposed user-rule helpers. |
| `feedback.py` | All three proposed feedback functions. No feedback log was written during verification. |
| `audit.py` | Both attribution helpers, `audit_book_score`, `print_score_audit`. |
| `experimental.py` | All nine specified dormant builders/helpers, moved without evaluating or redesigning them. |
| `catalog.py` | `load_catalog`, with its existing psycopg2 imports and unchanged SELECT queries. |
| `api.py` | `recommend`, `explain_match`, `series_dnf_outlook`. These are engine orchestrators, separate from the unchanged FastAPI `api/main.py`. |

### Why three boundaries differ from the proposed map

1. **Threshold calibration belongs beside the scorer it calls.** `user_calibrated_poor_threshold` calls `score_book`; `score_candidate` calls `match_label`, and the evaluator uses `scoring_confidence`. Leaving all these in the suggested calibration/pipeline split creates a calibration↔pipeline cycle. The three low-level confidence/label helpers remain in calibration; the score-based threshold helper joins pipeline.
2. **Series outlook is orchestration, not pure series data.** `series_dnf_outlook` calls `_resolve_profile`, `build_prevalence_lookup` and `score_book`. Keeping it in series creates a series↔pipeline dependency. It joins the other public orchestrators in scoring/api.py.
3. **Deduplication joins profile preparation.** `_series_deduped_id_to_magnitude` calls `_split_by_sign` and `_series_deduped`; `build_profile` calls `_series_deduped`. Keeping the proposed placement produces a profile↔series cycle. Both related deduplication functions now live together in profile.py.

The supplied rationale for keeping veto/dealbreaker evaluation with the scoring core was correct: `_apply_dealbreaker_veto` and `_apply_series_trajectory_penalty` call `explain_book`, while `score_candidate` calls those stages. The full dependency graph is acyclic. All new cross-module imports are ordinary module-level imports; no cycle is hidden with a deferred import. Existing function-local standard-library imports were retained byte-for-byte.

### One necessary location-sensitive assignment

The sole non-import expression adjustment is the default `FEEDBACK_LOG_PATH` assignment. Moving it from `scripts/recommend.py` to `scripts/scoring/constants.py` requires an extra `os.path.dirname` around `__file__` to preserve the original default `scripts/feedback_log.jsonl` destination. Its environment-variable override is unchanged. Every other assignment has identical source bytes. The verifier compares all original constant values, including the default feedback path, and confirms equality.

A literal unchanged `__file__` expression would silently relocate feedback output into `scripts/scoring/`; this proposal explicitly prevents that. Every function, including `log_feedback`, remains byte-identical.

## Compatibility and consumers

Re-derived accesses using an AST scan of all tracked Python files, supplemented by repository text search across scripts, API and tools. The task's list covers all **28 executable attributes** used by `api/main.py` and `scripts/scoring_tests.py`. It also includes `_series_trajectory_penalty_factor`, which is mentioned in test documentation rather than accessed by executable code; that helper remains exported too.

There are five actual importing consumers, not just the two emphasized in the assignment:

- `api/main.py`
- `api/catalog_cache.py`
- `scripts/scoring_tests.py`
- `scripts/import_goodreads.py`
- `tools/dogfood/app.py`

The additional required symbol is **`audit_book_score`**, used by the dogfood UI. All five files remain exactly equal to HEAD, and every accessed attribute resolves. [consumers.json](2026-09-17-phase-b-module-split-evidence/consumers.json) records the complete per-file access lists.

The shim uses explicit relative imports when loaded as `scripts.recommend`, and explicit `scoring.*` imports for the existing `import recommend` / direct-script path. Both paths were exercised in fresh processes. The original `if __name__ == "__main__"` block is byte-identical.

No `git mv` was used: one original file was split across sixteen new files while its original path remains the compatibility shim. There is no one-to-one file move to represent; plain source extraction is the assignment's stated fallback. The patch needs neither index staging nor a commit.

## Validation results

### Per-function source and AST verification

[verification.txt](2026-09-17-phase-b-module-split-evidence/verification.txt) contains an individual PASS line, new location and SHA-256 for each of the 68 functions. Verification compares both `ast.dump(..., include_attributes=False)` and the exact full function source, including signatures, defaults, bodies, docstrings and internal comments. No function was omitted or duplicated.

It also verifies constant equality, assignment bytes, unchanged CLI code, unchanged consumers and exports. The generator checks the dependency graph for cycles; **34 separate fresh-interpreter imports** cover both shim paths, both package roots and every implementation module under both package paths.

### Full canonical scoring suite

Both real executions use the authorized `codx_readonly` role, through the assignment's command-scoped `DATABASE_URL="$CODX_READONLY_DATABASE_URL"` convention. The launcher reads only that credential from `.env`; it does not load any write-capable credential or print connection strings. No local Supabase stack was used.

| Run | Exit | Bytes | SHA-256 |
| --- | --- | --- | --- |
| Hosted baseline | 0 | 29,599 | `0ef77ed37376853eb66954bfc9a28a165e7a7ff5d9b8bdf6eabfe2dfed155874` |
| Hosted proposal | 0 | 29,599 | `0ef77ed37376853eb66954bfc9a28a165e7a7ff5d9b8bdf6eabfe2dfed155874` |
| Frozen baseline | 0 | 29,599 | `0ef77ed37376853eb66954bfc9a28a165e7a7ff5d9b8bdf6eabfe2dfed155874` |
| Frozen proposal | 0 | 29,599 | `0ef77ed37376853eb66954bfc9a28a165e7a7ff5d9b8bdf6eabfe2dfed155874` |

Direct byte equality, not merely matching hashes, passes across all four complete outputs: [before.txt](2026-09-17-phase-b-module-split-evidence/before.txt), [after.txt](2026-09-17-phase-b-module-split-evidence/after.txt), [frozen-before.txt](2026-09-17-phase-b-module-split-evidence/frozen-before.txt), [frozen-after.txt](2026-09-17-phase-b-module-split-evidence/frozen-after.txt).

The additional frozen runs eliminate live-catalog drift as a confounder. One read-only snapshot contains **1,058 scored catalog rows** (books joined to book_dna), 867,637 pickle bytes, SHA-256 `92df2d3c83375d700ad9cb318e7b556e76d4f9557ef7bfb78dde2b5c1b2e13ec`. It contains only the catalog fields loaded by the existing SELECT-only loader. The frozen runs replace only `load_catalog` with that snapshot, reset both suite caches to their actual `None` initial state, and run the full unchanged `run_all()` against the baseline or proposal. `T.R is R` is explicitly checked before relying on the proposal run.

### Actual API consumer and supplemental call paths

Imported the actual `api/main.py` with its real declared FastAPI/JWT/multipart dependencies installed in an isolated temporary venv. The public JWKS URL is derived from app/shared.js; no token validation, signing-key retrieval or user database read is performed.

For each version, invoked the real `recommendations()` endpoint function for unfiltered, fantasy and sci-fi requests, three recommendations each. These calls execute real `R.recommend`, real `R.explain_match` for all nine returned books, and the endpoint's actual response construction. Only authentication, user-data loaders and catalog acquisition are replaced with local fixtures, using the existing Mathias rating data and print preference. Also executed the actual `rule_targets()` endpoint function, two audit calls and one series-outlook call per version.

The complete returned objects compare bit-exactly, preserving dictionary order, tuple/list distinctions and binary64 float bytes. Serialized comparison SHA-256: `0a7d3ed9347291dc74bf79af937f2e5fc01675e0993708953a8aae1091a95fc5`. Outputs: [consumer-results.json](2026-09-17-phase-b-module-split-evidence/consumer-results.json).

This is actual consumer execution, but not an authenticated HTTP/deployment test. The dogfood Streamlit UI and feedback-file write path were not launched. Experimental functions were source-verified, not assessed for quality or suitability, as requested.

## Commands and reproducibility

Complete executable harnesses are preserved alongside this report: [split.py](2026-09-17-phase-b-module-split-evidence/split.py), [launch.py](2026-09-17-phase-b-module-split-evidence/launch.py), [snapshot.py](2026-09-17-phase-b-module-split-evidence/snapshot.py), [verify.py](2026-09-17-phase-b-module-split-evidence/verify.py), [finalize.py](2026-09-17-phase-b-module-split-evidence/finalize.py). They use the evidence directory's location to resolve this clone. The original full source is `recommend.before.py`; hashes of every proposed source file are in `proposed-sha256.json`.

Substantive commands, executed from the clone root (the local `E` abbreviation below denotes the evidence directory, not a secret):

```sh
git pull --ff-only
E=docs/codx-reports/2026-09-17-phase-b-module-split-evidence
cp scripts/recommend.py "$E/recommend.before.py"
python3 "$E/launch.py" before
python3 "$E/launch.py" snapshot
python3 "$E/split.py"
python3 "$E/launch.py" after
python3 -m venv --system-site-packages /private/tmp/codx-task11-venv
/private/tmp/codx-task11-venv/bin/python -m pip install -r api/requirements.txt
PYTHONHASHSEED=0 /private/tmp/codx-task11-venv/bin/python "$E/verify.py" > "$E/verify-run.txt" 2>&1
python3 "$E/finalize.py"
/private/tmp/codx-task11-venv/bin/python -m pip freeze > "$E/python-environment.txt"
```

The suite launcher sets `PYTHONHASHSEED=0` for repeatability. Full dependency versions are preserved in `python-environment.txt`.

To review/apply in a suitable clean checkout at the recorded baseline, use `git apply --check` and then `git apply` with the saved `proposal.patch`. **The latter was not run against the owner's clone.** To reproduce using this clone's evidence, apply the proposal locally and run verify.py with the validation dependencies available; it is offline and uses the saved catalog. Its live counterpart remains launch.py. `finalize.py` saves the patch and restores the task changes; it intentionally requires the proposed package to be present.

### Failed attempts and corrections

- Initial sandboxed `git pull` failed with `cannot open '.git/FETCH_HEAD': Operation not permitted`; the authorized escalated fast-forward succeeded.
- Initial sandboxed suite connection failed with `could not translate host name`; rerunning through the same read-only launcher with network permission succeeded. Package installation similarly needed network permission after sandbox DNS failures. No alternate credential/access route was used.
- Initial mechanically proposed module placement revealed the profile↔series cycle described above. Consolidating the two deduplication helpers into profile removed it; the final dependency graph and every fresh import pass.
- Default Python lacked FastAPI. Installed exactly from `api/requirements.txt` into the temporary venv, leaving the repo dependency files unchanged.
- The first verifier loaded the saved baseline using the evidence file's `__file__`, causing a false `FEEDBACK_LOG_PATH` mismatch. Corrected the harness to execute original source with its actual original `scripts/recommend.py` filename; the production path adjustment then compares equal.
- A frozen-suite harness draft reset `_PREVALENCE_CACHE` to `{}` rather than the actual initializer `None`, causing a tuple-unpack failure. Corrected the harness; both final complete frozen runs pass. This did not affect either successful live canonical run.

The final successful verifier exited 0. Its complete stdout is in `verify-run.txt`; the intermediate cache-error attempt is retained in `verify-attempt.txt` so it cannot be mistaken for final results.

## Compatibility limits for future experiments

This proposal preserves existing call results, imports, exports and environment configuration. Moving functions necessarily changes their `__module__`, source locations and defining globals. Rebinding a shim attribute such as `R.WEIGHT_CAP` or `R.score_book` will no longer replace the name used inside another module's functions; a future monkeypatch experiment must patch and verify the actual defining module. None of the five current consumers performs such rebinding, and the canonical suite needs no changes. Shared mutable exported constants retain their object identity within a given import path. As before, mixing `recommend` and `scripts.recommend` can instantiate separate module graphs; the real-consumer checks assert the expected shared module identity.

This is relevant to the project's historical monkeypatch trap, not a reason to add module-proxy machinery to a pure movement task. No experimental scoring conclusion is drawn from the split.

## Restoration and handoff

Exact restoration output:

```text
HEAD 9d316308b8201ce68b59516b14ff8f50cccf6eb8
PASS all 68 functions moved byte-identically
PASS all 821 original comment tokens retained
PASS four canonical suite outputs identical (29599 bytes)
PASS proposal.patch applies cleanly to HEAD (git apply --check)
PASS task package removed; tracked working tree and index clean
PASS SHA-256 of all 351 tracked files equals HEAD
```

Evidence: [restoration.txt](2026-09-17-phase-b-module-split-evidence/restoration.txt), [facts.json](2026-09-17-phase-b-module-split-evidence/facts.json), and `SHA256SUMS` in the evidence directory. No immediate-write request or pending approval is needed. The patch is ready for CLDO's independent review and application.
