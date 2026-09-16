# CODX current task

**Assigned**: 2026-09-16, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 8 — migrate `audit_book_score()` onto `score_candidate(..., policy="audit")`

`main` is now at commit `c5de5b6` (your clone was last synced at
`96f3bb7` for Task 6/`e531320` for Task 7 — pull first; note two CLDA
tagging batches and a local/hosted drift fix landed on top of A5, none
of which touch `scripts/recommend.py` or `scripts/scoring_tests.py`).
A5 landed at commit `efe80d3`: `scoring_tests.py`'s `_full_score()` now
calls `score_candidate(..., policy="evaluation")`. Read
`docs/scoring-test-protocol.md`'s "A5: `_full_score()` migrated onto
`score_candidate()`" entry before starting. Note: this task is NOT one
of `docs/TODO.md`'s explicitly named Phase A steps (A1-A5 are complete)
— it's a follow-up decided separately, migrating the one remaining
production caller. Name your report without an "A6" prefix:
`docs/codx-reports/2026-09-16-audit-book-score-migration-proposal.md`
(or a same-day-dated equivalent if it runs past midnight).

Scope: migrate `audit_book_score()` (`scripts/recommend.py`, currently
around lines 3764-3881) to call `score_candidate(catalog, book_id,
centroid, weights, id_to_magnitude, policy="audit", validated_fields=
validated_fields, series_dna=series_dna, field_prevalence=
field_prevalence, trope_prevalence=trope_prevalence,
poor_threshold=poor_threshold, cold_start=csw,
normalized_rules=normalize_user_rules(user_rules), top_n=100)` — where
`book_id = title_to_id[title]` — instead of its own inline
`score_book() -> _apply_series_repeat() -> _apply_dealbreaker_veto() ->
_apply_series_trajectory_penalty() -> cold-start blend ->
apply_user_rules()` chain and its own direct `explain_book()`/
`dealbreaker_flags()` calls. This is caller migration of an
already-decided design (the same canonical scorer landed in A2),
following the exact same posture as Tasks 5-7.

Required restructuring: `audit_book_score()` currently computes
`poor_threshold` INLINE, inside the final return statement's ternary
(`user_calibrated_poor_threshold(...)`). Since score_candidate()
requires it as an upstream input, pull that call out into an earlier
local variable, computed before the score_candidate() call — same
value, same arguments, just moved earlier in the function.

Precise pipeline reconstruction — get this exact, it's the trickiest
part of this migration. Today's `pipeline` list has 6 entries built
from local variables; map each to the corresponding UNROUNDED
`result["scores"]` field, keeping the exact same stage labels,
`round(x, 4)`, and `abs(x - y) > 1e-9` "changed" comparisons:

  1. raw score_book()              <- result["scores"]["base"]
  2. after _apply_series_repeat()  <- result["scores"]["after_series_repeat"]
     changed vs. stage 1
  3. after _apply_dealbreaker_veto() <- result["scores"]["after_veto"]
     changed vs. stage 2
  4. after _apply_series_trajectory_penalty() <- result["scores"]["after_trajectory"]
     changed vs. stage 3
  5. after cold-start blend        <- result["scores"]["after_cold_start"]
     changed vs. stage 4 (i.e. vs. after_trajectory)
     "cold_start_weight": round(csw, 3) — csw is your own already-computed
     local variable, not read from result
  6. after user_rules              <- result["scores"]["final"]
     changed vs. stage 5, OR result["excluded_by_user_rule"]
     "excluded": result["excluded_by_user_rule"]

IMPORTANT: the audit policy never applies a diversity blend —
`result["scores"]["after_diversity"]` for this policy just carries
`after_trajectory` forward UNCHANGED (per score_candidate()'s own
documented "skipped stage carries forward its input unchanged"
contract). Stage 5's "changed" comparison must diff `after_cold_start`
against `after_trajectory` (stage 4), NOT against `after_diversity` —
even though they hold the same value for this policy, only one of them
is the conceptually correct comparison, and a future score_candidate()
change to how skipped stages are represented should not silently break
this if you picked the right one now. There is no "after diversity"
stage in audit's pipeline today and this migration must not add one.

matches/mismatches/dealbreaker_flags: read `result["matches"]`,
`result["mismatches"]`, `result["dealbreaker_flags"]` (the same raw
(label, magnitude) pairs `explain_book()`/`dealbreaker_flags()` already
produced) instead of calling those functions directly. Feed them into
the EXISTING, unchanged `build_rows()` helper and the existing
`[(f, round(m, 3)) for f, m in dealbreaker]` line exactly as today —
this task changes where their raw inputs come from, not the
presentation logic itself. Pass `top_n=100` explicitly to
score_candidate() (matching today's explicit `explain_book(...,
top_n=100)` call) — don't rely on score_candidate()'s own audit
default matching by omission.

match_label / excluded_by_user_rule / final: use `result["match_label"]`,
`result["excluded_by_user_rule"]`, and `result["scores"]["final"]`
directly instead of recomputing them.

A real, pre-existing discrepancy — flag it in your report, do NOT fix
it as part of this task: `audit_book_score()`'s own docstring lists
`"series_note": str` in its documented return shape, but its ACTUAL
current return dict never includes a `series_note` key at all (verify
this yourself by reading the function). CLDO already checked: nothing
anywhere reads `audit(...)["series_note"]` — not `print_score_audit()`,
not `tools/dogfood/app.py` (the only real caller) — so this is a
dormant documentation/behavior mismatch, not a live bug. score_candidate()'s
audit policy DOES compute `result["series_note"]` correctly. Adding it
to `audit_book_score()`'s returned dict now that it's trivially
available would be a real behavior change bundled into what should be
a byte-identical migration — don't do it. Whether to actually fix this
is a separate decision for CLDO/the repo owner later.

Hard constraint: `audit_book_score()`'s external return dict — every
one of its 11 keys, every value, every rounding — must be
byte-identical to today's for every input, including that dormant
`series_note` omission.

Do NOT touch: `_series_deduped_id_to_magnitude()`, `build_rows()`,
`_audit_attribute_nominal_or_trope()`, `_audit_attribute_ordinal()`,
`series_repeat_worst_similarity()`, or `print_score_audit()` — all
audit-only presentation/attribution helpers with nothing to do with
score_candidate(). Confirm all six byte-for-byte unchanged, the same
way you did for explain_book() etc. in Task 6.

IMPORTANT, verify yourself rather than assuming by analogy:
`audit_book_score()` is called from exactly one place in the whole
codebase — `tools/dogfood/app.py` (a Streamlit debugging tool), with
NO automated test coverage anywhere (CLDO already checked: zero hits
for `audit_book_score(` in scripts/scoring_tests.py, only comments —
same situation as Task 6's explain_match(), not Task 7's _full_score()).
Confirm this yourself. This means the canonical suite gives ZERO
regression coverage for this migration, and there is no live
"does the dogfood tool still work" check available to you in this
sandboxed task either — the entire correctness claim rests on your own
dedicated direct-comparison harness. Build one at least as thorough as
Task 6's: bit-exact comparison of the COMPLETE returned dict across
every book in the catalog, crossed with multiple real raters and a
reasoned set of genre/format/user_rules combinations (include both an
`exclude` and a `reduce` rule case), with explicit required coverage
of: a real dealbreaker flag, a real series-repeat interaction, a real
series-trajectory-penalty change, and a nonzero cold-start blend.

AST-diff requirement: confirm `audit_book_score` is the ONLY function
in scripts/recommend.py whose AST changes. Explicitly name and confirm
byte-for-byte unchanged: `_series_deduped_id_to_magnitude`, `build_rows`
(it's a nested closure inside audit_book_score() itself — confirm its
own source text is unchanged even though it's not a top-level AST
node), `_audit_attribute_nominal_or_trope`, `_audit_attribute_ordinal`,
`series_repeat_worst_similarity`, `print_score_audit`,
`score_candidate`, `recommend`, and `explain_match`.

As always: implement and validate in your own clone, uncommitted;
revert to exact HEAD bytes and hash-verify afterward; no commit, push,
or hosted write.
