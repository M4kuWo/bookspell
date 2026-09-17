import json,re,urllib.request,urllib.parse
from pathlib import Path
s=Path('app/shared.js').read_text();u=re.search(r"const SUPABASE_URL = '([^']+)'",s)[1];k=re.search(r"const SUPABASE_ANON_KEY = '([^']+)'",s)[1]
a=json.loads(Path('/private/tmp/codx-task9/hosted.json').read_text());ids='in.('+','.join(b['id'] for b in a['books'])+')'
url=u+'/rest/v1/books?'+urllib.parse.urlencode({'select':'*','id':ids})
with urllib.request.urlopen(urllib.request.Request(url,headers={'apikey':k}),timeout=60) as r:rows=json.load(r)
Path('/private/tmp/codx-task9/identities.json').write_text(json.dumps(rows,indent=2,ensure_ascii=False)+'\n')
for b in rows:print(json.dumps(b,ensure_ascii=False))
