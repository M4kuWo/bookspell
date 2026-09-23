# Task 17 — Magic Burns ranking diagnosis

2026-09-23 · CODX · synced commit `181e88858703de649cd2ce41102d05b26bce6b7e`

**CONFIRMED: Magic Burns ranks #3/695, score 0.8853603401494837 (Strong match), against Osnat's assigned training split.** The assignment's historical #4 is not the current exact rank; the underlying failure reproduces. This run uses today's hosted catalog, not a reconstructed historical database. The assignment names `6c78d9d`; the synced checkout is newer. I have not established which intervening catalog/code change accounts for the one-position difference.

**High-confidence mechanical diagnosis:** the learned profile rewards the attributes Magic Burns actually has, and supplies no substantial counter-signal for this particular book. Its base score is already 0.88536. All subsequent stages leave it unchanged. This is a limitation of the preference representation learned from this sparse, particular training history, not evidence of a candidate-scoring arithmetic error or an unintended post-score boost. The veto is unavailable, but that alone is not the root cause: this candidate has no sizable mismatch to veto in the first place.

**INCONCLUSIVE: why Osnat personally hated the book.** Ratings contain no reason for this judgment. These measurements cannot establish whether the missing distinction is execution, a tag error, an unrepresented preference, or something else. No tag verification or scoring-design proposal is part of this report.

## Reproduction and evidence

Read the current assignment and both metric docstrings. Their self-selection correction matters: readers already chose to read held-out books. Absolute high rank measures product visibility, not taste accuracy. The useful discrimination comparison here is positive versus negative held-out books.

Evidence is in `docs/codx-reports/2026-09-23-magic-burns-evidence/`:

- `investigate.py`: calls the unmodified repository ranking metrics, recommendation API, audit, and candidate pipeline for both raters.
- `catalog.json`: snapshot of all 1,230 tagged catalog books from the authorized `codx_readonly` role, using the repository's `catalog.load_catalog()` SELECT queries only.
- `output.txt`: actual live-load reproduction output; `offline-output.txt`: identical printed output from replaying the snapshot.
- `results.json`: complete profiles, training titles/labels, rankings, score stages, factors, exclusions, and audits. Floating-point last-bit differences between reruns are possible because trope traversal uses a set; reported ranks and printed scores match.
- `analyze.py` and `analysis.txt`: full numeric decomposition, training structure, source tags, pair comparisons, and four additional negative leave-one-out probes. Snapshot loading restores decimal series positions before eligibility checks.

Commands, from this clone's root:

```sh
git pull --ff-only
/private/tmp/scorevenv/bin/python docs/codx-reports/2026-09-23-magic-burns-evidence/investigate.py --fetch > docs/codx-reports/2026-09-23-magic-burns-evidence/output.txt
/private/tmp/scorevenv/bin/python docs/codx-reports/2026-09-23-magic-burns-evidence/investigate.py > docs/codx-reports/2026-09-23-magic-burns-evidence/offline-output.txt
diff -u docs/codx-reports/2026-09-23-magic-burns-evidence/output.txt docs/codx-reports/2026-09-23-magic-burns-evidence/offline-output.txt
/private/tmp/scorevenv/bin/python docs/codx-reports/2026-09-23-magic-burns-evidence/analyze.py > docs/codx-reports/2026-09-23-magic-burns-evidence/analysis.txt
```

All completed successfully; `diff` produced no output. The initial sandboxed network load failed; the authorized escalated retry succeeded. The fetch script reads only `CODX_READONLY_DATABASE_URL` from `.env`, maps it to the loader's environment variable inside that process, and never prints or saves the credential. No `.env` edits. No Hardcover checks were needed for this new assignment.

Sync initially encountered the prior task's local log append. Its exact text was preserved at `2026-09-22-post-round5-qa-evidence/local-log-before-sync.md` before removing that duplicate local append and fast-forwarding; the shared log already records CLDO's disposition of Task 16.

## Assigned split: actual results

No genre filter, default print semantics, no fatigue overrides, user rules, recent history, or diversity. Training is exactly `OSNAT_USABLE` minus `OSNAT_HELD_OUT`, not her entire raw rating file.

| Osnat held-out title | Rating | Rank / 695 | Score |
|---|---|---:|---:|
| Magic Burns | hated | 3 | 0.8854 |
| A Court of Wings and Ruin | loved | 30 | 0.8389 |
| Harry Potter and the Goblet of Fire | it_was_okay | 192 | 0.7479 |
| Iron Flame | it_was_okay | 223 | 0.7269 |
| Divergent | liked | 231 | 0.7222 |
| Daughter of No Worlds | hated | 450 | 0.6015 |
| Harry Potter and the Half-Blood Prince | loved | excluded: series_position | audit-only 0.8582 |

The top three are The Last Murder at the End of the World (0.920725), Daughter of the Moon Goddess (0.887577), and Magic Burns (0.885360). No tie explains its position. Top-5/10/20 rejection is 50% and NDCG is 0.000 at all three cutoffs. Those NDCG values are not an assertion that all other recommended books are bad: their relevance is unknown.

Magic Burns is eligible because Magic Bites, the preceding catalog installment, is rated in training. Exclusion of other held-out books is kept separate from successful negative scoring.

## Exact score decomposition

I chose `audit_book_score()` because it provides training-book attribution and downstream stages, supplemented by `score_candidate(policy="ranking")` for unrounded factors and actual eligibility. `explain_match()` alone omits ranking's cold-start/rule stages. The audit and ranking scores agree here; cold-start weight and diversity are both zero.

The canonical formula gives:

```text
scalar numerator = 1.6785776392; scalar absolute effective weight = 2.0732486391
trope numerator  = 1.3694604582; trope absolute effective weight  = 1.3694604582
total numerator  = 3.0480380974; total absolute effective weight  = 3.4427090973
score = 3.0480380974 / 3.4427090973 = 0.8853603401
```

The scalar-only weighted mean is 0.809636. Eight present tropes all have positive weights, so their component mean is 1.0; they supply 39.78% of the denominator and raise the combined mean to 0.88536. This is a decomposition of the existing formula, not a proposed alternate scorer.

Largest positive numerator terms, after candidate confidence, redundancy, and catalog-prevalence discounts:

| Factor | Learned weight | Effective weight | Similarity | Numerator contribution | Contribution / total denominator |
|---|---:|---:|---:|---:|---:|
| found_family | 0.472727 | 0.292860 | 1 | 0.292860 | 0.085067 |
| war_story | 0.363636 | 0.283518 | 1 | 0.283518 | 0.082353 |
| multiple_fantasy_species | 0.290909 | 0.260872 | 1 | 0.260872 | 0.075775 |
| violence_frequency | 0.424242 | 0.289382 | 0.757576 | 0.219229 | 0.063679 |
| intellectual_weight | 0.331818 | 0.172114 | 0.918182 | 0.158032 | 0.045903 |
| urban_fantasy_setting | 0.145455 | 0.139778 | 1 | 0.139778 | 0.040601 |
| violence_intensity | 0.242424 | 0.181523 | 0.757576 | 0.137517 | 0.039944 |
| noir_detective_structure | 0.145455 | 0.132092 | 1 | 0.132092 | 0.038369 |
| message_intensity | 0.254545 | 0.165144 | 0.754545 | 0.124609 | 0.036195 |
| morally_grey_protagonist | 0.145455 | 0.119084 | 1 | 0.119084 | 0.034590 |

These are additive numerator terms and normalized components, not causal score changes from deleting a factor: deleting one would also change the denominator. Full factors are in `analysis.txt`.

The attribution is concrete. Found family is supported by nine positive training books across several series. War story is supported by Ender's Game, Fourth Wing, and Ruthless Vows. Multiple fantasy species includes Magic Bites among its five positive supports. Urban fantasy, noir detective structure, and morally grey protagonist are supported by the liked Magic Bites and A Questionable Client. The latter is a standalone in the supplied catalog, so those two are separate clusters under the existing series-deduplication rule. That is a description of the input, not a bibliographic correction proposal.

For violence frequency, the positive weighted mean is 0.757576 versus negative mean 0.333333, producing weight 0.424242. Intellectual weight has positive mean 0.418182 versus negative mean 0.75, producing weight 0.331818. Magic Burns fits both fairly well.

Conversely, the learned negative tropes are second_chance_romance, cursed_protagonist, parallel_universe_or_multiverse, dragons, slow_burn_romance, enemies_to_lovers, and forbidden_love. **Magic Burns has none of them in this catalog.** Absent tropes do not enter its numerator or denominator. Daughter of No Worlds does contain enemies_to_lovers and forbidden_love, producing negative effective terms of −0.253134 and −0.177251, respectively. This helps explain the difference between the two held-out negatives under the same profile.

## Where the failure enters, and why no veto fires

`profile.build_profile()` builds ordinal positive means / nominal positive modes, and learns scalar importance from positive-negative separation. Tropes use signed frequency differences. Osnat's training negatives are only **The Midnight Library and When the Moon Hatched**. Her five neutral ratings do not supply either positive or negative preference evidence.

This profile does not encode a strong mismatch for Magic Burns. For example, its plot-driven, hard-magic, understated-romance values differ from the nominal centroid, but `drive`, `magic_system_hardness`, and `romance_tone` each have learned weight zero. The emotional-resolution mismatch has effective weight only 0.019956. The largest scalar loss is violence frequency at 0.070153; pace shape loses 0.069852. No individual loss exceeds the explanation's strict `> 0.1` display gate. Thus `mismatches=[]` does **not** mean every field is a perfect match.

`validated_dealbreaker_fields()` returns empty. Each side needs at least three observations; Osnat has two negatives before any field-specific missing/confidence exclusions. All 87 inspected scalar/trope separation calls are sample-ineligible. Fallback flags require magnitude >=0.3 and none qualifies. Even the validated magnitude threshold of 0.15 is above this candidate's largest mismatch. There is no supported claim that an existing strong dealbreaker was detected but accidentally ignored.

All stages have the same unrounded score: base, series repeat, veto, trajectory, diversity, cold start, and user rules. Series repeat only looks for disliked same-series books; neither negative is in Kate Daniels. Liking Magic Bites supplies profile evidence and eligibility, **not a separate same-series score bonus**. No trajectory penalty applies. The calibrated Poor threshold (0.385076) changes labeling, not ranking.

The strongest diagnosis is therefore **profile/data representation fails to distinguish this hated sequel from attributes of books she liked**. I found no evidence that the centroid was computed incorrectly. Calling it “miscalibrated” as a statement about her true taste would go beyond the data; calling the candidate scorer erroneous would contradict the reproduced arithmetic. The sparse negative sample and positively supported candidate tags explain the observed score without either claim. The known empty-validation P3 issue is present, but explaining this case solely as a disabled veto would be incomplete.

## Pattern and comparison with Mathias

| Training evidence in assigned splits | Osnat | Mathias |
|---|---:|---:|
| Total resolved ratings | 23 | 132 |
| Positive ratings | 16 | 104 |
| Negative ratings | 2 | 19 |
| Neutral ratings | 5 | 9 |
| All independent catalog series/standalone clusters | 15 | 65 |
| Positive clusters | 10 | 45 |
| Negative clusters | 2 | 18 |

Sign-specific cluster counts overlap and should not be added. Osnat's positives comprise 14 fantasy and two SF books; both negatives are fantasy. Mathias has 12 fantasy and seven SF negatives. Series deduplication is already active, so this is not an assertion that four ACOTAR or four positive Harry Potter ratings count as four independent series. Osnat's raw file has 153 ratings, but the assigned curated usable list has 30; 31 raw titles match the current tagged catalog. Sweep of the Heart (liked) is the sole additional match, and was not silently added to this experiment.

Mathias's held-out negatives rank as follows: Interview with the Vampire #282/661 (0.5508), Skyward #473 (0.4555), The Wise Man's Fear #511 (0.4320), Royal Assassin #531 (0.4206); Assassin's Quest is series-position excluded (audit score 0.5298). His eligible positives rank #28, #61, #122, and #463. The final one, Old Man's War, falls below Interview with the Vampire: separation is strong, not perfect.

Using actual production final scores for eligible positive-negative pairs gives Osnat **2/4 correct (50%)** and Mathias **15/16 (93.75%)**. These are explicitly eligible-pool pair counts, not the separate evaluation-policy `pairwise_accuracy()` scorecard metric. Excluded titles are absent from both counts. Mathias also has an empty validated set, but for a different reason: separation strength does not reach 0.65 (largest inspected magnitude 0.359001), rather than an across-the-board lack of three negatives. His better ranking does not come from an active veto.

The assigned Osnat split has only two negatives: Magic Burns is the top-list outlier, while Daughter of No Worlds is below both eligible positives. That alone cannot establish a broad population pattern. As a sensitivity check, I separately withheld each of her four usable negative titles, training on the other 29 usable ratings each time:

| Single negative held out | Rank / 692 | Score |
|---|---:|---:|
| Magic Burns | 2 | 0.9057 |
| When the Moon Hatched | 64 | 0.7578 |
| Daughter of No Worlds | 101 | 0.7445 |
| The Midnight Library | 296 | 0.6070 |

All four probes still have empty validated sets and no candidate flags. **These use different profiles and must not be mixed into the original split or compared as a common-profile accuracy metric.** They show that Magic Burns remains exceptional even with three other negatives available, and that negative rejection is not uniformly reliable for the other titles either. Low in-training scores for The Midnight Library (0.0175) and When the Moon Hatched (0.0648) in the original profile are resubstitution results, not evidence of generalization. The leave-one-out results expose that distinction.

## Confidence and falsification

- **High confidence, current snapshot:** ranking, exact factor arithmetic, absence of downstream boosts, and sample-gated empty validation. Falsified by a same-input independent run that yields materially different scores/stages, or by evidence that the captured catalog/ratings differ from the intended inputs. Saved snapshot and scripts make that check possible.
- **High confidence, conditional on current tags:** the learned positive attributes and lack of a learned negative match explain why this candidate scores highly. Falsified by an overlooked, materially weighted negative factor in the same scoring path, or failure of the numeric reconstruction. Neither occurred.
- **Moderate confidence, generalization diagnosis:** sparse and unrepresentative negative evidence plus coarse preference representation explain the inability to distinguish this book. The persistence in the single-negative holdout strengthens this; it is not proof that sparse data alone causes every error. A substantive error in this book's tags, a different intended rating, or rater-provided reasons already represented by a strong reliable field would change the interpretation.
- **Inconclusive, reader-level cause and prevalence of the problem:** no textual reason accompanies Osnat's hate rating, and four negatives are too few to estimate a stable failure rate. Evidence from additional independent negatives could falsify any broad claim that this is systematic. The defensible current result is a severe, persistent Magic Burns outlier plus broader warning signs, not “every hated book ranks at the top.”

No engine changes, migrations, retagging, DB writes, commits, pushes, or fix proposals. Only uncommitted report/evidence artifacts were produced.
