// One-off backfill: books.audio_seconds turned out to be unpopulated at the
// top level (see ingest-seed-catalog.js) — this corrects rows inserted
// before that was discovered. Safe to re-run; only touches existing rows
// that already have a hardcover_id.

import pg from 'pg';

const HARDCOVER_API = 'https://api.hardcover.app/v1/graphql';
const TOKEN = process.env.HARDCOVER_API_TOKEN;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function hcGraphQL(query, variables = {}) {
  const res = await fetch(HARDCOVER_API, {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error(JSON.stringify(json.errors));
  await sleep(1000);
  return json.data;
}

async function main() {
  const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  const { rows } = await client.query(
    'select id, hardcover_id from books where hardcover_id is not null'
  );
  console.log(`Backfilling audiobook duration for ${rows.length} books...`);

  const ids = rows.map((r) => r.hardcover_id);
  const map = new Map();
  for (let i = 0; i < ids.length; i += 50) {
    const batch = ids.slice(i, i + 50);
    const data = await hcGraphQL(
      `query($ids: [Int!]) { books(where: {id: {_in: $ids}}) { id default_audio_edition { audio_seconds } } }`,
      { ids: batch }
    );
    for (const b of data.books) map.set(b.id, b.default_audio_edition?.audio_seconds ?? null);
  }

  let updated = 0;
  for (const row of rows) {
    const seconds = map.get(row.hardcover_id);
    const minutes = seconds != null ? Math.round(seconds / 60) : null;
    if (minutes != null) {
      await client.query('update books set audiobook_duration_minutes = $1 where id = $2', [minutes, row.id]);
      updated++;
    }
  }
  console.log(`Updated ${updated}/${rows.length} books with real audiobook duration.`);
  await client.end();
}

main().catch((e) => { console.error(e); process.exit(1); });
