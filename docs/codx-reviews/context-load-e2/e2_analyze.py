import json, subprocess, sys, re, statistics, collections
sys.path.insert(0, '/Users/mathiaskurin/Documents/bookspell/scripts')
import measure_context_load as M
SP = sys.argv[1]
MAP = json.load(open(f'{SP}/e2_map.json'))
CONV = {'R1':['tagging','catalog','database'],'R2':['scoring','catalog'],'R3':['backups'],'R4':['web'],
        'R5':['tagging','catalog','scoring','database'],'T1':['web','tagging','catalog','database'],'T2':['tagging','catalog']}
FULL = {k:['CLAUDE.md','docs/TODO.md']+[f'docs/conventions/{c}.md' for c in v] for k,v in CONV.items()}
for k in ['R1','R2','R5','T1','T2']: FULL[k].append('docs/schema/book-dna.md')
for k in ['R5','T2']: FULL[k].append('docs/schema/book-dna.schema.yaml')
FULL['R5'].append('.claude/skills/tag-catalog-batch/SKILL.md')
SECT = {'R2':[('docs/scoring-test-protocol.md','front')],'R5':[('docs/scoring-test-protocol.md','front'),('docs/schema/book-dna-decisions.md','rejected')],
        'T2':[('docs/schema/book-dna-decisions.md','rejected')]}
def src(wt, rev, path):
    return subprocess.run(['git','-C',wt,'show',f'{rev}:{path}'],capture_output=True,text=True).stdout.split('\n')
def section_range(lines, kind):
    if kind=='front':
        end = next(i for i,l in enumerate(lines) if 'End of the always-read front section' in l)
        return 0, end
    a = next(i for i,l in enumerate(lines) if l.startswith('## Rejected / superseded'))
    b = next(i for i,l in enumerate(lines) if i>a and l.startswith('## '))
    return 0, b   # preamble through end of Rejected section (Deferred section sits between; counted too, conservative)
def coverage(m, wt, rev, path, rng=None):
    lines = src(wt, rev, path)
    lo, hi = rng or (0, len(lines))
    need = {i+1 for i in range(lo,hi) if lines[i].strip()}
    got = set()
    for e in m['events']:
        for sp in (e.get('matched_source_spans') or []):
            if sp['source'] == path:
                got.update(range(sp['start_line'], sp['end_line']+1))
    return len(need & got)/len(need) if need else 1.0
res = []
for arm in ('1','2'):
    wt = f'/Users/mathiaskurin/Documents/bookspell-copy-{arm}'
    rev = subprocess.run(['git','-C',wt,'rev-parse','HEAD'],capture_output=True,text=True).stdout.strip()
    for run,label,aid,f in MAP[arm]:
        t = label[:2]
        m = M.measure(f, repo=wt, revision=rev)
        cov = {p: coverage(m, wt, rev, p) for p in FULL[t]}
        for p,kind in SECT.get(t,[]):
            ls = src(wt, rev, p); cov[f'{p}#{kind}'] = coverage(m, wt, rev, p, section_range(ls, kind))
        rf = sum(1 for e in m['events'] if 'read_full.py' in (e.get('detail') or ''))
        res.append(dict(arm=arm, run=run, task=t, aid=aid, total=m['total_words'], returned=m['returned_words'],
                        injected=sum(m['injected_words'].values()), calls=m['tool_calls'],
                        tokens=sum(m['tokens'].values()), read_full_calls=rf, coverage=cov))
json.dump(res, open(f'{SP}/e2_results.json','w'), indent=1)
print('rows', len(res))
