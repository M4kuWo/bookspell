# Project TODO

**This file IS the project's roadmap** -- there is no separate
"roadmap" document anywhere in this repo. If you're looking for where
the roadmap lives, it's here (clarified 2026-09-24 after the repo owner
asked and there wasn't a clean answer).

A prioritized, cross-cutting task backlog -- distinct from the two docs
that already exist and cover different ground:

- `docs/project-log.md` is append-only HISTORY (what already happened,
  dated, never rewritten).
- `docs/schema/book-dna-decisions.md`'s "Deferred / open proposals"
  section is specifically SCHEMA/FIELD ideas (new DNA values, deferred
  vocabulary) -- moved out of `book-dna.md` itself during the
  2026-09-25 core/companion-file schema split (see that file's own
  "Schema map" section for the full 4-file structure).
- **This file** is forward-looking and mutable: things we've decided
  are worth doing, ordered by priority, checked off or re-ordered as
  the project moves. Update it directly (not append-only) as work
  starts/finishes/gets reprioritized. Where an item is really a schema
  idea, it stays tracked in `book-dna-decisions.md` and this file just
  points to it rather than duplicating the writeup.

**Keep every item short.** A checkbox, a bold one-line title, and 1-3
lines of *current* status/next-step -- that's it. The full story (what
happened, why, what was verified) belongs in `docs/project-log.md` as a
dated entry; this file just points to it (`see project-log.md's <date>
entry`). Don't paste UPDATE paragraphs in here as work progresses --
log the update there, then come back and just refresh this item's one-
or-two-line summary. See CLAUDE.md's "Logging" section for why this
matters (it drifted badly once already, full rewrite 2026-09-22).

**Closed items are one-line pointers (adopted 2026-09-28, CODX Task 25
lever D).** A finished item keeps its checkbox and title here, with its
full original text in `docs/TODO-completed.md` (history, not a task
queue, and not startup reading). Before reducing a completed item to an
archive pointer, inspect every phase and follow-up it mentions. Link each
unfinished phase to a live item or its authoritative tracker, retaining
its blocker or explicit deferral. Do not archive an unfinished phase
merely because the parent checkbox is checked.

Priority is P0 (do next) / P1 (soon, real value) / P2 (ongoing/routine)
/ P3 (blocked or parked -- not actionable right now, don't pick these
up without checking whether the blocker cleared).

**Token-economy note (2026-09-07)**: a heavy session today -- pace
future work accordingly. Cheap/quick items are ordered first within
each tier on purpose; the genuinely taxing ones (marked below) are
worth deferring to a later session rather than batching in for
"efficiency," which just concentrates cost instead of reducing it.

## P0

- [x] **Gate `book_length`/`audiobook_length` by listener format preference.** [Archived detail](TODO-completed.md#done-01).
- [x] **Set up a real database backup policy.** [Archived detail](TODO-completed.md#done-02).
- [x] **Bookspell v1 web app -- built and shipped.** [Archived detail](TODO-completed.md#done-03).
- [x] **`book_suggestions` admin view.** [Archived detail](TODO-completed.md#done-04).

*(Nothing currently open at P0 -- everything above shipped. Pull the next item down from P1 when something becomes genuinely urgent/blocking.)*

## P1

- [x] **Fresh-session context-load reduction -- all 3 CODX Task 21 recommendations done and measured.** [Archived detail](TODO-completed.md#done-05).

- [x] **Quantify the routing policy's real context-load gain.** [Archived detail](TODO-completed.md#done-06).
- [ ] **Context-load improvements (CODX Task 25) -- implementing A → C → D.** A (6 conditional CLAUDE.md sections moved to `docs/conventions/`, CLAUDE.md 8,893→4,440 words) + sub-agent-scoped B landed 2026-09-28; C (read-depth contract) and D (closed items → `docs/TODO-completed.md`, TODO 4,873→3,012 words) landed 2026-09-28. After-arm measured 2026-09-28: narrow routes −11% to −26%, heavy routes +19% to +104% (C's full-read rules now followed), quality 7/7 both arms. Repo owner kept C's full-read rules; CODX Task 26 (2026-09-28) found no lossless big saving; counter fixed and `scripts/read_full.py` added. **Open: repo owner decides whether to require `read_full.py` for full reads (a CLAUDE.md change)**; optionally confirm the fresh-session injection with 1 agent in a new terminal** (same 7 prompts, `docs/codx-reviews/context-load-e/`). See `docs/project-log.md`'s 2026-09-28 "six task-specific sections moved" and "read-depth contract landed" entries. Separate open item: `tag-catalog-batch` Step 4 still says batch inserts go straight to hosted, which conflicts with `docs/conventions/database.md` (flagged by CODX Task 25).

- [x] **A book Osnat hated ranks #4 of 695 in her real recommendations -- investigated 2026-09-23 by CODX (Task 17).** [Archived detail](TODO-completed.md#done-07).

- [x] **Fix `/recommendations` slowness.** [Archived detail](TODO-completed.md#done-08).

- [x] **Audiobook runtime/release-date schema landed; data backfill remains open (P3 below).** [Archived detail](TODO-completed.md#done-09).

- [x] **Self-host book cover images instead of hotlinking Hardcover's CDN.** [Archived detail](TODO-completed.md#done-10).

- [x] **Local/hosted `books.author` field drift.** [Archived detail](TODO-completed.md#done-11).

- [ ] **External AI consultation precedent -- ChatGPT ("Astra") full independent repo review, 2026-09-14 (parallel to CODX's code-level review).** Kept as a precedent for outside-persona review, not a one-off. Every point independently re-verified by CLDO against the codebase; original .docx not committed, record lives in `docs/project-log.md`'s 2026-09-14 entries.
  - Already built before the review (don't redo): Goodreads/reading-history import, "Why this recommendation?" match explanations.
  - Confirmed real and done since: spoiler-safety fix landed 2026-09-20 (collapsed "Spoilers" disclosure for tropes/content-warnings/`emotional_resolution`/`ends_on_cliffhanger`) -- the deeper per-series `spoiler_horizon` design was deliberately not built (needs reader-progress tracking this app doesn't collect).
  - Done since: `ranking_metrics()` + `rank_percentile_report()` landed 2026-09-22 in `scoring_tests.py` -- a product-surface check (does a held-out title literally land in the top-K a user would see), NOT an accuracy metric; `pairwise_accuracy()` remains the real taste-discrimination signal. See `docs/scoring-test-protocol.md`'s two matching 2026-09-22 entries (the landing, then a same-day correction on what the numbers actually prove) for the full reasoning -- worth reading both before citing a number from this. CI landed 2026-09-22 too (CODX Task 15, `.github/workflows/ci.yml`).
  - Done since: active-learning onboarding landed 2026-09-23 -- a 16-book curated starter list spanning the DNA space, shown below 5 ratings, dismissible. Simple/curated version only; the fully adaptive per-answer version (next question chosen by what's already been answered) is a real, larger follow-up, not built. See `docs/project-log.md`'s 2026-09-23 entry.
  - Lower priority / conditional: decomposing `genre_accessibility` into sub-signals (gated behind real cold-start evidence); freezing a gold eval set never touched during scoring design (gated behind more raters); `scripts/` folder reorganization into research/engine/backend/frontend (real but overstated -- `api/main.py` already treats `recommend.py` as a clean dependency).
  - Reader-count bottleneck: adopt the review's staged milestones as the framework -- ~10 readers x 30 ratings (surface broken assumptions) -> ~25 readers x 30-50 (start measuring generalization) -> ~100 readers (real comparative experiments).

- [ ] **Recruit more raters -- active priority since 2026-09-17, the single biggest lever on the reader-count bottleneck above. Paused (NOT deprioritized) 2026-09-24** -- the repo owner is still working it personally but wanted engineering effort to shift to beta-polish work in parallel rather than wait on it. Revisit the pitch/channels below once there's real signal on what's/isn't landing. r/Fantasy's subreddit front page bans standalone recruiting posts; post through looser-norm channels instead. Pitch drafts exist (long/short/one-liner) -- deliberately vague about what the project does, ask for a Goodreads/StoryGraph export or a manually rated book list, explicitly solicit disliked/hated books, not just favorites. Candidate channels: r/Fantasy's Discord + weekly self-promo/rec threads, 17th Shard, Sword & Laser, StoryGraph's community, Goodreads Groups, r/PrintSF / r/RomanceBooks / r/suggestmeabook, Indie Hackers, Show HN, personal network (highest trust, best fit for the first ~10 readers). Open, untested concern: raters likely skew toward liked books (a reading hobby survives occasional misses, not a high rate of them), which could leave dealbreaker/negative-signal fields chronically data-poor -- watch once real rater data comes in; the pitch already asks for disliked books to counteract it at collection time.

- [ ] **Beta-readiness polish pass -- active as of 2026-09-24.** Repo owner is doing a visual overhaul on his own side; engineering-side beta-readiness work (below) runs in parallel, not overlapping the visual work. Render cold start (confirmed live 2026-09-24: 25.65s cold, 0.55s warm) now has a keep-warm mitigation (see the item below) -- not fully eliminated, worth re-measuring once there's real beta traffic. Still open: `index.html` has no real explanation of what the app does before asking a stranger to sign up (fine for a personal invite, not for cold beta traffic), and there's no privacy note anywhere despite collecting reading history + email. See `docs/project-log.md`'s 2026-09-24 entries for the source (a second external AI review, `docs/external-reviews/2026-09-23-gpt-review.md`, independently fact-checked before trusting any of it).

- [x] **Render cold-start mitigation.** [Archived detail](TODO-completed.md#done-12).

- [x] **CI fixture-based deterministic scoring/API tests.** [Archived detail](TODO-completed.md#done-13).

- [x] **Import-coverage aggregation + cross-user unmatched-title tracking.** [Archived detail](TODO-completed.md#done-14).

- [x] **Prospective recommendation-outcome tracking.** [Archived detail](TODO-completed.md#done-15).

- [x] **Recommendation-confidence instrumentation, diagnostic/UI-only.** [Archived detail](TODO-completed.md#done-16).

- [x] **`recommend.py` structural refactor (Phase A: canonical `score_candidate()` pipeline; Phase B: split into `scripts/scoring/` submodules).** [Archived detail](TODO-completed.md#done-17).

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #1.** [Archived detail](TODO-completed.md#done-18).

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #2.** [Archived detail](TODO-completed.md#done-19).

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #3.** [Archived detail](TODO-completed.md#done-20).

- [ ] **CODX (Codex CLI) as a third working entity.** Set up 2026-09-13 (`AGENTS.md`, persona system in CLAUDE.md, a stricter destructive-action gate than CLDA's). Real environment: separate clone `~/Documents/bookspell-codex`, push blocked via a tracked `.githooks/pre-push` hook, a genuinely read-only Postgres role `codx_readonly` (2026-09-15) for running `scoring_tests.py`, the public anon key for everything else; every task ends with a report in `docs/codx-reports/`. Active and productive since 2026-09-14 -- its review tasks led to and executed the full `recommend.py` refactor above (through Phase B). Concrete task list and current review/propose-only scope live in `AGENTS.md`; deliberately NOT handed Book DNA tagging or scoring-algorithm design. See `docs/project-log.md`'s 2026-09-13 through 2026-09-17 entries and `docs/codx-reviews/` for the full task-by-task record.

- [x] **Bulk-populate `audiobook_editions` standard-edition narrator data via Hardcover's API.** [Archived detail](TODO-completed.md#done-21).

- [ ] **MOVED to P3, 2026-09-11** -- dramatized-audio edition data (GraphicAudio/BBC Audio/Audible Originals). See the P3 entry for current status; kept as a pointer here so a P1 skim doesn't miss the move.

- [x] **Promote `romance_tone`/`worldbuilding_delivery` from trope pairs to real scalar `book_dna` fields.** [Archived detail](TODO-completed.md#done-22).

## P2 (ongoing/routine, not new decisions)

- [ ] **Fix `tag-audiobook-editions` skill: it tells audio-original ingestion to use `edition_type 'audio_original'`, which the live CHECK constraint rejects.** Found 2026-09-28 by a context-load test agent (T1 after-arm), confirmed by CLDO at SKILL.md lines 210-211. The valid values are `standard`/`dramatized_full_cast`/`abridged`/`other`; `audio_original` is a `books.work_type` value, not an edition type (see `docs/conventions/web.md`). Following the skill as written would fail the insert. Fix the skill text (likely `other` or `standard`; the repo owner decides which) and note it in project-log. Skill edits may need the repo-owner-run script route, since the auto-mode classifier treats instruction files as self-modification.

- [ ] **MOVED to P3, 2026-09-17.** Recurring HIGH_RISK_FIELDS confidence QA pass (CODX) -- see the matching P3 entry. Two rounds landed with real value proven; paused for token-budget reasons, not because it stopped being worth doing.
- [ ] **MOVED to P3, 2026-09-11.** Dramatized-audio edition tracking (Throne of Glass 2-9, Dresden Files 6-14, Murderbot's 2 prequels) folded into the demoted P3 item -- same "wait for the producer" shape, no reason to track separately.
- [ ] **SUPERSEDED 2026-09-11 -- read before touching, the mechanism this item used to describe no longer exists.** Used to track tagging books with the `understated_romance`/`melodramatic_romance_subplot`/`worldbuilding_woven_into_narrative`/`worldbuilding_via_exposition_dump` trope pairs. Those 4 trope IDs and their `book_tropes` rows were permanently deleted 2026-09-11 (Step 4 of `convert-romance-worldbuilding-fields`) once the data was converted into real `book_dna.romance_tone`/`worldbuilding_delivery` scalar columns. **Any future sweep must write directly to those scalar columns via a new migration per batch** (values: `understated`/`melodramatic`/`mixed` for romance_tone, `woven`/`exposition_dump`/`mixed` for worldbuilding_delivery -- see the skill doc's tie-resolution rule), not `book_tropes` inserts -- the old ~136/~395 candidate-pool estimates are stale and unusable. Should be rescoped as a fresh item before anyone resumes it, not picked back up as-is.
- [x] **Catalog tagging completion (initial pass) -- FULLY DONE as of 2026-09-09.** [Archived detail](TODO-completed.md#done-23).
- [x] **Catalog expansion round 4 -- landed 2026-09-12, 378 new untagged books.** [Archived detail](TODO-completed.md#done-24).
- [ ] **Catalog expansion round 5 -- landed 2026-09-21, 226 new untagged books (a real pre-insertion quality filter this time, via Hardcover's `book_category_id`/`cached_tags.Genre` vote data, so less scope-audit cleanup expected than round 4).** Catalog now 1483 books / 570 series (was 1257/485). Batches 10-14 (2026-09-21, CLDA, ~90 books total) tagged via `tag-catalog-batch`, partial-series-first, completing dozens of series and backfilling `narrator_cast` catalog-wide (739 of 1193 books; a new `multi_narrator` enum value later added and backfilled to 21 more, 35 left NULL by design). 5 flagged issues from these batches (Remote Control's wrong `series_id`, an unpublished book archived, and the Holly/Lottery/Egg scope questions) all **RESOLVED 2026-09-22 (CLDO)** -- Holly and The Lottery archived as `non_sff_genre_leakage`, The Egg's standalone row replaced with the real in-scope "The Egg and Other Stories" collection. **139 untagged, not-archived books remain** (catalog 1229/1483 tagged, as of the 2026-09-21 batch-14 count -- query fresh before trusting this as it ages). Next batch continues per the skill's normal partial-series-first order. See project-log.md's dated "Catalog tagging batch N" / "Round-5 tagging batch N" entries for full per-batch detail.
- [ ] **`series.status`/`book_count` data-quality fix -- ongoing, batch-by-batch (display-only, doesn't affect scoring -- neither field is read by `scripts/recommend.py`).** Root cause (found 2026-09-08): `status` defaults to `'ongoing'` whenever Hardcover's `is_completed` flag isn't explicitly true; `book_count` is Hardcover's raw edition/omnibus count, not a curated mainline-installment number. Approach: batches of ~15-20 highest-profile series (ranked by Hardcover's raw `book_count` once the "currently linked" ranking signal saturated at 1 book/series around batch 8), each value verified via live search before writing, tested in a rolled-back transaction, applied and pushed/repaired per CLAUDE.md's migration-tracking rules. **213 of 484 series fixed as of batch 14 (2026-09-17).** Batches have also surfaced (and left unfixed, as separate bug classes for someone else to pick up) duplicate/parent-vs-leaf series rows, wrong `books.series_id` linkages, likely out-of-scope series names, and author-field contamination fixed inline when caught. **Each batch re-derives its own accurate checked/flagged name list directly from the migration files (ground truth) before starting, rather than trusting this summary** -- so nothing here needs to be treated as authoritative. See project-log.md's dated "series.status/book_count fix, batch N" entries (1-14) for full per-series reasoning, sourcing, and the current flagged-name list.
- [x] **Cosmere universe linking -- FIXED 2026-09-08.** [Archived detail](TODO-completed.md#done-25).
- [x] **Catalog-wide shared-universe linking audit -- functionally complete as of batch 9 (2026-09-13).** [Archived detail](TODO-completed.md#done-26).

## P3 (blocked or parked -- check the blocker before picking up)

- [ ] **Database backup dumps contain real bcrypt password hashes (`auth.users.encrypted_password`) in a private repo.** Noticed 2026-09-25 while taking a fresh snapshot -- not new (the 2026-09-11/09-16 backups already have the same thing, it's inherent to a full Supabase Auth data dump) and not urgent right now: `bookspell-backups` is confirmed private, and there are only a couple of real/test accounts. Repo owner's call: address properly once multiple real users are stored (e.g. exclude `auth.users`/`auth.identities` from future `--data-only` dumps, or a separate lower-sensitivity dump path) -- revisit before real beta traffic, not before.
- [ ] **Recurring HIGH_RISK_FIELDS confidence QA pass (CODX).** Round 3 (Task 20) landed 2026-09-25 -- 22 pairs/16 books, 3 value corrections + 5 confidence increases, 14 left genuinely inconclusive, independently re-verified (including 2 direct source re-fetches) before landing. Rounds 1-3 combined: 9 corrections + 19 confidence increases. 240 rows were below 0.6 catalog-wide before this round (query fresh before assigning round 4 -- catalog growth keeps outpacing these passes). See `docs/project-log.md`'s 2026-09-25 "CODX Task 20 landed" entry.
- [ ] **Dramatized-audio edition data (GraphicAudio/BBC Audio/Audible Originals).** Demoted P1 -> P3, 2026-09-11. See `.claude/skills/tag-audiobook-editions/SKILL.md`. Blocked: every currently-known candidate pool is genuinely exhausted (not under-resourced) -- what's left is waiting on external producers to release new material, a freshness/maintenance concern rather than core product-building work. Full sourcing history (Steps A1/A2 batches, BBC Audio sweep, Sub-task B Audible Originals discovery, the 3 ingested-and-tagged Audible Originals) is in `docs/project-log.md`'s 2026-09-08/09/11/13/18 "audiobook-editions skill" entries. Open threads to re-check when resuming: Throne of Glass books 2-9 (GraphicAudio has a real public "in production" announcement), Dresden Files 6-14 and Murderbot's 2 prequels (release-cadence inference only, no actual announcement), Elantris/Warbreaker each have a second, unrecorded "Tenth Anniversary" GraphicAudio edition pending confirmed runtime/completion data, and the Riyria-omnibus judgment call (does a dramatized-edition record belong on an omnibus row?) is still unresolved. The `release_date_start`/`release_date_end` columns now exist (migration `20260918231000`, 2026-09-18) but are empty on every row; still not built: the manual verification step for filling them (flagged 2026-09-18 after a Dragon Reborn UX gap) -- Hardcover's own `release_date` field proved unreliable for this (confirmed wrong for one real edition), so this can't just be an automated field copy. Repo owner's suggested paths forward, neither built yet: revisit as a P2 routine checkup once the product is stable, or build a real new-release alert instead of periodic re-research.
- [ ] **Audiobook runtime/release-date data backfill.** Split out 2026-09-28 from the archived edition-gap item: the schema landed 2026-09-18, but 306 rows still lack `runtime_minutes` and every `release_date_start`/`_end` is null. Queued to `tag-audiobook-editions`'s research backlog. Blocks any UI that displays release dates (it would render empty).
- [ ] **Import-coverage admin display.** Split out 2026-09-28 from the archived import-aggregation item: `import_events`/`import_unmatched_titles` exist and are populated; nothing surfaces them yet. Deliberately deferred until import volume makes the numbers meaningful.
- [ ] **Recheck the 1-row local/hosted `audiobook_length` gap.** Split out 2026-09-28 from the archived backfill item, which recorded local 1035/1058 vs hosted 1036/1058 as known deferred drift. Verify the current state (`scripts/check_db_sync.py` plus a per-table count) before calling it closed.
- [ ] **Graduated dealbreaker veto** (`_apply_dealbreaker_veto_graduated()` in `recommend.py`). Built and structurally verified 2026-09-07, but can't be proven against real data because `validated_dealbreaker_fields()` is currently empty for all 4 real raters -- rechecked 2026-09-12 (Mathias at 143 ratings), still empty, see project-log.md's 2026-09-12 entry. Blocked on more real per-rater rating data, not on more engineering. Revisit once a field/user pair actually validates.
- [ ] **Series-aware field-conditional dedup.** Parked 2026-09-06. One real lead not yet built: protect the minority subgroup within a series split (not just validated-dealbreaker fields, which was tried and found to be a no-op since nothing currently validates). See `docs/scoring-test-protocol.md`'s dedup entries for the full trajectory.
- [ ] **Schema-field ideas** (protagonist gender, protagonist competence trajectory, narrative sympathy between co-leads, `message_themes`/`anti_militarist_message` probe). Tracked in full in `docs/schema/book-dna-decisions.md`'s "Deferred / open proposals" section, not duplicated here. All explicitly waiting on more real rating evidence before committing to vocabulary.
- [ ] **Tier 4 "audiobook-native" `book_dna` fields are still 0% tagged catalog-wide** (`narrator_performance`, `narrator_cast`, `narration_pace_vs_prose`, `accent_authenticity`, `production_quality` -- confirmed 2026-09-13: 0 of 941 tagged books have any of the 5 set). `docs/schema/book-dna.md` already documents this as "skipped for the pilot corpus"; it's what blocks the "medium" (text vs. audio) `recommend()` parameter floated as a deferred idea in `docs/schema/book-dna-decisions.md`. Surfaced again 2026-09-13 by a real user noticing no narrator/cast/production info for audiobooks they'd listened to in the app's book-info modal (the modal now explains the gap transparently in-product rather than showing a misleading blank section, but the underlying tagging gap is unaddressed). Needs a real tagging pass verified against a real source (e.g. Hardcover's own audiobook-edition data), not guessed -- not undertaken yet, scope/size unassessed.
- [x] **`audiobook_editions.audiobook_length` backfilled from real edition runtime data.** [Archived detail](TODO-completed.md#done-27).
- [x] **Data quality: swept for GraphicAudio full-cast rows mislabeled `edition_type = 'standard'`.** [Archived detail](TODO-completed.md#done-28).
- [x] **`audiobook_editions` had RLS disabled and no grant to EITHER `anon` or `authenticated`.** [Archived detail](TODO-completed.md#done-29).
- [x] **21 of 97 `dramatized_full_cast` `audiobook_editions` rows were missing their cast list.** [Archived detail](TODO-completed.md#done-30).
