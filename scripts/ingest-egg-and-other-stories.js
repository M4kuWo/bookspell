// One-off ingestion for "The Egg and Other Stories" by Andy Weir --
// replaces the standalone "The Egg" row (deleted in
// 20260922030000_archive_holly_delete_egg_standalone.sql), which was a
// ~1,000-word flash-fiction piece mis-ingested as a standalone "book".
// This is the real audio-exclusive collection it belongs in (Hardcover
// id 839124, genres Science Fiction/Fantasy per Hardcover's own
// tagging), per the repo owner's 2026-09-22 framing: a short story is
// in scope via a real compilation, not by itself. Audio-only (no ebook
// edition on Hardcover) -- page_count left null, duration real.
// Follows scripts/ingest-traitor-god.js's pattern. Self-hosts the cover
// per CLAUDE.md's 2026-09-18 rule.
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
    const hardcoverId = 839124;
    const existing = await client.query('select id from books where hardcover_id = $1', [hardcoverId]);
    if (existing.rows.length > 0) {
      console.log('Already in DB (hardcover_id match) -- book_id:', existing.rows[0].id);
      return;
    }

    // Fixed values confirmed directly against Hardcover's API (see the
    // conversation that produced this script) -- author field is
    // "Andy Weir" only, NOT the 3 audiobook narrators (Christy Romano,
    // R.C. Bray, Jonathan Davis) that Hardcover's own author_names
    // lumps in -- confirmed via contribution_types (Author vs Reading)
    // per CLAUDE.md's author-contamination rule.
    const title = 'The Egg and Other Stories';
    const author = 'Andy Weir';
    const isbn = '197860405X';
    const sourceImageUrl = 'https://assets.hardcover.app/edition/30852380/d3e2cc945e5ca8c0a3fc85cc665f563722779319.jpeg';
    const description = `Collected for the first time anywhere, the nine tales in The Egg and Other Stories highlight Andy Weir's trademark wit and unexpected twists. For the few who have yet to experience The Martian, it's a perfect appetizer. For passionate Weir fans, it's a delicious dessert.
Stories included in this audio-exclusive collection are:
"Access"
"Antihypoxiant"
"Annie's Day"
"The Real Deal"
"Bored World"
"The Midtown Butcher"
"Meeting Sarah"
"The Chef"
"The Egg"`;
    const releaseYear = 2017;

    const audioMap = await fetchAudioSeconds([hardcoverId]);
    const audioSeconds = audioMap.get(hardcoverId) ?? 4633; // confirmed via search doc as fallback

    const result = await client.query(
      `insert into books
         (title, author, isbn, cover_url, synopsis, page_count,
          audiobook_duration_minutes, publication_year, hardcover_id,
          series_id, position_in_series)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       on conflict (hardcover_id) do nothing
       returning id`,
      [title, author, isbn, null, description, null,
       Math.round(audioSeconds / 60), releaseYear, hardcoverId, null, null]
    );
    if (result.rows.length === 0) {
      console.log('Insert conflicted (already present) -- nothing done.');
      return;
    }
    const bookId = result.rows[0].id;
    console.log(`Inserted book_id=${bookId}: ${title} by ${author}`);

    const hostedUrl = await selfHostCoverImage(sourceImageUrl, bookId);
    if (hostedUrl) {
      await client.query('update books set cover_url = $1 where id = $2', [hostedUrl, bookId]);
      console.log(`Self-hosted cover: ${hostedUrl}`);
    } else {
      console.log('Cover self-hosting failed -- cover_url left null.');
    }

    console.log('\nDONE. book_id =', bookId, ' hardcover_id =', hardcoverId, ' isbn =', isbn, ' audiobook_duration_minutes =', Math.round(audioSeconds / 60));
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
