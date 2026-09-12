// Shared client/helpers for every page in app/. Loaded after the
// supabase-js CDN script tag (see each page's <head>).
//
// Same hosted project + anon/publishable key tools/catalog-review and
// tools/rate-books already ship client-side -- it's a public, RLS-gated
// key, safe to embed (see their own READMEs on why this is fine).
const SUPABASE_URL = 'https://yhvubjqstswxvctdikbc.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_DXG7hpWr3UEnDGT60DcKZg_hbRNDUXI';

// The backend API's base URL (api/, deployed to Render -- see
// api/README.md). Live as of 2026-09-12: verified GET /rule-targets
// returns real catalog data and GET /recommendations correctly 401s
// without a token. Free tier spins down after 15 min idle -- the first
// request in a while can take 30-60s (see the "waking up" loading
// states in dashboard.html/import.html).
const API_BASE = 'https://bookspell-api.onrender.com';

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Theme: 'system' (default, no localStorage entry -- follows the OS via
// the plain @media query in shared.css), or an explicit 'light'/'dark'
// override stamped on <html data-theme> and remembered per-browser.
// Applied on every page load (including index.html, pre-auth) so the
// choice made from the nav's toggle sticks everywhere.
function applyStoredTheme() {
  try {
    const stored = localStorage.getItem('bookspell-theme');
    if (stored === 'light' || stored === 'dark') {
      document.documentElement.setAttribute('data-theme', stored);
    }
  } catch (e) { /* private-mode/blocked storage -- just use system default */ }
}
function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  const isDark = current === 'dark' || (!current && window.matchMedia('(prefers-color-scheme: dark)').matches);
  const next = isDark ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  try { localStorage.setItem('bookspell-theme', next); } catch (e) { /* ignore */ }
}
applyStoredTheme();

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
  await ensureProfile(session);
  return session;
}

// A `profiles` row is created lazily on first authenticated page load
// rather than via a DB trigger -- signUp() itself can't write it directly
// since a brand-new signup has no active session yet when email
// confirmation is required (see index.html). display_name comes from the
// `options.data` passed to signUp(), which Supabase stores on the user
// regardless of confirmation status, so it's available here the first
// time that user actually gets a real session.
async function ensureProfile(session) {
  const { data: existing } = await sb.from('profiles').select('id').eq('id', session.user.id).maybeSingle();
  if (existing) return;
  const displayName = session.user.user_metadata?.display_name || null;
  await sb.from('profiles').insert({ id: session.user.id, display_name: displayName });
}

function displayNameFor(session) {
  return session.user.user_metadata?.display_name || session.user.email.split('@')[0];
}

function initials(name) {
  return name.trim().split(/\s+/).slice(0, 2).map((w) => w[0].toUpperCase()).join('') || '?';
}

// Every call to our own backend (api/) needs the user's Supabase JWT --
// supabase-js keeps it fresh (auto-refreshes before expiry), just read
// it fresh each call rather than caching it ourselves.
async function apiFetch(path, options = {}) {
  const { data: { session } } = await sb.auth.getSession();
  const headers = { ...(options.headers || {}), Authorization: `Bearer ${session?.access_token || ''}` };
  return fetch(`${API_BASE}${path}`, { ...options, headers });
}

// Only 2 top-level destinations -- Import lives inside rate.html instead
// (a link there, not its own tab) since it's a one-off action, not
// something visited as often as the other two.
function renderNav(active, session) {
  const items = [
    ['dashboard.html', 'Recommendations'],
    ['rate.html', 'My ratings'],
  ];
  const nav = document.getElementById('top-nav');
  if (!nav) return;
  const name = session ? displayNameFor(session) : '';
  nav.innerHTML = items.map(([href, label]) =>
    `<a href="${href}" class="${active === href ? 'active' : ''}">${label}</a>`
  ).join('') + `
    <span class="nav-spacer"></span>
    <button class="theme-toggle" id="theme-toggle-btn" title="Toggle dark/light" type="button">◐</button>
    <div class="account-menu">
      <button class="avatar-btn" id="account-btn" type="button" title="${escapeAttr(name)}">${escapeHtml(initials(name))}</button>
      <div class="account-dropdown" id="account-dropdown" hidden>
        <div class="who">${escapeHtml(name)}</div>
        <button type="button" id="sign-out-btn">Sign out</button>
      </div>
    </div>
  `;
  document.getElementById('theme-toggle-btn').addEventListener('click', toggleTheme);
  const dropdown = document.getElementById('account-dropdown');
  document.getElementById('account-btn').addEventListener('click', (e) => {
    e.stopPropagation();
    dropdown.hidden = !dropdown.hidden;
  });
  document.addEventListener('click', () => { dropdown.hidden = true; });
  document.getElementById('sign-out-btn').addEventListener('click', async () => {
    await sb.auth.signOut();
    window.location.href = 'index.html';
  });
}
