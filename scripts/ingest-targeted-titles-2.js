// Targeted ingestion, round 2 (bibliographic data only, no DNA tagging --
// that's a separate pass). Companion to ingest-seed-catalog.js's bulk
// genre-popularity pull; this is for adding specific known-missing
// titles instead, confirmed via a search-only pass first rather than
// auto-matched.
//
// Context: 16 of these are direct sequels a real rater (Mathias) named
// in his ratings history that were confirmed missing during a docs
// consistency pass (2026-09-02) -- see docs/project-log.md's "corrects
// a stale earlier entry" entry for the verified list. The other 7 are
// famous/classic titles spread across subgenres, added after spot-
// checking a broader "should probably be in here" list against the live
// catalog and finding most classics already present -- these are the
// genuine gaps found, not a systematic subgenre audit.
//
// Two title/id choices worth noting:
// - "The Book of Three": chose the lower-popularity single-book match
//   (id=71845, users=134) over the higher-popularity omnibus edition
//   "The First Chronicles Of Prydain" (id=438960, users=526) -- this
//   catalog is per-book, and the omnibus would misrepresent one book as
//   several.
// - "Valor" (not "Valour"): Hardcover's own canonical title uses the
//   US spelling despite the UK-published British-spelling cover; used
//   as returned rather than corrected to match search intent.
// - The Handmaid's Tale is included but is borderline v1 scope
//   (literary/dystopian, same category "1984" and "We" already sit in
//   untagged) -- added as bibliographic data only, flagged for a scope
//   decision before tagging, not tagged here.
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
  if (hardcoverIds.length === 0) return new Map();
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

// Each hardcoverId confirmed via a search-only pass first (see the
// commit/log for the raw search output) rather than auto-matched.
const TARGETS = [
  // Mathias's confirmed-missing sequels
  { query: 'The Lady of the Lake Sapkowski', hardcoverId: 445169 },
  { query: 'Calamity Brandon Sanderson Reckoners', hardcoverId: 427477 },
  { query: 'King of Thorns Mark Lawrence', hardcoverId: 437921 },
  { query: 'Emperor of Thorns Mark Lawrence', hardcoverId: 36790 },
  { query: 'Grey Sister Mark Lawrence', hardcoverId: 60229 },
  { query: 'Holy Sister Mark Lawrence', hardcoverId: 446805 },
  { query: 'Valour John Gwynne', hardcoverId: 478363 },
  { query: 'The Desert Spear Peter Brett', hardcoverId: 381693 },
  { query: 'The Daylight War Peter Brett', hardcoverId: 437918 },
  { query: 'The Skull Throne Peter Brett', hardcoverId: 441058 },
  { query: 'The Core Peter Brett', hardcoverId: 225783 },
  { query: 'Rise of Empire Michael Sullivan', hardcoverId: 462825 },
  { query: 'The Blinding Knife Brent Weeks', hardcoverId: 477964 },
  { query: 'The Broken Eye Brent Weeks', hardcoverId: 12127 },
  { query: 'The Blood Mirror Brent Weeks', hardcoverId: 86440 },
  { query: 'The Burning White Brent Weeks', hardcoverId: 446514 },
  // Famous/classic breadth check gaps
  { query: 'The Sword of Shannara Terry Brooks', hardcoverId: 427307 },
  { query: 'Pawn of Prophecy David Eddings', hardcoverId: 82110 },
  { query: 'The Book of Three Lloyd Alexander', hardcoverId: 71845 },
  { query: 'Good Omens Pratchett Gaiman', hardcoverId: 434342 },
  { query: 'Neverwhere Neil Gaiman', hardcoverId: 65400 },
  { query: 'Babel Necessity of Violence Kuang', hardcoverId: 496492 },
  { query: 'The Handmaid\'s Tale Margaret Atwood', hardcoverId: 377799 },
  // Osnat's one remaining flagged catalog gap (see data/ratings/osnat.json's _meta)
  { query: 'Sweep of the Heart Ilona Andrews', hardcoverId: 589890 },
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
      doc.id = Number(doc.id);
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
