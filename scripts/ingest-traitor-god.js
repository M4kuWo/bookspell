// One-off ingestion for a single book: "The Traitor God" by Cameron
// Johnston (Age of Tyranny #1) -- the repo owner's real "suggest a
// book" test submission (book_suggestions id
// 2aaac6b1-a32c-407e-bbce-fd083560c2f6, 2026-09-18). Follows
// scripts/ingest-targeted-titles-2.js's pattern, single-book scope.
// Self-hosts the cover per CLAUDE.md's 2026-09-18 ingestion rule
// instead of storing Hardcover's own CDN URL directly.
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

async function fetchSeriesCompletion(hardcoverSeriesIds) {
  if (hardcoverSeriesIds.length === 0) return new Map();
  const gql = `
    query SeriesCompletion($ids: [Int!]) {
      series(where: { id: { _in: $ids } }) {
        id
        is_completed
      }
    }
  `;
  const data = await hcGraphQL(gql, { ids: hardcoverSeriesIds });
  const map = new Map();
  for (const s of data.series) map.set(s.id, s.is_completed);
  return map;
}

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    const hits = await search('The Traitor God Cameron Johnston', 8);
    console.log('Search hits:');
    for (const h of hits) {
      console.log(`  id=${h.id} title="${h.title}" author=${(h.author_names||[]).join(', ')} users=${h.users_count} year=${h.release_year}`);
    }

    // Pick the best match: title exact, author matches Cameron Johnston.
    const doc = hits.find((h) =>
      h.title?.toLowerCase() === 'the traitor god' &&
      (h.author_names || []).some((a) => a.toLowerCase().includes('cameron johnston'))
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

    let seriesId = null;
    const fs = doc.featured_series;
    if (fs?.series) {
      const existingSeries = await client.query('select id from series where hardcover_id = $1', [fs.series.id]);
      if (existingSeries.rows.length > 0) {
        seriesId = existingSeries.rows[0].id;
      } else {
        const completionMap = await fetchSeriesCompletion([fs.series.id]);
        const isCompleted = completionMap.get(fs.series.id);
        const status = isCompleted === true ? 'completed' : 'ongoing';
        const inserted = await client.query(
          `insert into series (name, status, book_count, hardcover_id)
           values ($1, $2, $3, $4) returning id`,
          [fs.series.name, status, fs.series.books_count ?? null, fs.series.id]
        );
        seriesId = inserted.rows[0].id;
        console.log(`Created series: ${fs.series.name} (status=${status})`);
      }
    }
    const positionInSeries = fs?.position ?? null;

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

    console.log('\nDONE. book_id =', bookId, ' series_id =', seriesId);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
