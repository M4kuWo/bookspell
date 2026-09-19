import hashlib,pickle,sys
from pathlib import Path
E=Path(__file__).resolve().parent;root=E.parents[2]
sys.path.insert(0,str(root/'scripts'))
from scoring.catalog import load_catalog
catalog=load_catalog();data=pickle.dumps(catalog,protocol=4)
(E/'catalog.pickle').write_bytes(data)
print('READ-ONLY catalog snapshot:',len(catalog),'scored rows;',len(data),'bytes; SHA256',hashlib.sha256(data).hexdigest())
