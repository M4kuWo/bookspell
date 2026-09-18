// Downloads a book cover from wherever Hardcover's search result points
// (its own CDN, whose asset URLs have already proven unreliable once --
// see docs/project-log.md's 2026-09-18 entries) and re-uploads it into
// this project's own `book-covers` Supabase Storage bucket, returning
// OUR public URL instead. Every ingestion script's `cover_url` field
// should go through this rather than storing Hardcover's URL directly,
// starting 2026-09-18 -- see CLAUDE.md's ingestion conventions.
//
// Uploads via the `supabase` CLI's own linked-project storage access
// (same mechanism the 2026-09-18 backfill used for all 1254 existing
// covers), not the JS Storage client -- this project doesn't hold a
// service-role key anywhere, and the CLI's login/link state already
// provides the needed write access without one.

import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { writeFile, rm, mkdtemp } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';

const execFileAsync = promisify(execFile);
const SUPABASE_PROJECT_URL = 'https://yhvubjqstswxvctdikbc.supabase.co';

function extFromUrl(url, contentType) {
  const pathExt = path.extname(new URL(url).pathname).toLowerCase();
  if (['.jpg', '.jpeg', '.png', '.webp', '.gif'].includes(pathExt)) {
    return pathExt === '.jpeg' ? '.jpg' : pathExt;
  }
  if (contentType?.includes('png')) return '.png';
  if (contentType?.includes('webp')) return '.webp';
  if (contentType?.includes('gif')) return '.gif';
  return '.jpg';
}

/**
 * @param {string} sourceUrl - the cover image URL from Hardcover (or any source)
 * @param {string} bookId - this project's own books.id (uuid), used as the
 *   storage object's filename so it's stable and never needs a title lookup
 * @returns {Promise<string|null>} our own public storage URL, or null if
 *   sourceUrl was falsy or the download/upload failed (logged, not thrown --
 *   a failed cover shouldn't block the rest of an ingestion batch)
 */
export async function selfHostCoverImage(sourceUrl, bookId) {
  if (!sourceUrl) return null;
  let tmpDir;
  try {
    const res = await fetch(sourceUrl, { headers: { 'User-Agent': 'curl/8.0' } });
    if (!res.ok) {
      console.warn(`selfHostCoverImage: ${sourceUrl} returned ${res.status}, skipping`);
      return null;
    }
    const buf = Buffer.from(await res.arrayBuffer());
    const ext = extFromUrl(sourceUrl, res.headers.get('content-type'));
    tmpDir = await mkdtemp(path.join(tmpdir(), 'cover-'));
    const tmpFile = path.join(tmpDir, `${bookId}${ext}`);
    await writeFile(tmpFile, buf);

    const dest = `ss:///book-covers/covers/${bookId}${ext}`;
    await execFileAsync('npx', ['supabase', 'storage', 'cp', tmpFile, dest, '--linked', '--experimental']);

    return `${SUPABASE_PROJECT_URL}/storage/v1/object/public/book-covers/covers/${bookId}${ext}`;
  } catch (err) {
    console.warn(`selfHostCoverImage: failed for ${sourceUrl} (book ${bookId}):`, err.message);
    return null;
  } finally {
    if (tmpDir) {
      await rm(tmpDir, { recursive: true, force: true }).catch(() => {});
    }
  }
}
