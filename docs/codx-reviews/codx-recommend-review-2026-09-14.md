# CODX review: recommend.py, 2026-09-14

Review/proposal only. Reviewed commit: `b3b6ff3d1c3d2d036596adc1c2355fc629965855`.
Implementation scope: `scripts/recommend.py`. No engine changes, commits,
or hosted writes were made. Findings below were reproduced by importing the
existing module with `python3 -B` and passing synthetic in-memory catalogs;
no database connection was invoked. These establish failure scenarios, not
their frequency among current users. The full database-backed scorecard was
not run; this review does not claim a validated scoring change.

## Environment checks

1. PASS: working directory is `/Users/mathiaskurin/Documents/bookspell-codex`,
   with its own `.git` directory, distinct from `~/Documents/bookspell`.
   `git config --get core.hooksPath` returned `.githooks`.
2. PASS: inspected process environment names and values without printing
   values. No `DATABASE_URL`, Supabase service/secret-key variable, `sb_secret_`
   key, or JWT with a `service_role` claim was detected.
3. PASS for push prevention: `git push origin main` exited 1 with
   `BLOCKED: this clone must never push.` No push succeeded.
   Documentation correction: the hook does **not** run before all network
   activity. The first attempt failed resolving GitHub in the sandbox before
   reaching the hook; the network-enabled retry reached the hook and blocked.
   This test establishes push prevention, not absence of network/auth activity.
4. PASS: REST GET `books?select=id,title&limit=1`, using only the public key
   from `app/shared.js`, returned HTTP 200 and a row titled `The Golden Compass`.
   The sandbox DNS restriction required a network-enabled retry here too.

Read root AGENTS.md and the local clone's full CLAUDE.md, including Persona
system. Consulted schema/backlog/history and scoring-test-protocol.md,
particularly the September 11 fixes, confidence policy, and trajectory and
experimental-variant decisions. Existing accepted tradeoffs are not proposed
for reconsideration here. The conversion skill's schema/scoring boundary
also confirms that implementing engine changes belongs to CLDO.

## Findings

### 1. Production audit crashes when its negative-side ordinal evidence is only neutral ratings

Location: `scripts/recommend.py:3534`, division at `:3543`.

`_audit_attribute_ordinal.summarize(-1)` accepts magnitude zero because
`(mag > 0) == (sign > 0)` is true for both zero and negative magnitudes on
that side. A tagged neutral book makes `positions` nonempty, but its total
weight is zero. The subsequent division raises `ZeroDivisionError`.

Reproduction: create six standalone books titled Loved, Neutral, Candidate,
Other1, Other2, Other3, each with matching `id`/`author` strings. Set
`overall_pace='fast'` on Loved and Candidate, and `'slow'` on the rest.
Call `audit_book_score(catalog, {'Loved': 'loved',
'Neutral': 'it_was_okay'}, 'Candidate')`. This raises at line 3543 through
`build_rows`. The extra unrated books keep the pace contribution above the
audit display threshold; they are not training evidence.

This is the same nonempty-list/zero-total-weight failure shape as September
11, now caused by neutral ratings. With additional genuinely negative
evidence, neutral entries also incorrectly inflate the reported negative `n`.
Proposed correction for CLDO: exclude zero magnitudes from both audit groups
and guard the total before dividing. No weight/threshold redesign is needed.

### 2. Production dealbreaker validation counts confidence-zeroed tags as real evidence

Locations: `scripts/recommend.py:2395`, `:2430`, and `:2457`.
Consumer: `validated_dealbreaker_fields` at `:2528` and veto at `:2840`.

The ordinal, nominal, and trope separation helpers never consult
`scoring_confidence`. Consequently, evidence below the 0.3 floor can satisfy
the three-observations-per-side requirement and create a validated field.
This can affect production scores even though `build_profile` correctly
ignores the same nominal tags.

Reproduced nominal case: three liked standalones tagged `understated` and
three disliked standalones tagged `melodramatic`. Only one book per side has
confidence 1.0; the other two have confidence 0.2. The learned romance weight
is 0.5 based on the credible pair. Validation nevertheless returns
`{'romance_tone'}`, treating all six tags as evidence. With a candidate
tagged `melodramatic` and four matching tropes weighted 0.5 each, raw score
0.800 is capped to 0.549. Replacing just the ignored 0.2-confidence nominal
tags with `None` leaves the learned nominal profile unchanged but produces
an empty validated set, so the veto does not fire.

Proposed correction for CLDO: enforce the confidence-floor contract in
validation evidence and its sample gate. This is separate from the already
documented genre-scoping simplification and rejected adaptive thresholds;
the report does not propose changing those decisions. The numeric veto
example exercises the nominal branch; ordinal/trope confidence omissions
were also confirmed by code inspection.

### 3. A confidence-zeroed series endpoint still penalizes a production recommendation

Locations: `scripts/recommend.py:631` and `:646` construct trajectories;
`:2774` consumes their divergence without endpoint confidence.

`compute_series_dna` accepts tags regardless of confidence and retains only
their values in the trajectory. The scoring penalty therefore cannot tell
whether the endpoint was too uncertain to count as evidence.

Reproduction: a two-book series has entry #1 tagged
`narrative_closure='requires_series', romance_tone='understated'` and #2
tagged `romance_tone='melodramatic'` at confidence 0.2. For a centroid of
`understated` and romance weight 0.5, applying the trajectory stage to an
incoming score of 0.800 returns 0.560, the full 30% penalty. Replacing only
the uncertain endpoint tag with `None` returns 0.800. Candidate confidence
is not the issue: the ignored evidence belongs to a different series book.

Proposed correction for CLDO: exclude below-floor endpoint evidence from
scoring trajectories, or retain the metadata needed to enforce the floor
when applying the penalty. Preserve the existing entry-point and
requires-series gates. This does not challenge the September 4 decision to
use a trajectory penalty; it concerns which evidence may activate it.

### 4. Four experimental profile builders retain the September 11 division bug

Locations (liked-side / disliked-side divisions):

- `build_profile_trope_shrinkage`: `scripts/recommend.py:1235` / `:1239`.
- `build_profile_trope_backoff`: `scripts/recommend.py:1357` / `:1361`.
- `build_profile_series_field_dedup`: `scripts/recommend.py:1532` / `:1539`.
- `build_profile_series_field_dedup_protected`: `scripts/recommend.py:1677` / `:1684`.

Each nominal loop tests list emptiness without removing evidence whose
confidence-adjusted magnitude is zero. Reproduced all eight exceptions with
two standalone books, ratings +1 and -1, romance tags understated and
melodramatic, setting the tested side's confidence to 0.2 and the other to
1.0. Each function raises `ZeroDivisionError` at the listed line.
Production `build_profile` handles both cases: no nominal centroid when
liked evidence is zeroed; nominal weight 0.3 when only disliked evidence is
zeroed.

Impact is limited to experimental invocations and future comparison runs;
these functions are not wired into normal recommendations. Proposed
correction for CLDO: propagate the existing positive-effective-magnitude
guard before reusing them. This is not a recommendation to land any of the
deferred algorithms. `build_profile_per_value`'s deliberately unupdated
confidence behavior is documented in the protocol and is not re-flagged.

## Verified non-findings and handoff

Production `score_book` and `explain_book` skip missing nominal fields;
production `build_profile` guards zeroed nominal evidence. No remaining
instance of the original missing-nominal-as-full-mismatch bug was confirmed
in those paths. Trope frequency denominators intentionally remain
undiscounted under the September 5 policy, so that is not a finding.

This uncommitted report can be read directly from the CODX clone or copied
into CLDO's session. A git fetch alone will not transfer an uncommitted file.
Any implementation remains a proposal for CLDO, followed by the project's
required scoring checks before landing.
