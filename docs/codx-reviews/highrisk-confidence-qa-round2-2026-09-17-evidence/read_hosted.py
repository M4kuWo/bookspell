import datetime
import json
import re
import urllib.parse
import urllib.request
from pathlib import Path

root = Path(__file__).resolve().parents[3]
source = (root / 'app/shared.js').read_text()
url = re.search(r"const SUPABASE_URL = '([^']+)'", source)[1]
key = re.search(r"const SUPABASE_ANON_KEY = '([^']+)'", source)[1]
queries = []

def get(table, params):
    request = urllib.request.Request(url + '/rest/v1/' + table + '?' + urllib.parse.urlencode(params), headers={'apikey': key})
    with urllib.request.urlopen(request, timeout=45) as response:
        rows = json.load(response)
    queries.append(dict(table=table, params=params, rows=len(rows)))
    return rows

task = (root / 'docs/codx-tasks/current-task.md').read_text()
pairs = []
for line in task.splitlines():
    if line.startswith('| ') and re.search(r'\| 0\.[34] \|$', line):
        title, author, field, confidence = [s.strip() for s in line.strip('|').split('|')]
        pairs.append(dict(title=title, author=author, field=field, assigned_confidence=float(confidence)))
assert len(pairs) == 20
books = []
while True:
    page = get('books', dict(select='id,title,author,hardcover_id,isbn,publication_year,synopsis,series_id', order='id', limit=1000, offset=len(books)))
    books.extend(page)
    if len(page) < 1000:
        break
selected = []
for title, author in dict.fromkeys((p['title'], p['author']) for p in pairs):
    matches = [b for b in books if b['title'] == title and b['author'] == author]
    assert len(matches) == 1, (title, author, matches)
    selected.extend(matches)
ids = 'in.(' + ','.join(b['id'] for b in selected) + ')'
dna = get('book_dna', dict(select='*', book_id=ids))
confidence = get('book_field_confidence', dict(select='*', book_id=ids))
for pair in pairs:
    book = next(b for b in selected if (b['title'], b['author']) == (pair['title'], pair['author']))
    row = next(d for d in dna if d['book_id'] == book['id'])
    conf = next(c for c in confidence if c['book_id'] == book['id'] and c['field_name'] == pair['field'])
    pair.update(book_id=book['id'], value=row[pair['field']], confidence=conf['confidence'], source=conf['source'])
out = dict(fetched_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(), books=selected, dna=dna, confidence=confidence, pairs=pairs, queries=queries)
Path(__file__).with_name('hosted.json').write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n')
for pair in pairs:
    print(json.dumps(pair, ensure_ascii=False))
print('READ_ONLY_GETS:', json.dumps(queries))
