# Task 25 — further context-load improvements

CODX, 2026-09-28. Baseline **2827739**, the assignment commit. Review and
proposal only; no conventions, skills, schema, TODO, protocol, scoring code,
or workflow files changed. No DB access or scoring tests. Candidate documents
and measurement scripts exist only under this report's evidence directory.

## Decision

Recommend explicit reference-read depth and conservative TODO compression
first. Tier 2 is now justified as a bounded, lossless move of the six already
conditional sections, with their old headings retained as forwarding links.
Do not claim Tier 2 alone solves stale snapshots or guarantees a net saving
on every route. Freshness verification can consume much of its benefit.

Keep both safety gates universal, keep persona/credential boundaries universal,
and keep the four-file schema split. Accept the reported 43/43 and 5/5 routing
results as settled; the accounting and future retrieval tests need improvement.

| Priority | Lever / verdict | Measured opportunity and confidence |
|---|---|---|
| 1 | **C — adopt an explicit front-section plus complete-entry retrieval contract** | Scoring: 30,830 words becomes 2,146 plus required history lookups, with a worked 3,429-word lookup set giving 5,575 total. Potential saving 25,255 in that example, not a universal allowance. Highest payoff, medium confidence until behavioral retest. |
| 2 | **D — collapse completed items to one-line pointers; archive their detail** | Concrete candidate: TODO 4,887 → 2,947, saving **1,940 on every route**, including three explicitly preserved follow-ups. High structural confidence; lifecycle decisions still need CLDO verification. |
| 3 | **A — proceed with six conditional convention files, retain forwarding headings** | Root 8,893 → 4,293. Root plus needed conditional files saves **652–4,353** across the five routes, if loaded once. High confidence in text preservation; discoverability must pass retest. |
| Required companion | **B — verified live read, then byte hashes; reject cheap unverified snapshot shortcuts** | The robust fallback costs a second 4,302-word root copy when an unverified snapshot was already injected. A+B savings versus today's one-copy lower bound range from **+42 to −3,659**, before D/C. Against today's full duplicate-read case, saves 5,234–8,935. Reliability work, not an independent savings claim. |
| Measurement prerequisite | **E — replace self-report totals with transcript accounting and repeated held-out tasks** | No direct per-session word saving assigned: **0**. Required to turn the projections above into demonstrated gains. |

This ranks opportunity × confidence qualitatively, not with invented
probabilities. C's largest figures apply to sessions currently reading the
whole protocol; targeted sessions may save little or even read more under a
clearer minimum. D is the most predictable immediate reduction. E should be
specified before applying changes, despite having no direct word saving.

## 1. Findings reproduced, corrected, or not independently observable

All counts below use the real `wc -w` executable, including counts on
extracted/candidate text passed through stdin. They are words, not model
tokens, billing, context-window usage, or cache-adjusted costs.

| Source | Current words |
|---|---:|
| CLAUDE.md | 8,893 |
| TODO.md | 4,887 |
| Schema core | 5,395 |
| Schema tables | 1,732 |
| Vocabulary-gap tracker | 3,001 |
| Schema decisions/history | 11,192 |
| Four schema files combined | **21,320** |
| Scoring protocol | 30,830 |
| YAML | 11,239 |
| tag-catalog-batch skill | 7,949 |
| Today's three complete latest log entries | 1,208 |

**Finding 1: direction supported; the advertised percentages are not all
loaded-context measurements.** The old tag reproduces exactly: CLAUDE
7,657 + TODO 4,626 + monolithic schema 19,578 = 31,861. Adding its old
scoring protocol, 30,803, gives 62,664. But the new ~47,580 used for the
“24%” comparison is a section-based prescription, whereas Part 2 later
acknowledges full CLAUDE injection. Counting the stated September 26 full
injection, TODO 4,868, log 1,093, core 5,395 and protocol 30,830 gives
**51,079**, before rereads, task source code, or other required references:
18.5% below 62,664, not 24%. Even that comparison includes a new log read
without a matching old log allowance, so it is illustrative, not a corrected
experimental effect size. At today's snapshot the same subtotal is 51,213.

The narrow-route floor is approximately right: 8,893 + 4,887 + 1,208 =
**14,988**, roughly 53% below the old three-file subtotal. It is not a
complete CI/UI task total. Tagging's roughly one-third reduction is plausible
for a bounded correction, not established for a full batch requiring the
whole YAML and skill. Schema design has no single comparable total without
specifying read depth and whether an earlier gate stops the proposal.

**Additional arithmetic error:** the protocol and log say the four schema
files total 34,929. Their own listed components sum to **21,320**, reproduced
from disk. This is 1,742 more than the old monolith, not 15,351 more. Keep
the split; correct the measurement narrative with a dated correction, leaving
append-only log entries intact.

**Finding 2: accept the reported auto-injection observation; consequence is
correct.** If all 8,893 words are injected, routing within that file cannot
remove them. I cannot independently inspect those five Claude Code system
prompts or replay their sessions from this clone. Do not generalize that
observation into identical Codex loading behavior. This session's explicit
disk reads are not a Claude fresh-session experiment.

**Finding 3: failure mechanism reproduced; occurrence counts not replayed.**
A same-word-count edit preserving every H2 heading changes SHA-256. Headings
and counts therefore cannot prove freshness. The reported 1/5 duplicate load
and 12/12 stale snapshots remain CLDO's observations, not independently
reproduced here. No agent transcripts accompany the measurement file.

**Finding 4: ambiguity confirmed by the literal rules.** CLAUDE's engine
section says “Read `docs/scoring-test-protocol.md` before changing any scoring
logic” and answer its ten questions before writing code. It does not define
a partial-read contract. The schema scalar-field gate's step 4 literally
requires clearing the **ten-question gate**, not reading every dated entry;
the routing row supplies the broader protocol prerequisite. The core's
Vocabulary growth process also says to read the full dated chronology before
proposing a new value. Targeted decisions retrieval therefore requires an
explicit edit there too; a new table alone would leave contradictory rules.

**Finding 5: closed-item count/size confirmed; open-item accounting incomplete.**
There are 30 `[x]` items containing **2,437 words on their checkbox lines**,
exactly as stated. Current full TODO is 4,887 rather than the assignment's
4,871. Eighteen open checkbox lines contain 1,817 words; including their
continuations gives **2,069**. The external-review item's nested bullets carry
real live constraints and cannot be excluded as formatting. Closed-block
counting gives 2,458 only because it also captures a 21-word standalone P0
status paragraph; the candidate preserves that paragraph in TODO.

## 2. A — lossless conditional convention files

Move exactly these whole sections, including caveats, examples and incident
rationale. Do not simultaneously summarize their content.

| Existing section | New authoritative path | Existing words | Main missed-rule risk |
|---|---|---:|---|
| Database & migrations | docs/conventions/database.md | 1,423 | Migration tracking vs actual local data; sync check; scoped SQL, dependency checks, public RLS/grants for both roles |
| Database backups | docs/conventions/backups.md | 247 | Separate backup repo, restore guidance, exact “database backup” log-heading trigger |
| Data quality / tagging | docs/conventions/tagging.md | 1,256 | Schema/YAML/skill synchronization; HIGH_RISK evidence; author checks, self-hosted covers, density gate |
| Catalog scope & series hierarchy | docs/conventions/catalog.md | 643 | Archive rather than delete out-of-scope real works, title+author scope, leaf series, comics vs collections |
| Recommendation engine | docs/conventions/scoring.md | 626 | Pre-change gate, both failure scenarios, conditional discounts, import identity/actual globals in A/B tests |
| v1 web app | docs/conventions/web.md | 574 | Whole-config push hazard, hidden/display CSS, theme tokens, actual audiobook table contract |

The other seven sections, the preamble, and the routing table stay universal
and auto-loaded. In particular keep the **before any DB access** routing
trigger, backup/risky-work trigger, scalar-field trigger, scope-expansion
rule and persona-specific connections available before a session selects
its route. No document move grants CODX writes or scoring design authority.

Each old H2 stays in CLAUDE with this forwarding text (substitute its path):

> Required in full when this route applies: `docs/conventions/database.md`.
> Follow the startup routing table.

Add to the routing policy:

> The conditional sections below are forwarding pointers to ordinary Markdown files.
> Read the linked file in full for every matching route before acting; do not
> auto-import those files or place them in an automatically loaded rules directory.
> If scope is unclear, read all six linked convention files and the schema core.
> Existing section links remain valid entry points, not substitutes for their targets.

`A-CLAUDE.candidate.md` and the six `moved-*.md` artifacts contain this exact
counted proposal. All six moved bodies are byte-for-byte source substrings.
These are review artifacts, not an applied or fully link-rewritten patch.
Resolve source-relative “this file”, “below”, and destination references in
one reviewed landing. Keep old anchors so historical references still resolve.

**Do not use eager `@` imports or an auto-loaded rules directory.** That would
recreate the full-load problem with more files. Verify actual injection after
the move; a smaller root on disk is not proof of a smaller system prompt.

### Cross-file reference audit and landing scope

Searched all tracked text files for CLAUDE/TODO references and every candidate
section name, including whitespace-spanning matches. The full path/line
inventory is `references.json`; `references-rg.txt` contains the broad textual
results (final generation uses `git grep` to exclude untracked files/secrets).
Many “recommendation engine” hits describe the product, not a section link;
do not bulk-replace them.

| Moved rule family | Concrete live reference sites to update or verify |
|---|---|
| Database | AGENTS.md:184; gap-sweep skill:178/193; tagging skill:380/383/534 and Step 4; conversion skill:208; audiobook skill:240; scripts/check_db_sync.py:15/21/124; schema table contracts:94 |
| Backups | .github/workflows/backup-reminder.yml:22; TODO's completed backup-policy pointer; routing acceptance scenarios; original root's backup trigger |
| Tagging | tag-catalog-batch skill:103/128 and ingestion/density guidance; gap-sweep skill:178/197; schema table contracts:197; self-host-cover.js and ingest/backfill script comments referring to root ingestion rules |
| Catalog | tag-catalog-batch skill:655 (name wraps across lines); audiobook skill:222; ingest-catalog-round5.js:23/214; AGENTS and routing acceptance checks |
| Scoring | AGENTS scoring scope/protocol pointers; schema core scalar-field gate; scoring protocol's root-convention references; task-class-routing-acceptance-tests.md; README's engine/conventions navigation |
| Web | schema book-dna-tables.md:32/72/81, including old historical correction wording; supabase/config.toml comments; README/api README and routing acceptance checks |

Additionally inspect all four skills' general “per CLAUDE.md” pointers, not
just exact section-name hits. The inventory includes historical project-log,
review-report and migration-comment references: **leave immutable historical
content alone and preserve root forwarding anchors**. Update current entry
points directly. This is why merely moving files and fixing the routing row
would be insufficient.

Required landing files: CLAUDE.md; six new convention files; relevant pointers
in AGENTS.md, docs/persona-workflow.md, all four skill files, README.md,
docs/schema/book-dna-tables.md, scripts/check_db_sync.py, and the backup workflow
comment; current acceptance/measurement documents. Other active ingestion
comments can continue reaching the forwarding root, or be relinked explicitly;
no ingestion implementation change is needed. Log the change and update TODO.

Dependencies: compatible with D; combine the engine pointer rewrite with C
to avoid conflicting read-depth language. Must be evaluated with B, not
credited as though freshness is free.

## 3. B — separate first-read trust from subsequent change detection

**Recommendation:** until the launcher provides a verified receipt for the
exact injected bytes, read the smaller live root once at fresh-session startup.
Hash those same bytes. Subsequent checks can compare live content hashes to
the last-read hashes and reread only changed documents, with rerouting before
dependent actions. This catches an in-place edit; it does not infer what an
unverified snapshot contains.

The complete proposed replacement for the stale-snapshot warning is in
`AB-CLAUDE.candidate.md` (root 4,302 words). Its core requirement is:

> At fresh-session startup, read the current CLAUDE.md from disk once, including
> all universal sections, and use it instead of any injected snapshot. Capture
> a SHA-256 digest from those same bytes. A digest supplied without its source
> text is not evidence that you have read that text.

Check again before a new phase, after a sync and before persistent actions;
hash every already-used convention/reference, not just root. New dependencies
must be read. A helper should read bytes once and output their digest and
content together, avoiding a hash-then-read race. Later calls may output only
changed documents plus their hashes. Count the helper's output too. If a
convention is edited during a dependent action, stop and re-evaluate that
action; hashing is not a concurrent filesystem lock.

| Suggested shortcut | Verdict |
|---|---|
| Headings + wc | Reject as freshness proof; equal-heading/equal-count mutation passes both checks. |
| `git log -1 --format=%H -- CLAUDE.md` | Reject alone: ignores dirty edits; without a trustworthy snapshot baseline, a current commit says nothing about injected bytes. |
| Manually bumped version line | Reject alone: an editor can forget the bump. CI helps committed changes, not arbitrary uncommitted runtime snapshots. |
| Embedded content hash, excluding its own line | Useful only with enforced generation/validation at **snapshot capture**, plus validation of current dirty bytes. CI alone is insufficient. A stale marker in an uncommitted snapshot could later equal the reverted disk's marker while the actual snapshot body differs. Do not assume the marker proves its own integrity. |
| Loader receipt computed from exactly the bytes injected | Accept if CLDO verifies that the installed tooling really supplies it and tests dirty/stale cases. No receipt is available in the supplied evidence. Do not claim this optimization is already implemented. |
| Live first read + stored byte digest | Recommend fallback: mechanically detectable changes, no remembered version requirement, safe basis for cheap later checks. |

The fallback is reliable but not free. With an already injected copy,
two root copies are now 8,604 words. The table below keeps that cost explicit.
This assumes the injected copy is also the new small root. A session still
carrying the old 8,893-word snapshot must count those actual older bytes;
changing disk files cannot remove text already loaded into its context.
For CODX, do not deliberately add an extra copy if there was no injection;
one verified disk read suffices. After compaction, a saved digest without
retained source text does not prove the model still has the rules: reread.

Required files: root warning, a small stdlib helper if adopted (e.g.
`scripts/read-conventions.py`), AGENTS/persona workflow freshness pointers,
measurement fixtures/spec. A loader-receipt optimization is a separate tooling
task for CLDO, conditional on real support, not a proposed manual convention.

## 4. C — explicit depth, without making grep equivalent to review

### Scoring protocol

Keep the protocol at its existing path. Mark the boundary after “What's been
tried” as dated history for targeted retrieval; no physical history split is
necessary, so old entry links survive. The existing front, including the
whole table, is **1,962 words**; the dated remainder is **28,868**. With the
proposed 184-word reading contract, the front is **2,146**.

`C-scoring-front.candidate.md` contains the complete front and proposed text.
The contract requires:

* Full front for scoring behavior changes, scoring-semantic tests, and scalar
  proposals. Both scenarios and all ten questions remain binding.
* Search the whole remaining protocol and project log using identifiers,
  concepts, renamed APIs, old terms, and known failure modes. Read full
  relevant entries and later corrections, not matching lines. Record terms
  and source sections supporting the recommendation.
* Always include current canonical-pipeline/import conventions and metric
  interpretation corrections when changing/evaluating scoring. Current code
  and current contracts arbitrate historical “not built yet” claims.
* Broaden, up to the full history, when relevance or reversals remain
  unresolved. A miss in a narrow search is not proof an idea was never tried.

The opening table itself has old statuses. For example, its prevalence entry
still says “not yet landed,” followed by the later landed section. Task 24
also found the per-value story reversed later the same day. Therefore **do
not treat front-only as sufficient** or as a complete live decision index.

Measured example, not a prescribed exhaustive set for every scoring task:
six whole entries (confidence floor 243; prevalence landed 521; canonical
A2 586; Phase B step 2 512; metric introduction 767; same-day metric
correction 800) total **3,429**. Front + those = **5,575**, saving 25,255
against full 30,830. A real dilution/design task may need many additional
rejected-aggregation entries. No claim that this example completes that task.

### Decisions, YAML, and skills: route-specific minima

| Task | Decisions/history | YAML | tag-catalog-batch skill |
|---|---|---|---|
| CI-only / isolated UI | No default read | No default read | Discover skills; no unrelated skill read |
| Bounded existing-field correction / confidence QA | Relevant prior decision and later reversals if value/evidence rule is disputed; schema core stays full | Complete touched field definitions, values, comments and related distinctions; expand on scope change | Applicable evidence/confidence guidance and linked current table contract; this is not a batch invocation |
| Full tagging batch | Targeted relevant decisions; full active gap tracker remains required | **Full 11,239 words**: selecting all meaningful tags needs the whole vocabulary | **Full 7,949 words for now**; preserve complete procedure and referred calibration guidance |
| Vocabulary-gap sweep | Decisions preamble + Rejected/superseded section, then full relevant proposal/growth entries and later corrections | **Full**, as the sweep skill already requires | Apply the actual gap-sweep skill fully; follow any referenced tagging evidence rules |
| Scoring behavior / semantic fixture change | Relevant design/history decisions; schema core full | Complete affected definitions, expand for unknown interactions | Only if task involves tagging/evidence semantics; no automatic batch invocation |
| New scalar / new vocabulary proposal | Preamble + whole Rejected/superseded section, then search **all** deferred/history text and read full relevant entries, related concepts and reversals | **Full for a new scalar or broad vocabulary design** to satisfy “already represented?”; narrow existing-value semantics changes may use complete affected groups if exhaustive overlap is demonstrable | Read the full skill before designing a change to its mandatory columns, examples, or procedure; read all other affected skills |

Decisions preamble + rejection section is **439 words**, versus 11,192 full.
Its maximum avoidable remainder is **10,753 minus actual retrieved entries**,
not an automatic 10,753 saving on every schema task. “Cannibalism” demonstrates
why the whole rejection entry and its reopening caveat must travel together.
Growth-round rejections also live outside that section; searching only the
Rejected heading is insufficient. A schema candidate stopped at gate 1 should
say which later prerequisites were not completed, not claim a finished design.

I **reject trimming the full skill during a real invocation in this pass**.
Its two “DONE/reference” sections total 1,481 words, but the active Step 0
explicitly reuses the previous audit's judgment-call/calibration methodology.
Moreover Step 4 still speaks of direct hosted inserts while the root database
rule forbids raw hosted-bound migration application. Moving the database rule
behind a route makes following that route essential; it does not make the
skill's stale example authoritative. Keep the higher-level rule and flag the
conflict for CLDO, rather than conceal it by selectively reading less. The
skill also contains older narrator-cast wording despite the YAML's
`multi_narrator`; the mandatory live-schema check and exact YAML remain vital.
No proposed savings from skipping YAML or skill on an actual batch.

Required edits for C: CLAUDE's route prerequisites and engine wording (or
`docs/conventions/scoring.md` after A), the protocol reading contract,
schema core's Schema map/Vocabulary growth prose, decisions preamble,
AGENTS prerequisite wording if necessary, and the tagging/gap-sweep entry
instructions so partial correction vs full invocation is explicit. Preserve
scalar-gate step 4's substantive ten-question requirement. Update acceptance
tests to grade complete applicable entries rather than whole-file counters.
This changes reading requirements; it is not just adding navigation.

## 5. D — keep the roadmap; archive detail, not unfinished work

Prefer one-line closed-item pointers over deleting every checked item from
TODO. External docs often point to an item title as a discoverability anchor.
Preserve its title/location when accurate and store the original full block
in `docs/TODO-completed.md`, with stable anchors. The archive is historical
detail, not a second roadmap and not mandatory startup reading.

The counted `D-TODO.candidate.md` is 2,947 words, down from 4,887. Its paired
archive preserves all 30 original completed blocks, and all 18 original open
blocks remain in the roadmap. A structural check verifies that preservation.
This includes keeping the nested external-review bullets, P2 superseded
mechanism warning, and MOVED-to-P3 pointers. Do not mechanically archive `[ ]`
entries merely because their title says “done” or “superseded.”

The candidate explicitly retains three follow-ups rather than hiding them:

1. Audiobook schema landed, runtime/release-date data backfill remains. The
   P3 item still says date columns do not exist, contradicting the closed
   schema item and current table contract. CLDO must reconcile that status.
2. Import aggregation landed, but its admin display remains conditional on
   enough volume. Preserve that condition; do not turn it into an urgent task.
3. The backfill item reports one deferred local/hosted audiobook-length row
   gap. Verify whether it remains before claiming the entire item is closed.

The existing Task 25 item already carries the context-work follow-up, and
the active vocabulary-gap tracker owns sweep follow-ups. There is no need
to recreate those as duplicate tasks. Proposed follow-up placement in P3 is
for review, not an owner-approved priority change.

Proposed closure rule to add to TODO's introductory guidance:

> Before reducing a completed item to an archive pointer, inspect every phase
> and follow-up it mentions. Link each unfinished phase to a live item or its
> authoritative tracker, retaining its blocker or explicit deferral. Do not
> archive an unfinished phase merely because the parent checkbox is checked.
> Keep the original detail in TODO-completed.md; the roadmap remains TODO.md.

This wording is included in the counted TODO candidate. The 1,940 is a measured
candidate delta, not a guarantee for an arbitrarily expanded landing. It strengthens rather than
weakens the universal multi-phase closure rule, whose original incident was
an unfinished routing phase hidden inside a checked parent item.

Reference dependencies found: README's roadmap link and task navigation;
persona-workflow's CLDA selection source; AGENTS; all relevant skill TODO
pointers (including audiobook lines 159/169); schema core/tables/decisions;
`docs/universe-linking-negatives.md`; workflow comments in keep-warm and
impression-count-check; `scripts/scoring/confidence.py`'s already-stale
outcome-tracking status pointer. No executable code was found parsing closed
checkboxes. Workflow mentions are comments/logging text, not TODO parsers.
Keep the existing TODO entry titles where possible, so these references still
reach an archival pointer or live follow-up. Rewrite stale operational status
links to the authoritative current contract; do not rewrite old logs.

Required files: TODO, new TODO-completed archive, relevant current pointers
above and a project-log entry. The closure wording may also be cross-linked
from universal Logging without duplicating the whole procedure. Independent
of A/C; apply with a lifecycle audit, not a blind regex in production.

## 6. Per-route accounting, including interactions

For A alone, compare the current **one fully injected root** with proposed
root + applicable conditional files. TODO/log/external files cancel in this
table. These are static content projections, not session measurements.

| Route | Current root | A root + conditional | A saved | A+B, injected root + verified disk root + conditional | A+B saved vs one old root |
|---|---:|---:|---:|---:|---:|
| CI backup reminder | 8,893 | 4,540 | 4,353 | 8,851 | 42 |
| Isolated UI | 8,893 | 4,867 | 4,026 | 9,178 | −285 |
| Existing-field correction with DB read | 8,893 | 7,615 | 1,278 | 11,926 | −3,033 |
| Scoring without DB | 8,893 | 5,562 | 3,331 | 9,873 | −980 |
| Scalar/schema design | 8,893 | 8,241 | 652 | 12,552 | −3,659 |

Pure CI without a backup operation does not load the 247-word backup file.
Scoring with a DB read adds 1,423 after the split; risky operations add backups.
Ambiguous work loads all six. Route totals are not filename classifications.

| Other lever | CI | UI | Correction | Scoring | Scalar/schema |
|---|---:|---:|---:|---:|---:|
| D counted candidate saving | 1,940 | 1,940 | 1,940 | 1,940 | 1,940 |
| C protocol saving vs full-file read | 0 | 0 | 0 unless scope expands | 28,684 − H | 28,684 − H |
| C decisions saving vs full-file read | 0 | 0 | Task-dependent; no blanket credit | Task-dependent | 10,753 − J |
| C YAML/skill policy | 0 | 0 | No new saving claimed | No new saving claimed | No new saving claimed |
| E direct saving | 0 | 0 | 0 | 0 | 0 |

H/J are the **actual complete history/decision entries loaded**, with duplicate
bytes counted if reloaded; new navigation/policy text and search output also
cost context. A/B and C may share some wording edits: regenerate exact totals
after combining, rather than summing changed-document sizes twice.

Example: A+B+D's counted changes save 1,982 words for CI and 1,655 for UI
against the one-old-root lower bound, before helper output.
For scoring, add the illustrative C reduction of 25,255 to −980 + 1,940,
giving **26,215**, subject to further required history reads. This example
does not predict a specific task's behavior or grading outcome. Compared
with an already-targeted scalar session, A+B may increase load; that buys
reliable freshness and an explicit reading contract, not a fake saving.

## 7. E — re-test specification for CLDO

Use two separate checks: deterministic source preservation/reference tests,
then fresh-session behavior. Run only in isolated checkouts/sandboxes with
persistent operations disabled. CODX did not launch Claude agents here.

### Freeze inputs and ground truth before observing runs

1. Pin baseline 2827739 and the exact proposed commit; record all source hashes,
   model/version, persona, tool/runtime version, invocation settings and which
   files the runtime actually injects. Same task prompts, model and permissions
   in both arms. Freeze TODO/log fixtures or account for their differing bytes.
2. Keep the existing settled routing cases. Add a required-evidence checklist
   per task, independently reviewed before runs. Grade the actual constraints
   and decisions, not “opened the right file.” Use current schema facts;
   don't perpetuate stale acceptance prose just because an earlier run passed.
3. Run the original five representative routes **three independent fresh runs
   each per arm** (30 sessions), randomizing order and using non-forked agents.
   This is a practical minimum for variability, not a statistical guarantee.
   Add held-out mixed-scope/adversarial cases below. Reserve those prompts
   from tuning the policy wording.
4. Don't tell the agents to optimize word counts or self-report every read.
   Give a normal bounded task to produce a review/plan in an isolated sandbox.
   Log reads passively. Define startup endpoint as first proposed mutation or
   completed plan, and also measure the complete task: merely delaying a
   necessary read past the startup endpoint is not a saving.

### Account from transcripts, not reported file sizes

Export the raw agent tool-call/tool-result transcript and available injected
context metadata. Parse **actual returned text**, not requested file length:

* Read ranges count only returned lines; Bash `cat`/`sed`/`rg` output counts
  only the actual result. Count repeated tool output repeatedly, and count
  injected CLAUDE separately from later disk reads. `wc` output is a few words,
  not evidence that the full file was read.
* Distinguish `requested`, `returned`, `truncated`, `failed`, and `unknown`.
  A file read by a subprocess whose body never reaches the model is not a
  full model-context load. Record truncation markers and recovered reads.
* Keep two metrics: **total delivered words** (duplicates included) and
  **unique source spans covered**. The second can establish coverage, not
  substitute for the first in cost claims. Hash known output spans against
  pinned files; arbitrary transformed shell output counts as output but needs
  manual/explicit mapping for semantic coverage.
* Record relevant output tokens from the runtime when available, with model
  tokenizer/version. Report words and tokens separately. Cache hits do not
  remove bytes from the logical context. Don't add cumulative input-token
  totals across turns and call the result a peak context size; track those
  separately, including compaction/retrieval effects.
* If injected system content isn't observable, report a lower bound for tool
  output plus a separately labeled injection estimate/range. A disk file at
  HEAD does not prove what the stale runtime injected. Do not invent a precise
  all-in total when that input is missing.

Suggested ledger columns: run/task/arm/persona, event ID, source path and
revision/hash, injected vs tool-returned, returned range or unmapped output,
word count, tokenizer count if available, duplicate-span count, truncation,
startup/completion phase, governing evidence found/missed, and task verdict.
Keep raw transcripts restricted if they contain incidental secrets; the
measurement report needs counts and source references, not credentials.

### Required held-out cases and negative controls

* Change a YAML field definition without changing headings or word count,
  after an agent has loaded it: next dependent phase must detect and reread.
* Inject an old root, change a rule in place on disk, and test missing/stale
  version/hash markers, dirty files and a reverted edit. The default first
  disk read must find the real rule; do not grade only printed checksums.
* New audiobook UI table read must reach web, catalog, DB RLS/grants, table
  contract and applicable edition skill; no Tier-B/narrator-identity confusion.
* CI fixture asserting a new score policy must take the scoring route, full
  schema core and gates, despite its CI/test path.
* A plausible new trope that was rejected only in growth history must find
  that rejection; cannibalism must also find the pending reopening caveat.
* Per-value scoring and metric interpretation tasks must find later reversals,
  not stop at the opening table or first matching entry.
* An apparently completed TODO parent with a hidden data-backfill phase must
  keep that phase open or explicitly deferred. Edition date schema vs backfill
  is a real example, not an invented sentinel.
* Restore/risky persistent work must reach backups and database conventions;
  a newly discovered scalar idea mid-task must reroute before proposal.

A negative-control candidate with one missing route link or omitted later
reversal should fail the grader. Otherwise a “zero misses” result may just
mean the grader cannot detect the relevant failure class.

### Acceptance and reporting

Require zero missed universal safety/persona rules and zero missed applicable
task-critical constraints. Any permission/under-read regression blocks that
proposal. Report per-route median, range and worst-case delivered words, number
of complete-entry lookups, repeated bytes, failed/truncated reads, task quality,
and time to find required evidence. With n=3 per arm, avoid confidence claims
about all future tasks; inspect every miss and widen only the affected tests.

Adopt a lever only if it reduces measured relevant load or has an explicitly
accepted reliability benefit. A heavy-route increase under B is a legitimate
tradeoff to report, not a reason to omit the duplicate root. Do not trade a
missed gate for a better average word count. Record accepted/deferred parts
in TODO separately so implementing D does not silently close A/B/C/E.

Files for E: revise `docs/context-load-measurement-protocol.md`, maintain
current acceptance checklists, and optionally add a standalone transcript
accounting tool once CLDO has an actual export sample. No new always-read
measurement file and no unverified assumptions about transcript JSON format.

## 8. Evidence, limitations, and handoff

Evidence directory:
`docs/codx-reports/2026-09-28-context-load-improvements-evidence/`.

Reproduce the candidate counts and structural checks:

```sh
python3 -B docs/codx-reports/2026-09-28-context-load-improvements-evidence/measure.py
python3 -B docs/codx-reports/2026-09-28-context-load-improvements-evidence/check_candidates.py
```

`measurements.json` and `measurement-output.txt` preserve exact counts;
`check-output.txt` records the successful preservation/hash checks. An initial
inline hash-demo assertion failed because its replacement string was absent
from the source; the saved corrected check asserts that its mutation really
changes the text before testing equal word count/headings and differing hash.
No source was modified by either demonstration.

The read route was documentation/process review across the proposed convention
boundaries: full root conventions, schema core, relevant schema contracts,
all of the measurement protocol and Task 21 report, Task 23's landing entry,
current assignment, TODO, persona workflow, and applicable skill sections.
The newest three complete log entries total 1,208 words; the named older
entries were retrieved separately. No claim of reading the entire 30,830-word
protocol or entire decisions chronology in this process audit. Source searches
and full relevant sections were used to check the proposed reading boundaries.

Sync initially hit the sandbox's `.git/FETCH_HEAD` restriction, then found
Task 24's local artifacts now tracked upstream. Preserved the local versions
at `/private/tmp/codx-task24-before-sync-lx0rwgbo` before completing the
fast-forward. Existing reports were not deleted. Final tracked diff is empty;
only this report and its evidence are new untracked output.

Next step belongs to CLDO: verify the arithmetic and dependency map, choose
the accepted proposals, implement them atomically with their reference updates,
and execute E. No production or process change is treated as landed here.
