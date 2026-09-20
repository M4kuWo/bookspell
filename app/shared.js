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

// Builds a Postgres ILIKE pattern that matches each typed word in
// order but tolerant of whatever sits between them (a hyphen, extra
// punctuation, nothing at all) -- e.g. "hard boiled wonderland" ->
// "%hard%boiled%wonderland%", which matches the real stored title
// "Hard-Boiled Wonderland and the End of the World" even though the
// typed query has a space where the title has a hyphen. Plain
// substring search (`%${q}%`) required an exact match for the whole
// typed phrase and missed this class of title entirely. Escapes `%`/`_`
// in each word first so a literal percent sign a user types can't be
// misread as a wildcard.
function ilikeWordPattern(q) {
  const words = q.trim().split(/\s+/).filter(Boolean).map((w) => w.replace(/[%_]/g, '\\$&'));
  return `%${words.join('%')}%`;
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
  'worldbuilding_delivery', 'narrative_closure',
  'magic_system_hardness', 'scifi_hardness', 'prose_density', 'prose_complexity',
  'intellectual_weight', 'stakes_scope', 'personal_stakes', 'genre_accessibility',
];
// Schema-flagged spoiler: true fields (docs/schema/book-dna.schema.yaml)
// -- kept OUT of the always-visible grid above and rendered inside the
// collapsed-by-default "Spoilers" section instead (see showBookInfo()).
// A real, live gap until 2026-09-20: these were rendered in the same
// always-open grid as every other field, and book_tropes/
// book_content_warnings' own per-value/per-instance spoiler flags
// (tropes.spoiler, book_content_warnings.reveals_spoiler) were written
// at tagging time but never once read by this app. This doesn't build
// the full per-series "reveals at installment N" horizon design note
// in the schema file (that needs reader-progress tracking this app
// doesn't collect anywhere) -- just stops the current plain leak with
// a basic click-to-reveal, the same `<details>` pattern already used
// for Description/Tropes/Content warnings above.
const DNA_SPOILER_FIELD_ORDER = ['emotional_resolution', 'ends_on_cliffhanger'];
// Tier B (craft/quality judgment) fields -- audiobook_length is a
// separate, Tier A field handled on its own below, not mixed into this
// list, since it's real metadata rather than a subjective listening
// assessment (see docs/schema/book-dna.schema.yaml's audiobook_native
// module note on the Tier A/B split).
const DNA_AUDIOBOOK_QUALITY_FIELD_ORDER = [
  'narrator_performance', 'narration_pace_vs_prose', 'accent_authenticity', 'production_quality',
];

function titleCase(s) {
  return String(s).replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}
function formatDnaValue(v) {
  if (v === null || v === undefined) return null;
  if (Array.isArray(v)) return v.map(titleCase).join(', ');
  return titleCase(v);
}
function formatEditionType(t) {
  if (t === 'dramatized_full_cast') return 'Full-Cast Dramatization';
  if (t === 'standard') return 'Standard';
  return titleCase(t);
}
function formatRuntime(mins) {
  return mins ? `${(mins / 60).toFixed(1)}h` : null;
}

function matchClass(label) {
  if (label === 'Strong match') return 'match-strong';
  if (label === 'Good match') return 'match-good';
  if (label === 'Mixed match') return 'match-mixed';
  return 'match-poor';
}

// "3 months ago" / "2 years, 1 month ago" style relative phrasing for a
// stored 'YYYY-MM-DD' rated_date -- readers rarely think in exact dates,
// but the exact value is still the source of truth (shown as a title
// tooltip wherever this is used), this is just a friendlier label over it.
function formatRelativeDate(dateStr) {
  if (!dateStr) return null;
  const then = new Date(`${dateStr}T00:00:00`);
  if (isNaN(then)) return null;
  const now = new Date();
  const days = Math.floor((now - then) / 86400000);
  if (days < 0) return dateStr; // a future date somehow -- just show it as-is
  if (days === 0) return 'today';
  if (days === 1) return 'yesterday';
  if (days < 7) return `${days} days ago`;
  if (days < 30) { const w = Math.floor(days / 7); return `${w} week${w > 1 ? 's' : ''} ago`; }
  let months = (now.getFullYear() - then.getFullYear()) * 12 + (now.getMonth() - then.getMonth());
  if (now.getDate() < then.getDate()) months--;
  if (months < 12) return `${months} month${months > 1 ? 's' : ''} ago`;
  const years = Math.floor(months / 12);
  const remMonths = months % 12;
  return remMonths === 0
    ? `${years} year${years > 1 ? 's' : ''} ago`
    : `${years} year${years > 1 ? 's' : ''}, ${remMonths} month${remMonths > 1 ? 's' : ''} ago`;
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
  document.body.style.overflow = '';
}

async function showBookInfo(bookId) {
  const overlay = ensureModalEl();
  const box = document.getElementById('book-info-box');
  box.innerHTML = '<div class="empty-state">Loading…</div>';
  overlay.hidden = false;
  document.body.style.overflow = 'hidden';

  const [{ data: book }, { data: dna }, { data: tropeRows }, { data: cwRows }, { data: editions }] = await Promise.all([
    sb.from('books').select('title, author, synopsis, page_count, publication_year, cover_url, position_in_series, series(name, status), universe(name)').eq('id', bookId).maybeSingle(),
    sb.from('book_dna').select('*').eq('book_id', bookId).maybeSingle(),
    sb.from('book_tropes').select('trope_id, tropes(spoiler)').eq('book_id', bookId),
    sb.from('book_content_warnings').select('warning_id, severity, reveals_spoiler').eq('book_id', bookId),
    sb.from('audiobook_editions').select('edition_type, narrators, production_company, runtime_minutes, release_status, parts_released, parts_total').eq('book_id', bookId).order('edition_type'),
  ]);

  if (!book) {
    box.innerHTML = `<div class="modal-header"><span class="modal-title">Not found</span><button class="modal-close" id="modal-close-btn">✕</button></div>`;
    document.getElementById('modal-close-btn').addEventListener('click', closeModal);
    return;
  }

  const dnaRows = (dna ? DNA_FIELD_ORDER : [])
    .map((f) => [f, formatDnaValue(dna[f])])
    .filter(([, v]) => v !== null);
  const spoilerDnaRows = (dna ? DNA_SPOILER_FIELD_ORDER : [])
    .map((f) => [f, formatDnaValue(dna[f])])
    .filter(([, v]) => v !== null);
  const audiobookLengthVal = dna ? formatDnaValue(dna.audiobook_length) : null;
  const audioQualityRows = (dna ? DNA_AUDIOBOOK_QUALITY_FIELD_ORDER : [])
    .map((f) => [f, formatDnaValue(dna[f])])
    .filter(([, v]) => v !== null);
  const allTropes = tropeRows || [];
  const tropes = allTropes.filter((t) => !t.tropes?.spoiler).map((t) => titleCase(t.trope_id));
  const spoilerTropes = allTropes.filter((t) => t.tropes?.spoiler).map((t) => titleCase(t.trope_id));
  const allCws = cwRows || [];
  const cws = allCws.filter((c) => !c.reveals_spoiler).map((c) => `${titleCase(c.warning_id)} (${titleCase(c.severity)})`);
  const spoilerCws = allCws.filter((c) => c.reveals_spoiler).map((c) => `${titleCase(c.warning_id)} (${titleCase(c.severity)})`);
  const hasSpoilers = spoilerDnaRows.length > 0 || spoilerTropes.length > 0 || spoilerCws.length > 0;
  const membership = [
    book.series ? `<span class="membership-badge">📚 ${escapeHtml(book.series.name)}${book.position_in_series ? ` #${book.position_in_series}` : ''} — ${book.series.status === 'completed' ? 'Completed' : 'Ongoing'}</span>` : null,
    book.universe ? `<span class="membership-badge">✦ ${escapeHtml(book.universe.name)} universe</span>` : null,
  ].filter(Boolean);

  // Real edition/narrator/cast data (audiobook_editions -- collected
  // separately from book_dna tagging) vs. the still-untagged Tier B
  // quality-judgment fields are two different things; shown separately
  // so real data isn't buried under a caveat about the other.
  const editionBlocks = (editions || []).map((e) => {
    const metaParts = [];
    const runtime = formatRuntime(e.runtime_minutes);
    if (runtime) metaParts.push(runtime);
    if (e.parts_total) metaParts.push(`Part${e.parts_total > 1 ? 's' : ''} ${e.parts_released ?? '?'}/${e.parts_total}${e.release_status === 'fully_released' ? ' · complete' : ''}`);
    const castLabel = e.edition_type === 'dramatized_full_cast' ? 'Cast' : 'Narrator(s)';
    return `
      <div class="audiobook-edition">
        <div class="edition-title">${formatEditionType(e.edition_type)}${e.production_company ? ` — ${escapeHtml(e.production_company.trim())}` : ''}</div>
        ${metaParts.length > 0 ? `<div class="edition-meta">${metaParts.join(' · ')}</div>` : ''}
        ${e.narrators && e.narrators.length > 0 ? `
          <details style="margin-top:6px;">
            <summary style="cursor:pointer; font-size:0.78rem; font-weight:600; color:var(--ink-soft);">${castLabel} (${e.narrators.length})</summary>
            <div class="dna-chips" style="margin-top:6px;">${e.narrators.map((n) => `<span class="dna-chip">${escapeHtml(n)}</span>`).join('')}</div>
          </details>
        ` : ''}
      </div>
    `;
  }).join('');

  box.innerHTML = `
    ${book.cover_url ? `<div class="modal-cover-row"><img class="modal-cover" src="${escapeAttr(book.cover_url)}" alt=""></div>` : ''}
    <div class="modal-header">
      <div style="flex:1 1 auto;">
        <div class="modal-title">${escapeHtml(book.title)}</div>
        <div class="modal-author">${escapeHtml(book.author || '')}${book.publication_year ? ` · ${book.publication_year}` : ''}${book.page_count ? ` · ${book.page_count}pp` : ''}</div>
      </div>
      <button class="modal-close" id="modal-close-btn">✕</button>
    </div>
    ${book.synopsis ? `<details open><summary class="dna-section-title">Description</summary><div class="dna-synopsis">${escapeHtml(book.synopsis)}</div></details>` : ''}
    ${membership.length > 0 ? `<div class="membership-line">${membership.join('')}</div>` : ''}
    ${!dna ? '<div class="empty-state">Not tagged with Book DNA yet.</div>' : `
      <details open><summary class="dna-section-title">Audiobook</summary>
        ${audiobookLengthVal ? `<div class="dna-row" style="margin-bottom:12px;"><div class="k">Length</div><div class="v">${escapeHtml(audiobookLengthVal)}</div></div>` : ''}
        ${editionBlocks}
        ${audioQualityRows.length > 0 ? `<div class="dna-grid" style="margin-top:10px;">${audioQualityRows.map(([k, v]) => `<div class="dna-row"><div class="k">${escapeHtml(titleCase(k))}</div><div class="v">${escapeHtml(v)}</div></div>`).join('')}</div>` : ''}
        ${(!editions || editions.length === 0) && !audiobookLengthVal ? '<div class="empty-state" style="text-align:left; padding:8px 0;">No audiobook edition data collected for this book yet.</div>' : ''}
        ${(editions && editions.length > 0) ? '<div class="dna-synopsis" style="margin-top:10px; font-size:0.78rem;">Narrator-performance/production-quality ratings aren\'t tagged catalog-wide yet -- the edition, narrator, and cast details above are real, though.</div>' : ''}
      </details>
      <details open><summary class="dna-section-title">Book DNA</summary>
        <details open style="margin-top:6px;"><summary style="cursor:pointer; font-size:0.8rem; font-weight:600; color:var(--ink-soft);">Fields</summary>
          <div class="dna-grid" style="margin-top:8px;">
            ${dnaRows.map(([k, v]) => `<div class="dna-row"><div class="k">${escapeHtml(titleCase(k))}</div><div class="v">${escapeHtml(v)}</div></div>`).join('')}
          </div>
        </details>
        ${tropes.length > 0 ? `
          <details open style="margin-top:10px;"><summary style="cursor:pointer; font-size:0.8rem; font-weight:600; color:var(--ink-soft);">Tropes</summary>
            <div class="dna-chips" style="margin-top:8px;">${tropes.map((t) => `<span class="dna-chip">${escapeHtml(t)}</span>`).join('')}</div>
          </details>
        ` : ''}
        ${cws.length > 0 ? `
          <details open style="margin-top:10px;"><summary style="cursor:pointer; font-size:0.8rem; font-weight:600; color:var(--ink-soft);">Content warnings</summary>
            <div class="dna-chips" style="margin-top:8px;">${cws.map((c) => `<span class="dna-chip">${escapeHtml(c)}</span>`).join('')}</div>
          </details>
        ` : ''}
        ${hasSpoilers ? `
          <details style="margin-top:10px;"><summary style="cursor:pointer; font-size:0.8rem; font-weight:600; color:var(--disliked);">⚠ Spoilers -- click to reveal</summary>
            ${spoilerDnaRows.length > 0 ? `
              <div class="dna-grid" style="margin-top:8px;">
                ${spoilerDnaRows.map(([k, v]) => `<div class="dna-row"><div class="k">${escapeHtml(titleCase(k))}</div><div class="v">${escapeHtml(v)}</div></div>`).join('')}
              </div>
            ` : ''}
            ${spoilerTropes.length > 0 ? `<div class="dna-chips" style="margin-top:8px;">${spoilerTropes.map((t) => `<span class="dna-chip">${escapeHtml(t)}</span>`).join('')}</div>` : ''}
            ${spoilerCws.length > 0 ? `<div class="dna-chips" style="margin-top:8px;">${spoilerCws.map((c) => `<span class="dna-chip">${escapeHtml(c)}</span>`).join('')}</div>` : ''}
          </details>
        ` : ''}
      </details>
    `}
  `;
  document.getElementById('modal-close-btn').addEventListener('click', closeModal);
}

// "Why this recommendation?" -- reuses the exact same expand-a-window
// modal as showBookInfo() above (same overlay/box elements), just with
// a different render for a recommendation-result object `r` (whatever
// shape /recommendations returned: title/author/match_label/summary/
// mismatch_summary/dealbreaker_summary/series_note/matches/mismatches/
// dealbreaker_flags). No network call needed -- the itemized detail
// already came back with the recommendation itself.
function showRecommendationExplanation(r) {
  const overlay = ensureModalEl();
  const box = document.getElementById('book-info-box');
  const listHtml = (items, emptyText) => items && items.length > 0
    ? `<ul class="dna-synopsis" style="margin:0; padding-left:1.2em;">${items.map((m) => `<li>${escapeHtml(m)}</li>`).join('')}</ul>`
    : `<div class="empty-state" style="text-align:left; padding:4px 0;">${escapeHtml(emptyText)}</div>`;
  box.innerHTML = `
    <div class="modal-header">
      <div>
        <div class="modal-title">${escapeHtml(r.title)}</div>
        <div class="modal-author">${escapeHtml(r.author || '')}</div>
      </div>
      <button class="modal-close" id="modal-close-btn">✕</button>
    </div>
    <div class="membership-line"><span class="pill ${matchClass(r.match_label)}">${escapeHtml(r.match_label)}</span></div>
    ${r.dealbreaker_flags && r.dealbreaker_flags.length > 0 ? `
      <details open style="margin-top:10px;">
        <summary class="dna-section-title" style="color:var(--disliked);">Dealbreakers</summary>
        <div style="margin-top:8px;">${listHtml(r.dealbreaker_flags)}</div>
      </details>
    ` : ''}
    <details open style="margin-top:10px;">
      <summary class="dna-section-title">Why it matches</summary>
      <div style="margin-top:8px;">${listHtml(r.matches, 'Nothing specific stood out -- this is more of a middling match.')}</div>
    </details>
    <details open style="margin-top:10px;">
      <summary class="dna-section-title">Where it differs from your taste</summary>
      <div style="margin-top:8px;">${listHtml(r.mismatches, 'No real mismatches found.')}</div>
    </details>
    ${r.series_note ? `
      <details open style="margin-top:10px;">
        <summary class="dna-section-title">Series note</summary>
        <div class="dna-synopsis" style="margin-top:8px;">${escapeHtml(r.series_note)}</div>
      </details>
    ` : ''}
  `;
  overlay.hidden = false;
  document.body.style.overflow = 'hidden';
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
  // `.nav-links` and `.nav-controls` are two SEPARATE flex items (see
  // shared.css) so the account avatar/theme toggle can never scroll out
  // of view when the logo+links overflow a narrow screen -- only
  // `.nav-links` itself scrolls internally in that case.
  nav.innerHTML = `
    <span class="nav-links">
      <img src="logo.svg" alt="Bookspell" width="26" height="26" style="flex:0 0 auto;">
      ${items.map(([href, label]) =>
        `<a href="${href}" class="${active === href ? 'active' : ''}">${label}</a>`
      ).join('')}
    </span>
    <span class="nav-controls">
      <button class="theme-toggle" id="theme-toggle-btn" title="Toggle dark/light" type="button">◐</button>
      <div class="account-menu">
        <button class="avatar-btn" id="account-btn" type="button" title="${escapeAttr(name)}">${escapeHtml(initials(name))}</button>
        <div class="account-dropdown" id="account-dropdown" hidden>
          <div class="who">${escapeHtml(name)}</div>
          <button type="button" id="sign-out-btn">Sign out</button>
        </div>
      </div>
    </span>
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
    try { sessionStorage.removeItem('bookspell-cached-recs'); } catch (e) { /* ignore */ }
    window.location.href = 'index.html';
  });
}
