-- Ingest "The Egg and Other Stories" by Andy Weir (Hardcover id 839124),
-- the real collection replacing the standalone "The Egg" row deleted in
-- 20260922030000. Sourced via scripts/ingest-egg-and-other-stories.js,
-- run against local first -- this file mirrors that same insert for
-- hosted, hardcover_id-scoped with ON CONFLICT DO NOTHING per this
-- project's idempotency convention. Author field is "Andy Weir" only --
-- NOT the 3 audiobook narrators Hardcover's own author_names lumps in,
-- confirmed via contribution_types (Author vs Reading), per CLAUDE.md's
-- author-contamination rule. Audio-only edition (no ebook on Hardcover);
-- page_count left null, audiobook_duration_minutes real (77 min).
-- cover_url points at this project's own self-hosted book-covers storage
-- bucket; the actual image was uploaded once, from local, via
-- scripts/lib/self-host-cover.js -- this migration only records the
-- resulting URL string.

insert into books
  (title, author, isbn, cover_url, synopsis, page_count,
   audiobook_duration_minutes, publication_year, hardcover_id,
   series_id, position_in_series)
select 'The Egg and Other Stories', 'Andy Weir', '197860405X', 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/0f0e4b06-a9bf-4d62-86fa-be3f25a8c92e.jpg',
  'Collected for the first time anywhere, the nine tales in The Egg and Other Stories highlight Andy Weir''s trademark wit and unexpected twists. For the few who have yet to experience The Martian, it''s a perfect appetizer. For passionate Weir fans, it''s a delicious dessert.
Stories included in this audio-exclusive collection are:
"Access"
"Antihypoxiant"
"Annie''s Day"
"The Real Deal"
"Bored World"
"The Midtown Butcher"
"Meeting Sarah"
"The Chef"
"The Egg"', null, 77, 2017,
  839124, null, null
on conflict (hardcover_id) do nothing;
