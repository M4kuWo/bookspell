# Task 3 — A2 prerequisite: shared base-factor evaluator proposal

Date: 2026-09-16. Author: CODX. Status: implemented locally and validated; proposed patch for CLDO to independently verify and apply. No commit, push, or hosted write.

## Context and scope

This implements Proposal 2 from Task 2, as independently verified in
docs/codx-reviews/codx-recommend-refactor-audit-2026-09-15.md. It is the
prerequisite extraction for Phase A2 of docs/TODO.md, building on landed A1.
It does not implement the canonical full-pipeline orchestrator or Phase B.
The initial attempt was blocked because the required upstream revision was
not available. Following the owner's retry, a successful `git pull --ff-only`
advanced this clone from 54fb632 to f93dbde. The earlier blocker is resolved;
its earlier “not implemented” status is superseded by this report.

The exact base is f93dbde8c77f6d6be2f90aa235f2a2b9b3f4c7f7.
Commit 2b76625 is an ancestor. AGENTS.md and CLAUDE.md were reread in full,
along with the required project context, Task 2 Proposal 2, the protocol's
2026-09-15 A1 kickoff entry, and the updated TODO. The September 16
clarification permits this local implementation and execution without
committing, pushing, or writing hosted data.

A1 supplies the permanent confidence-floor regressions, deterministic
secondary sort keys, and the format-aware benchmark scenario. Both canonical
runs here used that same post-A1 base and the same supplied codx_readonly
connection. No scoring_tests.py edit was needed.

## Implementation reasoning and preserved behavior

The duplicated base math was at score_book() and explain_book() in
scripts/recommend.py (base lines 2027 and 2114). The proposed
_iter_book_factors() begins at line 2027; the consumers follow it. It yields
(label, similarity, raw_weight, effective_weight, is_trope). Keeping both
weights matters: contribution display uses the raw weight, whereas the
score denominator and explanation magnitudes use the discounted weight.

The helper evaluates scalar fields in weights insertion order, then present
tropes in trope-weight insertion order. It does not sort factors, filter
zero-weight factors, or round them. Missing centroids, missing nominal
values, invalid/missing ordinal positions, and absent tropes retain their
existing skip behavior. This moves the September 11 missing-value fix into
one place without altering its meaning.

Scalar effective weight is computed in exactly the original operation
order: redundancy adjustment, multiplication by scoring_confidence(), then
optional multiplication by max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence).
Tropes retain their separate confidence/prevalence calculation without a
scalar redundancy adjustment. Present tropes have implicit similarity 1.0,
made explicit in the yielded record. Consumers still add a trope's
effective weight directly, avoiding a new multiplication in their arithmetic.

score_book() retains scalar contribution multiplication, sequential numerator
addition, absolute effective-weight denominator addition, the zero-denominator
guard, rounding only for displayed contributions, and existing sorting/top-five
selection. Its original gate is deliberately asymmetric: scalar raw weight
must be > 0.15, while trope absolute raw weight must be > 0.15. Neither was
“simplified” into the other.

explain_book() consumes the same factors but retains its original positive
and negative scalar branches. A negative fatigue weight reverses the
interpretation: similarity contributes to mismatch and dissimilarity to match.
The explanatory comment on that branch remains. Tropes continue to append
only to their sign-selected side using absolute effective weight. The strict
> 0.1 explanation floor, rounding, top_n slicing, and alphabetical secondary
sort key remain unchanged. AUDIT_CONTRIBUTION_THRESHOLD and the separately
declared display thresholds were not centralized or changed.

F2's recursion constraint is enforced by placement: the helper calls neither
consumer nor any higher-level modifier. explain_book() does not call a full
pipeline orchestrator. _apply_dealbreaker_veto() and
_apply_series_trajectory_penalty() can therefore continue to call it without
creating a recursion cycle.

Only scripts/recommend.py was edited for this proposal, apart from this
required report. No new heuristic, weight, DNA field, evaluation shortcut,
experimental-profile cleanup, or Phase B migration was included. The
five-element internal tuple keeps this extraction small; it is not a proposed
public full-pipeline result API. CLDO's remaining decision is whether to apply
this exact validated patch after independent verification. No unresolved
behavioral discrepancy or new product decision was found.

## Validation method and limits

The direct test runs the original functions loaded from the immutable git
revision and the proposed module side by side. It traces actual original
locals immediately before accumulation, rather than duplicating the factor
formulas in a second test implementation. It compares each factor in order,
including raw and effective weights, using IEEE-754 double byte encodings.
This distinguishes signed zero and is stronger than approximate equality.
For tropes, similarity 1.0 describes their original implicit full contribution.

It also compares unrounded numerator/denominator, normalized score,
contributions, and explanations at top_n 0/1/5/100. The 18 named cases include
missing evidence, confidence immediately below/exactly at/immediately above
0.3, partial nominal similarity, both redundancy triggers, prevalence
discounting and its floor, zero evidence, negative fatigue, tied magnitudes,
signed zero, and strict display boundaries. Another 360 cases cross weight,
confidence, prevalence, and ordinal-value choices. There are 1,119 compared
factors across 378 cases. Input dictionaries are checked for mutation.

The canonical suite is executed before the edit and after the edit through
the same launcher below. The launcher reads only CODX_READONLY_DATABASE_URL
from .env and passes it to the suite as DATABASE_URL; it does not source the
rest of .env or print credentials. PYTHONDONTWRITEBYTECODE avoids cache
artifacts. Both runs exit 0, including Scenario 14 and the format-aware
scenario. The entire captured suite output, not just selected metrics, is
included below twice and compares identically: 29,591 characters each.
Tool session IDs and elapsed times are execution metadata and are not suite
output. The launcher captures stdout followed by stderr with no metric,
ordering, timing, or warning filtering; its credential-redaction safeguard
was the same on both runs. No output difference was normalized away.

This demonstrates exact preservation on the synthetic battery and current
canonical data, not a proof for arbitrary malformed objects or every future
catalog state. The extraction preserves operation order to cover the broader
ordinary input contract as well. No nondeterminism was observed between these
two complete canonical runs.

## Exact validation commands and real output

### Revision, working tree, and whitespace check

```sh
git rev-parse HEAD
git merge-base --is-ancestor 2b76625 HEAD
git status --short
git diff --check
```

```text
f93dbde8c77f6d6be2f90aa235f2a2b9b3f4c7f7
 M scripts/recommend.py
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
```

Exit status: 0. The ancestor check and git diff --check produced no output.
The two untracked report locations existed before implementation.

### Canonical launcher — run before and after the code edit

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


Before edit, exit status 0:
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

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.665 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.548 Mixed match    MISS
    The Last Wish                liked        0.717 Good match     OK
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

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```


After edit, exit status 0:
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

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.665 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.548 Mixed match    MISS
    The Last Wish                liked        0.717 Good match     OK
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

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```


The actual orchestration comparison was:

```javascript
const before = load('t3before'), after = load('t3after');
if (before.exit_code !== 0 || after.exit_code !== 0 || before.output !== after.output)
  throw Error('Validation mismatch');
```


Observed result: both exits 0; complete output equality true. There are no
changed lines to show in an output diff. A disk-based verification of the
embedded outputs is recorded below after report creation.

### Direct comparison command

```sh
python3 -B - <<'PY'
import ast, copy, itertools, math, struct, subprocess, sys
sys.path.insert(0, 'scripts')
import recommend as new
revision = 'f93dbde8c77f6d6be2f90aa235f2a2b9b3f4c7f7'
source = subprocess.check_output(['git', 'show', revision + ':scripts/recommend.py'], text=True)
old = {'__name__': '_original_recommend', '__file__': '/Users/mathiaskurin/Documents/bookspell-codex/scripts/recommend.py'}
exec(compile(source, '<original-recommend>', 'exec'), old)
lines = source.splitlines()
tree = ast.parse(source)
functions = {n.name: n for n in tree.body if isinstance(n, ast.FunctionDef)}
def find_line(name, text):
    n = functions[name]
    hits = [i for i in range(n.lineno, n.end_lineno + 1) if lines[i-1].strip() == text]
    assert len(hits) == 1, (name, text, hits)
    return hits[0]
score_scalar = find_line('score_book', 'contribution = w_eff * sim')
score_trope = find_line('score_book', 'score += w_eff')
explain_scalar = find_line('explain_book', 'if w >= 0:')
explain_trope = find_line('explain_book', '(matches if w >= 0 else mismatches).append((f"trope:{t}", abs(w)))')
def bits(value):
    if isinstance(value, float):
        return ('float64', struct.pack('!d', value).hex())
    if isinstance(value, (tuple, list)):
        return tuple(bits(v) for v in value)
    return value
def observe(fn, args, kwargs, original=False):
    factors, totals = [], []
    def trace(frame, event, arg):
        if frame.f_code is fn.__code__ and event == 'line':
            v = frame.f_locals
            lineno = frame.f_lineno
            if original:
                if lineno == score_scalar and fn.__name__ == 'score_book':
                    factors.append((v['field'], v['sim'], v['w'], v['w_eff'], False))
                elif lineno == score_trope and fn.__name__ == 'score_book':
                    factors.append(('trope:' + v['t'], 1.0, v['w'], v['w_eff'], True))
                elif lineno == explain_scalar and fn.__name__ == 'explain_book':
                    factors.append((v['field'], v['sim'], args[2][v['field']], v['w'], False))
                elif lineno == explain_trope and fn.__name__ == 'explain_book':
                    factors.append(('trope:' + v['t'], 1.0, args[2]['tropes'][v['t']], v['w'], True))
            if fn.__name__ == 'score_book' and 'normalized' in v:
                totals[:] = [v['score'], v['total_weight']]
        return trace
    sys.settrace(trace)
    try:
        result = fn(*args, **kwargs)
    finally:
        sys.settrace(None)
    return result, factors, totals
cases = []
def case(name, book, centroid, weights, fp=None, tp=None):
    cases.append((name, book, centroid, weights, fp, tp))
case('missing scalar/centroid/absent trope', {'person': None, 'overall_pace': 'na'},
     {'person': 'first', 'overall_pace': 1.0}, {'person': .5, 'overall_pace': .5, 'drive': .4, 'tropes': {'quest': .5}})
for confidence in [0.0, math.nextafter(.3, 0), .3, math.nextafter(.3, 1), 1.0]:
    case('confidence boundary ' + repr(confidence),
         {'person': 'first', 'tropes': ['quest'], '_field_confidence': {'person': confidence}, '_trope_confidence': {'quest': confidence}},
         {'person': 'first'}, {'person': .5, 'tropes': {'quest': -.5}})
case('partial nominal', {'person': 'third_omniscient', 'drive': 'balanced', 'romance_tone': 'mixed'},
     {'person': 'third_limited', 'drive': 'plot_driven', 'romance_tone': 'understated'},
     {'person': .5, 'drive': .4, 'romance_tone': .3})
case('both redundancy triggers', {'person': 'first', 'pov_count': 'single', 'ends_on_cliffhanger': 'cliffhanger', 'narrative_closure': 'requires_series'},
     {'pov_count': .75, 'narrative_closure': 'self_contained'}, {'pov_count': .5, 'narrative_closure': .5})
case('prevalence and floor', {'overall_pace': 'fast', 'romance_tone': 'understated', 'tropes': ['quest', 'found_family']},
     {'overall_pace': .25, 'romance_tone': 'mixed'},
     {'tropes': {'quest': -.4, 'found_family': .5}, 'overall_pace': .3, 'romance_tone': .5},
     {'overall_pace': {'fast': .65}, 'romance_tone': {'understated': 1.0}}, {'quest': .8, 'found_family': 1.0})
case('zero evidence', {}, {}, {})
case('negative fatigue', {'overall_pace': 'medium', 'person': 'third_omniscient', 'tropes': ['quest']},
     {'overall_pace': 1.0, 'person': 'third_limited'}, {'overall_pace': -.7, 'person': -.6, 'tropes': {'quest': -.4}})
case('ties reverse order', {'form': 'prose', 'timeline': 'linear', 'tropes': ['z', 'a', 'm']},
     {'form': 'prose', 'timeline': 'linear'}, {'timeline': .4, 'form': .4, 'tropes': {'z': .4, 'm': .4, 'a': .4}})
case('zero weights retained', {'person': 'first', 'tropes': ['quest']},
     {'person': 'first'}, {'person': 0.0, 'tropes': {'quest': -0.0}})
for w in [.1, math.nextafter(.1,1), .15, math.nextafter(.15,1), -.15]:
    case('display boundary ' + repr(w), {'form':'prose','tropes':['quest']}, {'form':'prose'}, {'form':w,'tropes':{'quest':w}})
fixed_count = len(cases)
for w, confidence, prevalence, pace in itertools.product(
        [-1.0, -.15, -0.0, .1, .15, .5], [0.0, .299, .3, .85, 1.0], [None, 0.0, .8, 1.0], ['slow','medium','fast']):
    case('sweep', {'overall_pace':pace,'romance_tone':'mixed','tropes':['quest'],
                   '_field_confidence':{'overall_pace':confidence,'romance_tone':confidence},'_trope_confidence':{'quest':confidence}},
         {'overall_pace':.5,'romance_tone':'understated'},
         {'tropes':{'quest':-w},'overall_pace':w,'romance_tone':w},
         None if prevalence is None else {'overall_pace':{pace:prevalence},'romance_tone':{'mixed':prevalence}},
         None if prevalence is None else {'quest':prevalence})
factor_count = 0
for name, book, centroid, weights, fp, tp in cases:
    args = (book, centroid, weights)
    snapshot = copy.deepcopy(args)
    kwargs = dict(field_prevalence=fp, trope_prevalence=tp)
    actual = list(new._iter_book_factors(*args, **kwargs))
    a, sf, st = observe(old['score_book'], args, kwargs, True)
    b, ef, _ = observe(old['explain_book'], args, kwargs, True)
    assert bits(actual) == bits(sf) == bits(ef), (name, actual, sf, ef)
    c, _, ct = observe(new.score_book, args, kwargs)
    assert bits(a) == bits(c) and bits(st) == bits(ct), (name, a, c, st, ct)
    for top_n in [0, 1, 5, 100]:
        assert bits(old['explain_book'](*args, top_n=top_n, **kwargs)) == bits(new.explain_book(*args, top_n=top_n, **kwargs)), name
    assert args == snapshot, name
    factor_count += len(actual)
    if name != 'sweep':
        print('PASS', name, 'factors=', repr(actual))
print(f'PASS: {len(cases)} cases ({fixed_count} named boundary cases plus {len(cases)-fixed_count} sweep cases); {factor_count} factors')
print('PASS: original score_book AND explain_book traced locals match evaluator bit-for-bit, in order')
print('PASS: unrounded numerator, denominator, normalized score, contributions and explanations identical')
print('PASS: top_n=0/1/5/100; no input mutations; no database accessed')
PY
```


Real output, exit status 0:
```text
PASS missing scalar/centroid/absent trope factors= []
PASS confidence boundary 0.0 factors= [('person', 1.0, 0.5, 0.0, False), ('trope:quest', 1.0, -0.5, -0.0, True)]
PASS confidence boundary 0.29999999999999993 factors= [('person', 1.0, 0.5, 0.0, False), ('trope:quest', 1.0, -0.5, -0.0, True)]
PASS confidence boundary 0.3 factors= [('person', 1.0, 0.5, 0.15, False), ('trope:quest', 1.0, -0.5, -0.15, True)]
PASS confidence boundary 0.30000000000000004 factors= [('person', 1.0, 0.5, 0.15000000000000002, False), ('trope:quest', 1.0, -0.5, -0.15000000000000002, True)]
PASS confidence boundary 1.0 factors= [('person', 1.0, 0.5, 0.5, False), ('trope:quest', 1.0, -0.5, -0.5, True)]
PASS partial nominal factors= [('person', 0.5, 0.5, 0.425, False), ('drive', 0.5, 0.4, 0.34, False), ('romance_tone', 0.5, 0.3, 0.3, False)]
PASS both redundancy triggers factors= [('pov_count', 0.25, 0.5, 0.23800000000000002, False), ('narrative_closure', 0.0, 0.5, 0.17, False)]
PASS prevalence and floor factors= [('overall_pace', 0.25, 0.3, 0.08925, False), ('romance_tone', 0.5, 0.5, 0.05, False), ('trope:quest', 1.0, -0.4, -0.07999999999999999, True), ('trope:found_family', 1.0, 0.5, 0.05, True)]
PASS zero evidence factors= []
PASS negative fatigue factors= [('overall_pace', 0.5, -0.7, -0.595, False), ('person', 0.5, -0.6, -0.51, False), ('trope:quest', 1.0, -0.4, -0.4, True)]
PASS ties reverse order factors= [('timeline', 1.0, 0.4, 0.4, False), ('form', 1.0, 0.4, 0.4, False), ('trope:z', 1.0, 0.4, 0.4, True), ('trope:m', 1.0, 0.4, 0.4, True), ('trope:a', 1.0, 0.4, 0.4, True)]
PASS zero weights retained factors= [('person', 1.0, 0.0, 0.0, False), ('trope:quest', 1.0, -0.0, -0.0, True)]
PASS display boundary 0.1 factors= [('form', 1.0, 0.1, 0.1, False), ('trope:quest', 1.0, 0.1, 0.1, True)]
PASS display boundary 0.10000000000000002 factors= [('form', 1.0, 0.10000000000000002, 0.10000000000000002, False), ('trope:quest', 1.0, 0.10000000000000002, 0.10000000000000002, True)]
PASS display boundary 0.15 factors= [('form', 1.0, 0.15, 0.15, False), ('trope:quest', 1.0, 0.15, 0.15, True)]
PASS display boundary 0.15000000000000002 factors= [('form', 1.0, 0.15000000000000002, 0.15000000000000002, False), ('trope:quest', 1.0, 0.15000000000000002, 0.15000000000000002, True)]
PASS display boundary -0.15 factors= [('form', 1.0, -0.15, -0.15, False), ('trope:quest', 1.0, -0.15, -0.15, True)]
PASS: 378 cases (18 named boundary cases plus 360 sweep cases); 1119 factors
PASS: original score_book AND explain_book traced locals match evaluator bit-for-bit, in order
PASS: unrounded numerator, denominator, normalized score, contributions and explanations identical
PASS: top_n=0/1/5/100; no input mutations; no database accessed
```


Harness setup correction: the first attempt used
`old = {'__name__': '_original_recommend'}` without supplying __file__.
Loading the original module failed before any case executed:

```text
Traceback (most recent call last):
  File "<stdin>", line 7, in <module>
  File "<original-recommend>", line 3529, in <module>
NameError: name '__file__' is not defined. Did you mean: '__name__'?
```


The corrected command above supplies the module's real __file__. This was a
harness initialization error, not a factor mismatch or implementation change.
The corrected run passed in full.

## Full proposed patch

Captured with `git diff -- scripts/recommend.py` after both validations.
Apply against the base revision above for independent re-verification.

```diff
diff --git a/scripts/recommend.py b/scripts/recommend.py
index 12b4592..72d2aa8 100644
--- a/scripts/recommend.py
+++ b/scripts/recommend.py
@@ -2024,34 +2024,20 @@ def _redundancy_adjusted_weight(book, field, w):
     return w
 
 
-def score_book(book, centroid, weights, field_prevalence=None, trope_prevalence=None):
-    """Confidence discount (2026-08-30): a field/trope's effective weight
-    for THIS book is scaled by get_confidence(book, field) before it
-    contributes -- an uncertain tag gets less voting power in the
-    weighted average rather than being trusted at face value or assumed
-    to be a mismatch. Discounting both the numerator (contribution) and
-    denominator (total_weight) equally is what keeps this a "count for
-    less" effect rather than a bias toward either match or mismatch.
-
-    Candidate-pool prevalence discount (2026-09-06, LANDED): field_prevalence/
-    trope_prevalence -- from build_prevalence_lookup(catalog, genre), computed
-    ONCE per scoring session by the caller, never per candidate -- further
-    scale w_eff by max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence) when given.
-    A genuine, well-evidenced preference can still fail to RANK one candidate
-    above another if most of the candidate pool already shares the matching
-    value (e.g. emotional_resolution: bittersweet at ~53% catalog prevalence
-    contributed a suspiciously constant +0.323 across nearly every top
-    fantasy match before this landed) -- see docs/scoring-test-protocol.md's
-    2026-09-06 entries for the full validation (8-row scorecard, all 4 real
-    raters, every regression traced to a specific book and understood, not
-    just accepted because the aggregate numbers looked fine) this landed on.
-    None/None (the default) is a guaranteed no-op, byte-identical to
-    pre-2026-09-06 behavior -- callers with no genre/catalog context handy
-    (most of scripts/scoring_tests.py's direct calls) are unaffected."""
-    score = 0.0
-    total_weight = 0.0
-    contributions = []
-
+def _iter_book_factors(book, centroid, weights, field_prevalence=None, trope_prevalence=None):
+    """Yield (label, similarity, raw_weight, effective_weight, is_trope).
+
+    Scalar fields follow weights' insertion order; present tropes follow
+    weights["tropes"] order afterward, exactly as the original consumers.
+    Missing scalar values/centroids and absent tropes are skipped. Zero
+    effective weights are retained: filtering and accumulation belong to
+    the consumers, including their different raw-weight display gates.
+
+    A present trope has similarity 1.0, but consumers still add its
+    effective weight directly (rather than changing their arithmetic).
+    This evaluator sits below scoring and explanation; it never invokes
+    either consumer or a higher-level scoring modifier.
+    """
     for field, w in weights.items():
         if field == "tropes":
             continue
@@ -2086,24 +2072,58 @@ def score_book(book, centroid, weights, field_prevalence=None, trope_prevalence=
         if field_prevalence is not None:
             prevalence = field_prevalence.get(field, {}).get(book.get(field), 0.0)
             w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
-        contribution = w_eff * sim
-        score += contribution
-        total_weight += abs(w_eff)
-        if w > 0.15:
-            contributions.append((field, round(contribution, 3)))
+        yield field, sim, w, w_eff, False
 
     trope_weights = weights.get("tropes", {})
     book_tropes = set(book.get("tropes") or [])
     for t, w in trope_weights.items():
-        if t in book_tropes:
-            w_eff = w * scoring_confidence(book, t)
-            if trope_prevalence is not None:
-                prevalence = trope_prevalence.get(t, 0.0)
-                w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
-            score += w_eff
-            total_weight += abs(w_eff)
-            if abs(w) > 0.15:
-                contributions.append((f"trope:{t}", round(w_eff, 3)))
+        if t not in book_tropes:
+            continue
+        w_eff = w * scoring_confidence(book, t)
+        if trope_prevalence is not None:
+            prevalence = trope_prevalence.get(t, 0.0)
+            w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
+        yield f"trope:{t}", 1.0, w, w_eff, True
+
+
+def score_book(book, centroid, weights, field_prevalence=None, trope_prevalence=None):
+    """Confidence discount (2026-08-30): a field/trope's effective weight
+    for THIS book is scaled by get_confidence(book, field) before it
+    contributes -- an uncertain tag gets less voting power in the
+    weighted average rather than being trusted at face value or assumed
+    to be a mismatch. Discounting both the numerator (contribution) and
+    denominator (total_weight) equally is what keeps this a "count for
+    less" effect rather than a bias toward either match or mismatch.
+
+    Candidate-pool prevalence discount (2026-09-06, LANDED): field_prevalence/
+    trope_prevalence -- from build_prevalence_lookup(catalog, genre), computed
+    ONCE per scoring session by the caller, never per candidate -- further
+    scale w_eff by max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence) when given.
+    A genuine, well-evidenced preference can still fail to RANK one candidate
+    above another if most of the candidate pool already shares the matching
+    value (e.g. emotional_resolution: bittersweet at ~53% catalog prevalence
+    contributed a suspiciously constant +0.323 across nearly every top
+    fantasy match before this landed) -- see docs/scoring-test-protocol.md's
+    2026-09-06 entries for the full validation (8-row scorecard, all 4 real
+    raters, every regression traced to a specific book and understood, not
+    just accepted because the aggregate numbers looked fine) this landed on.
+    None/None (the default) is a guaranteed no-op, byte-identical to
+    pre-2026-09-06 behavior -- callers with no genre/catalog context handy
+    (most of scripts/scoring_tests.py's direct calls) are unaffected."""
+    score = 0.0
+    total_weight = 0.0
+    contributions = []
+
+    for label, sim, w, w_eff, is_trope in _iter_book_factors(
+        book, centroid, weights, field_prevalence, trope_prevalence
+    ):
+        contribution = w_eff if is_trope else w_eff * sim
+        score += contribution
+        total_weight += abs(w_eff)
+        # Preserve the original asymmetry: scalar display gates use the
+        # signed raw weight, while trope gates use its absolute value.
+        if (abs(w) if is_trope else w) > 0.15:
+            contributions.append((label, round(contribution, 3)))
 
     normalized = score / total_weight if total_weight > 0 else 0.0
     # Secondary sort key (field/trope name) for the same reason explain_book()
@@ -2119,7 +2139,7 @@ def explain_book(book, centroid, weights, top_n=5, field_prevalence=None, trope_
     math score_book() uses, decomposed for human explanation instead of
     collapsed into one number.
 
-    Why this needs its own pass rather than just re-reading
+    Why this needs its own factor view rather than just re-reading
     score_book()'s contributions: a field can have a small raw
     contribution (w * sim) for two very different reasons -- either the
     user doesn't weight it much (w is small), or it matters a lot AND
@@ -2143,27 +2163,12 @@ def explain_book(book, centroid, weights, top_n=5, field_prevalence=None, trope_
     pipeline than what the user actually sees."""
     matches, mismatches = [], []
 
-    for field, w in weights.items():
-        if field == "tropes" or field not in centroid:
-            continue
-        if field in ORDINAL_FIELDS:
-            pos = ordinal_position(field, book.get(field))
-            if pos is None:
-                continue
-            sim = 1 - abs(pos[0] / pos[1] - centroid[field])
-        else:
-            # See score_book()'s identical fix (2026-09-11) -- a
-            # never-tagged NOMINAL field must be skipped, not scored as
-            # a full mismatch against None.
-            if book.get(field) is None:
-                continue
-            sim = nominal_similarity(field, book.get(field), centroid[field])
-        w = _redundancy_adjusted_weight(book, field, w) * scoring_confidence(book, field)
-        if field_prevalence is not None:
-            prevalence = field_prevalence.get(field, {}).get(book.get(field), 0.0)
-            w *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
-
-        if w >= 0:
+    for field, sim, raw_weight, w, is_trope in _iter_book_factors(
+        book, centroid, weights, field_prevalence, trope_prevalence
+    ):
+        if is_trope:
+            (matches if w >= 0 else mismatches).append((field, abs(w)))
+        elif w >= 0:
             matches.append((field, w * sim))
             mismatches.append((field, w * (1 - sim)))
         else:
@@ -2173,20 +2178,9 @@ def explain_book(book, centroid, weights, top_n=5, field_prevalence=None, trope_
             matches.append((field, abs(w) * (1 - sim)))
             mismatches.append((field, abs(w) * sim))
 
-    trope_weights = weights.get("tropes", {})
-    book_tropes = set(book.get("tropes") or [])
-    for t, w in trope_weights.items():
-        if t not in book_tropes:
-            continue
-        w = w * scoring_confidence(book, t)
-        if trope_prevalence is not None:
-            prevalence = trope_prevalence.get(t, 0.0)
-            w *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
-        (matches if w >= 0 else mismatches).append((f"trope:{t}", abs(w)))
-
     # Secondary sort key (field/trope name) makes tie order deterministic --
     # without it, ties depend on set()/dict iteration order upstream (see
-    # `book_tropes = set(...)` above), which CODX's 2026-09-15 structural
+    # trope collection in _iter_book_factors()), which CODX's 2026-09-15 structural
     # audit (F10) caught actually flipping between two identical runs.
     # Scores/ranks are unaffected either way; only the DISPLAY order of
     # equal-magnitude matches/mismatches is now stable.
```


## Working-tree handoff

The patch is retained here for CLDO. The implementation is to be restored
to the exact HEAD bytes after this report is saved, as the owner requested.
The final cleanup and embedded-output verification transcript follows.

### Completed cleanup and disk verification

```sh
python3 -B - <<'PY'
from pathlib import Path
import hashlib, subprocess, re
p = Path('docs/codx-reports/2026-09-16-a2-factor-evaluator-proposal.md')
s = p.read_text()
before = re.search(r'Before edit, exit status 0:\n```text\n(.*?)```', s, re.S).group(1).encode()
after = re.search(r'After edit, exit status 0:\n```text\n(.*?)```', s, re.S).group(1).encode()
assert before == after
print('Canonical output diff: empty')
print('Both output lengths (UTF-8 bytes):', len(before))
print('Both SHA-256:', hashlib.sha256(before).hexdigest())
patch = s.split('## Full proposed patch',1)[1].split('```diff\n',1)[1].split('```',1)[0]
current = subprocess.check_output(['git','diff','--','scripts/recommend.py']).decode()
assert patch == current, 'Working diff differs from saved patch; refusing restore'
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip() == 'f93dbde8c77f6d6be2f90aa235f2a2b9b3f4c7f7'
original = subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])
Path('scripts/recommend.py').write_bytes(original)
assert Path('scripts/recommend.py').read_bytes() == original
assert not subprocess.check_output(['git','diff','--','scripts/recommend.py','scripts/scoring_tests.py'])
print('Restored recommend.py to exact HEAD bytes; scoring_tests.py unchanged')
check = subprocess.run(['git','apply','--check','-'], input=patch, text=True, capture_output=True)
assert check.returncode == 0, check.stderr
print('Saved patch: git apply --check passed against restored tree')
print('Final git status --short:')
print(subprocess.check_output(['git','status','--short'],text=True),end='')
PY
```

```text
Canonical output diff: empty
Both output lengths (UTF-8 bytes): 29591
Both SHA-256: 8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
Restored recommend.py to exact HEAD bytes; scoring_tests.py unchanged
Saved patch: git apply --check passed against restored tree
Final git status --short:
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
```

Exit status: 0. The tracked working tree is clean. Existing untracked reports
remain, including this handoff. No code changes remain to obstruct the next
fast-forward pull. No commit, push, or hosted write was performed.
