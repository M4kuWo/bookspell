"""Recount the 14 recorded runs; use only transcript paths recorded in repo evidence."""
import json
from pathlib import Path
import subprocess
from measure_context_load import measure
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent
summary={}
for arm, revision in [('before','ec00669'),('after','65cbe69')]:
    original=json.loads((ROOT/f'docs/codx-reviews/context-load-e/e-{arm}-results.json').read_text())
    results={name:measure(value['transcript'],str(ROOT),revision) for name,value in original.items()}
    assert all(results[name]['total_words']==old['total_words'] for name,old in original.items())
    (OUT/f'recount-{arm}.json').write_text(json.dumps(results,indent=2)+'\n')
    summary[arm]={}
    for name,result in results.items():
        coverage={}
        for source in ['docs/TODO.md','docs/schema/book-dna.md','docs/schema/book-dna.schema.yaml','.claude/skills/tag-catalog-batch/SKILL.md']:
            lines=subprocess.check_output(['git','-C',str(ROOT),'show',f'{revision}:{source}'],text=True).splitlines()
            required={i for i,line in enumerate(lines,1) if line.strip()}
            seen=set()
            for event in result['events']:
                for span in event['matched_source_spans']:
                    if span['source']==source: seen.update(range(span['start_line'],span['end_line']+1))
            coverage[source]={'matched_nonblank':len(required&seen),'total_nonblank':len(required),'complete':required<=seen}
        summary[arm][name]={'total_words':result['total_words'],'coverage':coverage,
            'TODO':result['per_source'].get('docs/TODO.md',{}),
            'log':result['per_source'].get('docs/project-log.md',{})}
(OUT/'audit-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print('14/14 original total_words preserved; pinned-source coverage saved to audit-summary.json')
