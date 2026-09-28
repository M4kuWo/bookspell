#!/usr/bin/env python3
"""Count what a Claude Code sub-agent actually loaded, from its JSONL transcript.

Built for docs/context-load-measurement-protocol.md's Part 3 (CODX Task 25's
lever E). The measurement is taken from the transcript rather than an agent's
self-report, because self-reports round ("about 695 words") and agents that
know they're being measured behave differently.

Counts, per transcript:
  - injected: words of each file Claude Code injected via the `instructions`
    attachment (normally the full CLAUDE.md), counted separately from reads.
  - returned: words of every tool result actually returned to the model,
    attributed to a source file when the call names one. Repeated reads count
    repeatedly: that's real context cost. `wc`/`grep` output counts as the
    few words it returned, not as the file it described.
  - tokens: summed API usage, plus the peak single-request context.

Usage:
  python3 scripts/measure_context_load.py <transcript.jsonl> [...] [--json]
Transcripts live at ~/.claude/projects/<project>/<session>/subagents/agent-<id>.jsonl.
"""
import json
import re
import sys
from collections import defaultdict

REPO = "/Users/mathiaskurin/Documents/bookspell/"
# Paths worth attributing a Bash call's output to, longest first so a
# specific file wins over its directory.
PATH_RE = re.compile(
    r"((?:/Users/[^\s'\"]+/bookspell/)?"
    r"(?:CLAUDE\.md|AGENTS\.md|README\.md|docs/[\w./-]+|\.claude/[\w./-]+|"
    r"scripts/[\w./-]+|app/[\w./-]+|api/[\w./-]+|\.github/[\w./-]+|supabase/[\w./-]+))"
)


def words(text):
    return len(text.split())


def result_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(c.get("text", "") for c in content if isinstance(c, dict))
    return ""


def norm(path):
    return path.replace(REPO, "") if path else path


def source_for(name, inp):
    if name == "Read":
        return norm(inp.get("file_path", "?"))
    if name in ("Grep", "Glob"):
        return f"<{name.lower()}> " + norm(inp.get("path", "") or ".")
    if name == "Bash":
        found = PATH_RE.findall(inp.get("command", ""))
        return norm(found[0]) if found else "<bash, no file>"
    return f"<{name}>"


def measure(path):
    rows = [json.loads(line) for line in open(path) if line.strip()]
    injected = {}
    pending = {}  # tool_use_id -> (name, source, input)
    per_source = defaultdict(lambda: {"words": 0, "calls": 0})
    events = []
    tok = defaultdict(int)
    peak = 0
    for r in rows:
        if r.get("type") == "attachment" and r["attachment"].get("type") == "instructions":
            for f in r["attachment"].get("files", []):
                injected[norm(f.get("path", "?"))] = words(f.get("content", ""))
        msg = r.get("message")
        if not isinstance(msg, dict):
            continue
        if r["type"] == "assistant":
            u = msg.get("usage") or {}
            for k in ("input_tokens", "cache_creation_input_tokens",
                      "cache_read_input_tokens", "output_tokens"):
                tok[k] += u.get(k, 0) or 0
            ctx = sum(u.get(k, 0) or 0 for k in
                      ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
            peak = max(peak, ctx)
            for c in msg.get("content", []):
                if c.get("type") == "tool_use":
                    pending[c["id"]] = (c["name"], source_for(c["name"], c.get("input", {})), c.get("input", {}))
        elif r["type"] == "user" and isinstance(msg.get("content"), list):
            for c in msg["content"]:
                if c.get("type") != "tool_result":
                    continue
                name, src, inp = pending.pop(c["tool_use_id"], ("?", "?", {}))
                w = words(result_text(c.get("content")))
                per_source[src]["words"] += w
                per_source[src]["calls"] += 1
                events.append({"tool": name, "source": src, "words": w,
                               "error": bool(c.get("is_error")),
                               "detail": (inp.get("command") or inp.get("file_path") or inp.get("pattern") or "")[:160]})
    returned = sum(v["words"] for v in per_source.values())
    return {
        "transcript": path,
        "injected_words": injected,
        "returned_words": returned,
        "total_words": returned + sum(injected.values()),
        "per_source": dict(sorted(per_source.items(), key=lambda kv: -kv[1]["words"])),
        "tool_calls": len(events),
        "events": events,
        "tokens": dict(tok),
        "peak_context_tokens": peak,
    }


def main():
    args = [a for a in sys.argv[1:] if a != "--json"]
    out = [measure(p) for p in args]
    if "--json" in sys.argv:
        json.dump(out, sys.stdout, indent=1)
        return
    for m in out:
        print(f"== {m['transcript']}")
        print(f"   injected: {m['injected_words']}")
        print(f"   returned by tools: {m['returned_words']} words over {m['tool_calls']} calls;"
              f" total incl. injection: {m['total_words']}")
        print(f"   tokens: {m['tokens']}  peak context: {m['peak_context_tokens']}")
        for src, v in m["per_source"].items():
            print(f"     {v['words']:>7}  x{v['calls']:<3} {src}")


if __name__ == "__main__":
    main()
