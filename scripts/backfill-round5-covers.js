// Self-hosts cover images for the 226 catalog-expansion-round-5 books
// (2026-09-21) that were ingested from an environment (CLDA) with no
// Supabase Storage access -- their cover_url still points at
// Hardcover's own CDN, which CLAUDE.md's 2026-09-18 rule says not to
// rely on long-term. Runs against local (DATABASE_URL), updates each
// row locally, and writes out a migration file with the equivalent
// hardcover_id-scoped UPDATEs for hosted -- never a raw local uuid,
// since local/hosted ids differ for the same book.
import pg from 'pg';
import { writeFile } from 'node:fs/promises';
import { selfHostCoverImage } from './lib/self-host-cover.js';

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) throw new Error('DATABASE_URL not set');

async function main() {
  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    const { rows } = await client.query(
      `select id, hardcover_id, title, cover_url from books
       where cover_url is not null and cover_url not like '%supabase.co/storage%'
       order by title`
    );
    console.log(`${rows.length} books to self-host.`);

    const succeeded = [];
    const failed = [];
    let i = 0;
    for (const row of rows) {
      i++;
      const hostedUrl = await selfHostCoverImage(row.cover_url, row.id);
      if (hostedUrl) {
        await client.query('update books set cover_url = $1 where id = $2', [hostedUrl, row.id]);
        succeeded.push({ hardcover_id: row.hardcover_id, title: row.title, url: hostedUrl });
        console.log(`[${i}/${rows.length}] OK   ${row.title}`);
      } else {
        failed.push({ hardcover_id: row.hardcover_id, title: row.title, source: row.cover_url });
        console.log(`[${i}/${rows.length}] FAIL ${row.title}`);
      }
    }

    console.log(`\nDone: ${succeeded.length} succeeded, ${failed.length} failed.`);
    if (failed.length) {
      console.log('Failed:', JSON.stringify(failed, null, 2));
    }

    const lines = [
      '-- Self-host cover images for the 226 catalog-expansion-round-5 books',
      '-- (2026-09-21) that still pointed at Hardcover\'s own CDN -- see',
      '-- scripts/backfill-round5-covers.js, run against local first. Each',
      '-- UPDATE is hardcover_id-scoped (never a raw local uuid, per CLAUDE.md\'s',
      '-- migration convention -- local/hosted ids differ for the same book).',
      '-- The images themselves were uploaded once, directly to this project\'s',
      '-- real (single, hosted) Storage bucket -- this file only records the',
      `-- resulting URL strings. ${failed.length} of ${rows.length} failed to`,
      '-- download/upload and are left pointing at Hardcover\'s CDN for now --',
      '-- see this migration\'s own generation log for which ones.',
      '',
    ];
    for (const s of succeeded) {
      const escapedUrl = s.url.replace(/'/g, "''");
      lines.push(`update books set cover_url = '${escapedUrl}' where hardcover_id = ${s.hardcover_id};`);
    }
    lines.push('');
    const sql = lines.join('\n');
    const outPath = 'supabase/migrations/20260922020000_backfill_round5_covers.sql';
    await writeFile(outPath, sql);
    console.log(`\nWrote ${outPath}`);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
