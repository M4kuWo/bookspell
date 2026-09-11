// Bulk-populate audiobook_editions with edition_type='standard' rows,
// sourced from Hardcover's per-edition contributor data (narrator data is
// exposed as a `contribution: "Narrator"` role on each edition's
// cached_contributors -- confirmed 2026-09-11, see docs/TODO.md).
//
// Why this is NOT a naive "take books.default_audio_edition and insert one
// row" script: Hardcover's `default_audio_edition` picks exactly ONE
// edition per book, which silently hides real multi-narration cases. The
// Eye of the World alone returned 15 raw edition rows: the classic Kramer/
// Reading narration (in ~7 near-duplicate/reprint records), a genuinely
// separate 2021 Rosamund Pike re-recording (in 3 records, 2 with missing
// narrator credit), and a Spanish-language edition (Francesc Gongora/Lola
// Sans) that must not be conflated with either English narration. A flat
// insert-one-row-per-book approach would either miss the Pike edition
// entirely or blend the two casts together -- exactly the failure mode
// flagged before this script was written.
//
// Algorithm per book:
//   1. Fetch every "Listened"-format edition (reading_format_id=2) with its
//      language, cached_contributors, users_count, audio_seconds, isbn/asin.
//   2. Exclude editions with an EXPLICIT non-English language (`language:
//      null` is kept, not excluded -- confirmed the real Pike edition
//      itself has a null language field in Hardcover's data, so requiring
//      language==='English' would silently drop it).
//   3. Extract each edition's narrator set (contribution === 'Narrator'),
//      sorted for a stable group key. Editions with zero narrator-labeled
//      contributors are dropped (nothing safe to assert).
//   4. Group remaining editions by narrator-set identity, NOT by publisher
//      or release date (reprints of the same performance land under
//      different publishers/dates and must collapse into one group).
//   5. Within each group, pick the representative edition (highest
//      users_count, tiebreak: has audio_seconds, tiebreak: lowest id) to
//      source runtime/publisher/a stable source_url from.
//   6. One distinct narrator-set group => one audiobook_editions row. A
//      book with N genuinely different narrations gets N rows.
//   7. Books with 3+ distinct groups, or any group whose representative
//      edition has a low users_count relative to another group (ambiguous
//      "which is real" cases), are flagged for manual review instead of
//      inserted automatically.
//
// Usage: node scripts/backfill-standard-narrators.js --dry-run [--limit N]
//        node scripts/backfill-standard-narrators.js --sql > out.sql
// Dry-run prints the grouped result per book for manual verification.
// --sql prints idempotent INSERT statements (title/author-scoped, never a
// raw UUID) suitable for pasting into a migration file -- this script does
// NOT write to the database directly, per this project's migration-file
// convention.
import pg from 'pg';

const HARDCOVER_API = 'https://api.hardcover.app/v1/graphql';
const TOKEN = process.env.HARDCOVER_API_TOKEN;
const DATABASE_URL = process.env.DATABASE_URL;
if (!TOKEN) throw new Error('HARDCOVER_API_TOKEN not set (check .env)');
if (!DATABASE_URL) throw new Error('DATABASE_URL not set (check .env)');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function hcGraphQL(query, variables = {}) {
  const res = await fetch(HARDCOVER_API, {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error('Hardcover GraphQL error: ' + JSON.stringify(json.errors));
  await sleep(1000);
  return json.data;
}

const EDITIONS_QUERY = `
  query BookEditions($id: Int!) {
    books(where: {id: {_eq: $id}}) {
      id
      slug
      editions(where: {reading_format_id: {_eq: 2}}) {
        id
        language { language }
        edition_format
        isbn_13
        asin
        users_count
        audio_seconds
        publisher { name }
        cached_contributors
      }
    }
  }
`;

function narratorSet(edition) {
  const names = (edition.cached_contributors || [])
    .filter((c) => c.contribution === 'Narrator')
    .map((c) => c.author?.name?.trim())
    .filter(Boolean);
  // dedupe + stable order for grouping key
  return [...new Set(names)].sort();
}

// Full-cast dramatized productions (GraphicAudio etc.) are tracked
// separately by the tag-audiobook-editions skill under edition_type=
// 'dramatized_full_cast' -- they must not leak into this script's
// 'standard' pool as a spurious extra "narrator group". A large named
// cast (dramatized work) or an explicit GraphicAudio-style publisher name
// are both strong, cheap signals; use either to exclude.
const DRAMATIZED_PUBLISHER_HINTS = ['graphicaudio', 'l.a. theatre works', 'big finish'];
function isLikelyDramatized(edition, narrators) {
  if (narrators.length > 4) return true;
  const pub = (edition.publisher?.name || '').toLowerCase();
  return DRAMATIZED_PUBLISHER_HINTS.some((hint) => pub.includes(hint));
}

function groupEditionsByNarratorSet(editions) {
  // Exclude only an EXPLICIT non-English language; null/missing language is kept.
  const candidates = editions.filter((e) => !e.language || e.language.language === 'English');
  const groups = new Map(); // key: sorted narrator names joined -> { narrators, editions: [] }
  for (const ed of candidates) {
    const narrators = narratorSet(ed);
    if (narrators.length === 0) continue; // nothing safe to assert
    if (isLikelyDramatized(ed, narrators)) continue; // out of scope for 'standard'
    const key = narrators.join('|');
    if (!groups.has(key)) groups.set(key, { narrators, editions: [] });
    groups.get(key).editions.push(ed);
  }
  return [...groups.values()];
}

function pickRepresentative(editions) {
  return [...editions].sort((a, b) => {
    if ((b.users_count || 0) !== (a.users_count || 0)) return (b.users_count || 0) - (a.users_count || 0);
    const aHas = a.audio_seconds != null ? 1 : 0;
    const bHas = b.audio_seconds != null ? 1 : 0;
    if (bHas !== aHas) return bHas - aHas;
    return a.id - b.id;
  })[0];
}

async function analyzeBook(bookRow) {
  const data = await hcGraphQL(EDITIONS_QUERY, { id: bookRow.hardcover_id });
  const hcBook = data.books?.[0];
  if (!hcBook) return { book: bookRow, status: 'no_hardcover_book', groups: [] };
  const editions = hcBook.editions || [];
  if (editions.length === 0) return { book: bookRow, status: 'no_audio_editions', groups: [] };

  const groups = groupEditionsByNarratorSet(editions);
  if (groups.length === 0) return { book: bookRow, status: 'no_narrator_data', groups: [] };

  const resolved = groups.map((g) => {
    const rep = pickRepresentative(g.editions);
    return {
      narrators: g.narrators,
      runtime_minutes: rep.audio_seconds != null ? Math.round(rep.audio_seconds / 60) : null,
      production_company: rep.publisher?.name ?? null,
      source_url: `https://hardcover.app/books/${hcBook.slug}/editions/${rep.id}`,
      users_count: rep.users_count ?? 0,
      member_edition_ids: g.editions.map((e) => e.id),
    };
  });

  // Flag ambiguous multi-group cases rather than silently inserting all of them.
  let status = 'ok';
  if (resolved.length > 2) status = 'flag_too_many_groups';
  else if (resolved.length === 2) {
    const [a, b] = resolved.sort((x, y) => y.users_count - x.users_count);
    // A group with weak/near-zero real signal (users_count <= 2, regardless
    // of the OTHER group's count -- both-zero pairs are just as unreliable
    // as a lopsided one) is more likely a data-entry variant (misspelled
    // narrator name, duplicate crowd-sourced entry) than a genuine second
    // narration -- flag for a human to check rather than auto-inserting a
    // possibly-spurious second row. A real second narration (e.g. Eye of
    // the World's Rosamund Pike re-recording, 18 users) clears this bar.
    if (b.users_count <= 2) {
      status = 'flag_weak_second_group';
    }
  }

  return { book: bookRow, status, groups: resolved };
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes('--dry-run');
  const sqlMode = args.includes('--sql');
  const limitIdx = args.indexOf('--limit');
  const limit = limitIdx >= 0 ? parseInt(args[limitIdx + 1], 10) : null;
  const titlesIdx = args.indexOf('--titles');
  const explicitTitles = titlesIdx >= 0 ? args[titlesIdx + 1].split('|') : null;

  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();

  let rows;
  if (explicitTitles) {
    const res = await client.query(
      `select id, title, author, hardcover_id from books where title = any($1) and hardcover_id is not null`,
      [explicitTitles]
    );
    rows = res.rows;
  } else {
    const res = await client.query(
      `select b.id, b.title, b.author, b.hardcover_id
       from books b
       where b.hardcover_id is not null
       and not exists (
         select 1 from audiobook_editions ae
         where ae.book_id = b.id and ae.edition_type = 'standard'
       )
       order by b.title
       ${limit ? 'limit ' + limit : ''}`
    );
    rows = res.rows;
  }
  await client.end();

  console.error(`Analyzing ${rows.length} books...`);

  const results = [];
  for (const row of rows) {
    try {
      const result = await analyzeBook(row);
      results.push(result);
      console.error(`  ${row.title}: ${result.status} (${result.groups.length} group(s))`);
    } catch (e) {
      console.error(`  ${row.title}: ERROR ${e.message}`);
      results.push({ book: row, status: 'error', groups: [], error: e.message });
    }
  }

  if (dryRun) {
    console.log(JSON.stringify(results, null, 2));
    return;
  }

  if (sqlMode) {
    const lines = [];
    for (const r of results) {
      if (r.status !== 'ok') {
        lines.push(`-- SKIPPED (${r.status}): ${r.book.title} by ${r.book.author}`);
        continue;
      }
      for (const g of r.groups) {
        const narratorsLiteral = 'ARRAY[' + g.narrators.map((n) => `'${n.replace(/'/g, "''")}'`).join(', ') + ']::text[]';
        const titleEsc = r.book.title.replace(/'/g, "''");
        const authorEsc = r.book.author.replace(/'/g, "''");
        const pubLiteral = g.production_company ? `'${g.production_company.replace(/'/g, "''")}'` : 'null';
        const runtimeLiteral = g.runtime_minutes != null ? g.runtime_minutes : 'null';
        lines.push(
          `insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)\n` +
          `select id, 'standard', ${narratorsLiteral}, ${pubLiteral}, ${runtimeLiteral}, '${g.source_url}', current_date\n` +
          `from books where title = '${titleEsc}' and author = '${authorEsc}'\n` +
          `on conflict (book_id, source_url) do nothing;`
        );
      }
    }
    console.log(lines.join('\n\n'));
    return;
  }

  // Default: summary report
  const byStatus = {};
  for (const r of results) byStatus[r.status] = (byStatus[r.status] || 0) + 1;
  console.log(JSON.stringify(byStatus, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
