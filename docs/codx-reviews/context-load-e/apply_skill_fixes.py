#!/usr/bin/env python3
"""Fix the two skill bugs recorded in docs/TODO.md (2026-09-28).

1. tag-catalog-batch: formalize the existing direct-to-hosted batch flow instead of
   leaving it in silent conflict with docs/conventions/database.md. CLDA flags each
   directly-applied migration version; CLDO verifies the data and runs
   `supabase migration repair`. database.md gains a scoped, documented exception.
2. tag-audiobook-editions: an audio original's own edition row must use a valid
   edition_type (standard / dramatized_full_cast by production), never 'audio_original'.

All-or-nothing: aborts unless each file matches HEAD and each anchor matches once.
  python3 apply_skill_fixes.py --dry-run   # check + preview, writes nothing
  python3 apply_skill_fixes.py             # apply
Undo:  git checkout -- <the files listed>
"""
import os, subprocess, sys
os.chdir("/Users/mathiaskurin/Documents/bookspell")
DRY = "--dry-run" in sys.argv
def die(m): sys.exit(f"ABORTED, nothing written: {m}")

T = ".claude/skills/tag-catalog-batch/SKILL.md"
A = ".claude/skills/tag-audiobook-editions/SKILL.md"
D = "docs/conventions/database.md"
EDITS = {T: [], A: [], D: []}

# --- 1a. tag-catalog-batch scope note (written by lever C) --------------------------
EDITS[T].append((
 "> `docs/conventions/database.md`. How a migration is applied is governed\n"
 "> by `docs/conventions/database.md`, which wins over any\n"
 "> direct-to-hosted wording in this skill.\n",
 "> `docs/conventions/database.md`. A bounded correction applies its\n"
 "> migration the standard way (local via psycopg2, hosted via `supabase db\n"
 "> push`). The direct-to-hosted flow in Setup/Step 3/Step 4 is a\n"
 "> documented exception for **batch runs only** (see\n"
 "> `docs/conventions/database.md`), and it always ends with CLDO's\n"
 "> tracking repair (Step 4, item 3).\n"))
# --- 1b. Step 3 migration conventions ------------------------------------------------
EDITS[T].append((
 "test-in-transaction, apply to hosted, then commit the migration file so\n"
 "it's part of the tracked history.\n",
 "test-in-transaction, apply to hosted, then commit the migration file so\n"
 "it's part of the tracked history. Because you apply it over a direct\n"
 "connection rather than `supabase db push`, hosted's migration-tracking\n"
 "table won't record it: flag the version for CLDO's repair (Step 4,\n"
 "item 3).\n"))
# --- 1c. Step 4 item 3 ------------------------------------------------------------------
EDITS[T].append((
 "     the repo owner will commit it on their end.\n\n",
 "     the repo owner will commit it on their end.\n"
 "3. **Flag the version for tracking repair.** Your inserts went in over a\n"
 "   direct connection, not `supabase db push`, so hosted's\n"
 "   migration-tracking table doesn't record this migration, and a later\n"
 "   `db push` would try to re-run it. In your Step 5 report, list the\n"
 "   file's version (its timestamp prefix) and say it was applied directly\n"
 "   to hosted. CLDO then confirms the data matches on hosted (row counts\n"
 "   or a spot-checked row) and runs `supabase migration repair --status\n"
 "   applied --linked <version>`, per `docs/conventions/database.md`.\n"
 "   **Never run `supabase db push` for this file yourself.**\n\n"))
# --- 1d. Step 5 report ------------------------------------------------------------------
EDITS[T].append((
 "For each book tagged, note anything genuinely uncertain or any\n"
 "vocabulary gap you noticed.",
 "For each book tagged, note anything genuinely uncertain or any\n"
 "vocabulary gap you noticed. List each migration version you applied\n"
 "directly to hosted, for CLDO's tracking repair (Step 4, item 3)."))
# --- 1e. database.md scoped exception -----------------------------------------------------
EDITS[D].append((
 "  `supabase migration list --linked` (entries with a `local` timestamp\n"
 "  but no matching `remote` one), not just when something breaks loudly.\n",
 "  `supabase migration list --linked` (entries with a `local` timestamp\n"
 "  but no matching `remote` one), not just when something breaks loudly.\n"
 "  **One documented exception (formalized 2026-09-28):**\n"
 "  `.claude/skills/tag-catalog-batch/SKILL.md` batch runs insert directly\n"
 "  against hosted by design (CLDA's established workflow). Such a run must\n"
 "  flag each directly-applied migration version in its report. CLDO then\n"
 "  verifies the data on hosted and runs `migration repair` for exactly\n"
 "  those versions, and nobody runs `db push` on them first. Nothing else\n"
 "  gets this exception: bounded corrections and every other hosted change\n"
 "  go through `supabase db push`.\n"))
# --- 2. audiobook edition_type ------------------------------------------------------------------
EDITS[A].append((
 "- Populate its OWN `audiobook_editions` row too (edition_type\n"
 "  `'audio_original'`, unless it's better described as\n"
 "  `dramatized_full_cast` if that's the more informative distinction --\n"
 "  use judgment, note which you picked and why in your report).",
 "- Populate its OWN `audiobook_editions` row too. Pick `edition_type` by\n"
 "  how it was produced: `dramatized_full_cast` for a full-cast production\n"
 "  (what all 3 Audible Originals ingested so far used, migration\n"
 "  `20260909130000`), `standard` for a single-narrator reading. **Never\n"
 "  `'audio_original'`**: that's a `books.work_type` value, and the\n"
 "  `edition_type` CHECK constraint rejects it (the allowed values are\n"
 "  `standard`, `dramatized_full_cast`, `abridged`, `other`; see\n"
 "  `docs/conventions/web.md`). The audio-original status is already\n"
 "  carried by `books.work_type`. Note which you picked and why in your\n"
 "  report. (Corrected 2026-09-28; this line previously said\n"
 "  `'audio_original'`, which would have failed the insert.)"))

writes = {}
for path, edits in EDITS.items():
    head = subprocess.run(["git", "show", f"HEAD:{path}"], capture_output=True, text=True)
    cur = open(path).read()
    if head.returncode != 0 or cur != head.stdout:
        die(f"{path} differs from HEAD; commit or stash first")
    for old, new in edits:
        n = cur.count(old)
        if n != 1: die(f"{path}: expected 1 match, found {n}: {old[:70]!r}")
        cur = cur.replace(old, new)
    writes[path] = cur
for p, c in writes.items():
    print(f"  edit  {p}  ({len(open(p).read().split())} -> {len(c.split())} words, {len(EDITS[p])} change(s))")
if DRY: print("DRY RUN: all checks passed, nothing written."); sys.exit(0)
for p, c in writes.items():
    open(p, "w").write(c)
print("APPLIED. Undo: git checkout -- " + " ".join(writes))
