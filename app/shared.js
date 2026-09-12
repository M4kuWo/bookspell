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

// -- Book info modal (feedback item #11) -------------------------------
// One overlay element, created once per page and reused, rather than a
// separate <dialog> markup block duplicated into every page -- any page
// that wants a "book info" button just calls showBookInfo(bookId).
const DNA_FIELD_ORDER = [
  'genre', 'age_category', 'book_length', 'pov_count', 'person', 'narrator_reliability',
  'timeline', 'form', 'overall_pace', 'pace_shape', 'drive', 'darkness', 'humor_level',
  'emotional_register', 'message_intensity', 'romance_heat_frequency', 'romance_heat_intensity',
  'romance_tone', 'violence_frequency', 'violence_intensity', 'worldbuilding_density',
  'worldbuilding_delivery', 'narrative_closure', 'emotional_resolution', 'ends_on_cliffhanger',
  'magic_system_hardness', 'scifi_hardness', 'prose_density', 'prose_complexity',
  'intellectual_weight', 'stakes_scope', 'personal_stakes', 'genre_accessibility',
];
const DNA_AUDIOBOOK_FIELD_ORDER = [
  'audiobook_length', 'narrator_performance', 'narrator_cast', 'narration_pace_vs_prose',
  'accent_authenticity', 'production_quality',
];

function titleCase(s) {
  return String(s).replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}
function formatDnaValue(v) {
  if (v === null || v === undefined) return null;
  if (Array.isArray(v)) return v.map(titleCase).join(', ');
  return titleCase(v);
}

function ensureModalEl() {
  let overlay = document.getElementById('book-info-overlay');
  if (overlay) return overlay;
  overlay = document.createElement('div');
  overlay.id = 'book-info-overlay';
  overlay.className = 'modal-overlay';
  overlay.hidden = true;
  overlay.innerHTML = '<div class="modal-box" id="book-info-box"></div>';
  overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(); });
  document.body.appendChild(overlay);
  return overlay;
}
function closeModal() {
  const overlay = document.getElementById('book-info-overlay');
  if (overlay) overlay.hidden = true;
}

async function showBookInfo(bookId) {
  const overlay = ensureModalEl();
  const box = document.getElementById('book-info-box');
  box.innerHTML = '<div class="empty-state">Loading…</div>';
  overlay.hidden = false;

  const [{ data: book }, { data: dna }, { data: tropeRows }, { data: cwRows }] = await Promise.all([
    sb.from('books').select('title, author, synopsis, page_count, publication_year, cover_url').eq('id', bookId).maybeSingle(),
    sb.from('book_dna').select('*').eq('book_id', bookId).maybeSingle(),
    sb.from('book_tropes').select('trope_id').eq('book_id', bookId),
    sb.from('book_content_warnings').select('warning_id, severity').eq('book_id', bookId),
  ]);

  if (!book) {
    box.innerHTML = `<div class="modal-header"><span class="modal-title">Not found</span><button class="modal-close" id="modal-close-btn">✕</button></div>`;
    document.getElementById('modal-close-btn').addEventListener('click', closeModal);
    return;
  }

  const dnaRows = (dna ? DNA_FIELD_ORDER : [])
    .map((f) => [f, formatDnaValue(dna[f])])
    .filter(([, v]) => v !== null);
  const audioRows = (dna ? DNA_AUDIOBOOK_FIELD_ORDER : [])
    .map((f) => [f, formatDnaValue(dna[f])])
    .filter(([, v]) => v !== null);
  const tropes = (tropeRows || []).map((t) => titleCase(t.trope_id));
  const cws = (cwRows || []).map((c) => `${titleCase(c.warning_id)} (${titleCase(c.severity)})`);

  box.innerHTML = `
    <div class="modal-header">
      <div>
        <div class="modal-title">${escapeHtml(book.title)}</div>
        <div class="modal-author">${escapeHtml(book.author || '')}${book.publication_year ? ` · ${book.publication_year}` : ''}${book.page_count ? ` · ${book.page_count}pp` : ''}</div>
      </div>
      <button class="modal-close" id="modal-close-btn">✕</button>
    </div>
    ${book.synopsis ? `<div class="dna-synopsis">${escapeHtml(book.synopsis)}</div>` : ''}
    ${!dna ? '<div class="empty-state">Not tagged with Book DNA yet.</div>' : `
      <div class="dna-section-title">Book DNA</div>
      <div class="dna-grid">
        ${dnaRows.map(([k, v]) => `<div class="dna-row"><div class="k">${escapeHtml(titleCase(k))}</div><div class="v">${escapeHtml(v)}</div></div>`).join('')}
      </div>
      ${audioRows.length > 0 ? `
        <div class="dna-section-title">Audiobook</div>
        <div class="dna-grid">
          ${audioRows.map(([k, v]) => `<div class="dna-row"><div class="k">${escapeHtml(titleCase(k))}</div><div class="v">${escapeHtml(v)}</div></div>`).join('')}
        </div>
      ` : ''}
      ${tropes.length > 0 ? `
        <div class="dna-section-title">Tropes</div>
        <div class="dna-chips">${tropes.map((t) => `<span class="dna-chip">${escapeHtml(t)}</span>`).join('')}</div>
      ` : ''}
      ${cws.length > 0 ? `
        <div class="dna-section-title">Content warnings</div>
        <div class="dna-chips">${cws.map((c) => `<span class="dna-chip">${escapeHtml(c)}</span>`).join('')}</div>
      ` : ''}
    `}
  `;
  document.getElementById('modal-close-btn').addEventListener('click', closeModal);
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
  const accountBtn = document.getElementById('account-btn');
  accountBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    if (!dropdown.hidden) { dropdown.hidden = true; return; }
    // `position: fixed` (see shared.css) needs its own coordinates --
    // it can't inherit them from an ancestor the way `absolute` did.
    const rect = accountBtn.getBoundingClientRect();
    dropdown.style.top = `${rect.bottom + 6}px`;
    dropdown.style.right = `${window.innerWidth - rect.right}px`;
    dropdown.hidden = false;
  });
  document.addEventListener('click', () => { dropdown.hidden = true; });
  window.addEventListener('resize', () => { dropdown.hidden = true; });
  // `position: fixed` doesn't track the page scrolling under it -- close
  // rather than let it drift away from the button that opened it.
  window.addEventListener('scroll', () => { dropdown.hidden = true; }, { passive: true });
  document.getElementById('sign-out-btn').addEventListener('click', async () => {
    await sb.auth.signOut();
    window.location.href = 'index.html';
  });
}
