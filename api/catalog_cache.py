"""In-process cache around recommend.py's load_catalog() -- that call
opens a fresh DB connection and does a full-catalog scan every time
(confirmed, not assumed -- see the plan's research pass), so calling it
per-request would make every API request pay that cost. The same
reasoning tools/dogfood/app.py already demonstrates via
`@st.cache_resource`, just without a Streamlit runtime to lean on here.

Refreshed on a timer (default 15 min) rather than never, since new
tagging batches land periodically from the other working session and
this service has no other way to learn about them."""
import threading
import time

import recommend as R

REFRESH_SECONDS = 15 * 60

_lock = threading.Lock()
_catalog = None
_loaded_at = 0.0


def get_catalog():
    global _catalog, _loaded_at
    now = time.time()
    with _lock:
        if _catalog is None or (now - _loaded_at) > REFRESH_SECONDS:
            _catalog = R.load_catalog()
            _loaded_at = now
        return _catalog


def force_refresh():
    """Manual override -- not wired to an endpoint yet (no auth model
    for "admin" actions exists in this API), call directly if a session
    needs the cache invalidated sooner than the timer."""
    global _catalog, _loaded_at
    with _lock:
        _catalog = R.load_catalog()
        _loaded_at = time.time()
    return _catalog
