import pickle, sys, hashlib
from pathlib import Path
E = Path(__file__).resolve().parent
sys.path.insert(0, str(E.parents[2] / 'scripts'))
import recommend as R
catalog = R.load_catalog()
data = pickle.dumps(catalog, protocol=4)
(E / 'catalog.pickle').write_bytes(data)
print('Read-only catalog snapshot:', len(catalog), 'books;', len(data), 'bytes; sha256', hashlib.sha256(data).hexdigest())
