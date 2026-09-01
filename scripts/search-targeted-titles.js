// One-off search-only script: looks up specific titles on Hardcover and
// prints the top candidates for manual review, before any insertion.
// Not the final ingestion script -- see ingest-targeted-titles.js for that,
// which takes explicit hardcover_id choices confirmed from this output.
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
  if (json.errors) throw new Error('Hardcover GraphQL error: ' + JSON.stringify(json.errors));
  await sleep(1000);
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

const TARGETS = [
  'Magic Bites Ilona Andrews',
  'Magic Burns Ilona Andrews',
  'A Questionable Client Ilona Andrews',
  'Magic Bites Unicorn Lane Ilona Andrews',
  'Fernando POV Ilona Andrews',
  'Daughter of No Worlds',
  'When the Moon Hatched Sarah A Parker',
  'Ruthless Vows Rebecca Ross',
  'The Assassin and the Healer Sarah J Maas',
  'Mate paranormal romance',
];

for (const q of TARGETS) {
  console.log(`\n=== "${q}" ===`);
  const hits = await search(q, 6);
  for (const doc of hits) {
    console.log(`  id=${doc.id}  "${doc.title}"  by ${(doc.author_names||[]).join(', ')}  (users=${doc.users_count}, series=${doc.featured_series?.series?.name ?? 'none'})`);
  }
}
