// One-off ingestion for a single book: "Ruin" by John Gwynne (The
// Faithful and the Fallen #3) -- a real ingestion gap flagged by CLDA
// during round-5 tagging batch 5 (2026-09-21): the series already has
// 3/4 books in the catalog (Malice, Valor, Wrath) but book 3 was never
// ingested. Follows scripts/ingest-traitor-god.js's pattern, single-book
// scope, except the series already exists here (hardcover_id 2438) so
// this looks it up instead of creating one. Self-hosts the cover per
// CLAUDE.md's 2026-09-18 ingestion rule.
import pg from 'pg';
import { selfHostCoverImage } from './lib/self-host-cover.js';

const HARDCOVER_API = 'https://api.hardcover.app/v1/graphql';
const TOKEN = process.env.HARDCOVER_API_TOKEN;
const DATABASE_URL = process.env.DATABASE_URL;
if (!TOKEN) throw new Error('HARDCOVER_API_TOKEN not set');
if (!DATABASE_URL) throw new Error('DATABASE_URL not set');

async function hcGraphQL(query, variables = {}) {
  const res = await fetch(HARDCOVER_API, {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error('Hardcover GraphQL error: ' + JSON.stringify(json.errors));
  return json.data;
}

async function search(query, count = 8) {
  const gql = `
    query Search($query: String!, $sort: String, $perPage: Int) {
      search(query: $query, query_type: "Book", sort: $sort, per_page: $perPage) {
        results
        error
      }
    }
  `;
  const data = await hcGraphQL(gql, { query, sort: 'users_count:desc', perPage: count });
  if (data.search.error) throw new Error('Search error: ' + data.search.error);
  return data.search.results.hits.map((h) => h.document);
}

async function fetchAudioSeconds(hardcoverIds) {
  const gql = `
    query AudioSeconds($ids: [Int!]) {
      books(where: { id: { _in: $ids } }) {
        id
        default_audio_edition { audio_seconds }
      }
    }
  `;
  const data = await hcGraphQL(gql, { ids: hardcoverIds });
  const map = new Map();
  for (const b of data.books) map.set(b.id, b.default_audio_edition?.audio_seconds ?? null);
  return map;
}

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    const hits = await search('Ruin John Gwynne', 8);
    console.log('Search hits:');
    for (const h of hits) {
      console.log(`  id=${h.id} title="${h.title}" author=${(h.author_names||[]).join(', ')} users=${h.users_count} year=${h.release_year} series=${h.featured_series?.series?.name}(#${h.featured_series?.position})`);
    }

    // Pick the best match: title exact, author John Gwynne, AND in the
    // right series -- "Ruin" is common enough as a title that the series
    // check matters here more than for a more distinctive title.
    const doc = hits.find((h) =>
      h.title?.toLowerCase() === 'ruin' &&
      (h.author_names || []).some((a) => a.toLowerCase().includes('john gwynne')) &&
      h.featured_series?.series?.id === 2438
    );
    if (!doc) {
      console.log('No confident match found -- stopping without inserting anything.');
      return;
    }
    doc.id = Number(doc.id);
    console.log('\nSelected match:', JSON.stringify({
      id: doc.id, title: doc.title, author_names: doc.author_names,
      release_year: doc.release_year, pages: doc.pages,
      featured_series: doc.featured_series, image: doc.image,
    }, null, 2));

    const existing = await client.query('select id from books where hardcover_id = $1', [doc.id]);
    if (existing.rows.length > 0) {
      console.log('Already in DB (hardcover_id match) -- book_id:', existing.rows[0].id);
      return;
    }

    const audioMap = await fetchAudioSeconds([doc.id]);
    const audioSeconds = audioMap.get(doc.id);

    const seriesRow = await client.query('select id from series where hardcover_id = $1', [2438]);
    if (seriesRow.rows.length === 0) throw new Error('The Faithful and the Fallen series (hardcover_id 2438) not found locally -- expected it to already exist.');
    const seriesId = seriesRow.rows[0].id;
    const positionInSeries = doc.featured_series?.position ?? 3;

    const result = await client.query(
      `insert into books
         (title, author, isbn, cover_url, synopsis, page_count,
          audiobook_duration_minutes, publication_year, hardcover_id,
          series_id, position_in_series)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       on conflict (hardcover_id) do nothing
       returning id`,
      [
        doc.title,
        (doc.author_names || []).join(', ') || 'Unknown',
        (doc.isbns || [])[0] ?? null,
        null, // cover_url filled in after self-hosting below
        doc.description ?? null,
        doc.pages ?? null,
        audioSeconds != null ? Math.round(audioSeconds / 60) : null,
        doc.release_year ?? null,
        doc.id,
        seriesId,
        positionInSeries,
      ]
    );
    if (result.rows.length === 0) {
      console.log('Insert conflicted (already present) -- nothing done.');
      return;
    }
    const bookId = result.rows[0].id;
    console.log(`\nInserted book_id=${bookId}: ${doc.title} by ${(doc.author_names||[]).join(', ')}`);

    if (doc.image?.url) {
      const hostedUrl = await selfHostCoverImage(doc.image.url, bookId);
      if (hostedUrl) {
        await client.query('update books set cover_url = $1 where id = $2', [hostedUrl, bookId]);
        console.log(`Self-hosted cover: ${hostedUrl}`);
      } else {
        console.log('Cover self-hosting failed -- cover_url left null.');
      }
    } else {
      console.log('No cover image on Hardcover doc -- cover_url left null.');
    }

    console.log('\nDONE. book_id =', bookId, ' series_id =', seriesId, ' isbn =', (doc.isbns||[])[0] ?? null, ' hardcover_id =', doc.id);
    console.log('SYNOPSIS:\n', doc.description ?? '(none)');
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
