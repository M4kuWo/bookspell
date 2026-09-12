// Shared client/helpers for every page in app/. Loaded after the
// supabase-js CDN script tag (see each page's <head>).
//
// Same hosted project + anon/publishable key tools/catalog-review and
// tools/rate-books already ship client-side -- it's a public, RLS-gated
// key, safe to embed (see their own READMEs on why this is fine).
const SUPABASE_URL = 'https://yhvubjqstswxvctdikbc.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_DXG7hpWr3UEnDGT60DcKZg_hbRNDUXI';

// The backend API's base URL (api/, deployed to Render -- see
// api/README.md). PLACEHOLDER until that deployment exists; update
// this one line once the Render service is live, nothing else needs
// to change.
const API_BASE = 'https://bookspell-api.onrender.com';

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}
function escapeAttr(s) {
  return escapeHtml(s).replace(/"/g, '&quot;');
}

function showToast(msg) {
  const el = document.getElementById('toast');
  if (!el) return;
  el.textContent = msg;
  el.classList.add('show');
  clearTimeout(showToast._t);
  showToast._t = setTimeout(() => el.classList.remove('show'), 2600);
}

// Redirects to index.html (with the current page remembered) if no
// one's signed in. Call at the top of every page except index.html
// itself. Returns the current session once resolved.
async function requireAuth() {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) {
    window.location.href = `index.html?next=${encodeURIComponent(location.pathname.split('/').pop())}`;
    return null;
  }
  return session;
}

// Every call to our own backend (api/) needs the user's Supabase JWT --
// supabase-js keeps it fresh (auto-refreshes before expiry), just read
// it fresh each call rather than caching it ourselves.
async function apiFetch(path, options = {}) {
  const { data: { session } } = await sb.auth.getSession();
  const headers = { ...(options.headers || {}), Authorization: `Bearer ${session?.access_token || ''}` };
  return fetch(`${API_BASE}${path}`, { ...options, headers });
}

function renderNav(active) {
  const items = [
    ['dashboard.html', 'Recommendations'],
    ['rate.html', 'My ratings'],
    ['import.html', 'Import'],
  ];
  const nav = document.getElementById('top-nav');
  if (!nav) return;
  nav.innerHTML = items.map(([href, label]) =>
    `<a href="${href}" class="${active === href ? 'active' : ''}">${label}</a>`
  ).join('') + `<a href="#" id="sign-out-link">Sign out</a>`;
  document.getElementById('sign-out-link').addEventListener('click', async (e) => {
    e.preventDefault();
    await sb.auth.signOut();
    window.location.href = 'index.html';
  });
}
