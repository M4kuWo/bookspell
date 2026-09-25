# Book DNA — related table & mechanism contracts

Current-state documentation for tables/mechanisms that grew out of
`book-dna.md`'s former "Future fields backlog" but are actually BUILT
and in production use — split into their own file 2026-09-25
(`docs/codx-reports/2026-09-25-book-dna-split-review.md`) specifically
so a UI/read consumer (or anyone touching these tables) doesn't have to
find current facts inside a document titled "backlog." Read the
relevant section here before building against any of these tables.
Original deferred-idea rationale/history for each is preserved verbatim
in `book-dna-decisions.md`, linked from each section below — this file
states current facts only, verified directly against migrations/live
code as of 2026-09-25 (not re-derived from old prose, which in more
than one case below had gone stale).

## `audiobook_editions`

One-to-many per book (a book can have a standard audiobook AND a
separate GraphicAudio full-cast dramatization AND multiple
re-releases). Original rationale: `book-dna-decisions.md`'s deferred/
built entry (kept there for the full narrative — the bug it fixed,
why one-to-many was needed).

Schema (`supabase/migrations/20260905260000_audiobook_editions_table.sql`,
plus later alterations below):
- `book_id` — FK to `books`.
- `edition_type` — **real current CHECK-constrained values:
  `standard`, `dramatized_full_cast`, `abridged`, `other` (4 values).**
  **Correction (verified 2026-09-25 directly against the live CHECK
  constraint and real usage in `20260909130000_ingest_audible_originals.sql`,
  which inserts Audible Originals as `edition_type = 'dramatized_full_cast'`):
  CLAUDE.md's v1-web-app section currently lists a 5th value,
  `audio_original`, as an `edition_type` — this is wrong.
  `audio_original` is a value of `books.work_type` (a different
  column, different table — see the `work_type` section below), not
  `audiobook_editions.edition_type`. Flag this for CLAUDE.md to be
  corrected; not fixed as part of this split (out of scope for a doc
  reorganization to also hand-edit CLAUDE.md's substantive claims
  beyond routing references).**
- `narrators` — `text[]`, a **flat array of names, no character-role
  mapping** (a known, documented gap, not a bug — see
  `book-dna-decisions.md` for the "movie-credits-style cast list" idea
  this is deferred from).
- `production_company`, `runtime_minutes`, `source_url`,
  `last_verified_date`.
- `release_status` — `fully_released` / `in_progress` / `announced`
  (default `fully_released`), plus `parts_released`/`parts_total` —
  added because dramatized full-cast productions (GraphicAudio in
  particular) release EPISODICALLY over months, not all at once (Wind
  and Truth's GraphicAudio adaptation: 5 parts, late 2025 to March
  2026). A lookup mid-release would otherwise correctly find "yes, a
  GraphicAudio exists" while badly misrepresenting how much is
  actually available to listen to. Same "refreshed periodically, never
  set once at tagging time" pattern as `series.status`/`book_count`.
- `release_date_start`/`release_date_end` (added
  `20260918231000_audiobook_editions_release_date_range.sql`) — a
  RANGE, not a single date: a single-release edition gets both columns
  set to the same date; a multi-part release gets a genuinely
  different start/end, with `release_date_end` left **null** until
  `release_status = 'fully_released'` (the end date isn't knowable
  before then). This is a **documented sourcing rule, not a
  database-enforced CHECK constraint** — the migration only adds
  nullable columns and column comments; nothing in Postgres itself
  prevents violating the convention.

**Known, currently-unpopulated gaps** (not bugs, just not-yet-done
research work, queued to `.claude/skills/tag-audiobook-editions/SKILL.md`):
`release_date_start`/`release_date_end` are null on every existing row
as of the migration that added them; a separate `runtime_minutes` gap
(306 rows as of 2026-09-18) is tracked in `docs/TODO.md`.

**Data-quality history, current status verified 2026-09-25**: CLAUDE.md
currently describes "some GraphicAudio full-cast productions mislabeled
`edition_type = 'standard'`" as a known, flagged-but-NOT-fixed issue.
**This is stale.** `docs/TODO.md` records this was swept 2026-09-18 and
closed — no confirmed mislabeled rows were found catalog-wide (the one
originally-suspected row, *A Court of Frost and Starlight*, was already
correctly tagged; the earlier report was a local-Postgres-drift
artifact, not a real hosted data issue). The TODO item itself notes
this was a one-time sweep, not a standing guarantee — re-check after
any future GraphicAudio/BBC batch. Flag CLAUDE.md's own audiobook
section for a matching correction; not made here (see the `edition_type`
correction note above for the same reasoning on scope).

Tier A `book_dna` columns (`narrator_cast`, `audiobook_length`) are
sourced FROM this table as part of ordinary `tag-catalog-batch` tagging
— see `book-dna.md`'s "Audiobook-native" category for the full
Tier A/Tier B split and the `narrator_cast` backfill/`multi_narrator`
value history.

RLS/access: `20260913100000_expose_audiobook_editions_to_app.sql`
(`authenticated`) and `20260913110000_grant_audiobook_editions_to_anon.sql`
(`anon`) — both roles needed (verified via real REST calls under each,
not just a grants check); see CLAUDE.md's "new public-catalog-style
table" rule, itself written after this table shipped with neither
grant and broke the book-info modal silently.

Consumers: `.claude/skills/tag-audiobook-editions/SKILL.md` (writes
this table), `app/`'s book-info modal (reads it for display).

Full dated build history (the 2026-08-29 through 2026-09-18 sequence
of what was added when and why) preserved in `book-dna-decisions.md`.

## `books.work_type`

Real, built column on `books`. **Current CHECK-constrained values:
`novella`, `novel`, `audio_original` (3 values — verified directly
against `supabase/migrations/20260829080000_add_work_type.sql`
(novella/novel) and `20260907140000_work_type_audio_original.sql`
(widened to add `audio_original`, for a full-cast audio drama with NO
print/ebook counterpart at all, e.g. an Audible Original).** No
`novelette` value — this catalog is published SFF books, not
magazine-length short fiction. Deliberately NOT computed from
`page_count` (checked directly, an unreliable discriminator across
this catalog — see `book-dna-decisions.md` for the specific
counter-examples). Set manually from real-world publishing
classification.

Nothing in `scripts/scoring/` currently reads `work_type` for scoring
(confirmed true as of the `audio_original` migration; not re-checked
during this split — verify again if this matters for a specific task).

Original rationale and the specific novella-classification evidence
(Murderbot Diaries, *Edgedancer*, *This Is How You Lose the Time War*)
preserved verbatim in `book-dna-decisions.md`.

## Omnibus/compilation editions — current operational rule

The real data-model fix (a proposed `books.edition_kind` field) is
**not built** — full proposal in `book-dna-decisions.md`'s deferred
proposals. The CURRENT operational rule, already in effect regardless
of that missing field:

**Skip tagging any book that duplicates an already-tagged book's
content at the same series position** (an omnibus/compilation
edition sitting alongside the individual volumes it collects, both in
the `books` table under the same series). Don't force a `book_dna`
value in, and don't count it as a real tagging gap — Series DNA needs
>= 2 tagged books per series, and these rows are meant to sit untagged
by design, not by oversight. This connects to CLAUDE.md's broader
catalog-scope/archiving policy (`books.archived`/`archived_reason` for
genuinely out-of-scope rows) — an omnibus row is a different case (a
real, in-scope catalog entry, just not one that needs its own DNA tags)
from an archived row, don't conflate the two treatments.

Separately, not a schema gap at all: a real future series entry that
simply hasn't been published yet (e.g. an announced-but-unreleased
book) has nothing to tag or read — skip and re-check once actually
published, same as any other legitimately-not-yet-existing content.

## Series DNA

Built aggregation over already-tagged `book_dna` rows, grouped by
`series_id`, ordered by `position_in_series` — NOT a fresh tagging
pass. **Current function locations, verified 2026-09-25 (the original
backlog entry says `recommend.py`, which is stale since this project's
Phase A/B scoring-engine refactor split that file into
`scripts/scoring/` submodules):**
- `compute_series_dna()` — `scripts/scoring/series.py`.
- `describe_series_trajectory()` — `scripts/scoring/series.py`.
- `series_dnf_outlook()` — per-user (unlike the objective trajectory
  above): compares how well the CURRENT book in a series scores
  against a specific user's profile vs. the NEXT one.
- `explain_match()`'s `series_note` field reuses this same machinery to
  pair a book's explanation with an objective caveat about how the
  series shifts over its run.

`books.series_id` always points at a **leaf** series, never a parent/
umbrella one — this is what lets grouping by `series_id` compute
trajectories only at the level a reader actually commits to reading in
order, with no special-casing needed for shared universes or
tonally-split parent series (Mistborn Era One/Two, not "Mistborn").

Full original rationale, the shared-universe scope question and its
resolution, and per-series verification examples (Harry Potter,
Percy Jackson, LOTR, Murderbot) preserved verbatim in
`book-dna-decisions.md`.

## Confidence + source layer

Built data contract, used directly by tagging and QA work (including
every HIGH_RISK_FIELDS confidence QA pass CODX has run) — not an
optional future idea.

- `book_tropes.confidence`/`.source` — directly on the join row.
- `book_field_confidence` (`book_id`, `field_name`, `confidence`,
  `source`) — a side table for scalar `book_dna`/`books` fields
  (avoids ~29 extra always-present columns on the wide `book_dna` row).
- **Source values**: `ai_inferred` (the vast majority — an LLM judgment
  call), `verified_external` (a real citable authority, e.g.
  `work_type`'s Hugo Award backing), `manual_review` (a deliberate
  editorial correction), `community_tagged`/`community_confirmed`
  (reserved for a future community-tagging feature, not populated).
- **What a missing row means — verified directly against
  `scripts/scoring/calibration.py`'s `get_confidence()` 2026-09-25**:
  absence of a row means "unassessed," and defaults to **full trust
  (1.0)** — EXCEPT for fields in `HIGH_RISK_FIELDS` (see CLAUDE.md's
  "Data quality / tagging" section for the current field list), which
  default to **`HIGH_RISK_FIELD_DEFAULT` (0.85)** instead when
  unassessed — a deliberately lower default given this project's
  documented track record of confident-but-wrong tags specifically on
  those fields. This is the RAW, undiscounted accessor, used for
  display/audit — never silently zeroed.
- **`scoring_confidence()`** (same file) is the accessor actually used
  in scoring/weight-learning math: `get_confidence()`'s value, floored
  to **0.0 below `MIN_CONFIDENCE_TO_COUNT` (0.3)** — a tag this
  uncertain is excluded from contributing at all, not just discounted.
  `book_field_confidence`/`book_tropes.confidence` was never
  retroactively fabricated for tags that predate this system — absence
  is absence, not backfilled to look falsely precise.
- Wired into scoring: a field/trope's effective weight for a specific
  book is discounted by its confidence before contributing (both the
  numerator and the total-weight denominator, so this is a "counts for
  less" effect, not a bias toward match or mismatch).

Full original rationale, the specific verification example (The Bands
of Mourning), and the two originally-proposed-but-not-built uses
(confidence as a re-research triage signal; community-tag-correlation-
based confidence raising) preserved verbatim in `book-dna-decisions.md`.

## Post-read/DNF "why didn't it work" feedback

Built behavior: reuses a book's own already-tagged tropes/fields (via
the explanation layer's `describe()`) as a dynamic checklist — "here's
what we tagged this book with, tell us which of these worked against
you" — plus a small fixed set of `NEUTRAL_FEEDBACK_REASONS` (wasn't the
mood, didn't click with characters, lost interest, life got in the way)
that produce no calibration signal at all.

**Important distinction, easy to get wrong**: only TROPE selections
translate into a `fatigue_overrides` entry. Field-level selections
(e.g. "overall_pace was the problem") deliberately do NOT — because
`fatigue_overrides` flips a field's weight relative to the user's own
centroid ("avoid being similar to your average"), a different claim
than "avoid this specific book's slow-pace value." The correct existing
mechanism for a field-level dislike is just rating the book itself
hated/disliked — `build_profile()` already learns whether that field is
a real discriminator once it recurs across several disliked books.
Field-level selections are still captured (via `book_feedback_options()`)
for triage/logging value, just not wired into calibration.

Full original rationale and the real end-to-end verification example
(*A Clash of Kings*'s `court_intrigue` dislike reason correctly
demoting/promoting real candidates in a live `recommend()` call)
preserved verbatim in `book-dna-decisions.md`.
