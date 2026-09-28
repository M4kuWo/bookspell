# Completed TODO items — archive

Full original text of items closed in `docs/TODO.md`, moved here 2026-09-28
(CODX Task 25, lever D) so the roadmap stays short. This is history, not a
task queue, and not startup reading: `docs/TODO.md` remains the roadmap, and
every closed item there links to its entry here. Unfinished phases found
inside closed items were split out into live `docs/TODO.md` items.

## done-01

- [x] **Gate `book_length`/`audiobook_length` by listener format preference.** Done 2026-09-07. See `docs/scoring-test-protocol.md`.

## done-02

- [x] **Set up a real database backup policy.** Done 2026-09-11 -- separate [`bookspell-backups`](https://github.com/M4kuWo/bookspell-backups) repo, manual cadence. See CLAUDE.md's "Database backups" section for the process.

## done-03

- [x] **Bookspell v1 web app -- built and shipped.** Started 2026-09-12, initial build complete 2026-09-18 (real accounts/auth, manual rating, recommendations, Goodreads import, book-info modal, mobile-viewport pass with 2 real bugs found and fixed by the repo owner's own phone testing). Full build history in `docs/project-log.md`'s 2026-09-12 through 2026-09-18 entries. Ongoing feature/bug work on the live app is tracked as its own items below, not here.

## done-04

- [x] **`book_suggestions` admin view.** Done 2026-09-20 -- `app/suggestions.html`, two new RLS policies scoped to the repo owner's Auth user id. See `docs/project-log.md`'s 2026-09-20 entry.

## done-05

- [x] **Fresh-session context-load reduction -- all 3 CODX Task 21 recommendations done and measured.** Step 1 (2026-09-25): bounded project-log read window (3 entries/1,500 words). Step 2 (2026-09-25): `book-dna.md` split into 4 files, ~72% smaller always-read core; measured 26/26 checklist items, zero regressions (see project-log's 2026-09-25 "after results" entry). Step 3 (2026-09-26): task-class routing policy in `CLAUDE.md` -- CLDO's original "purely additive table" framing was corrected by CODX's Task 23 review into a real reading-requirement policy (6 task-specific sections now conditional, 7 universal sections including both safety gates stay always-read); measured against CODX's FULL original 12-scenario proposal (extended from an initial lighter 4-scenario pass at the repo owner's explicit request), **43/43 checklist items passed, zero regressions**, plus several real bonus findings (a caught would-be regression, a real code insight about ratings-source handling, a correct flag-don't-build call on a scope-expansion case). Also surfaced and mitigated a genuine tooling issue: sub-agent system-prompt CLAUDE.md snapshots going stale mid-session, confirmed independently 12/12 times across every test agent -- now warned about at the top of the file itself and filed as product feedback. Tier 2 (an actual CLAUDE.md file split) explicitly deferred, not dropped -- revisit only if real usage shows Tier 1 isn't enough. See `docs/project-log.md`'s 2026-09-26 entries (the initial "measured" entry and the later full-12-scenario entry).

## done-06

- [x] **Quantify the routing policy's real context-load gain.** Both parts done 2026-09-26. Real fresh-agent runs on 5 routes found no under-reads (no routing bug). Part 1's totals had left out required external files, notably `scoring-test-protocol.md`, so the scoring route's corrected gain is ~24%, not 51%; the narrow routes are ~53% below the old baseline even counting CLAUDE.md's full auto-load. See `docs/context-load-measurement-protocol.md`'s Results and `docs/project-log.md`'s 2026-09-26 "Context-load measurement Part 2 run" entry.

## done-07

- [x] **A book Osnat hated ranks #4 of 695 in her real recommendations -- investigated 2026-09-23 by CODX (Task 17).** Rigorous root-cause dig (exact factor arithmetic reproduced, leave-one-out sensitivity check across all 4 of her usable negatives), independently spot-checked by CLDO. Conclusion: not a scoring bug -- no engine-level error found, the arithmetic reproduces exactly. Real cause is data sparsity: only 2 negative ratings meant `validated_dealbreaker_fields()` returns empty (needs >=3 each side), so no veto can fire, and the coarse profile representation can't distinguish this hated sequel from attributes of books she liked. Same root blocker as the P3 "graduated dealbreaker veto" item below (empty validation across all real raters) -- not a new, separate problem, and not actionable without more real negative rating data (ties to the rater-recruitment item above). See `docs/codx-reviews/2026-09-23-magic-burns-ranking.md` for the full analysis.

## done-08

- [x] **Fix `/recommendations` slowness.** Raised 2026-09-18; real cause found (`explain_match()` redundantly re-resolving the whole profile on every call, plus the dashboard firing 3 parallel requests). Backend fix (`resolve_explain_profile()`/`explain_match_with_profile()`, resolved once per request) and dashboard fix (`GET /recommendations/all`, one shared request instead of 3) both landed 2026-09-20. CODX's follow-up review (Tasks 13-14) caught and fixed a title-validation-ordering regression and a partial-failure resilience gap the same week. See `docs/project-log.md`'s 2026-09-18/19/20 entries and `docs/scoring-test-protocol.md`.

## done-09

- [x] **Audiobook edition data gaps: missing `runtime_minutes` (27% of rows), no `release_date` field.** Raised and schema-fixed 2026-09-18 -- added `release_date_start`/`release_date_end` (a range, for multi-part editions) via migration `20260918231000`; `docs/schema/book-dna.md` and the tagging skill updated same session. Data backfill (306 rows missing runtime, all release-date values) is queued to `tag-audiobook-editions`'s research backlog, not yet done.

## done-10

- [x] **Self-host book cover images instead of hotlinking Hardcover's CDN.** Done 2026-09-18, prompted by Hardcover's CDN breaking for 7 already-ingested books with no warning. New `book-covers` Supabase Storage bucket, all 1254 covers migrated, `books.cover_url` repointed; reusable `scripts/lib/self-host-cover.js` helper is now mandatory for any new ingestion script. Two mistakes caught and fixed same session (a migration hardcoding local UUIDs; 6 books with stale local `author` data, see next item). See `docs/project-log.md`'s 2026-09-18 entries.

## done-11

- [x] **Local/hosted `books.author` field drift.** Found and fixed 2026-09-18 as a side effect of the cover-image backfill above -- 6 books had contaminated (translator/narrator/etc.) `author` values on local Postgres that hosted already had cleaned up via an earlier fix that never made it back to local. Fixed directly on local (no migration needed, hosted was already correct). See `docs/project-log.md`'s 2026-09-18 entry.

## done-12

- [x] **Render cold-start mitigation.** Done 2026-09-24 -- `.github/workflows/keep-warm.yml`, pings `GET /rule-targets` every 10min. Doesn't eliminate cold starts entirely (a long idle stretch, or GitHub's own schedule slipping under load, can still open a gap) but should catch the vast majority of real visits during active hours. The other real option, upgrading Render's paid tier, remains a cost decision for the repo owner, not an engineering one -- worth revisiting if the ping alone isn't enough once there's real beta traffic.

## done-13

- [x] **CI fixture-based deterministic scoring/API tests.** Landed 2026-09-25 via CODX Tasks 18-19, both independently re-verified by CLDO (clean run + a real negative-control mutation, reproduced myself, not just re-read). `scripts/scoring/tests/test_fixtures.py`, 15 methods, all synthetic/DB-free, run as `.github/workflows/ci.yml`'s 4th check. Covers ordinal/nominal similarity, `build_profile()` sign correctness, all 4 `score_candidate()` policies, series-position gating, prevalence/redundancy discounts, series-repeat/trajectory, both cold-start components, user rules, explanation-text direction, and both dealbreaker-veto modes. See `docs/project-log.md`'s 2026-09-25 "CODX Task 18/19 landed" entries.

## done-14

- [x] **Import-coverage aggregation + cross-user unmatched-title tracking.** Done 2026-09-24 -- new `import_events`/`import_unmatched_titles` tables (migration `20260924010000`), written from `api/main.py`'s existing import endpoint. Real coverage % and repeated-unmatched-title queries now possible (see the migration file's own comment for the exact SQL); nothing built yet to actually SURFACE this to anyone (no admin view) -- a real, still-open follow-up once there's enough import volume to make the numbers meaningful. See `docs/project-log.md`'s 2026-09-24 entry for the verification (a real end-to-end `TestClient` request, not just a syntax check).

## done-15

- [x] **Prospective recommendation-outcome tracking.** Design pass done + landed 2026-09-25 with the repo owner (retention, privacy-notice scope) before any schema was written. `recommendation_impressions` table logs what `/recommendations` actually shows (book, rank, score, `evidence_confidence`); "outcome" is computed by joining against the existing `ratings` table rather than new frontend click-tracking. Retention: indefinite, with a 100,000-row early-warning check (`.github/workflows/impression-count-check.yml`, a new `impression_count_monitor` role scoped to count-only). See `docs/project-log.md`'s 2026-09-25 "recommendation-outcome tracking" entry for the full reasoning and the privacy-notice discussion (deferred, tied to a real public launch, not before).

## done-16

- [x] **Recommendation-confidence instrumentation, diagnostic/UI-only.** Landed 2026-09-25 (`scripts/scoring/confidence.py`), wired into `explain_match_with_profile()`/`/recommendations`' `evidence_confidence` key -- NOT fed into ranking/score. Learned-weight stability deliberately deferred (no cheap proxy found yet). Not yet surfaced in the frontend (the user's own in-progress visual pass) or measured against real outcomes (blocked on the outcome-tracking item above). See `docs/project-log.md`'s 2026-09-25 entry.

## done-17

- [x] **`recommend.py` structural refactor (Phase A: canonical `score_candidate()` pipeline; Phase B: split into `scripts/scoring/` submodules).** Fully landed 2026-09-17 via CODX Tasks 4-12, each independently re-verified by CLDO before landing (byte-identical scorecards, AST diffs, real consumer checks). Originally proposed by the GPT review above, 2026-09-14. `scripts/recommend.py` is now a 105-line CLI demo; the real engine lives under `scripts/scoring/`. Full step-by-step record in `docs/scoring-test-protocol.md`'s "Phase A"/"Phase B" entries and `docs/codx-reviews/`.

## done-18

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #1.** Run 2026-09-13 by CLDA (methodology in `.claude/skills/catalog-trope-gap-sweep/SKILL.md`), covering 377 books across 31 authors (~39% of the tagged catalog). 5 new tropes landed (migration `20260913170000`), 3 real candidates deferred to `docs/schema/book-dna-vocabulary-gaps.md`'s tracker, docs verified zero-diff against the DB. Applied directly to hosted (CLDA's sandbox has no linked Supabase project); migration-tracking repaired in sweep #3's session. See `docs/project-log.md`'s 2026-09-13 entries.

## done-19

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #2.** Run 2026-09-13 by CLDA, same day, covering the remaining ~366-book pool (117 authors). 7 new tropes + 1 new content warning landed (migration `20260913220000`); `caste_or_faction_stratified_society` deliberately deferred pending a dystopia-overlap check (later promoted in sweep #3); 6 more single-occurrence leads added to the tracker. Same hosted-direct-apply situation as sweep #1. See `docs/project-log.md`'s 2026-09-13 entries.

## done-20

- [x] **Catalog-wide trope/content-warning vocabulary gap sweep #3.** Run 2026-09-13 by CLDA, the third and (for now) final regular pass, covering the remaining ~224-book pool clustered by subgenre/theme. 11 new tropes landed (migration `20260913230000`, including promoting `caste_or_faction_stratified_society`), plus 2 smaller flagged-item fixes (an incomplete trope insert, 5 author-contamination cases) same session. All 3 sweeps' pending migration-tracking repairs were completed this session via `supabase migration repair --db-url`. Coverage across all 3 sweeps is effectively full deliberate-sweep coverage of the ~961-tagged catalog -- closes the proactive-sweep phase for now; future gaps surface reactively via ordinary tagging. See `docs/project-log.md`'s 2026-09-13 entries and `docs/schema/book-dna-vocabulary-gaps.md`'s tracker for remaining Open items.

## done-21

- [x] **Bulk-populate `audiobook_editions` standard-edition narrator data via Hardcover's API.** Done 2026-09-11: 1026 `standard` rows across 786 of 869 books with a `hardcover_id`, grouped by narrator-set identity (not publisher/date) to avoid conflating distinct narrations of the same book. Six migration batches (`20260911120000` through `20260911180000`); five real content-leakage categories found and excluded (a narrator-name typo variant, full-cast re-recordings under a generic imprint, placeholder "narrator" values, an unofficial fan recording, radio dramatizations under generic publisher names). Remaining 83 books have no narrator data in Hardcover at all -- not actionable without a different source. See `docs/project-log.md`'s 2026-09-11 entries.

## done-22

- [x] **Promote `romance_tone`/`worldbuilding_delivery` from trope pairs to real scalar `book_dna` fields.** Done 2026-09-11, both schema+backfill and scoring-engine halves. Columns added with a 3rd `mixed` value for genuine confidence ties; backfilled (`romance_tone` 160/864, `worldbuilding_delivery` 117/864 non-null); old trope rows and vocabulary entries deleted only after direct repo-owner go-ahead, backed up to a tracked manifest first. Scoring side: both added as content-scoped `NOMINAL_FIELDS` with partial credit for `mixed`; also fixed two general latent bugs found while testing (an untagged nominal field scoring as a full mismatch; a possible divide-by-zero in `build_profile()`). See `docs/project-log.md`'s 2026-09-09/2026-09-11 entries and `docs/scoring-test-protocol.md`'s 2026-09-11 entry.

## done-23

- [x] **Catalog tagging completion (initial pass) -- FULLY DONE as of 2026-09-09.** 871 books total, 861 tagged, 10 untagged and all 10 confirmed permanent exceptions (4 omnibus/compilation duplicates, 2 unpublished sequels, 4 graphic novels -- out of v1 scope). Shōgun and The Screwtape Letters deleted the same day as confirmed out-of-scope (dependent tables checked first). See project-log.md's 2026-09-09 entries.

## done-24

- [x] **Catalog expansion round 4 -- landed 2026-09-12, 378 new untagged books.** Catalog grew to 1256 books / 484 series (was 878/366). Batches 1-9 (2026-09-13 through 2026-09-21, mixed CLDO/CLDA sessions) tagged the pool via `tag-catalog-batch`, completing dozens of series and routinely catching author-field contamination and density shortfalls along the way. **Closed 2026-09-21**: rather than deleting, a new `books.archived`/`archived_reason`/`archived_at` mechanism (per the repo owner's direct instruction) archived 115 of the 118 remaining untagged books (96 `non_sff_genre_leakage`, 11 `graphic_novel`, 5 `omnibus_duplicate`, 3 `unpublished`); `app/rate.html`'s book-search queries updated to filter `archived = false`. The 3 titles deliberately left open (Holly, The Lottery, The Egg) were resolved 2026-09-22 -- see the round-5 item below. Untagged-but-not-archived from this round is effectively 0; stays closed until new books are ingested. See project-log.md's dated "Catalog tagging batch N" entries for full per-batch detail.

## done-25

- [x] **Cosmere universe linking -- FIXED 2026-09-08.** Only 3 of Sanderson's real Cosmere books were actually linked to the "The Cosmere" universe row (plus a duplicate "Cosmere" series row holding 2 misplaced books). Linked 22 more books (Mistborn both eras, full Stormlight Archive, Elantris novellas, 2 real Secret Projects entries), deleted the duplicate row. See project-log.md.

## done-26

- [x] **Catalog-wide shared-universe linking audit -- functionally complete as of batch 9 (2026-09-13).** Checks every multi-series author for a genuine structural connection (not just thematic/cameo overlap) before linking `series.universe_id`. Batches 1-9 checked 70 author-groupings: 16 confirmed connected and built (Westeros, Foundation, Cosmere gap-fixes, Maasverse, Riordanverse, Wizarding World, Grishaverse, Enderverse, First Law World, and others -- `universe` table has 21 rows), 51 confirmed not connected, 2 flagged as series-table duplicate-row issues rather than true universe questions, 1 flagged ambiguous/thin and left deliberately unlinked. **The 2 naming calls ("Lyra's World", "The Legend Universe") confirmed 2026-09-24** -- neither is an established fandom/author term, both kept as their original fallback names per the repo owner's direct call. **A real, separate bug found while confirming this**: local Postgres was silently missing both of these plus a 3rd universe row (Meridian Empire) since 2026-09-13 -- `check_db_sync.py` never monitored `universe`/`series`, now fixed to. See `docs/project-log.md`'s 2026-09-24 entry. **Candidate pool fully exhausted as of batch 9** -- every author in the query has been checked at least once; a future batch just re-runs the candidate query fresh, since only catalog growth produces genuinely new candidates. **Full confirmed-negative roster (don't re-research these) lives in `docs/universe-linking-negatives.md`** -- pulled out to its own file since it's a reference list, not narrative; see project-log.md's dated "shared-universe audit batch N" entries for the evidence behind each verdict.

## done-27

- [x] **`audiobook_editions.audiobook_length` backfilled from real edition runtime data.** Done 2026-09-13 (864 -> 904 of 941 tagged books) and completed 2026-09-18 (remaining 14 books with multiple standard-edition runtimes -- none actually straddled a bucket boundary, so no judgment call was needed after all). Migrations `20260913090000_backfill_audiobook_length_from_editions.sql`, `20260918232000_backfill_audiobook_length_remaining_14.sql`. Local (1035/1058) vs. hosted (1036/1058) 1-row gap is the same pre-existing, already-deferred drift noted back in the 2026-09-13 batch, not something this backfill introduced.

## done-28

- [x] **Data quality: swept for GraphicAudio full-cast rows mislabeled `edition_type = 'standard'`.** Done 2026-09-18 -- no confirmed mislabeled rows found catalog-wide (the originally-suspected "A Court of Frost and Starlight" row was already correctly tagged `dramatized_full_cast`; the 2026-09-13 report was a local-Postgres-drift artifact, not a real hosted data issue). Re-check after any future GraphicAudio/BBC batch (`tag-audiobook-editions` Sub-task A) -- this was a one-time sweep, not a standing guarantee.

## done-29

- [x] **`audiobook_editions` had RLS disabled and no grant to EITHER `anon` or `authenticated`.** Fixed 2026-09-13 (`20260913100000_expose_audiobook_editions_to_app.sql` for `authenticated`, `20260913110000_grant_audiobook_editions_to_anon.sql` for `anon`), verified with real REST calls under each role against hosted, not just a grants check. See CLAUDE.md's "Database & migrations" section for the resulting standing rule on new public-catalog-style tables.

## done-30

- [x] **21 of 97 `dramatized_full_cast` `audiobook_editions` rows were missing their cast list.** Done 2026-09-13 -- 12 recovered directly from each row's GraphicAudio `source_url` (via curl, since `WebFetch`'s markdown conversion was dropping the cast section), 9 confirmed genuinely unavailable rather than left as a silent gap (6 are the deliberate Earthsea/Foundation BBC bundled-dramatization no-op; the other 3 have no "Starring" attribute published anywhere on GraphicAudio's site). Migration `20260913120000_backfill_missing_dramatized_cast_lists.sql`, verified post-push: exactly the 9 confirmed-unavailable rows still missing cast.

## done-31

- [x] **Fix `tag-audiobook-editions` skill: it tells audio-original ingestion to use `edition_type 'audio_original'`, which the live CHECK constraint rejects.** Found 2026-09-28 by a context-load test agent (T1 after-arm), confirmed by CLDO at SKILL.md lines 210-211. The valid values are `standard`/`dramatized_full_cast`/`abridged`/`other`; `audio_original` is a `books.work_type` value, not an edition type (see `docs/conventions/web.md`). Following the skill as written would fail the insert. Fix the skill text (likely `other` or `standard`; the repo owner decides which) and note it in project-log. Skill edits may need the repo-owner-run script route, since the auto-mode classifier treats instruction files as self-modification. **Done 2026-09-28:** the skill now picks `edition_type` by production (`dramatized_full_cast`/`standard`), never `audio_original`.
