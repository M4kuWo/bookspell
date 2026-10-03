import os, re, subprocess, sys
W = sys.argv[1]; os.chdir(W)
HIDE = ["docs/codx-reviews/context-load-e", "docs/codx-reviews/context-load-improvements-2026-09-28-evidence",
        "docs/codx-reviews/read-cost-without-relaxing-2026-09-28-evidence",
        "docs/codx-reviews/codx-context-load-improvements-2026-09-28.md",
        "docs/codx-reviews/codx-read-cost-without-relaxing-2026-09-28.md",
        "docs/context-load-measurement-protocol.md", "docs/task-class-routing-acceptance-tests.md",
        "docs/codx-reports/2026-09-25-context-load-review.md"]
hide = [p for p in HIDE if os.path.exists(p)]
subprocess.run(["git", "rm", "-r", "-q", *hide], check=True)
# project-log: drop measurement entries (2026-09-26 onward) by keyword
log = open("docs/project-log.md").read()
parts = re.split(r"(?m)^(?=## \d{4}-\d{2}-\d{2})", log)
pat = re.compile(r"context-load|after-arm|before-arm|after arm|before arm|e-prompts|e-checklists|measure_context_load|read_full|CODX Task 2[56]|Task 25|Task 26|routing acceptance|12-scenario|Part 2|Part 3", re.I)
kept, dropped = [], []
for p in parts:
    m = re.match(r"## (\d{4}-\d{2}-\d{2})", p)
    if m and m.group(1) >= "2026-09-26" and pat.search(p):
        dropped.append(p.split("\n", 1)[0][:90]); continue
    kept.append(p)
open("docs/project-log.md", "w").write("".join(kept))
# TODO: neutralize the context-load item
t = open("docs/TODO.md").read()
lines = t.split("\n")
idx = [i for i, l in enumerate(lines) if l.startswith("- [ ] **Context-load improvements")]
assert len(idx) == 1
lines[idx[0]] = "- [x] **Context-load improvements (CODX Tasks 25-26) -- landed 2026-09-28.**"
t = "\n".join(lines)
assert "e-prompts" not in t and "Re-measurement" not in t
open("docs/TODO.md", "w").write(t)
open("docs/codx-tasks/current-task.md", "w").write("# CODX current task\n\n**Status**: nothing queued right now.\n")
subprocess.run(["git", "add", "-A", "docs"], check=True)
subprocess.run(["git", "commit", "-q", "-m", "e2 harness: hide measurement material (throwaway branch, never push)"], check=True)
print(W, "| hidden:", len(hide), "| log entries dropped:", len(dropped))
for d in dropped: print("   -", d)
