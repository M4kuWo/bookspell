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
    attributed conservatively using pinned source text when supplied. Repeated reads count
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
import argparse
import difflib
import shlex
import subprocess
from collections import defaultdict
from pathlib import Path, PurePosixPath

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
        return "<bash, unattributed>"
    return f"<{name}>"


def candidates(name, inp):
    """Candidate sources only. Never execute a recorded command or expand shell code."""
    if name == 'Read':
        return [norm(inp.get('file_path', '?'))]
    command = inp.get('command', '')
    result = set(norm(p) for p in PATH_RE.findall(command))
    try:
        lex = shlex.shlex(command, posix=True, punctuation_chars=';&|')
        lex.whitespace_split = True
        segments, current = [], []
        for token in lex:
            if token in (';', '&&', '||', '|'):
                segments.append(current)
                current = []
            else:
                current.append(token)
        segments.append(current)
        cwd = ''
        for seg in segments:
            if not seg:
                continue
            if seg[0] == 'cd' and len(seg) == 2:
                cwd = norm(seg[1]).rstrip('/')
                # Original repo root is stripped to an empty string by norm().
                if cwd == REPO.rstrip('/'):
                    cwd = ''
            elif seg[0] in ('cat', 'sed'):
                for token in seg[1:]:
                    if token.startswith('-') or not re.search(r'\.(?:md|yaml|yml|py|js|html|css)$', token):
                        continue
                    token = norm(token)
                    result.add(str(PurePosixPath(cwd) / token) if cwd and not token.startswith('/') else token)
    except ValueError:
        pass  # Heredocs/complex shell remain explicitly unresolved.
    return sorted(result)


class Reference:
    """Pinned git text, not mutable files from the transcript's original working tree."""
    def __init__(self, repo, revision):
        self.repo, self.revision, self.cache = repo, revision, {}

    def get(self, path):
        if not self.repo or not self.revision or path.startswith('/') or '..' in PurePosixPath(path).parts:
            return None
        if path not in self.cache:
            proc = subprocess.run(['git', '-C', self.repo, 'show', f'{self.revision}:{path}'],
                                  capture_output=True, text=True)
            self.cache[path] = proc.stdout if proc.returncode == 0 else None
        return self.cache[path]


def attribute(text, sources, reference, numbered=False):
    """Conservative exact-line matching; ambiguity is retained, never guessed away.

    Per-source words are proven source content, not line-number/wrapper overhead.
    Returned-word totals still count every byte-derived word, including overhead.
    Matching establishes returned text only, never that an agent understood it.
    """
    lines = text.splitlines()
    clean = [re.sub(r'^\s*\d+[\t→]', '', l) if numbered else l for l in lines]
    owners = [set() for _ in clean]
    full = []
    spans = []
    for source in sources:
        body = reference.get(source)
        if body is None:
            continue
        src = body.splitlines()
        blocks = difflib.SequenceMatcher(None, src, clean, autojunk=False).get_matching_blocks()
        matched = set()
        for block in blocks:
            chunk = src[block.a:block.a + block.size]
            # Avoid attributing common syntax/blank lines as evidence of a source.
            if sum(bool(l.strip()) for l in chunk) < 2 or words('\n'.join(chunk)) < 12:
                continue
            for j in range(block.size):
                owners[block.b + j].add(source)
                matched.add(block.a + j)
            spans.append({'source': source, 'start_line': block.a + 1,
                          'end_line': block.a + block.size})
        if src and all(i in matched for i, line in enumerate(src) if line.strip()):
            full.append(source)
    parts = defaultdict(int)
    for original, decoded, owner in zip(lines, clean, owners):
        if len(owner) == 1:
            parts[next(iter(owner))] += words(decoded)
            parts['<delivery overhead>'] += words(original) - words(decoded)
        else:
            parts['<mixed/unattributed>'] += words(original)
    assert sum(parts.values()) == words(text)
    return {k: v for k, v in parts.items() if v}, spans, full


def measure(path, repo=None, revision=None):
    with open(path) as stream:
        rows = [json.loads(line) for line in stream if line.strip()]
    injected = {}
    pending = {}  # tool_use_id -> (name, source, input)
    per_source = defaultdict(lambda: {"words": 0, "calls": 0})
    events = []
    tok = defaultdict(int)
    peak = 0
    reference = Reference(repo, revision)
    persisted = {}  # path -> originating tool id and all its candidate sources
    injection_events = []
    for r in rows:
        if r.get("type") == "attachment" and r["attachment"].get("type") == "instructions":
            for f in r["attachment"].get("files", []):
                source = norm(f.get("path", "?"))
                count = words(f.get("content", ""))
                injected[source] = injected.get(source, 0) + count
                injection_events.append({'source': source, 'words': count})
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
                text = result_text(c.get("content"))
                w = words(text)
                sources = candidates(name, inp)
                origin = None
                if name == 'Read' and inp.get('file_path') in persisted:
                    origin, sources = persisted[inp['file_path']]
                marker = re.search(r'Full output saved to:\s*(\S+)', text)
                if marker:
                    persisted[marker[1]] = (c['tool_use_id'], sources)
                # Never open saved output automatically: only tool-returned text counts.
                if c.get('is_error'):
                    parts, spans, full = {'<error output>': w}, [], []
                elif repo and revision:
                    parts, spans, full = attribute(text, sources, reference, numbered=name == 'Read')
                elif name == 'Read' and not origin:
                    parts, spans, full = {src: w}, [], []
                else:
                    parts, spans, full = {'<mixed/unattributed>': w}, [], []
                for source, count in parts.items():
                    per_source[source]['words'] += count
                    per_source[source]['calls'] += 1
                events.append({"tool": name, "source": src, "words": w,
                               "error": bool(c.get("is_error")),
                               "tool_use_id": c['tool_use_id'], 'candidate_sources': sources,
                               'origin_tool_use_id': origin, 'attribution': parts,
                               'matched_source_spans': spans, 'full_source_matches': full,
                               'persisted_output_path': marker[1] if marker else None,
                               'truncated_or_persisted': bool(marker or re.search(r'truncated|Output too large', text, re.I)),
                               # Keep complete input: the previous 160-character cut hid later cat/sed segments.
                               "detail": (inp.get("command") or inp.get("file_path") or inp.get("pattern") or "")})
    returned = sum(v["words"] for v in per_source.values())
    return {
        "transcript": path,
        "injected_words": injected,
        'injection_events': injection_events,
        'reference_revision': revision,
        "returned_words": returned,
        "total_words": returned + sum(injected.values()),
        "per_source": dict(sorted(per_source.items(), key=lambda kv: -kv[1]["words"])),
        "tool_calls": len(events),
        "events": events,
        "tokens": dict(tok),
        "peak_context_tokens": peak,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('transcripts', nargs='+')
    parser.add_argument('--json', action='store_true')
    parser.add_argument('--repo-root', help='Local checkout used only for git show; no transcript command executes')
    parser.add_argument('--revision', help='Pinned source revision for exact output attribution')
    args = parser.parse_args()
    if bool(args.repo_root) != bool(args.revision):
        parser.error('--repo-root and --revision must be supplied together')
    out = [measure(p, args.repo_root, args.revision) for p in args.transcripts]
    if args.json:
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
