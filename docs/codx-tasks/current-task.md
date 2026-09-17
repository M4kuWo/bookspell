# CODX current task

**Assigned**: 2026-09-17, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

**Same note as Task 11**: CLDO already did the research (the exact
per-file "old name → new submodule" mapping below is grepped directly
from your own Task 11 `module-map.json`, not guessed) so this stays a
bounded, mechanical task rather than open-ended exploration.

---

## Task 12 — Phase B, step 2 (B4): drop the `scripts/recommend.py` compatibility shim

`main` is at commit `d9a0c6a` (your Task 11 work, already landed). This
is the direct follow-up: now that every real consumer's actual
dependency is known precisely (your own Task 11 report found 5, not
the 2 originally assumed), update all 5 to import directly from
`scripts/scoring/` submodules, and reduce `scripts/recommend.py` to a
small standalone CLI demo script that no longer serves as anyone's
import shim.

**Pure mechanical refactor, zero behavior change** — same discipline
as Task 11: every call site's actual arguments/logic stays identical,
only which name resolves to which module changes.

## Convention to use (all 5 files already do this, don't invent a new pattern)

Every one of the 5 files already does `sys.path.insert(0, <path to
scripts/>)` before `import recommend as R`. Keep that exact
`sys.path.insert` line unchanged in each file (it already points at
the right place — `scripts/`, the parent of the `scoring/` package),
and replace only the import statement and every `R.name` call site:

```python
# before
sys.path.insert(0, <existing path expression, unchanged>)
import recommend as R
...
R.recommend(...)
R.load_catalog()

# after
sys.path.insert(0, <same existing path expression, unchanged>)
from scoring import api, catalog  # only the submodules THIS file actually needs
...
api.recommend(...)
catalog.load_catalog()
```

`api/catalog_cache.py` has no `sys.path.insert` of its own — it's only
ever imported from `api/main.py` after `main.py`'s own `sys.path.insert`
has already run in the same process. Leave that as-is; don't add a
redundant `sys.path.insert` to `catalog_cache.py`.

## Exact per-file mapping (derived from your own Task 11 `module-map.json`)

### `api/main.py`
Needs `scoring.api`, `scoring.rules`, `scoring.constants`.
| Old | New |
|---|---|
| `R.recommend` | `api.recommend` |
| `R.explain_match` | `api.explain_match` |
| `R.list_user_rule_targets` | `rules.list_user_rule_targets` |
| `R.DATABASE_URL` | `constants.DATABASE_URL` |
| `R.DEFAULT_REDUCE_STRENGTH` | `constants.DEFAULT_REDUCE_STRENGTH` |

### `api/catalog_cache.py`
Needs `scoring.catalog`.
| Old | New |
|---|---|
| `R.load_catalog` | `catalog.load_catalog` |

### `scripts/scoring_tests.py`
Needs `scoring.api`, `scoring.audit`, `scoring.calibration`,
`scoring.catalog`, `scoring.constants`, `scoring.explanations`,
`scoring.pipeline`, `scoring.prevalence`, `scoring.profile`,
`scoring.rules`, `scoring.series` (11 submodules).
| Old | New |
|---|---|
| `R.recommend` | `api.recommend` |
| `R._audit_attribute_ordinal` | `audit._audit_attribute_ordinal` |
| `R.match_label` | `calibration.match_label` |
| `R.DEFAULT_REDUCE_STRENGTH` | `constants.DEFAULT_REDUCE_STRENGTH` |
| `R.NOMINAL_FIELDS` | `constants.NOMINAL_FIELDS` |
| `R.ORDINAL_FIELDS` | `constants.ORDINAL_FIELDS` |
| `R.RATING_LABELS` | `constants.RATING_LABELS` |
| `R.STAT_SEPARATION_THRESHOLD` | `constants.STAT_SEPARATION_THRESHOLD` |
| `R.describe` | `explanations.describe` |
| `R._nominal_field_separation` | `pipeline._nominal_field_separation` |
| `R._trope_separation` | `pipeline._trope_separation` |
| `R.dealbreaker_flags` | `pipeline.dealbreaker_flags` |
| `R.explain_book` | `pipeline.explain_book` |
| `R.score_candidate` | `pipeline.score_candidate` |
| `R.user_calibrated_poor_threshold` | `pipeline.user_calibrated_poor_threshold` |
| `R.validated_dealbreaker_fields` | `pipeline.validated_dealbreaker_fields` |
| `R.build_prevalence_lookup` | `prevalence.build_prevalence_lookup` |
| `R._resolve_profile` | `profile._resolve_profile` |
| `R.build_profile` | `profile.build_profile` |
| `R.apply_user_rules` | `rules.apply_user_rules` |
| `R.list_user_rule_targets` | `rules.list_user_rule_targets` |
| `R.normalize_user_rules` | `rules.normalize_user_rules` |
| `R.parse_user_rule_key` | `rules.parse_user_rule_key` |
| `R.book_similarity` | `series.book_similarity` |
| `R.compute_series_dna` | `series.compute_series_dna` |
| `R.load_catalog` | `catalog.load_catalog` |

### `scripts/import_goodreads.py`
Needs `scoring.catalog`, `scoring.constants`.
| Old | New |
|---|---|
| `R.load_catalog` | `catalog.load_catalog` |
| `R.DATABASE_URL` | `constants.DATABASE_URL` |

### `tools/dogfood/app.py`
Needs `scoring.api`, `scoring.audit`, `scoring.calibration`,
`scoring.catalog`, `scoring.constants`, `scoring.pipeline`,
`scoring.prevalence`, `scoring.profile`, `scoring.rules`.
| Old | New |
|---|---|
| `R.recommend` | `api.recommend` |
| `R.audit_book_score` | `audit.audit_book_score` |
| `R.match_label` | `calibration.match_label` |
| `R.load_catalog` | `catalog.load_catalog` |
| `R.DATABASE_URL` | `constants.DATABASE_URL` |
| `R.DEFAULT_REDUCE_STRENGTH` | `constants.DEFAULT_REDUCE_STRENGTH` |
| `R.RATING_LABELS` | `constants.RATING_LABELS` |
| `R.user_calibrated_poor_threshold` | `pipeline.user_calibrated_poor_threshold` |
| `R.build_prevalence_lookup` | `prevalence.build_prevalence_lookup` |
| `R._resolve_profile` | `profile._resolve_profile` |
| `R.list_user_rule_targets` | `rules.list_user_rule_targets` |

**Re-derive every one of these mappings yourself from the real
`module-map.json` and a fresh grep of each file before touching
anything — this table is a precise starting point, not a substitute
for checking. If your own Task 11 module map has since been superseded
by anything, or you find an `R.` access this table missed, that's a
real gap: fix it, don't just note it.**

## What happens to `scripts/recommend.py`

Not deleted — the README documents `python3 scripts/recommend.py` as a
real, working demo entry point (loads the catalog, runs `recommend()`
and `explain_match()` against a fixed sample profile, prints results).
Keep exactly that `if __name__ == "__main__":` block and the file's
original module docstring, dropping everything else (no more
re-exports, no more shim role). It needs `from scoring import catalog,
api` for its own demo calls — no `sys.path.insert` required, since
Python auto-adds a directly-run script's own directory (`scripts/`) to
`sys.path`, and `scoring/` lives right inside it.

## Validation bar

This changes real call sites, not just file locations, so validate
accordingly:

1. **Full canonical suite (`scripts/scoring_tests.py`) byte-identical
   before/after** — its own behavior must be completely unchanged; only
   its imports change.
2. **Confirm zero remaining `import recommend`, `R.`, or any reference
   to the old shim pattern** across all 5 files (a grep-based check,
   not "I replaced what the table listed").
3. **Re-exercise `api/main.py`'s real endpoint functions** the same way
   you did in Task 11 (isolated venv, real dependencies, bit-exact
   comparison against the Task 11 baseline) — this is the strongest
   evidence the refactor didn't silently break request handling.
4. **Confirm `python3 scripts/recommend.py` still runs successfully**
   and produces the same output as before this change (compare full
   stdout, not just exit code).
5. **Confirm `tools/dogfood/app.py` and `scripts/import_goodreads.py`
   at least import cleanly and their top-level code paths resolve**
   (a full Streamlit UI launch or a real CSV import isn't required, but
   don't just claim they're fine without checking).
6. No circular imports: fresh-interpreter import of all 5 updated files
   plus `scripts/recommend.py` itself.

## A real documentation staleness this task creates — flag it, don't fix it

`CLAUDE.md`'s "A/B testing an experimental scoring variant via
monkeypatch" guidance tells a future session to verify
`import scripts.recommend as R; import scripts.scoring_tests as T; R is
T.R` before trusting a monkeypatch-based comparison. After this task,
`scoring_tests.py` no longer has a single `R` object — it has several
submodule imports instead. That check is now inapplicable in its exact
current wording. **Don't edit `CLAUDE.md` yourself** — flag this
precisely in your report (the exact stale line, why it no longer
applies, and a proposed replacement check per-submodule, e.g. `pipeline
is T.pipeline`) so CLDO can apply the fix after reviewing it, same
process as every other doc/skill staleness you've flagged before.

## Deliverable

A report at `docs/codx-reports/2026-09-17-phase-b-shim-removal.md` (or
same-day-dated equivalent), same rigor as Task 11's report. Proposal
only — implement and validate in your own clone, uncommitted; revert to
exact HEAD bytes and hash-verify afterward; no commit, push, or hosted
write.
