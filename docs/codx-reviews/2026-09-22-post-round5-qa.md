# Post-round-5 QA — CODX, 2026-09-22

**Status: assignment complete as a bounded QA review; Hardcover follow-up completed 2026-09-23 after the user supplied the token locally. All pending API checks passed. The findings and explicitly inconclusive source judgments below remain for CLDO review.**

Baseline: main `edad08d`, fast-forwarded from `bb22ea0`. No hosted writes, local database access, commits, or pushes. Supabase reads used only the public publishable key embedded in app/shared.js; Hardcover verification used its own API token from the local gitignored .env. No user tables were queried. Scoring logic and all tags remain unchanged.

## Findings for CLDO

1. **Confirmed wrong cover identity:** hardcover_id **428569**, *Just One Damned Thing After Another*, has a live 1000×1000 image of a ten-book Chronicles of St Mary’s box set, with *Hope for the Best* facing forward. The stored book is volume 1, not a box set. Both the migration URL and current hosted URL point at this image; it returns HTTP 200 and decodes normally. This is a content/identity failure that a URL-health check would miss. See `2026-09-22-post-round5-qa-evidence/428569.jpg` and contact sheet 2. CLDO should obtain and verify a cover for the individual book, then replace the hosted asset/reference through the normal process. This audit does not establish when the original wrong asset was selected; the backfill may have faithfully copied an earlier wrong source.
2. **Confirmed incorrect single-POV tag:** hardcover_id **440985**, *Enchanters’ End Game* (stored straight-apostrophe title: `Enchanters' End Game`), is tagged `pov_count = single`. The sources explicitly identify independent Garion, Ce’Nedra and queens’ viewpoints. This is not merely multiple characters appearing in one narrator’s scenes. No explicit pov_count confidence row exists in the current response, so scoring uses the high-risk default 0.85. CLDO should correct after counting recurring, page-time-significant viewpoints; this bounded audit establishes **not single**, but does not invent a precise `dual`/`few`/`several` replacement. [C.E. Murphy’s February 22, 2013 review](https://goodreads.com/book/show/162735587), [Russ Allbery’s review](https://www.eyrie.org/~eagle/reviews/books/0-345-33871-5.html).
3. **Likely wrong closure tag, verify ending before changing:** hardcover_id **427496**, *The Fold*, has `narrative_closure = requires_series`. The book-specific review describes sufficient closure to stand alone; the author explicitly distinguishes Threshold’s shared universe from a uniformly sequential series. The schema defines closure by whether this book resolves its plot, not by its series membership. Proposed direction: `self_contained`, subject to CLDO checking the actual final resolution; no direct full-ending inspection here. No explicit narrative_closure confidence row exists. [Book-specific closure review](https://beta.thestorygraph.com/book_reviews/b28895bc-c4f7-48b4-8055-0c231371c055?page=6&sort=oldest), [Clines’s FAQ, question 3](https://www.peterclines.com/2020/07/faq-xv-questions-of-the-plague-months/).
4. **Cover-resolution observation:** hardcover_id **429081**, *War Storm*, returns a genuine recognizable cover, but only **98×150 pixels**. It passes the task’s broken/placeholder test, yet is visibly blurred when enlarged. Flag for a higher-resolution source if available; no claim here that a better edition image has already been found.

**Inconclusive, not an additional confirmed defect:** *Babel-17*’s single-POV classification needs a full-book look at the recurrence and page time of secondary viewpoints. Its existing confidence is already 0.5. See the individual check below. Do not count this as a correction found.

## Part A — stale file disposition

The assignment’s premise that the old draft never landed was incorrect. `docs/codx-recommend-review-2026-09-14.md` was **byte-identical** (`cmp` exit 0) to the already tracked permanent report `docs/codx-reviews/codx-recommend-review-2026-09-14.md`. SHA-256 for both: `1c348c0f525e4f2e9a60eab8ab9c9a6914042969b41f3862108dc746b292bf20`.

All four findings are explicitly recorded as independently verified and fixed in docs/project-log.md’s 2026-09-14 “CODX’s first real task: 4 bugs found, all verified and fixed” entry and docs/scoring-test-protocol.md’s matching “4 real bugs found” entry: neutral ordinal-audit division, confidence-floor dealbreaker validation, confidence-zeroed trajectory endpoints, and four experimental builders’ zero-weight divisions. Later reports retain the regression results. This was a leftover source copy of a completed report, not an abandoned unfinished task.

Deleted only the redundant untracked file, as authorized by Part A. The permanent review remains untouched. `part-a.json` records the paths, decision and checksum.

## Sync housekeeping

Initial pull fetched origin/main but stopped because the last task’s local project-log addition and untracked CI files overlapped the now-landed changes. Verified both CI files were byte-identical to origin/main; moved their local copies plus the exact local Task 15 log suffix into `docs/codx-reports/2026-09-22-ci-workflow-evidence/pre-next-sync/`, restored only that task’s local log addition to HEAD, and re-ran the fast-forward. Nothing from another task was discarded. Root conventions, updated TODO and project-log tail were consulted; tagging skill was read for evidence/schema context, not invoked to perform tagging.

## B1 — live hosted checklist

Fetched all 1484 public books with stable id ordering and pagination (1000 + 484), then the relevant public DNA/confidence and series rows. Therefore “The Egg absent” is not inferred from an incomplete first page. `books.json`, `series.json`, and `b1-checks.json` retain actual responses/check results.

| Migration | Check | Result |
|---|---|---|
| 20260922000000 | Remote Control / Nnedi Okorafor has null series_id | PASS; position_in_series also null. Who Fears Death retains a non-null, distinct series link. |
| 20260922000000 | The Thorn of Emberlain archived as unpublished | PASS: archived=true, archived_reason=unpublished. |
| 20260922010000 | Ruin identity and membership in hosted catalog | PASS: author John Gwynne, hardcover_id=1235599, position=3; linked series has hardcover_id=2438, name The Faithful and the Fallen, book_count=4. |
| 20260922010000 | Four actual series members | PASS: Malice 1 (429071), Valor 2 (478363), Ruin 3 (1235599), Wrath 4 (475446), all unarchived. |
| 20260922010000 | Independent Hardcover API verification of Ruin id/position | PASS (2026-09-23): Hardcover books.id=1235599, title=Ruin, contributor John Gwynne; book_series position=3, series.id=2438 and name=The Faithful and the Fallen. |
| 20260922030000 | Holly archived as non_sff_genre_leakage | PASS. |
| 20260922030000 | Standalone The Egg row absent | PASS: zero title matches in the complete current public catalog. Historical dependent-row checks cannot be reconstructed from today’s read-only snapshot. |
| 20260922040000 | The Egg and Other Stories present with only Andy Weir | PASS: hardcover_id=839124, author exactly Andy Weir, unarchived. |
| 20260922040000 | Hardcover roles for Christy Romano, R.C. Bray and Jonathan Davis | PASS (2026-09-23): Hardcover cached_contributors independently returns Andy Weir=Author and Christy Romano/R.C. Bray/Jonathan Davis=Reading. |
| 20260922050000 | The Lottery / Shirley Jackson archived as non_sff_genre_leakage | PASS. |
| 20260922060000 | 18 random covers resolve and decode | PASS: 18/18 HTTP 200, Content-Type image/jpeg, decoded JPEGs; all 18 live URLs equal the migration URLs. |
| 20260922060000 | Cover visual plausibility/identity | 17 correct individual-book cover identities, 1 box-set mismatch; no broken or generic placeholder images. War Storm is very low resolution. |

These are observed result checks, not claims that migration tracking is correct, every unsampled row is correct, or every historical safety check occurred. No local Supabase stack was used, so no check_db_sync.py/local-vs-hosted claim is involved.

## Randomization and scope

Sampling was performed before inspecting live values or researching the books. Python `random.Random(20260922)` sampled 15 rows without replacement from the ordered tagging population, then 18 (URL, hardcover_id) pairs without replacement from the 226-update cover migration. No redraws or substitutions. `samples.json` preserves the full population, sample order, seed and migration membership. Tag population is 170 unique titles, not the assignment’s approximate 156. Four 20-book batches plus five 18-book batches = 170. Sampling is global, not stratified: seven of nine source migrations are represented in the draw; it does not guarantee a book from each batch.

Population extraction: sort *.sql filenames; keep timestamps 20260920010000 through 20260921090000 with “tagging” in the filename; extract each `insert into book_dna (...) ... from books where title = '...'` statement, decode SQL doubled apostrophes, and assert titles are unique. Individual files contain 20,20,20,20,18,18,18,18,18 inserts. All 15 sampled titles match exactly one hosted book and have DNA rows.

`HIGH_RISK_FIELDS` was read from scripts/scoring/constants.py: person, pov_count, narrator_reliability, magic_system_hardness, overall_pace, romance_heat_intensity, drive, stakes_scope, narrative_closure, humor_level. The check below covers one or more selected high-risk values per book, not every field or a full retag. Reviewed current schema bucket definitions: single=1, dual=2, few=3–4, several=5–7, ensemble=8+, counting recurring, significant POV characters.

## B2 — sampled books and source checks

PASS means the selected value is supported to the scope stated, not proof that the entire book’s tagging is correct. All author strings below were read live. **Hardcover cached_contributors verification completed for all 15 rows on 2026-09-23: no author contamination found.** Most author contribution fields are null rather than explicitly Author; the sole unlabeled contributor matches the stored author, with no extra non-author included. These are checks against Hardcover’s credits, not proof of complete worldwide contributor metadata. The Fold explicitly credits Ray Porter as Narrator, correctly excluded from books.author.

### 1. The Heir — Hardcover 58916

Current author: **Kiera Cass**. Migration: `20260921030000_catalog_tagging_batch10_18books.sql`.

Checked: `person = first; pov_count = single` — **PASS**. BookRags explicitly identifies Eadlyn as the first-person narrator; Cass independently confirms that Eadlyn tells the story. [Source](https://www.bookrags.com/studyguide-the-heir-the-selection/styles.html) · [Second source](https://www.kieracass.com/news/2014/10/23/things-you-must-know-about-the-heir.html)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Kiera Cass = Author. Stored author matches; no credited narrator, translator or illustrator is included.

### 2. The Mask of Mirrors — Hardcover 476479

Current author: **M.A. Carrick**. Migration: `20260920020000_catalog_tagging_batch7_20books.sql`.

Checked: `person = third_limited` — **PASS**. Co-author Alyc Helms explicitly says all viewpoints are close third person. This supports person; it does not independently settle the exact few/several boundary. [Source](https://www.goodreads.com/questions/2005906-is-the-book-in-first-person-perspective-or)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. M.A. Carrick = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 3. Wrath — Hardcover 475446

Current author: **John Gwynne**. Migration: `20260921050000_catalog_tagging_batch12_18books.sql`.

Checked: `narrative_closure = self_contained; overall_pace = fast` — **PASS**. Petrik Leo describes the resolution of the story begun in Malice and the sustained, accelerating action. Closure here means the plot resolves, not that book four is a good entry point. [Source](https://novelnotions.net/2019/03/30/wrath-the-faithful-and-the-fallen-4/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. John Gwynne = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 4. Automatic Noodle — Hardcover 1598053

Current author: **Annalee Newitz**. Migration: `20260920010000_catalog_tagging_batch6_20books.sql`.

Checked: `stakes_scope = intimate` — **PASS (interpretive)**. Book-specific synopsis and review focus on a small robot crew keeping its restaurant and livelihood afloat. The war is background history, not the present conflict whose scale is being tagged. [Source](https://sffbookreview.wordpress.com/2026/05/08/annalee-newitzi-automatic-noodle/) · [Second source](https://sfrareview.org/2026/01/28/automatic-noodle/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Annalee Newitz = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 5. The Dragon Keeper — Hardcover 384242

Current author: **Robin Hobb**. Migration: `20260921050000_catalog_tagging_batch12_18books.sql`.

Checked: `overall_pace = slow` — **PASS**. Independent reviews explicitly describe its slow progression and extensive character setup; this is evidence about this volume, not an inference from Hobb generally. [Source](https://www.fantasybookreview.co.uk/Robin-Hobb/The-Dragon-Keeper.html) · [Second source](https://fantasyliterature.com/reviews/dragon-keeper/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Robin Hobb = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 6. The Hurricane Wars — Hardcover 617576

Current author: **Thea Guanzon**. Migration: `20260920010000_catalog_tagging_batch6_20books.sql`.

Checked: `pov_count = dual` — **PASS**. Book-specific review identifies Talasyn and Alaric as the two perspectives and explains access to both characters’ thoughts. Excluded results about sequel A Monsoon Rising. [Source](https://booksandcaffeine.com/book-review-the-hurricane-wars) · [Second source](https://mustreadbooks.co.za/fiction/booktok/reviews-of-the-hurricane-wars/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Thea Guanzon = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 7. Enchanters' End Game — Hardcover 440985

Current author: **David Eddings**. Migration: `20260921080000_catalog_tagging_round5_batch4_18books.sql`.

Checked: `pov_count = single` — **FAIL — confirmed multiple POVs**. C.E. Murphy’s review explicitly distinguishes Garion, Ce’Nedra and the queens’ viewpoints. Russ Allbery independently describes the long separate Ce’Nedra/queens thread. Exact replacement bucket requires a count of recurring, significant viewpoints. [Source](https://goodreads.com/book/show/162735587) · [Second source](https://www.eyrie.org/~eagle/reviews/books/0-345-33871-5.html)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. David Eddings = Author. Stored author matches; no credited narrator, translator or illustrator is included.

### 8. Babel-17 — Hardcover 430657

Current author: **Samuel R. Delany**. Migration: `20260921090000_catalog_tagging_round5_batch5_18books.sql`.

Checked: `person = third_limited; pov_count = single` — **INCONCLUSIVE**. The publisher’s German sample gives Forester’s internal thoughts and then shifts to other focalization; research also identifies the Customs Officer perspective. Third-person focalization is supported, but neither the complete limited/omniscient classification nor the count of recurring significant viewpoints is established. Do not infer an exact bucket from minor opening viewpoints. Existing pov_count confidence is already 0.5. [Source](https://carcosa-verlag.de/wp-content/uploads/2023/08/Delany_Babel-17_Leseprobe.pdf) · [Second source](https://dl.tufts.edu/downloads/7p88cw544?filename=8s45qq09d.pdf)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Samuel R. Delany = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 9. Hexed — Hardcover 429262

Current author: **Kevin Hearne**. Migration: `20260921050000_catalog_tagging_batch12_18books.sql`.

Checked: `person = first` — **PASS**. Publisher’s Chapter 1 directly uses Atticus’s first-person narration. This verifies the sampled narrative mode, not every voice throughout the book. [Source](https://www.penguinrandomhouseretail.com/book/?isbn=9780593359648)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Kevin Hearne = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 10. Spark of the Everflame — Hardcover 766436

Current author: **Penn Cole**. Migration: `20260920010000_catalog_tagging_batch6_20books.sql`.

Checked: `person = first` — **PASS**. Book-specific review explicitly describes the first-person narration of Diem’s story. [Source](https://traceyreadsandrambles.wordpress.com/2023/06/13/book-review-spark-of-the-everflame/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Penn Cole = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 11. The Fold — Hardcover 427496

Current author: **Peter Clines**. Migration: `20260920010000_catalog_tagging_batch6_20books.sql`.

Checked: `narrative_closure = requires_series` — **LIKELY WRONG**. A book-specific review explicitly describes enough closure to stand alone; Clines explains Threshold is a shared universe, not uniformly a sequential series. This supports self_contained, but I did not inspect the full ending. [Source](https://beta.thestorygraph.com/book_reviews/b28895bc-c4f7-48b4-8055-0c231371c055?page=6&sort=oldest) · [Second source](https://www.peterclines.com/2020/07/faq-xv-questions-of-the-plague-months/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Peter Clines = unlabeled (null); Ray Porter = Narrator. Stored author matches; no credited narrator, translator or illustrator is included.

### 12. The Broken Kingdoms — Hardcover 430979

Current author: **N. K. Jemisin**. Migration: `20260921090000_catalog_tagging_round5_batch5_18books.sql`.

Checked: `person = first` — **PASS**. Author-provided sample chapter reproduced by Fresh Fiction directly uses Oree’s first-person narrative. It is marked pre-copyediting, so this is narrative-mode evidence rather than exact final-edition wording. [Source](https://freshfiction.com/excerpt.php?id=42497)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. N. K. Jemisin = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 13. Uncrowned — Hardcover 446607

Current author: **Will Wight**. Migration: `20260921050000_catalog_tagging_batch12_18books.sql`.

Checked: `narrative_closure = requires_series` — **PASS**. The review specifies that the tournament covers only roughly three quarters of its course and the book ends on a cliffhanger. This is an unresolved plot, not just shared-series membership. [Source](https://feministquill.wordpress.com/2020/03/16/cradle-will-wight-uncrowned-book-review/)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Will Wight = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 14. Library of Souls — Hardcover 438370

Current author: **Ransom Riggs**. Migration: `20260921040000_catalog_tagging_batch11_18books.sql`.

Checked: `person = first; pov_count = single` — **PASS**. GradeSaver identifies Jacob as the first-person narrator. This is a community-authored study guide, not direct full-text verification. [Source](https://www.gradesaver.com/library-of-souls/study-guide/literary-elements)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Ransom Riggs = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

### 15. The Ex Hex — Hardcover 433773

Current author: **Erin Sterling**. Migration: `20260920010000_catalog_tagging_batch6_20books.sql`.

Checked: `pov_count = dual` — **PASS**. The review distinguishes Vivi’s main perspective and shorter switches to Rhys; another reader independently describes both viewpoints. [Source](https://budgettalesblog.wordpress.com/tag/the-ex-hex/) · [Second source](https://www.allbookstores.com/The-Hex-Witchy-Paranormal-Romance/9780063027473)

Author-role audit: **PASS — Hardcover checked 2026-09-23**. Erin Sterling = unlabeled (null). Stored author matches; no credited narrator, translator or illustrator is included.

## Cover sample — exact IDs and outcomes

All images below returned HTTP 200, decoded as JPEG, and matched their migration URL. Dimensions are pixels. Original images plus SHA-256 and response metadata are retained in the evidence directory; contact sheets 1 and 2 were actually viewed, not only generated.

| Hardcover ID | Book | Dimensions | Visual result |
|---|---|---|---|
| 248133 | Specials | 995×1500 | PASS |
| 441048 | The Dragon's Path | 326×500 | PASS |
| 981093 | Four: A Divergent Collection | 324×500 | PASS |
| 385967 | Dandelion Wine | 243×400 | PASS |
| 735454 | What the River Knows | 329×500 | PASS |
| 526083 | Sword Catcher | 329×500 | PASS |
| 427559 | Spell or High Water | 666×1000 | PASS |
| 1670203 | Brigands & Breadknives | 978×1500 | PASS |
| 68716 | The Angel Experiment | 321×500 | PASS |
| 1078965 | The Life Impossible | 331×500 | PASS |
| 429081 | War Storm | 98×150 | PASS identity; low-resolution thumbnail |
| 1175092 | Five Broken Blades | 1000×1500 | PASS |
| 428676 | More Than This | 324×500 | PASS |
| 280856 | Dogs of War | 1655×2560 | PASS |
| 506322 | Ice Planet Barbarians | 853×1280 | PASS |
| 567927 | He Who Fights with Monsters 7 | 1000×1500 | PASS |
| 428569 | Just One Damned Thing After Another | 1000×1000 | FAIL identity: ten-book box set |
| 219338 | Boneshaker | 333×500 | PASS |

## Commands, evidence and completed follow-up

- `git pull --ff-only`: first fetched but refused overlapping Task 15 files; after preserving those artifacts, fast-forwarded successfully to edad08d. Network/git metadata sandbox escalation was needed.
- `cmp docs/codx-recommend-review-2026-09-14.md docs/codx-reviews/codx-recommend-review-2026-09-14.md`: exit 0, no output. Byte equality was also asserted before removing the stale copy.
- `python3 docs/codx-reports/2026-09-22-post-round5-qa-evidence/fetch_catalog.py`: sandbox DNS failure on the first attempt; authorized network retry exited 0: “Read 1484 books; 15 sampled title matches”; series response saved. The script is restricted to public REST GETs on books, book_dna, book_field_confidence and series. It does not read .env or use a direct DB connection.
- `python3 -m venv /private/tmp/codx-round5-qa-venv` then `/private/tmp/codx-round5-qa-venv/bin/pip install Pillow`: initial sandbox network failure, authorized retry installed Pillow 12.3.0 in the temporary environment only. No repo dependencies changed.
- `/private/tmp/codx-round5-qa-venv/bin/python docs/codx-reports/2026-09-22-post-round5-qa-evidence/fetch_covers.py`: authorized network execution exited 0; `covers.json` holds all exact URLs, HTTP statuses, content types, byte counts, dimensions and hashes. No remote writes.
- Hosted assertions: all requested row/series assertions passed; output “B1 hosted assertions PASS. The Egg absent from all 1484 paginated books.”
- Web research used book-specific title/field queries and the linked sources in each entry; no series/genre stereotype was used to fill a missing check. Unavailable pages and inconclusive research were not turned into passes.

**Dependency resolved 2026-09-23:** the user added the token locally. Ran `python3 docs/codx-reports/2026-09-22-post-round5-qa-evidence/fetch_hardcover.py`; first sandbox attempt failed DNS, authorized retry returned HTTP 200 and 17 book records with no GraphQL errors. The query uses only `books { id title slug cached_contributors book_series { position series { id name } } }`; no mutation or account-data query. Raw response is in `hardcover.json`, assertions and per-book contributor results in `hardcover-checks.json`. Neither file contains the token. Refreshed the public hosted catalog (1484 books, 15 sample matches) and confirmed all author comparisons, both questioned DNA values, and all 18 sampled cover URLs against current rows. Cover image bytes were not downloaded again; visual inspection remains the September 22 observation.

The Hardcover response confirms Ruin’s title/id/John Gwynne attribution and exact series position. The Egg and Other Stories lists Andy Weir as Author and the three named performers as Reading. All 15 sampled author strings match the sole Author/unlabeled contributor after excluding explicit narrator credits. No additional author-contamination findings. `complete_hardcover.py` validates the response and updates this report; `write_report.py` is the original partial-report generator, not the final report generator.

CLDO can already review the confirmed box-set mismatch and Enchanters’ End Game finding, and verify The Fold’s ending. This report and evidence stay uncommitted in CODX’s clone for the usual handoff.
