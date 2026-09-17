# Task 12 — Phase B shim removal proposal

2026-09-17 · CODX · **Implemented and validated; ready for CLDO review.**

Synced from `9d31630` to **`16d09c9685547c0ca829a47eb6cc0c9767c3bb33`** and read the refreshed assignment. Its embedded `d9a0c6a` baseline identifies the previously landed split; this proposal uses the actual synced HEAD above.

The [complete proposal patch](2026-09-17-phase-b-shim-removal-evidence/proposal.patch) updates all five real consumers to import their scoring submodules directly and reduces `scripts/recommend.py` from 439 to **105 lines**: its exact original module docstring, one import statement, and its existing CLI demo with qualified call names. **No scoring implementation changes.**

All required checks pass, including byte-identical canonical suite and CLI output, exact API-baseline comparison, and actual Streamlit recommendation/audit execution. The six edited files have been restored; **all 391 tracked files hash-match HEAD**, with no staged changes. No commit, push, hosted write, local database operation, real user-data query or rater-file write occurred. Existing unrelated untracked reports remain intact.

## Files and mapping

Re-derived executable `R.name` accesses from the five source files, checked documentary references with a fresh grep, and verified each name against both Task 11's committed `module-map.json` and the actual current function/constant definitions. The assignment's mappings are complete. The complete name-to-module and alias mapping is saved in [mapping.json](2026-09-17-phase-b-shim-removal-evidence/mapping.json).

| Changed file | Direct scoring imports |
| --- | --- |
| `api/main.py` | `api`, `constants`, `rules as scoring_rules` |
| `api/catalog_cache.py` | `catalog` |
| `scripts/scoring_tests.py` | `api`, `audit`, `calibration`, `catalog as scoring_catalog`, `constants`, `explanations`, `pipeline`, `prevalence`, `profile`, `rules`, `series` |
| `scripts/import_goodreads.py` | `catalog as scoring_catalog`, `constants` |
| `tools/dogfood/app.py` | `api`, `audit as scoring_audit`, `calibration`, `catalog as scoring_catalog`, `constants`, `pipeline`, `prevalence`, `profile`, `rules` |
| `scripts/recommend.py` | `api`, `catalog as scoring_catalog`; no re-exports |

**Aliases are necessary to preserve existing variable names and behavior.** In the suite and Goodreads importer, `catalog = catalog.load_catalog()` would raise `UnboundLocalError`. The dogfood tool stores its loaded dictionary in module-global `catalog`, and each iteration stores its audit result in `audit`; unaliased imports would be overwritten. The CLI likewise stores its data in `catalog`. `api/main.py` also uses a local `rules` dictionary; `scoring_rules` keeps that distinct from the module. All data variable names and call arguments remain unchanged.

The four existing `sys.path.insert` lines are byte-identical. No path insertion was added to catalog_cache.py. Current comments/docstrings in these five files now refer to scoring implementations instead of the former shim; this includes one wrapped documentary `R.user_calibrated_poor_` reference, which a naive complete-name grep would miss. No historical project-log or protocol entries were rewritten. All sixteen `scripts/scoring/*.py` files remain exactly equal to HEAD.

The CLI's original docstring is byte-identical. Its main block differs only in qualifying calls to `scoring_catalog.load_catalog`, `api.recommend` and `api.explain_match`. All sample ratings, printing, arguments and control flow are unchanged. The old export branches and shim-adjacent historical comment block are dropped as instructed. The documented direct-script entry point remains supported; the old module-as-engine API is intentionally retired.

## Validation and actual results

Full machine-readable/pass output is in [verification.txt](2026-09-17-phase-b-shim-removal-evidence/verification.txt). Individual full before/after outputs and executable harnesses are alongside it.

| Check | Result |
| --- | --- |
| Structural comparison of all five consumers | ASTs equal after removing changed imports, normalizing qualified names, and excluding documentation strings. Actual statements, arguments, expressions, exceptions and control flow match. |
| CLI structure | Original docstring exact; main-block AST equal after normalizing the three qualified names. Only docstring/import/main remain. |
| Scoring package | All 16 files byte-identical to HEAD. |
| Actual grep across five consumers | Exit 1, no matches for `\bR\.|import recommend|recommend\.py|\bshim\b`. |
| Live canonical suite | Before/after exit 0; complete stdout byte-identical, empty stderr. |
| Live `python3 scripts/recommend.py` | Before/after exit 0; complete stdout byte-identical, empty stderr. |
| Frozen full suite | Before/after byte-identical, also equal to both live outputs. |
| Actual API endpoints | Both versions exactly match Task 11's saved bit-exact consumer results. |
| Actual cache functions | Cache miss, hit and force_refresh pass, with loader-call counts 1/1/2. |
| Goodreads importer | Fresh import and its existing synthetic `__main__` self-check pass; full output byte-identical. |
| Dogfood | Real Streamlit AppTest startup and “Get recommendations” click pass; 20 audit tables per version; compared display results byte-identical. |
| Fresh-interpreter imports | All five consumers and the CLI import successfully in separate interpreters with their required dependencies/import paths. |

### Exact output hashes

| Complete compared output | Bytes per version | SHA-256 |
| --- | ---: | --- |
| Canonical suite (live and frozen) | 29,599 | `0ef77ed37376853eb66954bfc9a28a165e7a7ff5d9b8bdf6eabfe2dfed155874` |
| CLI demo stdout | 4,721 | `dd0ec3fcffa9429b95ef65b5bb72cc68cc586587fdf7c939d81a2731950d9ad2` |
| API comparison results | 44,169 | `0a7d3ed9347291dc74bf79af937f2e5fc01675e0993708953a8aae1091a95fc5` |
| Goodreads self-check stdout | 755 | `ae0e07278b911bde806886b9f05154c832bbf1dcc3783da52d2a874f38127584` |
| Dogfood display results | 15,710 | `d14f5b5a8c9c64c3c1abdfbebfa541c3526cb54adf25fe686bd353e9ef37db60` |

The verifier compares bytes directly, not just hashes. Before/after logs preserve the actual PASS output. `suite-*.txt`, `cli-*.txt`, `frozen-suite-*.txt`, `api-*.json`, `goodreads-*.txt` and `dogfood-*.json` hold the complete respective outputs.

### Consumer execution details and limits

The frozen catalog is Task 11's committed snapshot: **1,058 scored books**, SHA-256 `92df2d3c83375d700ad9cb318e7b556e76d4f9557ef7bfb78dde2b5c1b2e13ec`, at `docs/codx-reviews/phase-b-module-split-2026-09-17-evidence/catalog.pickle`. This deliberately permits exact comparison against Task 11's actual API evidence, without relying on a moving live catalog. The before consumer source is saved from this task's HEAD; source execution preserves the real original filename so path-dependent imports/data access behave normally.

API execution uses real FastAPI/JWT/multipart dependencies and actual endpoint function bodies. Each version calls `recommendations()` for unfiltered, fantasy and sci-fi requests, three results each: **nine real recommend/explain results**, plus `rule_targets()`. As in Task 11, two audit calls and a series-outlook call complete the serialized comparison. Authentication and user-data/catalog loaders are fixture boundaries; scoring and response construction are real. No authenticated HTTP or deployed-service test is claimed.

The dogfood check uses actual Streamlit **AppTest**, not a fake Streamlit module: it executes the whole tool at startup and after clicking “Get recommendations,” then compares all expander labels, markdown and twenty audit tables. Catalog acquisition uses the saved snapshot; the separate cover query uses an empty response from a fake connection that asserts its exact SELECT. A write guard forbids any rater-file modification. This catches both the catalog-name and repeated-audit-loop shadowing hazards without launching a web server or changing real ratings. Streamlit emits its standard bare-mode `missing ScriptRunContext` warning; both runs complete without app exceptions. No real browser session or exhaustive interaction test is claimed.

The Goodreads check executes the module's existing synthetic CSV self-check and compares its complete output; no real person's export is used and no rater file is created. The cache check runs the real cache functions with only catalog acquisition replaced.

After-change harnesses reject attempts to import `recommend` or `scripts.recommend`, demonstrating consumers do not quietly fall back to the shim. Module-identity assertions confirm `A.api is T.api`, `T.pipeline is pipeline`, `T.profile is profile`, and that importer/cache/suite catalog imports share `scoring.catalog`. Fresh CLI import is checked with scripts/ on the import path, consistent with direct script execution; no old package-level re-export contract is claimed.

## Required documentation finding — not applied

**`CLAUDE.md:568–569` is stale after this proposal**:

```python
import scripts.recommend as R
import scripts.scoring_tests as T
R is T.R
```

The suite no longer defines `R`, and recommend.py no longer represents the scoring engine. The earlier example at line 555 (`R.build_profile = R.build_profile_per_value`) is likewise not a usable post-split monkeypatch route. CLAUDE.md is untouched, as instructed.

Proposed replacement guidance for CLDO: verify the identity of the specific submodule used by the consumer, then verify the actual global lookup used by the function being exercised. For example, for a base-score experiment:

```python
import scripts.scoring_tests as T
from scoring import pipeline

assert T.pipeline is pipeline
assert T.pipeline.score_candidate.__globals__ is vars(pipeline)
# After installing the intended variant on pipeline.score_book:
assert T.pipeline.score_candidate.__globals__["score_book"] is variant
```

For a profile-builder experiment, the corresponding checks are `T.profile is profile` and `profile._resolve_profile.__globals__["build_profile"] is variant`. These are illustrative identity checks, not proposed scoring changes. Always restore the original binding after the experiment. Where one module imports a function directly from another, rebinding only the exporting module's attribute may not replace a consumer's existing binding; inspect/assert the exact lookup the tested path uses. Avoid mixing `scoring.*` and `scripts.scoring.*` module graphs. A matching output alone is still insufficient evidence that a monkeypatch was exercised.

Related references outside this task's five consumers remain historical/documentation follow-ups, not edits made here: tools/dogfood/README.md describes interacting with recommend.py, and scoring-test-protocol.md preserves the prior import-history narrative. The CLI's original prototype docstring also remains intentionally unchanged per the task.

## Commands, environments and reproducibility

All harnesses and original six files are in `docs/codx-reports/2026-09-17-phase-b-shim-removal-evidence/`. [implement.py](2026-09-17-phase-b-shim-removal-evidence/implement.py) derives the mapping and reproduces the edits from HEAD; [verify.py](2026-09-17-phase-b-shim-removal-evidence/verify.py) performs independent AST, grep, output and import checks; [finalize.py](2026-09-17-phase-b-shim-removal-evidence/finalize.py) saves the patch and restores only the six task files.

Substantive executed commands (using `E` below only as a readable abbreviation):

```sh
git pull --ff-only
E=docs/codx-reports/2026-09-17-phase-b-shim-removal-evidence
python3 "$E/launch.py" before
python3 "$E/implement.py"
python3 "$E/launch.py" after
/private/tmp/codx-task11-venv/bin/python -m pip install streamlit
python3 -m venv --system-site-packages /private/tmp/codx-task12-api-venv
/private/tmp/codx-task12-api-venv/bin/python -m pip install -r api/requirements.txt
PYTHONHASHSEED=0 /private/tmp/codx-task12-api-venv/bin/python "$E/consumer_check.py" before
PYTHONHASHSEED=0 /private/tmp/codx-task12-api-venv/bin/python "$E/consumer_check.py" after
PYTHONHASHSEED=0 /private/tmp/codx-task11-venv/bin/python "$E/dogfood_check.py" before
PYTHONHASHSEED=0 /private/tmp/codx-task11-venv/bin/python "$E/dogfood_check.py" after
/private/tmp/codx-task12-api-venv/bin/python "$E/verify.py"
python3 "$E/finalize.py"
```

The consumer and dogfood worker stdout/stderr were redirected to their corresponding `*-before.log` / `*-after.log` files. The launcher itself records full suite/CLI stdout and separate stderr. It reads only `CODX_READONLY_DATABASE_URL` from .env, supplies `DATABASE_URL="$CODX_READONLY_DATABASE_URL"` for each child command, fixes `PYTHONHASHSEED=0`, and never prints the credential. Both live runs used that authorized role and required network permission. No local Postgres connection was used, so the local sync check was not applicable.

Dependency manifests were not modified. API validation uses the exact declared `api/requirements.txt`; dependency versions are saved in `api-environment.txt`. Dogfood uses Streamlit 1.64.0 and its resolved dependencies, recorded in `dogfood-environment.txt`. Installing Streamlit into the previously used temporary Task 11 environment upgraded Starlette incompatibly with the old FastAPI pin; this was caught in pip's output **before API validation**, and all Task 12 API checks were run in the separate clean API venv. The dogfood environment still contains that unused incompatible FastAPI installation; it does not import FastAPI. No claim of a jointly deployable dependency environment is made.

An initial mapping-only probe stopped on the wrapped documentation fragment `R.user_calibrated_poor_` (KeyError), before editing source. The final implementation uses AST-derived executable references plus explicit documentary updates; this is why it handles that fragment without guessing a nonexistent export. No production failure was hidden or bypassed. All final checks exit 0, except the expected no-match grep exit 1.

To review in a clean checkout at the recorded baseline, use `git apply --check <proposal.patch>` and then apply the patch if approved. The check already succeeds here. Re-running verify.py requires the proposal to be present and the recorded evidence outputs available; the consumer workers can regenerate their offline outputs from the committed Task 11 snapshot. No write-capable credential is required.

## Final restoration

```text
HEAD 16d09c9685547c0ca829a47eb6cc0c9767c3bb33
PASS six task files restored; working tree/index contain no tracked changes
PASS SHA-256 of all 391 tracked files equals HEAD
PASS proposal.patch applies cleanly (git apply --check)
PASS core.hooksPath = .githooks
```

[restoration.txt](2026-09-17-phase-b-shim-removal-evidence/restoration.txt), [facts.json](2026-09-17-phase-b-shim-removal-evidence/facts.json), per-proposal-file hashes and recursive `SHA256SUMS` preserve the handoff evidence. No pending approval entry is needed; the patch and documentation finding await CLDO's normal independent review.
