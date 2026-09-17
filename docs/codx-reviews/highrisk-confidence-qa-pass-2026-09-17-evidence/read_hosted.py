import json,re,urllib.request,urllib.parse,datetime
from pathlib import Path
s=Path('app/shared.js').read_text()
u=re.search(r"const SUPABASE_URL = '([^']+)'",s)[1];k=re.search(r"const SUPABASE_ANON_KEY = '([^']+)'",s)[1]
log=[]
def get(table,params):
 q=urllib.parse.urlencode(params);req=urllib.request.Request(u+'/rest/v1/'+table+'?'+q,headers={'apikey':k})
 with urllib.request.urlopen(req,timeout=60) as r:data=json.load(r)
 log.append({'table':table,'params':params,'rows':len(data)});return data
# Reading the catalog's public bibliographic fields also disambiguates titles.
books=[]
while True:
 page=get('books',{'select':'id,title,author,hardcover_id','order':'title,id','limit':'1000','offset':str(len(books))})
 books.extend(page)
 if len(page)<1000:break
titles=['Shroud','Gateway','Soulless','Congo','Dreamcatcher','Fall; or, Dodge in Hell','Fall or, Dodge in Hell','Gods of Jade and Shadow','Legion','Lord of Light','Pushing Ice','Shards of Honour','Six Wakes','The Bright Sword','The Deep Sky','Accelerando','Annie Bot','The Echo Wife','Ilium']
selected=[b for b in books if b['title'] in titles];ids='in.('+','.join(b['id'] for b in selected)+')'
dna=get('book_dna',{'select':'book_id,person,pov_count,humor_level,narrator_reliability,drive','book_id':ids})
confidence=get('book_field_confidence',{'select':'book_id,field_name,confidence,source','book_id':ids})
humor=get('book_field_confidence',{'select':'book_id,field_name,confidence,source','field_name':'eq.humor_level','confidence':'eq.0.5'})
byid={b['id']:b for b in books}
out={'fetched_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'books':selected,'dna':dna,'confidence':confidence,'humor_half_catalog':[dict(c,book=byid.get(c['book_id'])) for c in humor],'queries':log}
p=Path('/private/tmp/codx-task9/hosted.json');p.write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
for b in selected:
 d=next(x for x in dna if x['book_id']==b['id']);c={x['field_name']:x['confidence'] for x in confidence if x['book_id']==b['id']}
 print(json.dumps(dict(book=b,values=d,confidence=c),ensure_ascii=False))
print('HUMOR_HALF:',json.dumps(out['humor_half_catalog'],ensure_ascii=False))
print('READ_ONLY_GETS:',json.dumps(log));print('Saved:',p)
