// Catalog expansion round 5: bootstrap the next tier of Fantasy/Science
// Fiction candidates from Hardcover's GraphQL API — bibliographic data only,
// deliberately NOT tagged (that's a separate future step).
//
// Round 4 (2026-09-12) bumped the per-genre pull to 850 and inserted every
// new hardcover_id unconditionally. Roughly a third of the 378 new books
// turned out to be non-SFF leakage from Hardcover's loose `genres:=[X]`
// search filter (confirmed 2026-09-21 when the whole leftover untagged pool
// was screened and 115/118 remaining books got archived as out-of-scope).
// This round adds a REAL pre-insertion quality filter instead of repeating
// that pattern — see the two structured signals below, found via GraphQL
// introspection against the `books` type (not previously used by any
// ingestion script in this repo):
//
//   1. `book_category_id` — Hardcover's own format classification (queried
//      directly: `book_categories { id name }` returns 1=Book, 2=Novella,
//      3=Short Story, 4=Graphic Novel, 5=Fan Fiction, 6=Research Paper,
//      7=Poetry, 8=Collection, 9=Web Novel, 10=Light Novel). Confirmed
//      empirically that every one of round 4's flagged graphic novels
//      (Saga, The Sandman, Monstress, Watchmen) carries category_id 4.
//      This is a clean, mechanical, forward-looking replacement for round
//      4's after-the-fact manual comic-spotting. Short stories/collections
//      stay eligible per CLAUDE.md's "short-story collections are in scope"
//      policy; only Graphic Novel/Fan Fiction/Research Paper/Poetry are
//      auto-excluded as clearly outside v1's prose-SFF-novel scope.
//
//   2. `document.genres` — the search index's per-book genre list is NOT
//      just Hardcover's loose `genres:=[X]` filter match; it's the same
//      data backing `books.cached_tags.Genre` (confirmed by direct
//      comparison — the array order matches cached_tags' vote-count-sorted
//      Genre list exactly), i.e. already ordered by community tag-vote
//      count, descending. Calibrated against known-good and known-bad
//      titles (see docs/project-log.md's round-5 entry for the full table):
//      every real leakage case (Atlas Shrugged, White Noise, The
//      Fountainhead, The Girl with the Dragon Tattoo, Fifty Shades of Grey,
//      The Godfather, Shogun, A Farewell to Arms, The Bluest Eye) has its
//      top-voted genre be something else entirely (Classics, Mystery,
//      Romance, Historical Fiction, Crime) even when "Fantasy" or "Science
//      Fiction" appears buried further down as noise (e.g. The Godfather:
//      Fantasy at position 5, clearly a mistag). Every real SFF book tested
//      — including literary-marketed SFF (Station Eleven, Kindred, Never
//      Let Me Go, The Left Hand of Darkness, Cloud Atlas) — has Fantasy or
//      Science Fiction in position 0 or 1. Rule adopted: reject unless one
//      of the top 2 genre-tag entries matches /fantasy|sci-?fi|
//      science[\s-]?fiction|speculative fiction/i. A handful of genuinely
//      SFF books with no community genre tags at all (e.g. very new/niche
//      titles) will false-negative under this rule and get silently
//      skipped rather than inserted — an intentional precision-over-recall
//      trade given the task explicitly asked for a real quality bar, not a
//      padded count.
//
// Adapted from ingest-seed-catalog.js: same GraphQL client, pagination,
// audiobook-duration/series-completion batch fetchers, docToBookFields
// shape, and series dedup-by-hardcover-id pattern. This script does NOT
// do pilot-book matching (that one-time backfill is long done) and does
// NOT write to the database directly — it fetches, filters, and emits a
// migration SQL file for review/idempotency-testing before a separate
// apply step, per this round's task instructions.
//
// Cover images: this environment has no `supabase link` / Storage access
// (no service-role key, no linked project — confirmed 2026-09-21), so
// `scripts/lib/self-host-cover.js` cannot run here. `cover_url` is
// populated with Hardcover's own asset URL directly for every book in
// this batch, a deliberate, documented deviation from the 2026-09-18
// self-hosting convention. These ~200 covers still need to go through
// the self-hosting pipeline from a machine that DOES have Storage access.

import pg from 'pg';
import { writeFileSync } from 'node:fs';

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
    const data = await hcGraphQL(gql, { ids: batch });
    for (const b of data.books) map.set(b.id, b.default_audio_edition?.audio_seconds ?? null);
  }
  return map;
}

// Real per-tag vote counts (not just search-index list position -- see
// genreDominance() below for why position alone proved insufficient).
async function fetchGenreTags(hardcoverIds) {
  const map = new Map();
  const batchSize = 50;
  for (let i = 0; i < hardcoverIds.length; i += batchSize) {
    const batch = hardcoverIds.slice(i, i + batchSize);
    const gql = `
      query GenreTags($ids: [Int!]) {
        books(where: { id: { _in: $ids } }) {
          id
          cached_tags
        }
      }
    `;
    const data = await hcGraphQL(gql, { ids: batch });
    for (const b of data.books) map.set(b.id, b.cached_tags?.Genre ?? []);
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

function authorTokens(author) {
  return new Set(
    (author || '')
      .toLowerCase()
      .split(/\s+/)
      .filter((w) => w.length > 2) // drop initials/particles
  );
}

function authorsOverlapTokens(wantedTokens, hardcoverNames) {
  return (hardcoverNames || []).some((name) => {
    const got = authorTokens(name);
    for (const t of wantedTokens) if (got.has(t)) return true;
    return false;
  });
}

// --- Quality filter signals ---

// Auto-excluded formats: out of v1's prose-SFF-novel scope. Short Story (3)
// and Collection (8) deliberately NOT included — in scope per CLAUDE.md.
const EXCLUDED_CATEGORY_IDS = new Set([4, 5, 6, 7]); // Graphic Novel, Fan Fiction, Research Paper, Poetry

const SFF_GENRE_PATTERN = /fantasy|sci-?fi|science[\s-]?fiction|speculative fiction/i;

// Real vote-count-based dominance check, using books.cached_tags.Genre
// (see fetchGenreTags). Calibrated 2026-09-21 after the cheaper position-
// only version (top-2 of document.genres) let real false positives through
// when total votes were tiny -- e.g. "Fall of Giants" (Ken Follett's WWI
// historical-fiction novel) had "Fantasy" at genres[1] on a sample of just
// 13 total votes (Historical Fiction:4, Fantasy:1, ...) -- position alone
// can't distinguish "a real secondary genre" from "one user's mistag that
// happened to rank second out of three total tags." Requiring the SFF tag
// to hold the single highest RAW vote count (not just an early position),
// with a minimum sample floor so a 1-vote document can't trivially "win",
// caught that case and every other reviewed false positive (The Pumpkin
// Spice Café, Sputnik Sweetheart, Heroes: The Greek Myths Reimagined --
// the last of these also carries an explicit "non-fiction" tag) while
// still passing every real SFF book checked (We Are Legion, The Lion the
// Witch and the Wardrobe, Mistborn, Atlas Shrugged correctly still
// rejected: its top tag is Classics:4 vs Science Fiction:2).
const MIN_GENRE_VOTE_FLOOR = 3;
function genreDominance(genreTags) {
  if (!genreTags || genreTags.length === 0) return { verdict: 'no_data' };
  const topCount = Math.max(...genreTags.map((g) => g.count));
  if (topCount < MIN_GENRE_VOTE_FLOOR) return { verdict: 'no_data' };
  const sffTags = genreTags.filter((g) => SFF_GENRE_PATTERN.test(g.tag));
  const sffTopCount = sffTags.length ? Math.max(...sffTags.map((g) => g.count)) : 0;
  const topTag = genreTags.find((g) => g.count === topCount)?.tag;
  if (sffTopCount === topCount) return { verdict: 'accept', topTag, topCount, sffTopCount };
  return { verdict: 'reject', topTag, topCount, sffTopCount };
}

function sqlEscape(s) {
  if (s === null || s === undefined) return 'null';
  if (typeof s === 'number') return String(s);
  return `'${String(s).replace(/'/g, "''")}'`;
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

const TARGET_PER_GENRE = Number(process.env.PULL_COUNT || 1050);

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();

  const rejectLog = { duplicate_hardcover_id: [], duplicate_title_author: [], category: [], genre_not_dominant: [], no_genre_data: [] };
  const accepted = [];

  try {
    // --- 1. Existing dedup sets (ALL books, archived included) ---
    console.log('Loading existing dedup sets from DB (incl. archived rows)...');
    const existingHardcoverIds = new Set(
      (await client.query('select hardcover_id from books where hardcover_id is not null'))
        .rows.map((r) => r.hardcover_id)
    );
    const existingByTitle = new Map(); // normalizedTitle -> [authorTokens sets]
    for (const row of (await client.query('select title, author from books')).rows) {
      const nt = normalizeTitle(row.title);
      if (!existingByTitle.has(nt)) existingByTitle.set(nt, []);
      existingByTitle.get(nt).push(authorTokens(row.author));
    }
    console.log(`  ${existingHardcoverIds.size} existing hardcover_ids, ${existingByTitle.size} distinct normalized titles.`);

    // --- 2. Pull the next tier of Fantasy + Science Fiction by popularity ---
    console.log(`Pulling top ${TARGET_PER_GENRE} Fantasy books...`);
    const fantasy = await searchBooks({
      filterBy: 'genres:=[Fantasy]',
      sort: 'users_count:desc',
      count: TARGET_PER_GENRE,
    });
    console.log(`Pulling top ${TARGET_PER_GENRE} Science Fiction books...`);
    const scifi = await searchBooks({
      filterBy: 'genres:=[Science Fiction]',
      sort: 'users_count:desc',
      count: TARGET_PER_GENRE,
    });

    const seen = new Set();
    const rawCandidates = [];
    for (const doc of [...fantasy, ...scifi]) {
      // The search index returns doc.id (and nested series ids) as JSON
      // STRINGS, while every DB-sourced id and every `books(where:...)`/
      // `series(where:...)` follow-up query returns real integers. Normalize
      // once here so every downstream Set/Map keyed on these ids (existing-
      // hardcover-id dedup, fetchGenreTags, fetchAudioSeconds, series
      // resolution) compares like-for-like -- a real bug caught during this
      // round's own testing: a first pass silently returned "no genre data"
      // for EVERY candidate (including manually-verified-rich-tag-data books
      // like We Are Legion) because Map.get(string) never matches a Map
      // keyed by number.
      doc.id = Number(doc.id);
      if (doc.featured_series?.series?.id != null) {
        doc.featured_series.series.id = Number(doc.featured_series.series.id);
      }
      if (seen.has(doc.id)) continue; // dedup fantasy/sci-fi overlap
      seen.add(doc.id);
      rawCandidates.push(doc);
    }
    console.log(`${rawCandidates.length} raw candidates after fantasy/scifi overlap dedup.`);

    // --- 3a. Cheap filters first: hardcover_id dedup, title/author dedup
    //         (against BOTH the existing DB and other candidates already
    //         accepted this same run -- two different editions of the same
    //         not-yet-catalogued book can both appear across the fantasy/
    //         scifi pulls), and format-category exclusion. Candidates are
    //         processed in popularity order (fantasy list then scifi list,
    //         each already sorted users_count desc), so "first seen" for a
    //         title is the higher-popularity edition.
    const runSeenTitles = new Map(); // normalizedTitle -> [authorTokens sets] (this run's survivors so far)
    const reducedCandidates = [];
    for (const doc of rawCandidates) {
      if (existingHardcoverIds.has(doc.id)) {
        rejectLog.duplicate_hardcover_id.push(doc.title);
        continue;
      }

      const nt = normalizeTitle(doc.title);
      const candTokens = authorTokens((doc.author_names || []).join(', '));
      const isDupAgainst = (map) => {
        const sets = map.get(nt);
        if (!sets) return false;
        return sets.some((wanted) => {
          for (const t of wanted) if (candTokens.has(t)) return true;
          return false;
        });
      };
      if (isDupAgainst(existingByTitle)) {
        rejectLog.duplicate_title_author.push(`${doc.title} (hardcover #${doc.id}) -- matches existing row under a different edition`);
        continue;
      }
      if (isDupAgainst(runSeenTitles)) {
        rejectLog.duplicate_title_author.push(`${doc.title} (hardcover #${doc.id}) -- duplicate edition of another candidate already accepted this run`);
        continue;
      }

      if (EXCLUDED_CATEGORY_IDS.has(doc.book_category_id)) {
        rejectLog.category.push(`${doc.title} -- book_category_id ${doc.book_category_id}`);
        continue;
      }

      if (!runSeenTitles.has(nt)) runSeenTitles.set(nt, []);
      runSeenTitles.get(nt).push(candTokens);
      reducedCandidates.push(doc);
    }
    console.log(`${reducedCandidates.length} candidates survive dedup+category filters; fetching real genre-tag vote counts for these...`);

    // --- 3b. Real vote-count-based genre-dominance filter (see genreDominance) ---
    const genreTagMap = await fetchGenreTags(reducedCandidates.map((d) => d.id));
    const manualReviewDocs = []; // full detail for the no-structured-signal fallback bucket -- see CLAUDE.md-directed synopsis screen
    for (const doc of reducedCandidates) {
      const genreTags = genreTagMap.get(doc.id) || [];
      const verdict = genreDominance(genreTags);
      if (verdict.verdict === 'no_data') {
        rejectLog.no_genre_data.push(`${doc.title} -- ${genreTags.length === 0 ? 'no genre tags at all' : `top count ${verdict.topCount ?? 'n/a'} below floor ${MIN_GENRE_VOTE_FLOOR}`}`);
        manualReviewDocs.push({
          id: doc.id,
          title: doc.title,
          author: (doc.author_names || []).join(', '),
          description: doc.description ?? null,
          genres: doc.genres ?? [],
          genreTags,
          book_category_id: doc.book_category_id,
        });
        continue;
      }
      if (verdict.verdict === 'reject') {
        rejectLog.genre_not_dominant.push(`${doc.title} -- top tag "${verdict.topTag}":${verdict.topCount} vs best SFF tag count ${verdict.sffTopCount} (${JSON.stringify(genreTags.slice(0, 5).map((g) => `${g.tag}:${g.count}`))})`);
        continue;
      }
      accepted.push(doc);
    }

    console.log(`\n=== Filter results ===`);
    console.log(`Accepted: ${accepted.length}`);
    console.log(`Rejected - duplicate hardcover_id: ${rejectLog.duplicate_hardcover_id.length}`);
    console.log(`Rejected - duplicate title/author (different edition): ${rejectLog.duplicate_title_author.length}`);
    console.log(`Rejected - excluded category (graphic novel/fan fiction/research paper/poetry): ${rejectLog.category.length}`);
    console.log(`Rejected - genre not dominant (non-SFF leakage): ${rejectLog.genre_not_dominant.length}`);
    console.log(`Rejected - no/insufficient genre data (manual-review bucket): ${rejectLog.no_genre_data.length}`);

    // --- 4. Batch-fetch audiobook duration for accepted docs only ---
    const audioMap = await fetchAudioSeconds(accepted.map((d) => d.id));

    // --- 5. Resolve series for accepted docs ---
    const seriesByHcId = new Map();
    for (const doc of accepted) {
      const s = doc.featured_series?.series;
      if (s && !seriesByHcId.has(s.id)) {
        seriesByHcId.set(s.id, { name: s.name, books_count: s.books_count ?? null });
      }
    }
    const existingSeriesHcIds = new Set(
      (await client.query('select hardcover_id from series where hardcover_id is not null'))
        .rows.map((r) => r.hardcover_id)
    );
    const hcSeriesIds = [...seriesByHcId.keys()];
    const needCreation = hcSeriesIds.filter((id) => !existingSeriesHcIds.has(id));
    const completionMap = await fetchSeriesCompletion(needCreation);

    const seriesSqlLines = [];
    for (const hcId of needCreation) {
      const meta = seriesByHcId.get(hcId);
      const isCompleted = completionMap.get(hcId);
      const status = isCompleted === true ? 'completed' : 'ongoing';
      seriesSqlLines.push(
        `insert into series (name, status, book_count, hardcover_id) values (${sqlEscape(meta.name)}, ${sqlEscape(status)}, ${meta.books_count ?? 'null'}, ${hcId}) on conflict (hardcover_id) do nothing;`
      );
    }

    const seriesLinkFor = (doc) => {
      const fs = doc.featured_series;
      if (!fs || !fs.series) return { hcSeriesId: null, position: null };
      return { hcSeriesId: fs.series.id, position: fs.position ?? null };
    };

    // --- 6. Build books INSERT statements ---
    const bookSqlLines = [];
    for (const doc of accepted) {
      const fields = docToBookFields(doc, audioMap.get(doc.id));
      const { hcSeriesId, position } = seriesLinkFor(doc);
      const seriesExpr = hcSeriesId != null ? `(select id from series where hardcover_id = ${hcSeriesId})` : 'null';
      bookSqlLines.push(
        `insert into books (title, author, isbn, cover_url, synopsis, page_count, audiobook_duration_minutes, publication_year, hardcover_id, series_id, position_in_series) values (${sqlEscape(fields.title)}, ${sqlEscape(fields.author)}, ${sqlEscape(fields.isbn)}, ${sqlEscape(fields.cover_url)}, ${sqlEscape(fields.synopsis)}, ${fields.page_count ?? 'null'}, ${fields.audiobook_duration_minutes ?? 'null'}, ${fields.publication_year ?? 'null'}, ${fields.hardcover_id}, ${seriesExpr}, ${sqlEscape(position)}) on conflict (hardcover_id) do nothing;`
      );
    }

    // --- 7. Write outputs to scratchpad for review before generating the real migration ---
    const out = {
      targetPerGenre: TARGET_PER_GENRE,
      rawCandidateCount: rawCandidates.length,
      acceptedCount: accepted.length,
      seriesCreatedCount: needCreation.length,
      rejectLog,
      acceptedTitles: accepted.map((d) => ({ id: d.id, title: d.title, author: (d.author_names || []).join(', '), genres: d.genres })),
      manualReviewDocs,
      acceptedFullDocs: accepted,
      manualReviewFullDocs: reducedCandidates.filter((d) => manualReviewDocs.some((m) => m.id === d.id)),
      seriesSqlLines,
      bookSqlLines,
    };
    const outPath = process.env.OUT_PATH || 'round5-output.json';
    writeFileSync(outPath, JSON.stringify(out, null, 2));
    console.log(`\nWrote full output (incl. generated SQL lines) to ${outPath}`);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
