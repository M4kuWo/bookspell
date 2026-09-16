# Task 8 — audit_book_score migration proposal

Date: 2026-09-16. Author: CODX. This is a local, uncommitted proposal for CLDO to independently verify and apply. No commit, push, hosted write, or deployment was performed. The full proposed diff and validation harness are preserved below; source restoration evidence is appended after the checks.

## Baseline and scope

The task's initial `git pull --ff-only` advanced the clone from `96f3bb7` to `e531320e801b9cb6861a4b1e87a3ff991b0d656c`, including A5 (`efe80d3`). The interruption occurred after sync and reading, before implementation or validation. On resumption, HEAD remained at that revision and the tracked working tree was clean. Read the protocol's “A5: _full_score() migrated onto score_candidate()” entry and current TODO context. This is the separately authorized audit follow-up, **not an A6 step**; named Phase A steps A1–A5 are already complete.

Only `audit_book_score()` in `scripts/recommend.py` changes. The function signature, profile preparation, attribution, display rounding, six-stage pipeline, title lookup behavior, and 11-key return contract are preserved. `scripts/scoring_tests.py` is byte-identical to HEAD. No scoring decisions, weights, eligibility rules, optimizations, or new output fields are introduced.

## Implementation and reasoning

Resolve `book_id = title_to_id[title]` and pass the same prepared context to `score_candidate(..., policy="audit")`, including the existing local `csw`, `normalize_user_rules(user_rules)`, and **explicit `top_n=100`**. Compute the real `user_calibrated_poor_threshold()` first, with exactly the arguments previously used in the return expression. Calibration stays separate from the candidate's stage sequence.

The original excluded-by-rule branch did not evaluate the calibration ternary's other arm. As explicitly required by this task's restructuring, the new implementation computes calibration once even for excluded candidates. The harness counts this difference deliberately: original calibration calls are zero when excluded and one otherwise; migrated calls are one for every successful audit. The returned exclusion flag and label remain identical. This is additional computation, not a changed result.

Map canonical unrounded scores into the existing locals:

| Existing local | Canonical scores field |
| --- | --- |
| raw_score | base |
| after_series | after_series_repeat |
| after_veto | after_veto |
| after_trajectory | after_trajectory |
| after_cold_start | after_cold_start |
| final | final |

`excluded_by_rule` comes from `excluded_by_user_rule`; raw matches, mismatches, and dealbreaker pairs come from their result fields. The existing `build_rows()` calls and `[(f, round(m, 3)) for f, m in dealbreaker]` expression are untouched. The returned label comes directly from `result["match_label"]`.

The **entire six-entry pipeline source text is byte-identical**. All labels, `round(x, 4)`, `abs(x-y) > 1e-9` comparisons, local `round(csw, 3)`, and exclusion logic remain intact. In particular, cold start compares `after_cold_start` against **`after_trajectory`**. No diversity stage or reference to `after_diversity` is added.

The canonical scorer's own historical “audit_book_score() is not migrated yet” docstring is deliberately unchanged to honor the requirement that `score_candidate()` remain byte-identical. CLDO may record the landed migration separately.

## Verified coverage boundary and dormant documentation discrepancy

A source search and AST scan of every tracked Python file identify exactly one executable audit caller: `tools/dogfood/app.py:187`. The hit in `scripts/scoring_tests.py:228` is documentation, not a call. There is no automated audit test in the tracked Python code. The canonical suite therefore provides **zero direct regression coverage of this migration**. Its identical output is a collateral check only; the correctness evidence is the dedicated original-versus-migrated public-function harness below. No live Streamlit/dogfood UI check was performed or claimed.

Verified in the original function: the docstring advertises `"series_note": str`, but the actual return dict has exactly these 11 keys, in this order:

`title`, `author`, `final_score`, `match_label`, `excluded_by_user_rule`, `pipeline`, `matches`, `mismatches`, `dealbreaker_flags`, `validated_fields`, `series_repeat_worst_similarity`.

Neither `tools/dogfood/app.py` nor `print_score_audit()` reads `series_note`. The canonical result computes it, and the harness observes nonempty notes, but the migrated audit continues to **omit** the key. Adding it would change the public contract. This pre-existing documentation/behavior discrepancy remains a separate decision for CLDO/the owner.

## Direct comparison design

The harness imports the exact saved HEAD implementation as `O` and the locally migrated implementation as `N`. Both receive the same frozen snapshot of the full real catalog and unchanged local rater data. All public audit calls run real profile resolution, calibration, canonical scoring/dependencies, and attribution: no mocked scoring, no substituted profile preparation, no added memoization. Snapshot acquisition uses only the authorized read-only role. The snapshot is 1,018 rows, SHA-256 `c2dcdc3d9e90fbfa7f12e830e028c4ea16bdeb5900cbc0f13aa9e6503d5c9a74`; it is newer than the 978-row catalog from Tasks 6/7, so old suite hashes are not used as the baseline.

Every physical catalog row is crossed with **all five real rater files**, under two rule variants, at these genre/format combinations:

| Rater | Genre | Format |
| --- | --- | --- |
| Dandan | None | None |
| Gabriel | sci_fi | mixed |
| Mathias | fantasy | audiobook |
| Osnat | fantasy | None |
| Mathias Goodreads | None | None |

This covers unscoped and both scoped content profiles, default and audio-adjusted structural preferences, and sparse as well as dense histories. All 1,018 rows per rater are tested under each rule variant (10,180 paired calls):

- Exclude `age_category:ya`, plus reduce `drive:romance_driven` with strength 0.37.
- Reduce `age_category:ya` (0.6), `drive:romance_driven` (0.37), and the `quest` trope (0.2).

The ordinary public API resolves duplicate titles with its existing last-row-wins dictionary. For the shadowed physical row sharing a title, the harness moves only that row to the end of an otherwise identical catalog view and gives the same view to original and migrated functions. It asserts the resolved ID against the intended physical row, and records full resolved-ID coverage per rater/rule variant. This permits testing every physical row without changing production title resolution or silently counting the same title twice.

Additional cases cover the entire catalog with empty ratings and no rules (1,018 paired calls), all nine None/fantasy/sci_fi × None/audiobook/mixed combinations across all five raters on observed interaction examples, a missing title for every rater and empty catalog, fatigue overrides, invalid-rule warning behavior, and the eight-book Task 4 interaction fixture under no rules, stacked reductions, and exclude-plus-reduce. Selected results are passed through the real `print_score_audit()` on both sides and their full printed output is compared; this is not a live dogfood UI test.

The recursive comparison preserves dictionary key order and list/tuple distinctions and encodes **every float as IEEE-754 binary64 hexadecimal bytes** (`struct.pack('!d', x).hex()`), including already-rounded public values. It compares the entire returned object, each of its 11 keys, exception type/args/text, and printed warnings. `sys.settrace` captures original audit return locals and the migrated canonical return so all six **unrounded** stage values, raw evidence pairs, series similarity, cold-start weight, attribution input, and exclusions are also compared bit-for-bit. It explicitly asserts both pipeline changed comparisons around cold start/user rules and the canonical policy/top_n arguments.

Observed required coverage includes actual dealbreaker flags, repeat score changes, trajectory penalties, cold-start score changes and nonzero cold-start weights, actual reductions, and actual exclusions. The output below records examples and counts, rather than inferring coverage from a book's tags. Missing titles retain the original **KeyError** behavior (audit does not use explain_match's ValueError contract). Catalog and rater inputs are checked for mutation.

## Structural verification

AST comparison confirms `audit_book_score` is the ONLY changed top-level function/class; its signature is unchanged. A stronger source comparison verifies every byte before and after it is identical. Named source-byte checks and SHA-256 hashes explicitly confirm all of these remain unchanged:

- `_series_deduped_id_to_magnitude`
- nested `build_rows` closure, despite its parent function changing
- `_audit_attribute_nominal_or_trope`
- `_audit_attribute_ordinal`
- `series_repeat_worst_similarity`
- `print_score_audit`
- `score_candidate`
- `recommend`
- `explain_match`

`git diff --check` passes. The complete diff contains 22 insertions and 19 deletions in `scripts/recommend.py` only.

## Execution commands

These are the substantive execution commands, with the complete launchers and harness preserved below. Credential values are neither printed nor embedded. The launcher reads only `CODX_READONLY_DATABASE_URL` from the existing `.env` and supplies `DATABASE_URL` for the child command only, following the authorized suite convention. The canonical runs and snapshot acquisition required sandbox network escalation; the direct harness is offline.

```sh
git pull --ff-only
git rev-parse HEAD
rg -n 'audit_book_score\(' --glob '*.py'
rg -n 'series_note' tools/dogfood scripts/scoring_tests.py
python3 /private/tmp/codx-task8/run.py before
python3 /private/tmp/codx-task8/run.py snapshot
python3 -B /private/tmp/codx-task8/validate.py > /private/tmp/codx-task8/parity.txt 2>&1
python3 /private/tmp/codx-task8/run.py after
git diff --check
git diff --numstat
git diff -- scripts/recommend.py
```

The `before` process started before editing; the `after` process used the proposal. Both exited 0. Both complete canonical outputs contain 29,592 bytes with SHA-256 `75bdc050cafc459b1c61f40ccf9382a39be74d2966416076884d8a8f5459a6ea`; direct byte equality also passes. Again, neither run exercises `audit_book_score()`.

The harness wall-clock duration below is for traced paired validation, not a production latency benchmark. The migration adds factor/series-note evidence computation and calibration on excluded candidates; no optimization or performance claim is made.

## Direct comparison results

**PASS: 11,455 original/migrated pairs**, including 11,449 complete returned dictionaries and 6 matching missing-title exceptions. All five rater matrices resolve all 1,018 physical rows under both rule variants. The required flag/repeat/trajectory/cold-start/rule-reduction/rule-exclusion examples below all arise from the real-catalog runs, before the synthetic fixture. No mismatch or harness failure occurred.

```text
UNCHANGED _series_deduped_id_to_magnitude sha256=a6c46abb185f53130b71def63fd99d20ffc29721fccbcc2d7ae1d57987e3501f
UNCHANGED _audit_attribute_nominal_or_trope sha256=29cd23b53dbd26b969851252e4e00fe616066afa059152108d487de2ed3b2c62
UNCHANGED _audit_attribute_ordinal sha256=251d8d600a9954336c9943df167bcc5a460d652c76a351e2c6148fd29645e423
UNCHANGED series_repeat_worst_similarity sha256=92eba56ab7d2bc672655464b41515227ca0c36733599f32daab8d08ca4e6423a
UNCHANGED print_score_audit sha256=1840cfd875cbb892ffe1938b92c2ba344f01c164f90ffe8c677cea50455ac0aa
UNCHANGED score_candidate sha256=e0916c3e19a4b90e82c5c9808465b8a8114968873f5868b85069063f6198dacf
UNCHANGED recommend sha256=7dc9d77bb2097ed286be01cd067b2a87651ffa26c865c03f4b8264a818f33a0e
UNCHANGED explain_match sha256=9bd8a5dfc5a4263a90628bdeebab0e0fa7238c15b31212e8414570785026ff33
UNCHANGED nested build_rows sha256=6186183042d098ec539bfdd6e802fd79a373e359a0f5bb18bc67f869e9c78aea
PASS only audit_book_score AST changed; all outside bytes, signature, nested attribution closure and full six-stage pipeline source unchanged
Original actual return keys: ["title", "author", "final_score", "match_label", "excluded_by_user_rule", "pipeline", "matches", "mismatches", "dealbreaker_flags", "validated_fields", "series_repeat_worst_similarity"]
PASS sole executable tracked-Python audit caller: [('tools/dogfood/app.py', 187)] ; no canonical suite audit call; no dogfood/print audit series_note reads
Catalog rows: 1018 sha256=c2dcdc3d9e90fbfa7f12e830e028c4ea16bdeb5900cbc0f13aa9e6503d5c9a74
PROGRESS dandan 100 /1018 elapsed=14.51
PROGRESS dandan 200 /1018 elapsed=29.46
PROGRESS dandan 300 /1018 elapsed=44.58
PROGRESS dandan 400 /1018 elapsed=59.08
PROGRESS dandan 500 /1018 elapsed=73.55
PROGRESS dandan 600 /1018 elapsed=88.07
PROGRESS dandan 700 /1018 elapsed=102.59
PROGRESS dandan 800 /1018 elapsed=117.12
PROGRESS dandan 900 /1018 elapsed=131.61
PROGRESS dandan 1000 /1018 elapsed=145.83
PROGRESS dandan 1018 /1018 elapsed=148.36
PASS full physical-row coverage dandan {'exclude': 1018, 'reduce': 1018}
PROGRESS gabriel 100 /1018 elapsed=159.01
PROGRESS gabriel 200 /1018 elapsed=169.67
PROGRESS gabriel 300 /1018 elapsed=180.67
PROGRESS gabriel 400 /1018 elapsed=191.66
PROGRESS gabriel 500 /1018 elapsed=202.64
PROGRESS gabriel 600 /1018 elapsed=213.63
PROGRESS gabriel 700 /1018 elapsed=224.67
PROGRESS gabriel 800 /1018 elapsed=235.7
PROGRESS gabriel 900 /1018 elapsed=246.78
PROGRESS gabriel 1000 /1018 elapsed=257.79
PROGRESS gabriel 1018 /1018 elapsed=259.82
PASS full physical-row coverage gabriel {'exclude': 1018, 'reduce': 1018}
PROGRESS mathias 100 /1018 elapsed=286.58
PROGRESS mathias 200 /1018 elapsed=313.41
PROGRESS mathias 300 /1018 elapsed=340.19
PROGRESS mathias 400 /1018 elapsed=366.74
PROGRESS mathias 500 /1018 elapsed=393.23
PROGRESS mathias 600 /1018 elapsed=419.84
PROGRESS mathias 700 /1018 elapsed=446.38
PROGRESS mathias 800 /1018 elapsed=473.04
PROGRESS mathias 900 /1018 elapsed=499.78
PROGRESS mathias 1000 /1018 elapsed=526.3
PROGRESS mathias 1018 /1018 elapsed=531.1
PASS full physical-row coverage mathias {'exclude': 1018, 'reduce': 1018}
PROGRESS osnat 100 /1018 elapsed=544.64
PROGRESS osnat 200 /1018 elapsed=558.18
PROGRESS osnat 300 /1018 elapsed=571.73
PROGRESS osnat 400 /1018 elapsed=585.25
PROGRESS osnat 500 /1018 elapsed=598.79
PROGRESS osnat 600 /1018 elapsed=612.29
PROGRESS osnat 700 /1018 elapsed=625.82
PROGRESS osnat 800 /1018 elapsed=639.33
PROGRESS osnat 900 /1018 elapsed=652.89
PROGRESS osnat 1000 /1018 elapsed=666.45
PROGRESS osnat 1018 /1018 elapsed=668.9
PASS full physical-row coverage osnat {'exclude': 1018, 'reduce': 1018}
PROGRESS mathias_goodreads 100 /1018 elapsed=689.0
PROGRESS mathias_goodreads 200 /1018 elapsed=709.11
PROGRESS mathias_goodreads 300 /1018 elapsed=729.23
PROGRESS mathias_goodreads 400 /1018 elapsed=749.3
PROGRESS mathias_goodreads 500 /1018 elapsed=770.04
PROGRESS mathias_goodreads 600 /1018 elapsed=790.25
PROGRESS mathias_goodreads 700 /1018 elapsed=810.42
PROGRESS mathias_goodreads 800 /1018 elapsed=830.53
PROGRESS mathias_goodreads 900 /1018 elapsed=850.64
PROGRESS mathias_goodreads 1000 /1018 elapsed=870.54
PROGRESS mathias_goodreads 1018 /1018 elapsed=874.13
PASS full physical-row coverage mathias_goodreads {'exclude': 1018, 'reduce': 1018}
PASS cold-empty/no-rules full catalog
PASS physical-row matrix: {"dandan": {"exclude": 1018, "reduce": 1018}, "gabriel": {"exclude": 1018, "reduce": 1018}, "mathias": {"exclude": 1018, "reduce": 1018}, "mathias_goodreads": {"exclude": 1018, "reduce": 1018}, "osnat": {"exclude": 1018, "reduce": 1018}}
PASS coverage: {"cold_start": 2986, "flags": 3185, "nonzero_csw": 3123, "rated_book_audited": 709, "repeat": 153, "rule_excluded": 770, "rule_reduction": 1166, "series_note_computed_but_omitted": 6852, "trajectory": 278, "veto": 3}
PASS examples: {"cold_start": {"after": 0.45480661467375305, "before": 0.44576793760850375, "case": "full/gabriel/sci_fi/mixed/d67034b9-1305-4a6a-89d4-d56b504fc44c/exclude", "title": "The Golden Compass"}, "flags": {"case": "full/dandan/None/None/d67034b9-1305-4a6a-89d4-d56b504fc44c/exclude", "title": "The Golden Compass"}, "nonzero_csw": {"case": "full/gabriel/sci_fi/mixed/d67034b9-1305-4a6a-89d4-d56b504fc44c/exclude", "title": "The Golden Compass"}, "rated_book_audited": {"case": "full/dandan/None/None/fe08b7b0-ef8b-4609-ace7-7b6fb1cccb4a/exclude", "title": "Ender's Game"}, "repeat": {"after": 0.2757336114350713, "before": 0.2694775692575348, "case": "full/dandan/None/None/f2250e75-ee7f-4ba7-ac02-8a7663133ad9/exclude", "title": "Shadows of Self"}, "rule_excluded": {"case": "full/dandan/None/None/11b7e342-0a73-4a55-8798-bd5e6e1f2837/exclude", "title": "A Wizard of Earthsea"}, "rule_reduction": {"after": 0.2047808623294794, "before": 0.5119521558236985, "case": "full/dandan/None/None/11b7e342-0a73-4a55-8798-bd5e6e1f2837/reduce", "title": "A Wizard of Earthsea"}, "series_note_computed_but_omitted": {"case": "full/dandan/None/None/d67034b9-1305-4a6a-89d4-d56b504fc44c/exclude", "title": "The Golden Compass"}, "trajectory": {"after": 0.08162915322284472, "before": 0.11661307603263532, "case": "full/dandan/None/None/d67034b9-1305-4a6a-89d4-d56b504fc44c/exclude", "title": "The Golden Compass"}, "veto": {"after": 0.549, "before": 0.8421052631578947, "case": "interaction/candidate-1/none", "title": "candidate-1"}}
PASS counts: {"duplicate_views": 5, "missing_title_pairs": 6, "pairs": 11455, "render_pairs": 50, "successful_pairs": 11449, "warning_pairs": 2083}
PASS bit-exact assertions: 433906
PASS original output digest: e465140aaca3094679397fb5a556ce07667f10f5b3987675afb48b8c45a1b9f4
PASS migrated output digest: e465140aaca3094679397fb5a556ce07667f10f5b3987675afb48b8c45a1b9f4
Elapsed seconds: 951.9431061251089
PASS final: complete 11-key dictionaries, six-stage pipeline, attribution, rounding, raw floats, rules/exclusions, cold start, exceptions, warnings and rendered text preserved; no input mutations
```

## Baseline, proposal, rater and output hashes

```json
{
  "scripts/recommend.py": {
    "head": "a4d6dd44d7f11ec71a38ce1aa2d0f706c4e42ca881d0fa3da33105d0fa337955",
    "proposed": "9b13887ecea405ef9acbb8709df92757c037b8659e6e506d7931c7209fa07f5c",
    "equal": false
  },
  "scripts/scoring_tests.py": {
    "head": "4dc979831db39effd58db880172b0744c1621792434d8a7dcdc3a362c6f743b7",
    "proposed": "4dc979831db39effd58db880172b0744c1621792434d8a7dcdc3a362c6f743b7",
    "equal": true
  },
  "data/ratings/dandan.json": "86c9ccd896ca8f2ed30af8195060b390fc18d9a3c466668c698a3ad7f305dcef",
  "data/ratings/gabriel.json": "72ee7165963a97f969273fcf83f3bfd972b41e5ae699ef622fb93d93ec78322e",
  "data/ratings/mathias.json": "852ee65c674b9badb1a2afcd542dc520e824eecfa36314601981bdda915580e2",
  "data/ratings/mathias_goodreads.json": "7a81276e9e5d9e24a7b1532b4823a880ff11de47a0162dcee94b83cd4c4cffb4",
  "data/ratings/osnat.json": "e5c3245c28a264562aba0606d57cf5b3d370f1b61f8af5d121f1c964fc59bca3",
  "before": {
    "bytes": 29592,
    "sha256": "75bdc050cafc459b1c61f40ccf9382a39be74d2966416076884d8a8f5459a6ea"
  },
  "after": {
    "bytes": 29592,
    "sha256": "75bdc050cafc459b1c61f40ccf9382a39be74d2966416076884d8a8f5459a6ea"
  },
  "snapshot": {
    "bytes": 102,
    "sha256": "be95793bae20c704bd86c941e438ac52aa6d43b70d24e691a08ee6021dca3bc2"
  },
  "HEAD": "e531320e801b9cb6861a4b1e87a3ff991b0d656c"
}
```

## Complete proposed diff (`git diff -- scripts/recommend.py`)

```diff
diff --git a/scripts/recommend.py b/scripts/recommend.py
index b98f584..2a51139 100644
--- a/scripts/recommend.py
+++ b/scripts/recommend.py
@@ -3790,22 +3790,27 @@ def audit_book_score(catalog, ratings, title, genre=None, fatigue_overrides=None
     deduped_id_to_magnitude = _series_deduped_id_to_magnitude(catalog, id_to_magnitude)
     series_dna = compute_series_dna(catalog)
     field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
-    book = catalog[title_to_id[title]]
+    book_id = title_to_id[title]
+    book = catalog[book_id]
 
-    raw_score, _ = score_book(book, centroid, weights, field_prevalence, trope_prevalence)
-    after_series = _apply_series_repeat(catalog, id_to_magnitude, book, raw_score)
-    after_veto = _apply_dealbreaker_veto(
-        catalog, id_to_magnitude, validated_fields, book, centroid, weights, after_series,
-        field_prevalence, trope_prevalence
+    poor_threshold = user_calibrated_poor_threshold(
+        catalog, id_to_magnitude, centroid, weights,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
     )
-    after_trajectory = _apply_series_trajectory_penalty(series_dna, book, centroid, weights, after_veto,
-                                                         field_prevalence, trope_prevalence)
-    if csw > 0:
-        demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"), 0.5)
-        after_cold_start = (1 - csw) * after_trajectory + csw * (1.0 - demand)
-    else:
-        after_cold_start = after_trajectory
-    final, excluded_by_rule = apply_user_rules(book, after_cold_start, normalize_user_rules(user_rules))
+    result = score_candidate(
+        catalog, book_id, centroid, weights, id_to_magnitude,
+        policy="audit", validated_fields=validated_fields, series_dna=series_dna,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence,
+        poor_threshold=poor_threshold, cold_start=csw,
+        normalized_rules=normalize_user_rules(user_rules), top_n=100
+    )
+    raw_score = result["scores"]["base"]
+    after_series = result["scores"]["after_series_repeat"]
+    after_veto = result["scores"]["after_veto"]
+    after_trajectory = result["scores"]["after_trajectory"]
+    after_cold_start = result["scores"]["after_cold_start"]
+    final = result["scores"]["final"]
+    excluded_by_rule = result["excluded_by_user_rule"]
 
     pipeline = [
         {"stage": "raw score_book()", "score": round(raw_score, 4), "changed": None},
@@ -3822,8 +3827,7 @@ def audit_book_score(catalog, ratings, title, genre=None, fatigue_overrides=None
          "excluded": excluded_by_rule},
     ]
 
-    matches, mismatches = explain_book(book, centroid, weights, top_n=100,
-                                        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
+    matches, mismatches = result["matches"], result["mismatches"]
 
     def build_rows(rows, negate=False):
         out = []
@@ -3862,15 +3866,14 @@ def audit_book_score(catalog, ratings, title, genre=None, fatigue_overrides=None
             out.append(row)
         return out
 
-    dealbreaker = dealbreaker_flags(book, centroid, weights, validated_fields=validated_fields,
-                                     field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
+    dealbreaker = result["dealbreaker_flags"]
     series_sim = series_repeat_worst_similarity(catalog, id_to_magnitude, book)
 
     return {
         "title": book["title"],
         "author": book["author"],
         "final_score": round(final, 4),
-        "match_label": "Excluded by user rule" if excluded_by_rule else match_label(final, user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights, field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)),
+        "match_label": result["match_label"],
         "excluded_by_user_rule": excluded_by_rule,
         "pipeline": pipeline,
         "matches": build_rows(matches),
```

## Read-only suite/snapshot launcher

```python
import os, re, shlex, subprocess, sys, hashlib
from pathlib import Path
root = Path.cwd()
s = (root / '.env').read_text()
m = re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$', s)
if not m: raise SystemExit('Missing CODX_READONLY_DATABASE_URL')
parts = shlex.split(m.group(1), comments=True)
if len(parts) != 1 or not parts[0]: raise SystemExit('Invalid read-only variable')
e = os.environ.copy()
e['CODX_READONLY_DATABASE_URL'] = parts[0]
e['PYTHONDONTWRITEBYTECODE'] = '1'
mode = sys.argv[1]
command = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py' if mode in ('before', 'after') else 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task8/snapshot.py'
p = subprocess.run(['zsh', '-f', '-c', command], env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if parts[0].encode() in p.stdout: raise SystemExit('Credential appeared in output; not saved')
path = Path('/private/tmp/codx-task8') / (mode + '.txt')
path.write_bytes(p.stdout)
print(f'{mode}: exit={p.returncode} bytes={len(p.stdout)} sha256={hashlib.sha256(p.stdout).hexdigest()}')
if p.returncode: print(p.stdout.decode())
sys.exit(p.returncode)
```

## Catalog snapshot acquisition

```python
import sys,pickle,hashlib
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'scripts'))
import recommend as R
catalog=R.load_catalog()
data=pickle.dumps(catalog)
Path('/private/tmp/codx-task8/catalog.pickle').write_bytes(data)
print('Catalog books:',len(catalog),'snapshot sha256:',hashlib.sha256(data).hexdigest())
```

## Complete dedicated direct-comparison harness

```python
import ast,contextlib,copy,hashlib,importlib.util,io,itertools,json,pickle,struct,subprocess,sys,time
from collections import Counter
from pathlib import Path
ROOT=Path.cwd();W=Path('/private/tmp/codx-task8');sys.path.insert(0,str(ROOT/'scripts'))
import recommend as N
spec=importlib.util.spec_from_file_location('original_task8',W/'original.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
old=(W/'original.py').read_text();new=Path('scripts/recommend.py').read_text()
a={n.name:n for n in ast.parse(old).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))};b={n.name:n for n in ast.parse(new).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
assert a.keys()==b.keys() and {k for k in a if ast.dump(a[k])!=ast.dump(b[k])}=={'audit_book_score'}
ol,nl=old.splitlines(keepends=True),new.splitlines(keepends=True)
x,y=a['audit_book_score'],b['audit_book_score']
assert ol[:x.lineno-1]==nl[:y.lineno-1] and ol[x.end_lineno:]==nl[y.end_lineno:]
assert ast.dump(x.args)==ast.dump(y.args)
for name in ['_series_deduped_id_to_magnitude','_audit_attribute_nominal_or_trope','_audit_attribute_ordinal','series_repeat_worst_similarity','print_score_audit','score_candidate','recommend','explain_match']:
    os=''.join(ol[a[name].lineno-1:a[name].end_lineno]).encode();ns=''.join(nl[b[name].lineno-1:b[name].end_lineno]).encode();assert os==ns
    print('UNCHANGED',name,'sha256='+hashlib.sha256(os).hexdigest(),flush=True)
ox=next(n for n in x.body if isinstance(n,ast.FunctionDef) and n.name=='build_rows');ny=next(n for n in y.body if isinstance(n,ast.FunctionDef) and n.name=='build_rows')
os=''.join(ol[ox.lineno-1:ox.end_lineno]).encode();ns=''.join(nl[ny.lineno-1:ny.end_lineno]).encode();assert os==ns
print('UNCHANGED nested build_rows sha256='+hashlib.sha256(os).hexdigest())
# Pipeline source is deliberately preserved, including the cold-start comparison.
op=old[old.index('    pipeline = [',old.index('def audit_book_score(')):old.index('    matches, mismatches',old.index('def audit_book_score('))]
np=new[new.index('    pipeline = [',new.index('def audit_book_score(')):new.index('    matches, mismatches',new.index('def audit_book_score('))]
assert op==np and 'abs(after_cold_start - after_trajectory) > 1e-9' in np and 'after_diversity' not in np
print('PASS only audit_book_score AST changed; all outside bytes, signature, nested attribution closure and full six-stage pipeline source unchanged')
keys=[k.value for k in next(n for n in x.body if isinstance(n,ast.Return)).value.keys]
assert len(keys)==11 and 'series_note' not in keys and 'series_note' in ast.get_docstring(x)
print('Original actual return keys:',json.dumps(keys))
# Only tracked Python files: scratch reports contain historical code, not callers.
paths=subprocess.check_output(['git','ls-files','*.py'],text=True).splitlines();callers=[]
for path in paths:
    tree=ast.parse(Path(path).read_text())
    for n in ast.walk(tree):
        if isinstance(n,ast.Call) and ((isinstance(n.func,ast.Name) and n.func.id=='audit_book_score') or (isinstance(n.func,ast.Attribute) and n.func.attr=='audit_book_score')):callers.append((path,n.lineno))
assert callers==[('tools/dogfood/app.py',187)],callers
assert 'series_note' not in Path('tools/dogfood/app.py').read_text()
assert 'series_note' not in ''.join(ol[a['print_score_audit'].lineno-1:a['print_score_audit'].end_lineno])
print('PASS sole executable tracked-Python audit caller:',callers,'; no canonical suite audit call; no dogfood/print audit series_note reads')

stats=Counter();coverage=Counter();examples={};checks=0;od=hashlib.sha256();nd=hashlib.sha256()
def enc(x):
    if isinstance(x,float):return ['float64',struct.pack('!d',x).hex()]
    if isinstance(x,tuple):return ['tuple',[enc(v) for v in x]]
    if isinstance(x,list):return ['list',[enc(v) for v in x]]
    if isinstance(x,dict):return ['dict',[(k,enc(v)) for k,v in x.items()]]
    return x
def pack(x):return json.dumps(enc(x),ensure_ascii=False,separators=(',',':')).encode()
def eq(x,y,label):
    global checks
    assert pack(x)==pack(y),(label,x,y);checks+=1

def observe(module,cat,ratings,title,kw):
    fn=module.audit_book_score;state={};calls=Counter();out=io.StringIO()
    def trace(frame,event,arg):
        code=frame.f_code
        if code is fn.__code__:
            frame.f_trace_lines=False
            if event=='return':state['locals']=frame.f_locals.copy()
            return trace
        if code is module.user_calibrated_poor_threshold.__code__:
            frame.f_trace_lines=False
            if event=='call':calls['calibration']+=1
            if event=='return':state['threshold']=arg
            return trace
        if module is N and code is N.score_candidate.__code__:
            frame.f_trace_lines=False
            if event=='call':
                calls['canonical']+=1
                assert frame.f_locals['policy']=='audit' and frame.f_locals['top_n']==100
            if event=='return':state['result']=arg
            return trace
        return None
    sys.settrace(trace)
    try:
        with contextlib.redirect_stdout(out):result=fn(cat,ratings,title,**kw)
        error=None
    except Exception as e:result=None;error=(type(e).__name__,e.args,str(e))
    finally:sys.settrace(None)
    return result,error,out.getvalue(),state,calls

stage_locals={'base':'raw_score','after_series_repeat':'after_series','after_veto':'after_veto','after_trajectory':'after_trajectory','after_cold_start':'after_cold_start','final':'final'}
def pair(case,cat,ratings,title,kw,expected_id=None,render=False):
    original,oe,ow,os,oc=observe(O,cat,ratings,title,kw);actual,ne,nw,ns,nc=observe(N,cat,ratings,title,kw)
    eq(ne,oe,(case,'exception'));eq(nw,ow,(case,'warnings'));eq(actual,original,(case,'entire audit dict'))
    od.update(case.encode()+pack(original)+pack(oe));nd.update(case.encode()+pack(actual)+pack(ne));stats['pairs']+=1
    if ow:stats['warning_pairs']+=1
    if oe:
        assert oe[0]=='KeyError' and nc['canonical']==0
        stats['missing_title_pairs']+=1;return None
    assert list(actual)==list(original)==keys and 'series_note' not in actual
    for key in keys:eq(actual[key],original[key],(case,key))
    v,u=os['locals'],ns['locals'];result=ns['result']
    assert nc['canonical']==nc['calibration']==1
    assert oc['calibration']==(0 if original['excluded_by_user_rule'] else 1)
    if 'threshold' in os:eq(ns['threshold'],os['threshold'],(case,'threshold'))
    if expected_id is not None:eq(v['book']['id'],expected_id,'original physical id');eq(u['book']['id'],expected_id,'migrated physical id')
    for key,local in stage_locals.items():
        eq(result['scores'][key],v[local],(case,key));eq(u[local],v[local],(case,local))
    for local in ['matches','mismatches','dealbreaker','series_sim','excluded_by_rule','csw','deduped_id_to_magnitude']:
        eq(u[local],v[local],(case,local))
    assert len(actual['pipeline'])==6
    eq(actual['pipeline'][4]['changed'],abs(v['after_cold_start']-v['after_trajectory'])>1e-9,(case,'cold changed'))
    eq(actual['pipeline'][5]['changed'],abs(v['final']-v['after_cold_start'])>1e-9 or v['excluded_by_rule'],(case,'rule changed'))
    for first,last,name in [('raw_score','after_series','repeat'),('after_series','after_veto','veto'),('after_veto','after_trajectory','trajectory'),('after_trajectory','after_cold_start','cold_start'),('after_cold_start','final','rule_reduction')]:
        if v[first]!=v[last]:
            coverage[name]+=1;examples.setdefault(name,dict(case=case,title=title,before=v[first],after=v[last]))
    for condition,name in [(bool(actual['dealbreaker_flags']),'flags'),(actual['excluded_by_user_rule'],'rule_excluded'),(v['csw']>0,'nonzero_csw'),(bool(result['series_note']),'series_note_computed_but_omitted'),(v['book']['id'] in v['id_to_magnitude'],'rated_book_audited')]:
        if condition:coverage[name]+=1;examples.setdefault(name,dict(case=case,title=title))
    if render:
        l=io.StringIO();r=io.StringIO()
        with contextlib.redirect_stdout(l):O.print_score_audit(original)
        with contextlib.redirect_stdout(r):N.print_score_audit(actual)
        eq(r.getvalue(),l.getvalue(),(case,'printed audit'));stats['render_pairs']+=1
    stats['successful_pairs']+=1
    return v['book']['id']

snapshot=(W/'catalog.pickle').read_bytes();catalog=pickle.loads(snapshot);unchanged=pickle.dumps(catalog)
print('Catalog rows:',len(catalog),'sha256='+hashlib.sha256(snapshot).hexdigest(),flush=True)
raters={p.stem:json.loads(p.read_text())['ratings'] for p in sorted(Path('data/ratings').glob('*.json'))}
profiles=[('dandan',None,None),('gabriel','sci_fi','mixed'),('mathias','fantasy','audiobook'),('osnat','fantasy',None),('mathias_goodreads',None,None)]
variants=[('exclude',{'exclude':['age_category:ya'],'reduce':[{'key':'drive:romance_driven','strength':.37}]}),('reduce',{'reduce':[{'key':'age_category:ya','strength':.6},{'key':'drive:romance_driven','strength':.37},{'key':'quest','strength':.2}]})]
title_map={b['title']:bid for bid,b in catalog.items()};row_coverage={};start=time.perf_counter()
for name,genre,fmt in profiles:
    ratings=raters[name];input_before=pickle.dumps(ratings);seen={k:set() for k,_ in variants}
    for i,(bid,book) in enumerate(catalog.items(),1):
        cat=catalog
        if title_map[book['title']]!=bid:
            cat={k:v for k,v in catalog.items() if k!=bid};cat[bid]=book;stats['duplicate_views']+=1
        for mode,rules in variants:
            kw=dict(genre=genre,format_preference=fmt,user_rules=rules)
            resolved=pair(f'full/{name}/{genre}/{fmt}/{bid}/{mode}',cat,ratings,book['title'],kw,bid)
            assert resolved is not None;seen[mode].add(resolved)
        if i%100==0 or i==len(catalog):print('PROGRESS',name,i,'/'+str(len(catalog)),'elapsed='+str(round(time.perf_counter()-start,2)),flush=True)
    assert seen['exclude']==seen['reduce']==set(catalog)
    assert pickle.dumps(ratings)==input_before
    row_coverage[name]={k:len(v) for k,v in seen.items()}
    print('PASS full physical-row coverage',name,row_coverage[name],flush=True)

# No-rules, empty-history full catalog: explicitly exercise cold-start defaults.
for bid,book in catalog.items():
    cat=catalog
    if title_map[book['title']]!=bid:cat={k:v for k,v in catalog.items() if k!=bid};cat[bid]=book
    pair('cold-empty/'+bid,cat,{},book['title'],{},bid)
print('PASS cold-empty/no-rules full catalog',flush=True)
# Supplement all genre/format combinations on observed interaction examples.
titles=list(dict.fromkeys([v['title'] for v in examples.values()]+['Warbreaker']))
for name,ratings in raters.items():
    for genre,fmt in itertools.product([None,'fantasy','sci_fi'],[None,'audiobook','mixed']):
        for title in titles:pair(f'extra/{name}/{genre}/{fmt}/{title}',catalog,ratings,title,dict(genre=genre,format_preference=fmt),render=genre is None and fmt is None)
    pair('missing/'+name,catalog,ratings,"Missing 'audit'\n☃",{})
pair('missing/empty',{}, {},'No title',{})
pair('fatigue',catalog,raters['mathias'],'Warbreaker',dict(fatigue_overrides={'person':-.6,'quest':-1.0}),render=True)
pair('invalid-rule',catalog,raters['mathias'],'Warbreaker',dict(user_rules={'exclude':['invalid_field:x']}))
# Force veto+trajectory+cold-start+stacked-rules without mocking profile learning.
report=Path('docs/codx-reviews/codx-a2-canonical-scorer-proposal-2026-09-16.md').read_text()
fixture={};ratings={};exec(report.split('fixture={};ratings={}\n',1)[1].split('ctx=context(fixture,ratings)',1)[0])
for mode,rules in [('none',None),('reduce',{'reduce':[{'key':'person:first','strength':.2},{'key':'overall_pace:fast','strength':.3}]}),('exclude',{'exclude':['person:first'],'reduce':[{'key':'overall_pace:fast','strength':1.0}]})]:
    for bid,book in fixture.items():pair(f'interaction/{bid}/{mode}',fixture,ratings,book['title'],dict(user_rules=rules),bid,render=True)
assert pickle.dumps(catalog)==unchanged
for key in ['flags','repeat','trajectory','cold_start','nonzero_csw','rule_reduction','rule_excluded','veto','series_note_computed_but_omitted']:assert coverage[key]>0,(key,coverage)
assert stats['missing_title_pairs']==6 and od.hexdigest()==nd.hexdigest()
print('PASS physical-row matrix:',json.dumps(row_coverage,sort_keys=True))
print('PASS coverage:',json.dumps(dict(coverage),sort_keys=True))
print('PASS examples:',json.dumps(examples,sort_keys=True))
print('PASS counts:',json.dumps(dict(stats),sort_keys=True))
print('PASS bit-exact assertions:',checks)
print('PASS original output digest:',od.hexdigest());print('PASS migrated output digest:',nd.hexdigest())
print('Elapsed seconds:',time.perf_counter()-start)
print('PASS final: complete 11-key dictionaries, six-stage pipeline, attribution, rounding, raw floats, rules/exclusions, cold start, exceptions, warnings and rendered text preserved; no input mutations')
```

## Canonical suite before (complete output, exit 0)

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.663 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.453 Poor match     OK
    Eragon                       it_was_okay  0.538 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.717 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.549 Mixed match    MISS
    The Last Wish                liked        0.716 Good match     OK
    Old Man's War                liked        0.463 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out, format_preference=audiobook: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.371 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.747 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.374 Mixed match    OK
    Words of Radiance            loved        0.470 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.438 Mixed match    OK
    The Hero of Ages             it_was_okay  0.228 Mixed match    OK
    Ender's Shadow               loved        0.727 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.649 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.515 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.616 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.445 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.562 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.554 Good match     OK
    Rhythm of War                loved        0.454 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.580 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.514 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.494 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.652 Good match     OK
    Iron Flame                   it_was_okay  0.549 Mixed match    OK
    Daughter of No Worlds        hated        0.574 Good match     MISS
    Magic Burns                  hated        0.854 Strong match   MISS
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
  tone                Mathias, full     82% (+9pp)       84% (+0pp)       80% (+0pp)       100% (+20pp)   
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
    32           70%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.078
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6784) vs The True Bastards (hated, held-out score 0.6933)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8225) vs Magic Burns (hated, held-out score 0.8489)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0346) vs The Path of Daggers (hated, held-out score 0.0237)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0171) vs A Crown of Swords (it_was_okay, held-out score -0.0631)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0438) vs The Dragon Reborn (it_was_okay, held-out score -0.0225)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0554) vs Lord of Chaos (loved, held-out score -0.0076)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.059) vs The Path of Daggers (hated, held-out score 0.0215)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0375) vs A Crown of Swords (it_was_okay, held-out score -0.0638)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0368) vs The Fires of Heaven (disliked, held-out score -0.0532)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0233) vs The Shadow Rising (loved, held-out score -0.0171)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.0557) vs Knife of Dreams (loved, held-out score 0.0153)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0646) vs The Path of Daggers (hated, held-out score 0.0237)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0559) vs The Gathering Storm (loved, held-out score 0.054)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0269) vs Winter's Heart (liked, held-out score 0.0884)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.064) vs Knife of Dreams (loved, held-out score -0.0134)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0065) vs The Path of Daggers (hated, held-out score 0.0221)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0506) vs Winter's Heart (liked, held-out score -0.0121)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0642) vs The Gathering Storm (loved, held-out score 0.0246)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0438) vs A Crown of Swords (it_was_okay, held-out score -0.0615)  [OK]
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

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```

## Canonical suite after (complete output, exit 0)

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.663 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.453 Poor match     OK
    Eragon                       it_was_okay  0.538 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.717 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.549 Mixed match    MISS
    The Last Wish                liked        0.716 Good match     OK
    Old Man's War                liked        0.463 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out, format_preference=audiobook: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.371 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.747 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.374 Mixed match    OK
    Words of Radiance            loved        0.470 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.438 Mixed match    OK
    The Hero of Ages             it_was_okay  0.228 Mixed match    OK
    Ender's Shadow               loved        0.727 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.649 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.515 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.616 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.445 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.562 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.554 Good match     OK
    Rhythm of War                loved        0.454 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.580 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.514 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.494 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.652 Good match     OK
    Iron Flame                   it_was_okay  0.549 Mixed match    OK
    Daughter of No Worlds        hated        0.574 Good match     MISS
    Magic Burns                  hated        0.854 Strong match   MISS
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
  tone                Mathias, full     82% (+9pp)       84% (+0pp)       80% (+0pp)       100% (+20pp)   
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
    32           70%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.078
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6784) vs The True Bastards (hated, held-out score 0.6933)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8225) vs Magic Burns (hated, held-out score 0.8489)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0346) vs The Path of Daggers (hated, held-out score 0.0237)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0171) vs A Crown of Swords (it_was_okay, held-out score -0.0631)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0438) vs The Dragon Reborn (it_was_okay, held-out score -0.0225)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0554) vs Lord of Chaos (loved, held-out score -0.0076)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.059) vs The Path of Daggers (hated, held-out score 0.0215)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0375) vs A Crown of Swords (it_was_okay, held-out score -0.0638)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0368) vs The Fires of Heaven (disliked, held-out score -0.0532)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0233) vs The Shadow Rising (loved, held-out score -0.0171)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.0557) vs Knife of Dreams (loved, held-out score 0.0153)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0646) vs The Path of Daggers (hated, held-out score 0.0237)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0559) vs The Gathering Storm (loved, held-out score 0.054)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0269) vs Winter's Heart (liked, held-out score 0.0884)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.064) vs Knife of Dreams (loved, held-out score -0.0134)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0065) vs The Path of Daggers (hated, held-out score 0.0221)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0506) vs Winter's Heart (liked, held-out score -0.0121)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0642) vs The Gathering Storm (loved, held-out score 0.0246)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0438) vs A Crown of Swords (it_was_okay, held-out score -0.0615)  [OK]
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

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```

## Handoff and restoration

The proposal is for independent verification against the stated baseline. The only unresolved documentation issue is the pre-existing series_note omission; it is intentionally preserved. No live Streamlit check or performance guarantee is claimed. The canonical suite is collateral evidence only; the exhaustive paired audit harness supplies direct regression evidence.

Source restoration and report-extracted patch applicability are verified below. Untracked reports that predate this task are preserved.

### Restoration command and complete output

```sh
python3 /private/tmp/codx-task8/restore.py > /private/tmp/codx-task8/restoration.txt 2>&1
cat /private/tmp/codx-task8/restoration.txt
```

```text
Restored scripts/recommend.py SHA-256: a4d6dd44d7f11ec71a38ce1aa2d0f706c4e42ca881d0fa3da33105d0fa337955
Untouched scripts/scoring_tests.py SHA-256: 4dc979831db39effd58db880172b0744c1621792434d8a7dcdc3a362c6f743b7
$ git diff --exit-code
exit: 0
$ git diff --cached --exit-code
exit: 0
$ git diff --check
exit: 0
$ git apply --check /private/tmp/codx-task8/report-extracted.patch
exit: 0
$ git status --short
exit: 0
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
PASS embedded patch and both suite outputs verified byte-for-byte
PASS tracked working tree and index clean; untracked reports preserved
```

### Restoration/check script

```python
import hashlib,json,re,subprocess
from pathlib import Path
work=Path('/private/tmp/codx-task8')
report=Path('docs/codx-reports/2026-09-16-audit-book-score-migration-proposal.md')
s=report.read_text();patches=re.findall(r'^```diff\n(.*?)^```$',s,re.M|re.S)
assert len(patches)==1 and patches[0].encode()==(work/'proposal.patch').read_bytes()
extracted=work/'report-extracted.patch';extracted.write_text(patches[0])
facts=json.loads((work/'facts.json').read_text())
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==facts['HEAD']
p=Path('scripts/recommend.py')
assert hashlib.sha256(p.read_bytes()).hexdigest()==facts[str(p)]['proposed']
base=subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])
assert base==(work/'original.py').read_bytes()
p.write_bytes(base);assert p.read_bytes()==base
print('Restored scripts/recommend.py SHA-256:',hashlib.sha256(base).hexdigest())
r=Path('scripts/scoring_tests.py').read_bytes()
assert r==subprocess.check_output(['git','show','HEAD:scripts/scoring_tests.py'])
assert hashlib.sha256(r).hexdigest()==facts['scripts/scoring_tests.py']['head']
print('Untouched scripts/scoring_tests.py SHA-256:',hashlib.sha256(r).hexdigest())
for cmd in [['git','diff','--exit-code'],['git','diff','--cached','--exit-code'],['git','diff','--check'],['git','apply','--check',str(extracted)],['git','status','--short']]:
 result=subprocess.run(cmd,capture_output=True,text=True)
 print('$ '+' '.join(cmd));print('exit:',result.returncode);print(result.stdout+result.stderr,end='')
 assert result.returncode==0
for name in ['before','after']:
 embedded=s.split('## Canonical suite '+name+' (complete output, exit 0)\n\n```text\n',1)[1].split('```\n',1)[0].encode()
 assert embedded==(work/(name+'.txt')).read_bytes()
print('PASS embedded patch and both suite outputs verified byte-for-byte')
print('PASS tracked working tree and index clean; untracked reports preserved')
```

Final state: tracked working tree and index are clean. `scripts/recommend.py` is restored byte-for-byte to HEAD, and `scripts/scoring_tests.py` was never changed. The report-extracted patch passes `git apply --check`. Only the pre-existing untracked review/report area remains, including this new report.
