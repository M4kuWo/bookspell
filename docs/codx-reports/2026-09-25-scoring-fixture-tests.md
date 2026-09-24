# Task 18 — synthetic scoring mechanics fixtures

CODX, 2026-09-25. Synced successfully to `b065a5a` (newer than the assignment's `1c92666`). Proposal implemented and verified locally, uncommitted.

## Deliverable

New file: `scripts/scoring/tests/test_fixtures.py`. It lives beside the engine it exercises, separate from the real-rater benchmark. It uses standard-library `unittest` and imports only the scoring modules needed for the assigned mechanics. No database loader, API server, external dependency, credential, or network access is involved. The existing engine, `scripts/recommend.py`, `scripts/scoring_tests.py`, and `.github/workflows/ci.yml` are unchanged.

The fixture contains 15 fake books with independent mutable containers: three pace probes, six standalone profile-training books, three narration-person probes, and a three-book series. Each has the loader's bibliographic/series fields, all current `book_dna` column keys, and trope/confidence containers. Scalar values follow `docs/schema/book-dna.schema.yaml`; optional fields and irrelevant timestamps are null. These dictionaries are synthetic engine inputs, not proposed insertable database rows. Content warnings are not a `book_dna` column or part of `load_catalog()`'s result, so they are not fabricated here.

No relevant table-maintenance skill applies: this work neither tags books nor changes schemas. The new scoring-design gate does not apply to this implementation: it changes no scoring logic, weight, or algorithm design.

## What the six methods assert

| Test | Assertion and purpose |
|---|---|
| `test_ordinal_similarity_uses_normalized_distance` | `score_book()` scores slow/medium/fast as 1/.5/0 against a slow target, and 0/.5/1 against a fast target. Tests the actual normalized distance formula, not raw category-index distance. Only one field has weight. |
| `test_nominal_exact_partial_and_mismatch` | Both `nominal_similarity()` and its use by `score_book()` give exact person matches 1, first versus third-limited 0, and third-limited versus third-omniscient .5. Mismatch and partial-credit cases are checked in both directions. |
| `test_profile_learns_separating_field_in_both_directions` | Three loved slow versus three hated fast books learn pace weight >.1, target slow, and score slow above fast. Reversing ratings reverses the target and score preference while retaining positive importance. The weight's exact tuned value is deliberately not asserted. Scalar weight is importance, not a signed preference; the centroid carries direction. |
| `test_policies_agree_on_scores_with_optional_adjustments_inactive` | All four real `score_candidate()` policies produce the hand-computable .5 base and final score, carry that score through every intermediate output, and advertise exactly their documented stage sequences. Ranking includes diversity/cold-start/rules; audit includes cold-start/rules; explanation/evaluation end at trajectory. |
| `test_only_ranking_short_circuits_series_ineligibility` | An unread second installment is excluded only by ranking, with null scores/label and empty evidence. Explanation, evaluation, and audit still score the same book at .5. This checks an actual policy difference, not just identical numbers with different labels. |
| `test_series_position_requires_every_earlier_installment` | Book 1 is eligible without history. Book 2 is blocked without book 1, including when an unrelated book is rated, and becomes eligible with book 1. Book 3 remains blocked when either earlier installment is missing and becomes eligible when both are rated. |

Optional adjustments are neutral: no prevalence lookup, no supplied series trajectory data, empty validated fields, no disliked series-mates, no rules, zero diversity and cold-start weight. This first slice checks stage declarations and consistency under those conditions; it does not claim to verify the deferred adjustments' nonzero behavior, explanation text, or recommendation quality. No new weight-design decision or retagging is implicit in these tests.

## Validation and failure proof

Evidence directory: `docs/codx-reports/2026-09-25-scoring-fixture-evidence/`.

Commands run from the clone root:

```sh
python3 -S scripts/scoring/tests/test_fixtures.py
python3.12 docs/codx-reports/2026-09-25-scoring-fixture-evidence/validate.py
git diff --check
```

The first direct run passed all six methods. The evidence runner invokes the test in separate Python 3.12.9 subprocesses with `-S`, which disables site-package initialization; this verifies the no-installed-dependencies requirement against CI's Python minor version. It measures wall time around the whole subprocess, including interpreter startup/imports.

Actual clean output (`clean.txt` has the full method list):

```text
Ran 6 tests in 0.001s

OK
```

Clean exit code: **0**. Full subprocess wall time: **0.481737 seconds**, below one second. The unittest body itself took 0.001 seconds; these are distinct measurements.

For the required negative control, `validate.py` copies `scripts/scoring/` (including the new test) into a `TemporaryDirectory`, excluding cached bytecode, and changes exactly this conditional in the copied `pipeline.py`:

```diff
- elif not series_position_ready(catalog, id_to_magnitude, book):
+ elif False:  # deliberate Task 18 mutation: bypass series-position gate
```

It then runs the copied test in a fresh subprocess. Path resolution makes that test import the copied package. Actual result:

```text
Ran 6 tests in 0.002s

FAILED (failures=5)
```

Broken-copy exit code: **1**, wall time **0.099492 seconds**. The ranking-short-circuit test fails, plus four blocked-series subcases in the series-position test. Failures show actual `[]` exclusions versus expected `['series_position']`; these are assertion failures, not import errors. The temporary copy is automatically removed. SHA-256 comparisons before/after confirm every real engine/test Python file remained unchanged throughout the mutation experiment.

`clean.txt`, `broken.txt`, `mutation.diff`, and `validation.json` preserve the exact outputs and measurements. `validate.py` preserves the full reproduction procedure; it is report evidence, not proposed CI machinery. `git diff --check` passed. No live benchmark was run because this changes no engine behavior and the task explicitly requires zero DB access.

## Exact proposed fourth CI check

Add this step after the existing three checks in `.github/workflows/ci.yml`'s existing job:

```yaml
      - name: Check scoring mechanics fixtures
        run: python3 -S scripts/scoring/tests/test_fixtures.py
```

No install step, secrets, services, or additional workflow permissions are needed. `unittest.main()` returns a nonzero process status on failure, as demonstrated above. The workflow itself has not been edited; CLDO can review this proposal and wire it in. Runtime on GitHub's runner has not been measured; the local Python 3.12 subprocess met the requested time bound.

No commits, pushes, hosted writes, migrations, or engine modifications. The only tracked-file edit is the required append-only project-log handoff; the proposed test and this report/evidence remain untracked in the working clone.
