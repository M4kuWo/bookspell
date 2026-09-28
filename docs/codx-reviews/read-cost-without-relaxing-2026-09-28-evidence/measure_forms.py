"""Measure candidate forms against pinned after-arm sources, never edit tracked files."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
from read_full import pages, render

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
REV = '65cbe69'
def read(path):
    return subprocess.check_output(['git', '-C', str(ROOT), 'show', f'{REV}:{path}'])
def wc(data):
    return int(subprocess.check_output(['wc', '-w'], input=data))

ROUTES = {
    'R1-tagging': ['tagging', 'database', 'catalog'],
    'R2-scoring': ['scoring', 'catalog'],
    'R3-ci': ['backups'],
    'R4-ui': ['web'],
    'R5-scalar': ['tagging', 'database', 'catalog', 'scoring'],
    'T1-audiobook-panel': ['tagging', 'database', 'catalog', 'web'],
    'T2-possession-trope': ['tagging', 'catalog'],
}

def bundle(names):
    inputs = [(f'docs/conventions/{n}.md', read(f'docs/conventions/{n}.md')) for n in names]
    if len(inputs) == 1:
        return inputs[0][1], {'sources': [inputs[0][0]], 'identity': True}
    notice = re.compile(rb'\*Moved verbatim.*?\*', re.S)
    common = [notice.search(data).group() for _, data in inputs]
    assert len(set(common)) == 1, 'notices differ: fail rather than discard a rule'
    # All shared words appear once and are explicitly scoped to every source below.
    result = b'# Convention reading bundle\n\nThe following shared notice applies to every source below.\n\n' + common[0] + b'\n\n'
    manifest = {'revision': REV, 'shared_notice_sha256': hashlib.sha256(common[0]).hexdigest(), 'sources': []}
    for path, data in inputs:
        start, end = notice.search(data).span()
        remainder = data[:start] + data[end:]
        assert remainder[:start] + common[0] + remainder[start:] == data
        result += f'## Source: {path}\n\n'.encode() + remainder + b'\n'
        manifest['sources'].append({'path': path, 'sha256': hashlib.sha256(data).hexdigest(),
                                    'shared_insertion_byte': start})
    return result, manifest

sources = ['docs/schema/book-dna.schema.yaml', 'docs/schema/book-dna.md',
           '.claude/skills/tag-catalog-batch/SKILL.md', 'docs/TODO.md']
result = {'baseline_after': REV, 'source_forms': {}, 'routes': {}}
for source in sources:
    data = read(source)
    chunks = pages(data)
    delivered = sum(wc(render(source, data, i+1)) for i in range(len(chunks)))
    numbered = b''.join(str(i).encode()+b'\t'+line for i,line in enumerate(data.splitlines(True),1))
    result['source_forms'][source] = {'plain_words':wc(data),'lines':len(data.splitlines()),
                                    'numbered_words':wc(numbered), 'pages':len(chunks),
                                    'paged_words':delivered, 'saving_vs_numbered':wc(numbered)-delivered}
yaml = read(sources[0]).decode()
full = [l for l in yaml.splitlines() if l.lstrip().startswith('#')]
inline = [l.split('#',1)[1] for l in yaml.splitlines() if '#' in l and not l.lstrip().startswith('#')]
result['yaml_comments'] = {'full_line_count':len(full),
    'full_line_prose_words':wc('\n'.join(re.sub(r'^\s*# ?', '',l) for l in full).encode()),
    'inline_prose_words':wc('\n'.join(inline).encode())}

for task, names in ROUTES.items():
    data, manifest = bundle(names)
    (OUT / (task + '-conventions.candidate.md')).write_bytes(data)
    (OUT / (task + '-manifest.json')).write_text(json.dumps(manifest,indent=2)+'\n')
    old = sum(wc(read('docs/conventions/'+n+'.md')) for n in names)
    new = wc(data)
    chunked = sum(wc(render(task, data, i+1)) for i in range(len(pages(data))))
    result['routes'][task]={'conventions_before':old, 'conventions_bundle':new,
                            'bundle_saved':old-new, 'paged_bundle':chunked}

skill = read('.claude/skills/tag-catalog-batch/SKILL.md').decode()
parts = re.split(r'(?m)(?=^## )',skill)
done = ''.join(p for p in parts if p.startswith('## Step 0 ('))
main = ''.join(p for p in parts if not p.startswith('## Step 0 ('))
pointer = '\nFull-read requirement covers both this file and references/completed-batches.md. Read the companion in full, including calibration anchors and historical SQL; it is not optional.\n'
companion = '# Completed batch references\n\n' + done
(OUT/'skill-main.candidate.md').write_text(main+pointer)
(OUT/'skill-reference.candidate.md').write_text(companion)
result['skill_split']={'before':wc(skill.encode()), 'done':wc(done.encode()),
    'main':wc((main+pointer).encode()),'companion':wc(companion.encode()),
    'total':wc((main+pointer+companion).encode())}

(OUT/'form-measurements.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
