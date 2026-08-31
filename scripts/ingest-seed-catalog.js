// Step 03: bootstrap a seed catalog from Hardcover's GraphQL API.
//
// - Pulls the top ~110 Fantasy + ~110 Science Fiction books by popularity
//   (users_count), bibliographic data only — no DNA tagging (that's step 04).
// - Matches the 30 already-tagged pilot books by title+author and UPDATEs
//   their existing `books` row (preserving book_id so book_dna/book_tropes/
//   book_content_warnings stay linked) instead of inserting duplicates.
// - Creates `series` rows as needed, deduped by Hardcover's own series id.
//   Series completion status (is_completed) isn't in the search index, so
//   it's fetched separately via a batched `series` query rather than
//   silently defaulting everything to "ongoing".
// - `universe` is NOT populated here — that's a curated, manual concept
//   (shared continuities like "The First Law World") that no metadata API
//   models; left for later, deliberately.

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
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) {
    throw new Error('Hardcover GraphQL error: ' + JSON.stringify(json.errors));
  }
  await sleep(1000); // 60/min limit -> stay at ~1 req/sec even ignoring latency
  return json.data;
}

const MAX_PER_PAGE = 25; // Hardcover's actual cap, confirmed empirically (requesting more is silently truncated)

async function searchBooksPage({ query = '', filterBy, sort, page = 1 }) {
  const gql = `
    query Search($query: String!, $filterBy: String, $sort: String, $page: Int, $perPage: Int) {
      search(query: $query, query_type: "Book", filter_by: $filterBy, sort: $sort, page: $page, per_page: $perPage) {
        results
        error
      }
    }
  `;
  const data = await hcGraphQL(gql, { query, filterBy, sort, page, perPage: MAX_PER_PAGE });
  if (data.search.error) throw new Error('Search error: ' + data.search.error);
  return data.search.results.hits.map((h) => h.document);
}

// Paginates in MAX_PER_PAGE chunks until `count` results are collected.
async function searchBooks({ query = '', filterBy, sort, count = MAX_PER_PAGE }) {
  const results = [];
  let page = 1;
  while (results.length < count) {
    const hits = await searchBooksPage({ query, filterBy, sort, page });
    if (hits.length === 0) break; // no more results available
    results.push(...hits);
    page++;
  }
  return results.slice(0, count);
}

async function fetchAudioSeconds(hardcoverIds) {
  const map = new Map();
  const batchSize = 50;
  for (let i = 0; i < hardcoverIds.length; i += batchSize) {
    const batch = hardcoverIds.slice(i, i + batchSize);
    const gql = `
      query AudioSeconds($ids: [Int!]) {
        books(where: { id: { _in: $ids } }) {
          id
          default_audio_edition {
            audio_seconds
          }
        }
      }
    `;
    // books.audio_seconds itself is NOT a populated field — confirmed empty
    // for every book tried, including well-known audiobook titles. The real
    // duration lives on the default audio edition.
    const data = await hcGraphQL(gql, { ids: batch });
    for (const b of data.books) map.set(b.id, b.default_audio_edition?.audio_seconds ?? null);
  }
  return map;
}

async function fetchSeriesCompletion(hardcoverSeriesIds) {
  const map = new Map();
  const batchSize = 50;
  for (let i = 0; i < hardcoverSeriesIds.length; i += batchSize) {
    const batch = hardcoverSeriesIds.slice(i, i + batchSize);
    const gql = `
      query SeriesCompletion($ids: [Int!]) {
        series(where: { id: { _in: $ids } }) {
          id
          is_completed
        }
      }
    `;
    const data = await hcGraphQL(gql, { ids: batch });
    for (const s of data.series) map.set(s.id, s.is_completed);
  }
  return map;
}

function normalizeTitle(t) {
  return (t || '')
    .normalize('NFD').replace(/[̀-ͯ]/g, '') // strip diacritics: Circé -> Circe
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

// Name-order-agnostic: "Liu Cixin" vs "Cixin Liu" both tokenize to {liu, cixin}.
function authorTokens(author) {
  return new Set(
    (author || '')
      .toLowerCase()
      .split(/\s+/)
      .filter((w) => w.length > 2) // drop initials/particles
  );
}

function authorsOverlap(storedAuthor, hardcoverNames) {
  const wanted = authorTokens(storedAuthor);
  return (hardcoverNames || []).some((name) => {
    const got = authorTokens(name);
    for (const t of wanted) if (got.has(t)) return true;
    return false;
  });
}

// Title equality OR containment, to tolerate subtitle differences
// (Hardcover's "We Are Legion" vs our "We Are Legion (We Are Bob)").
function titlesMatch(a, b) {
  return a === b || a.startsWith(b) || b.startsWith(a);
}

async function matchPilotBook(pilotBook) {
  // Sorted by popularity, not raw text relevance — otherwise niche spin-offs
  // (comic adaptations, etc.) can outrank the actual novel for a well-known
  // title. Checking 20 candidates rather than 5 gives real matches more
  // room to surface past those.
  const hits = await searchBooks({ query: pilotBook.title, sort: 'users_count:desc', count: 20 });
  if (hits.length === 0) return null;

  const wantTitle = normalizeTitle(pilotBook.title);

  const scored = hits
    .map((doc) => ({
      doc,
      titleMatch: titlesMatch(normalizeTitle(doc.title), wantTitle),
      authorMatch: authorsOverlap(pilotBook.author, doc.author_names),
    }))
    .filter((s) => s.titleMatch && s.authorMatch)
    .sort((a, b) => (b.doc.users_count ?? 0) - (a.doc.users_count ?? 0));

  return scored[0]?.doc ?? null;
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

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();

  const log = { pilotMatched: [], pilotUnmatched: [], inserted: 0, seriesCreated: 0 };

  try {
    // --- 1. Match the 30 pilot books (collect docs, don't write yet) ---
    console.log('Matching pilot books against Hardcover...');
    const pilotBooks = (
      await client.query('select id, title, author from books where hardcover_id is null')
    ).rows;

    const pilotMatches = []; // { pilotBook, doc }
    const matchedHardcoverIds = new Set();

    for (const pilotBook of pilotBooks) {
      const doc = await matchPilotBook(pilotBook);
      if (!doc) {
        log.pilotUnmatched.push(pilotBook.title);
        continue;
      }
      matchedHardcoverIds.add(doc.id);
      pilotMatches.push({ pilotBook, doc });
    }

    // A popular pilot book (e.g. The Eye of the World) can ALSO appear in the
    // general genre pull below. Exclude every hardcover_id already present in
    // the DB too (not just this run's pilot matches) — otherwise a book ends
    // up represented twice: once as the real, DNA-tagged pilot row, once as
    // an untagged duplicate from the popularity pull. Also makes re-running
    // this script safe (won't re-insert candidates from a prior run).
    const existingHardcoverIds = new Set(
      (await client.query('select hardcover_id from books where hardcover_id is not null'))
        .rows.map((r) => r.hardcover_id)
    );

    // --- 2. Pull top Fantasy + Science Fiction books by popularity ---
    console.log('Pulling top Fantasy books...');
    const fantasy = await searchBooks({
      filterBy: 'genres:=[Fantasy]',
      sort: 'users_count:desc',
      count: 420, // bumped 2026-08-31 (220->420) to fetch the next ~200-per-genre
      // tier ahead of the next real tagging expansion -- bibliographic data
      // only, deliberately NOT tagged yet (see ingest-only note below).
      // dedup against existingHardcoverIds means ranks 1-220 (already in
      // the DB) are skipped automatically, netting only ranks 221-420.
    });
    console.log('Pulling top Science Fiction books...');
    const scifi = await searchBooks({
      filterBy: 'genres:=[Science Fiction]',
      sort: 'users_count:desc',
      count: 420,
    });

    const seen = new Set();
    const candidates = [];
    for (const doc of [...fantasy, ...scifi]) {
      if (seen.has(doc.id)) continue; // dedup fantasy/sci-fi overlap
      if (matchedHardcoverIds.has(doc.id)) continue; // already a pilot book (this run)
      if (existingHardcoverIds.has(doc.id)) continue; // already in the DB (this or a prior run)
      seen.add(doc.id);
      candidates.push(doc);
    }
    // Not guaranteed all-new: the upstream search API's pagination isn't
    // perfectly stable when many results tie on the sort key, so this can
    // include a few ids already in the DB — `on conflict do nothing` below
    // is the actual source of truth, tracked via rowCount, not this number.
    console.log(`${candidates.length} candidate books to try after local dedup.`);

    // --- 3. Batch-fetch audiobook duration for every doc we'll write ---
    const allDocs = [...pilotMatches.map((m) => m.doc), ...candidates];
    const audioMap = await fetchAudioSeconds(allDocs.map((d) => d.id));

    // --- 4. Resolve series: collect unique hardcover series ids, check
    //         which already exist locally, batch-fetch completion status
    //         for the rest, then create them all before touching books.
    const seriesByHcId = new Map(); // hardcover series id -> {name, books_count}
    for (const doc of allDocs) {
      const s = doc.featured_series?.series;
      if (s && !seriesByHcId.has(s.id)) {
        seriesByHcId.set(s.id, { name: s.name, books_count: s.books_count ?? null });
      }
    }

    const seriesCache = new Map(); // hardcover series id -> local series uuid
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
        log.seriesCreated++;
      }
    }

    const seriesLinkFor = (doc) => {
      const fs = doc.featured_series;
      if (!fs || !fs.series) return { seriesId: null, position: null };
      return { seriesId: seriesCache.get(fs.series.id) ?? null, position: fs.position ?? null };
    };

    // --- 5. Update the 30 pilot books with real bibliographic data ---
    for (const { pilotBook, doc } of pilotMatches) {
      const fields = docToBookFields(doc, audioMap.get(doc.id));
      const { seriesId, position } = seriesLinkFor(doc);
      await client.query(
        `update books set
           isbn = $1, cover_url = $2, synopsis = $3, page_count = $4,
           audiobook_duration_minutes = $5, publication_year = $6,
           hardcover_id = $7, series_id = $8, position_in_series = $9,
           updated_at = now()
         where id = $10`,
        [
          fields.isbn, fields.cover_url, fields.synopsis, fields.page_count,
          fields.audiobook_duration_minutes, fields.publication_year,
          fields.hardcover_id, seriesId, position, pilotBook.id,
        ]
      );
      log.pilotMatched.push(`${pilotBook.title} -> hardcover #${doc.id}`);
    }

    // --- 6. Insert the new candidate books ---
    for (const doc of candidates) {
      const fields = docToBookFields(doc, audioMap.get(doc.id));
      const { seriesId, position } = seriesLinkFor(doc);
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
      if (result.rowCount > 0) log.inserted++; // 0 means on-conflict skipped it
    }

    // --- Summary ---
    console.log('\n=== Seed catalog ingestion summary ===');
    console.log(`Pilot books matched & updated: ${log.pilotMatched.length}/${pilotBooks.length}`);
    if (log.pilotUnmatched.length) {
      console.log('Pilot books NOT matched (left as-is, no bibliographic data added):');
      for (const t of log.pilotUnmatched) console.log('  -', t);
    }
    console.log(`New books inserted: ${log.inserted}`);
    console.log(`New series created: ${log.seriesCreated}`);

    const totals = await client.query(
      'select (select count(*) from books) as books, (select count(*) from series) as series'
    );
    console.log(`Totals now in DB: ${totals.rows[0].books} books, ${totals.rows[0].series} series.`);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
