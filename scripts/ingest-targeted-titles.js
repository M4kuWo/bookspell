// Targeted ingestion for specific, manually-confirmed Hardcover book ids
// (bibliographic data only, no DNA tagging -- that's a separate pass).
// Companion to ingest-seed-catalog.js's bulk genre-popularity pull; this
// is for adding specific known-missing titles instead, confirmed via
// search-targeted-titles.js first rather than auto-matched. Reuses the
// exact `search` GraphQL endpoint/document shape ingest-seed-catalog.js
// already uses (confirmed working), not a different, unverified query.
//
// Context: these 7 titles were flagged missing from the catalog by a
// real external reader (Osnat)'s ratings list -- in v1 scope (fantasy)
// but not yet ingested, mostly paranormal/fantasy romance the original
// Hardcover popularity-genre pull under-represented. See
// docs/scoring-test-protocol.md's Osnat entries and
// docs/project-log.md 2026-09-01 for the full context. Two novella
// candidates (Magic Bites' "Unicorn Lane"/"Fernando's POV" Curran-POV
// side stories) and "Mate" were deliberately skipped -- the novellas
// are extremely obscure (1-2 Hardcover users, no author metadata,
// likely free blog serials rather than real standalone works) and
// "Mate" had no confident match among the search results (a pile of
// unrelated low-visibility werewolf romances, none clearly the book
// Osnat meant) -- not guessed at.
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

async function search(query, count = 6) {
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

function docToBookFields(doc, audioSeconds) {
  return {
    title: doc.title,
    author: (doc.author_names || []).join(', ') || 'Unknown',
    isbn: (doc.isbns || [])[0] ?? null,
    cover_url: doc.image?.url ?? null,
    synopsis: doc.description ?? null,
    page_count: doc.pages ?? null,
    audiobook_duration_minutes:
      audioSeconds != null ? Math.round(audioSeconds / 60) : null,
    publication_year: doc.release_year ?? null,
    hardcover_id: doc.id,
  };
}

// Each search query confirmed via scripts/search-targeted-titles.js to
// return the intended book as its top hit by the given hardcover_id --
// see that script's output and the comment above for why the two
// novellas and "Mate" aren't here.
const TARGETS = [
  { query: 'Magic Bites Ilona Andrews', hardcoverId: 1509459 },
  { query: 'Magic Burns Ilona Andrews', hardcoverId: 65446 },
  { query: 'A Questionable Client Ilona Andrews', hardcoverId: 485037 },
  { query: 'Daughter of No Worlds', hardcoverId: 502041 },
  { query: 'When the Moon Hatched Sarah A Parker', hardcoverId: 1121118 },
  { query: 'Ruthless Vows Rebecca Ross', hardcoverId: 746647 },
  { query: 'The Assassin and the Healer Sarah J Maas', hardcoverId: 531377 },
];

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    console.log(`Re-fetching ${TARGETS.length} confirmed titles via search...`);
    const docs = [];
    for (const t of TARGETS) {
      const hits = await search(t.query, 6);
      const doc = hits.find((h) => Number(h.id) === t.hardcoverId);
      if (!doc) {
        console.log(`  WARNING: hardcover_id ${t.hardcoverId} not found again for "${t.query}" -- skipping`);
        continue;
      }
      doc.id = Number(doc.id); // Hardcover's search API returns id as a string -- normalize once, here
      docs.push(doc);
    }

    const existingHardcoverIds = new Set(
      (await client.query('select hardcover_id from books where hardcover_id is not null'))
        .rows.map((r) => r.hardcover_id)
    );

    const audioMap = await fetchAudioSeconds(docs.map((d) => d.id));

    const seriesByHcId = new Map();
    for (const doc of docs) {
      const s = doc.featured_series?.series;
      if (s && !seriesByHcId.has(s.id)) {
        seriesByHcId.set(s.id, { name: s.name, books_count: s.books_count ?? null });
      }
    }
    const seriesCache = new Map();
    const hcSeriesIds = [...seriesByHcId.keys()];
    if (hcSeriesIds.length > 0) {
      const existing = await client.query(
        'select id, hardcover_id from series where hardcover_id = any($1)',
        [hcSeriesIds]
      );
      for (const row of existing.rows) seriesCache.set(row.hardcover_id, row.id);
      const needCreation = hcSeriesIds.filter((id) => !seriesCache.has(id));
      const completionMap = await fetchSeriesCompletion(needCreation);
      for (const hcId of needCreation) {
        const meta = seriesByHcId.get(hcId);
        const isCompleted = completionMap.get(hcId);
        const status = isCompleted === true ? 'completed' : 'ongoing';
        const inserted = await client.query(
          `insert into series (name, status, book_count, hardcover_id)
           values ($1, $2, $3, $4) returning id`,
          [meta.name, status, meta.books_count, hcId]
        );
        seriesCache.set(hcId, inserted.rows[0].id);
        console.log(`  created series: ${meta.name}`);
      }
    }

    let inserted = 0, skipped = 0;
    for (const doc of docs) {
      if (existingHardcoverIds.has(doc.id)) {
        console.log(`  SKIP (already in DB): ${doc.title}`);
        skipped++;
        continue;
      }
      const fields = docToBookFields(doc, audioMap.get(doc.id));
      const fs = doc.featured_series;
      const seriesId = fs?.series ? seriesCache.get(fs.series.id) ?? null : null;
      const position = fs?.position ?? null;
      const result = await client.query(
        `insert into books
           (title, author, isbn, cover_url, synopsis, page_count,
            audiobook_duration_minutes, publication_year, hardcover_id,
            series_id, position_in_series)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
         on conflict (hardcover_id) do nothing`,
        [
          fields.title, fields.author, fields.isbn, fields.cover_url,
          fields.synopsis, fields.page_count, fields.audiobook_duration_minutes,
          fields.publication_year, fields.hardcover_id, seriesId, position,
        ]
      );
      if (result.rowCount > 0) {
        console.log(`  inserted: ${fields.title} by ${fields.author}`);
        inserted++;
      }
    }

    console.log(`\nInserted ${inserted} new books, skipped ${skipped} already-present.`);
    const totals = await client.query('select count(*) from books');
    console.log(`Total books in DB now: ${totals.rows[0].count}`);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
