-- First real use of Supabase Storage in this project. Self-hosting book
-- cover images (repo owner's decision, 2026-09-18) instead of hotlinking
-- Hardcover's own CDN, whose asset URLs already proved unreliable once
-- (see 20260918180000_fix_broken_cover_url_books_path.sql and
-- 20260918190000_upgrade_cover_url_resolution.sql). One image per book
-- for now -- multiple cover-art variants (e.g. US vs UK editions) are a
-- deliberately-deferred future idea, see docs/schema/book-dna.md's
-- Future fields backlog.
--
-- `public = true` serves every object in this bucket via a public URL
-- (`/storage/v1/object/public/book-covers/<path>`) with no auth needed
-- to READ, matching this project's existing pattern for public catalog
-- data (books/book_dna already grant anon+authenticated SELECT) -- cover
-- art isn't sensitive, the same reasoning that already applies to every
-- other catalog field. Writing to this bucket (uploading/replacing a
-- cover) is NOT opened up here -- no insert/update/delete policy is
-- added for `anon`/`authenticated`, so only the service role (or the
-- Supabase CLI's own linked-project storage access, which is what this
-- session actually used for the real upload) can write. This matches
-- the read-only-to-the-public, write-only-by-us shape every other
-- write path in this project already has.
insert into storage.buckets (id, name, public)
values ('book-covers', 'book-covers', true)
on conflict (id) do nothing;
