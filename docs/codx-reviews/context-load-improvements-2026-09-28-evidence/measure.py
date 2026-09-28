"""Read-only source measurements; generated candidates stay in this evidence directory."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
def wc(text):
    return int(subprocess.check_output(['wc', '-w'], input=text, text=True))
def read(path):
    return (ROOT / path).read_text()
def sections(text):
    return re.split(r'(?m)(?=^## )', text)
def save(name, text):
    (OUT / name).write_text(text)
    return wc(text)

claude = read('CLAUDE.md')
parts = sections(claude)
moves = {
    'Database & migrations': 'database.md',
    'Database backups': 'backups.md',
    'Data quality / tagging': 'tagging.md',
    'Catalog scope & series hierarchy': 'catalog.md',
    'Recommendation engine (`scripts/recommend.py`)': 'scoring.md',
    'v1 web app (`app/`, `api/`)': 'web.md',
}
counts = {}
candidate = []
for part in parts:
    title = part.splitlines()[0].removeprefix('## ')
    counts[title] = wc(part)
    if title in moves:
        save('moved-' + moves[title], part)
        candidate.append(part.splitlines()[0] + '\n\nRequired in full when this route applies: '
                         + '`docs/conventions/' + moves[title] + '`. Follow the startup routing table.\n\n')
    else:
        candidate.append(part)
candidate = ''.join(candidate)
route_addition = '''The conditional sections below are forwarding pointers to ordinary Markdown files.
Read the linked file in full for every matching route before acting; do not
auto-import those files or place them in an automatically loaded rules directory.
If scope is unclear, read all six linked convention files and the schema core.
Existing section links remain valid entry points, not substitutes for their targets.
'''
candidate = candidate.replace('## Persona system', route_addition + '\n## Persona system', 1)
a = save('A-CLAUDE.candidate.md', candidate)
old_warning = claude[claude.index("**If you're a sub-agent"):claude.index('Read the startup policy')]
btext = '''At fresh-session startup, read the current CLAUDE.md from disk once, including
all universal sections, and use it instead of any injected snapshot. Capture
a SHA-256 digest from those same bytes. A digest supplied without its source
text is not evidence that you have read that text. Before a new phase, after
a sync, and before DB, deployment or other persistent actions, compare current
file bytes with the last-read digest. If changed, reread the changed document
and reroute before acting. Apply the same check to every convention/reference
already relied on; newly required documents must be read before their route's
work. Never use headings, word counts or commit IDs as content freshness proof.
Only a verified loader receipt tying the exact injected bytes to a digest can
replace the first disk read. Without that receipt, do the disk read.

'''
ab = candidate.replace(old_warning, btext)
assert ab != candidate
ab_count = save('AB-CLAUDE.candidate.md', ab)

todo = read('docs/TODO.md')
# Preserve boundaries at the next checkbox or heading; non-item prose is retained.
pattern = re.compile(r'(?ms)^- \[([x ])\] .*?(?=^- \[[x ]\] |^## |\Z)')
closed = [m for m in pattern.finditer(todo) if m[1] == 'x']
opened = [m for m in pattern.finditer(todo) if m[1] == ' ']
archive = '# Completed TODO detail — archived from 2827739\n\nHistorical snapshots, not a new task queue. Active work remains in TODO.md.\n\n'
num = 0
def collapse(m):
    global archive, num
    if m[1] != 'x':
        return m[0]
    num += 1
    block = m[0]
    title = re.search(r'\*\*(.*?)\*\*', block, re.S)[1]
    archive += f'## done-{num:02}\n\n' + block + '\n'
    # Preserve the standalone P0 status paragraph, not part of its last item.
    suffix = ''
    if '\n*(' in block:
        suffix = '\n' + block[block.index('\n*('):].strip() + '\n'
    return f'- [x] **{title}** [Archived detail](TODO-completed.md#done-{num:02}).\n' + suffix + '\n'
d = pattern.sub(collapse, todo)
d = d.replace('**Audiobook edition data gaps: missing `runtime_minutes` (27% of rows), no `release_date` field.**',
              '**Audiobook runtime/release-date schema landed; data backfill remains open below.**')
closure = '''Before reducing a completed item to an archive pointer, inspect every phase
and follow-up it mentions. Link each unfinished phase to a live item or its
authoritative tracker, retaining its blocker or explicit deferral. Do not
archive an unfinished phase merely because the parent checkbox is checked.
Keep the original detail in TODO-completed.md; the roadmap remains TODO.md.

'''
d = d.replace('Priority is P0', closure + 'Priority is P0', 1)
followups = '''
- [ ] **Audiobook runtime/release-date backfill remains open.** Schema landed;
  data work remains in tag-audiobook-editions. Reconcile the P3 item's stale
  claim that date columns are not built before resuming. See archived edition-gap item.
- [ ] **Import-coverage admin display remains conditional.** Aggregation landed;
  no admin view yet. Resume when import volume justifies it; see archived aggregation item.
- [ ] **Recheck the recorded one-row audiobook-length local/hosted gap before closing it.**
  The archived backfill item reports deferred drift; verify current state first.

'''
d = d.replace('## P3 (blocked or parked -- check the blocker before picking up)\n',
              '## P3 (blocked or parked -- check the blocker before picking up)\n' + followups)
save('D-TODO.candidate.md', d)
save('D-TODO-completed.candidate.md', archive)

protocol = read('docs/scoring-test-protocol.md')
front = protocol[:protocol.index('## Second rater:')]
c_policy = '''## Reading contract (proposed)

Read this front section through "What's been tried" in full for scoring
behavior changes, scoring-semantic tests, and scalar-field proposals. Answer
all ten gate questions before implementing a scoring change. The table is
historical navigation, not a complete or authoritative current-status index.
Search the entire remaining protocol and project log for touched identifiers,
related concepts, old names and known failure modes. Read complete relevant
entries and their later corrections, not isolated matching lines. Consult
current code and contracts before treating a historical status as current.
Record search terms and the entries supporting the proposal. If a dependency
or reversal cannot be resolved, broaden the read, including the full history
when needed. No design change can be justified by a narrow search miss.

Always include the latest canonical-pipeline/module-import conventions and
metric-interpretation corrections when changing or evaluating scoring behavior.
Both failure scenarios and applicable current validation requirements remain
mandatory. This reading policy grants no implementation or benchmark authority.
For a scalar proposal failing an earlier gate, report that stop explicitly;
do not claim a complete design review or permission to bypass later gates.

'''
save('C-scoring-front.candidate.md', c_policy + front)
save('C-scoring-history.candidate.md', protocol[len(front):])

skill = read('.claude/skills/tag-catalog-batch/SKILL.md')
# Conservative: retain both DONE sections because they contain reused guidance.
# Report potential, not recommended, savings from omitting them.
skillparts = sections(skill)
skill_done = sum(wc(p) for p in skillparts if p.startswith('## Step 0 ('))
decisions = read('docs/schema/book-dna-decisions.md')
decision_base = ''.join(p for p in sections(decisions) if p.startswith('# Book DNA') or p.startswith('## Rejected /'))
save('C-decisions-required-slice.md', decision_base)

routes = {
    'CI reminder': ['Database backups'],
    'UI only': ['v1 web app (`app/`, `api/`)'],
    'Tag correction with DB read': ['Database & migrations','Data quality / tagging','Catalog scope & series hierarchy'],
    'Scoring without DB': ['Recommendation engine (`scripts/recommend.py`)','Catalog scope & series hierarchy'],
    'Scalar/schema': ['Database & migrations','Data quality / tagging','Catalog scope & series hierarchy','Recommendation engine (`scripts/recommend.py`)'],
}
routecounts = {}
for name, req in routes.items():
    r = sum(counts[k] for k in req)
    routecounts[name] = {'conditional': r, 'A_loaded_once': a+r, 'A_saving_vs_8893':wc(claude)-a-r,
                        'AB_injection_plus_first_disk_read':2*ab_count+r,
                        'AB_saving_vs_one_old_copy':wc(claude)-2*ab_count-r,
                        'AB_saving_vs_two_old_copies':2*wc(claude)-2*ab_count-r}

# Tracked-source searches only: no credentials, backups, or untracked reports.
files = subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0')
search = re.compile(r'CLAUDE\.md|TODO\.md|Database\s*&\s*migrations|Database\s+backups|Data quality\s*/\s*tagging|Catalog\s+scope|Recommendation\s+engine|v1[-\s]+web[-\s]+app', re.I)
refs = []
for file in filter(None,files):
    try: text = read(file)
    except (UnicodeError, OSError): continue
    for match in search.finditer(text):
        line = text.count('\n',0,match.start()) + 1
        refs.append({'path':file, 'line':line, 'match':match[0]})
save('references.json',json.dumps(refs,indent=2)+'\n')
gitgrep = subprocess.run(['git','grep','-n','-i','-E',r'CLAUDE\.md|TODO\.md|Database & migrations|Database backups|Data quality / tagging|Catalog scope|Recommendation engine|v1 web app'],cwd=ROOT,capture_output=True,text=True)
save('references-rg.txt',gitgrep.stdout)

result = {'baseline':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
          'source_sha256':hashlib.sha256(claude.encode()).hexdigest(), 'CLAUDE_sections_wc':counts,
          'A_root':a,'AB_root':ab_count,'routes':routecounts,
          'TODO':{'before':wc(todo),'closed_count':len(closed),'closed_block_words':sum(wc(m[0]) for m in closed),
                  'closed_checkbox_line_words':wc('\n'.join(l for l in todo.splitlines() if l.startswith('- [x]'))),
                  'open_checkbox_line_words':wc('\n'.join(l for l in todo.splitlines() if l.startswith('- [ ]'))),
                  'open_count':len(opened),'open_words':sum(wc(m[0]) for m in opened),'D_after':wc(d),'D_saved':wc(todo)-wc(d)},
          'protocol':{'full':wc(protocol),'front':wc(front),'history':wc(protocol)-wc(front),'C_front':wc(c_policy+front),'C_avoidable_before_lookups':wc(protocol)-wc(c_policy+front)},
          'decisions':{'full':wc(decisions),'base_slice':wc(decision_base),'avoidable_before_lookups':wc(decisions)-wc(decision_base)},
          'skill':{'full':wc(skill),'DONE_sections':skill_done},
          'schema_total':sum(wc(read('docs/schema/'+f)) for f in ['book-dna.md','book-dna-decisions.md','book-dna-tables.md','book-dna-vocabulary-gaps.md'])}
save('measurements.json',json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
