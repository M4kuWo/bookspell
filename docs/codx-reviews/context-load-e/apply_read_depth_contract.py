#!/usr/bin/env python3
"""Apply CODX Task 25 lever C (explicit read depth) to the Bookspell repo.

- scoring-test-protocol.md: a Reading contract at the top, an end-of-front-section
  marker before the dated history, and the stale prevalence-discount status fixed.
- CLAUDE.md routing rows: explicit depth for YAML, skills, decisions and the protocol,
  plus one general "read depth" rule.
- docs/conventions/scoring.md, schema core, decisions preamble, tag-catalog-batch
  skill: matching read-depth wording.

All-or-nothing: aborts unless every touched file matches HEAD, and checks every
replacement in memory before writing anything. Run from anywhere.

  python3 apply_read_depth_contract.py --dry-run   # check + preview, writes nothing
  python3 apply_read_depth_contract.py             # apply
Undo:  git checkout -- <the files listed>
"""
import os
import subprocess
import sys

REPO = "/Users/mathiaskurin/Documents/bookspell"
DRY = "--dry-run" in sys.argv
os.chdir(REPO)


def die(msg):
    sys.exit(f"ABORTED, nothing written: {msg}")


EDITS = {}  # path -> list of (old, new)


def edit(path, old, new):
    EDITS.setdefault(path, []).append((old, new))


# --- scoring-test-protocol.md --------------------------------------------------
P = "docs/scoring-test-protocol.md"
edit(P, "# Scoring engine test protocol\n\n## Why this exists\n",
     "# Scoring engine test protocol\n\n"
     "## Reading contract (adopted 2026-09-28)\n\n"
     "Read this front section through \"What's been tried\" in full for scoring\n"
     "behavior changes, scoring-semantic tests, and scalar-field proposals. Answer\n"
     "all ten gate questions before implementing a scoring change. The table is\n"
     "historical navigation, not a complete or authoritative current-status index.\n"
     "Search the entire remaining protocol and project log for touched identifiers,\n"
     "related concepts, old names and known failure modes. Read complete relevant\n"
     "entries and their later corrections, not isolated matching lines. Consult\n"
     "current code and contracts before treating a historical status as current.\n"
     "Record search terms and the entries supporting the proposal. If a dependency\n"
     "or reversal cannot be resolved, broaden the read, including the full history\n"
     "when needed. No design change can be justified by a narrow search miss.\n\n"
     "Always include the latest canonical-pipeline/module-import conventions and\n"
     "metric-interpretation corrections when changing or evaluating scoring behavior.\n"
     "Both failure scenarios and applicable current validation requirements remain\n"
     "mandatory. This reading policy grants no implementation or benchmark authority.\n"
     "For a scalar proposal failing an earlier gate, report that stop explicitly;\n"
     "do not claim a complete design review or permission to bypass later gates.\n\n"
     "(Proposed by CODX, Task 25; see\n"
     "`docs/codx-reviews/codx-context-load-improvements-2026-09-28.md`.)\n\n"
     "## Why this exists\n")
edit(P, "\n## Second rater: Osnat (2026-09-01, two rounds)\n",
     "\n> **End of the always-read front section.** Everything below is dated\n"
     "> history: search it for your change's identifiers and concepts and read\n"
     "> complete matching entries, per the Reading contract at the top. Don't read\n"
     "> it linearly, and don't treat the table above as a complete current-status\n"
     "> index.\n\n"
     "## Second rater: Osnat (2026-09-01, two rounds)\n")
edit(P, "| **Promising, not yet landed** 2026-09-06 -- directly confirms",
     "| **Landed** 2026-09-06 -- see \"Candidate-pool prevalence discount -- LANDED for real\" "
     "below (status corrected 2026-09-28; the row's original text follows). Originally: directly confirms")

# --- CLAUDE.md routing rows -----------------------------------------------------
C = "CLAUDE.md"
edit(C, "| Schema core; exact YAML vocabulary; applicable tagging skill; gap tracker before tagging; relevant table/confidence contract |",
     "| Schema core; exact YAML vocabulary (full for a tagging batch; the complete touched field definitions for a bounded correction); "
     "applicable tagging skill (full for a batch invocation; its evidence, confidence and high-risk-field guidance for a bounded correction); "
     "gap tracker before tagging new books; relevant table/confidence contract |")
edit(C, "| Schema core and full YAML; vocabulary-gap tracker; decisions/rejections; gap-sweep skill when running a sweep |",
     "| Schema core and full YAML; vocabulary-gap tracker; decisions per its preamble's reading rule; gap-sweep skill in full when running a sweep |")
edit(C, "| Schema core including scalar-field gate; YAML; relevant decisions/table contracts; scoring-test-protocol.md; affected skills |",
     "| Schema core including scalar-field gate; full YAML; decisions per its preamble's reading rule; relevant table contracts; "
     "scoring-test-protocol.md per its Reading contract; affected skills in full |")
edit(C, "| Schema core; scoring-test-protocol.md with its existing pre-change gate; applicable contracts and prior decisions |",
     "| Schema core; scoring-test-protocol.md per its Reading contract (front section in full, then complete relevant history entries); "
     "applicable contracts and prior decisions |")
edit(C, "External schema names above live in `docs/schema/`;",
     "**Read depth:** \"full\" means the whole file. Anywhere else, read the\n"
     "complete relevant entries or sections (found by searching the whole file\n"
     "for the identifiers, concepts and older names involved), including their\n"
     "later corrections, never isolated matching lines. If relevance or a\n"
     "reversal is unclear, read more, up to the whole file.\n"
     "External schema names above live in `docs/schema/`;")

# --- docs/conventions/scoring.md --------------------------------------------------
edit("docs/conventions/scoring.md",
     "  binding pre-check (adopted 2026-09-24), not optional framing.\n",
     "  binding pre-check (adopted 2026-09-24), not optional framing. Read\n"
     "  the protocol per its own \"Reading contract\" (front section in full,\n"
     "  then complete relevant history entries found by search); its running\n"
     "  table is navigation, not an authoritative current-status index.\n")

# --- schema core -------------------------------------------------------------------
S = "docs/schema/book-dna.md"
edit(S, "  history. Read when proposing a new field/trope/content-warning\n"
        "  (check for a prior rejection first) or revisiting a past design call.",
     "  history. Read when proposing a new field/trope/content-warning\n"
     "  (check for a prior rejection first, per the reading rule at the top of\n"
     "  that file) or revisiting a past design call.")
edit(S, "`book-dna-decisions.md`** — read it before proposing a new value, both\n"
        "to see the evidence bar in action and to check whether your candidate\n"
        "has already been considered and rejected once.",
     "`book-dna-decisions.md`** — before proposing a new value, read it per\n"
     "the reading rule at the top of that file, both to see the evidence bar\n"
     "in action and to check whether your candidate has already been\n"
     "considered and rejected once (many rejections live in the growth\n"
     "rounds, not only in the Rejected / superseded section).")

# --- decisions preamble -----------------------------------------------------------
edit("docs/schema/book-dna-decisions.md",
     "chronological record of how the schema got to its current shape).\n",
     "chronological record of how the schema got to its current shape).\n\n"
     "**How much to read (adopted 2026-09-28).** Before proposing a new\n"
     "field, trope or content warning: read this preamble and the whole\n"
     "**Rejected / superseded decisions** section. Then search the *entire*\n"
     "file for the candidate, related concepts and older names; the growth\n"
     "rounds hold many \"real term but not added\" rejections too. Read every\n"
     "matching entry in full, together with any later reopening or correction\n"
     "(e.g. the cannibalism entry's pending-reopening caveat). A narrow search\n"
     "miss is not proof an idea was never considered: if relevance is\n"
     "unclear, read more, up to the whole file. Other tasks read only the\n"
     "entries they need.\n")

# --- tag-catalog-batch skill ----------------------------------------------------------
edit(".claude/skills/tag-catalog-batch/SKILL.md",
     "# Tag a batch of Bookspell catalog books\n\n",
     "# Tag a batch of Bookspell catalog books\n\n"
     "> **Scope (2026-09-28):** read this skill in full whenever you run a\n"
     "> tagging batch. A bounded correction to already-tagged books (e.g. one\n"
     "> field on a few books) is not a batch invocation: follow its evidence\n"
     "> standard, confidence conventions and high-risk-field guidance (\"The\n"
     "> evidence standard\", \"Confidence conventions\", Step 3's high-risk\n"
     "> section), plus `docs/conventions/tagging.md` and\n"
     "> `docs/conventions/database.md`. How a migration is applied is governed\n"
     "> by `docs/conventions/database.md`, which wins over any\n"
     "> direct-to-hosted wording in this skill.\n\n")

# --- Preconditions, apply in memory -------------------------------------------------
writes = {}
for path, edits in EDITS.items():
    head = subprocess.run(["git", "show", f"HEAD:{path}"], capture_output=True, text=True)
    cur = open(path).read()
    if head.returncode != 0 or cur != head.stdout:
        die(f"{path} differs from HEAD (uncommitted changes?); commit or stash first")
    for old, new in edits:
        n = cur.count(old)
        if n != 1:
            die(f"{path}: expected exactly 1 match, found {n}: {old[:70]!r}")
        cur = cur.replace(old, new)
    writes[path] = cur

for path, content in writes.items():
    before = open(path).read()
    print(f"  edit  {path}  ({len(before.split())} -> {len(content.split())} words, {len(EDITS[path])} change(s))")
if DRY:
    print("DRY RUN: all checks passed, nothing written.")
    sys.exit(0)
for path, content in writes.items():
    with open(path, "w") as f:
        f.write(content)
print("APPLIED. Undo: git checkout -- " + " ".join(writes))
