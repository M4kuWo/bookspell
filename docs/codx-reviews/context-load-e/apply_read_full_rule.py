#!/usr/bin/env python3
"""Make scripts/read_full.py required for every "full" read (CLAUDE.md only).

All-or-nothing: aborts unless CLAUDE.md matches HEAD and each anchor matches once.
  python3 apply_read_full_rule.py --dry-run   # check + preview, writes nothing
  python3 apply_read_full_rule.py             # apply
Undo:  git checkout -- CLAUDE.md
"""
import os, subprocess, sys
os.chdir("/Users/mathiaskurin/Documents/bookspell")
DRY = "--dry-run" in sys.argv
def die(m): sys.exit(f"ABORTED, nothing written: {m}")
head = subprocess.run(["git", "show", "HEAD:CLAUDE.md"], capture_output=True, text=True).stdout
src = open("CLAUDE.md").read()
if src != head: die("CLAUDE.md differs from HEAD; commit or stash first")

EDITS = [
 ("reversal is unclear, read more, up to the whole file.\n",
  "reversal is unclear, read more, up to the whole file.\n\n"
  "**Full reads use `scripts/read_full.py`** (adopted 2026-09-28, CODX Task\n"
  "26). Whenever a rule or route requires a file \"in full\" (the YAML, a\n"
  "skill, the schema core, `docs/TODO.md`, a `docs/conventions/` file, a\n"
  "sub-agent's CLAUDE.md re-read), run `python3 scripts/read_full.py <file>\n"
  "--part 1`, then every remaining part its header advertises (`PART k/N`),\n"
  "passing `--expect-sha <SHA256 from part 1>` on each later part. If it\n"
  "reports the source changed, restart from part 1. A preview, a truncated\n"
  "or `cut`/`head`-limited output, or a persisted-output notice you did not\n"
  "read back is **not** a full read. Targeted reads of relevant sections\n"
  "still use ordinary tools. The receipts make an incomplete full read\n"
  "detectable (two measured test agents believed they had read files in\n"
  "full and hadn't).\n"),
 ("**If you're a sub-agent (launched by another Claude Code session),\n"
  "read `CLAUDE.md` from disk once before acting",
  "**If you're a sub-agent (launched by another Claude Code session),\n"
  "read `CLAUDE.md` from disk once before acting (all parts, via\n"
  "`scripts/read_full.py`)"),
]
new = src
for old, rep in EDITS:
    n = new.count(old)
    if n != 1: die(f"expected 1 match, found {n}: {old[:60]!r}")
    new = new.replace(old, rep)
print(f"  edit  CLAUDE.md  ({len(src.split())} -> {len(new.split())} words, {len(EDITS)} changes)")
if DRY: print("DRY RUN: all checks passed, nothing written."); sys.exit(0)
open("CLAUDE.md", "w").write(new)
print("APPLIED. Undo: git checkout -- CLAUDE.md")
