-- Ingest "The Traitor God" by Cameron Johnston (Age of Tyranny #1) --
-- the repo owner's real "suggest a book" test submission
-- (book_suggestions id 2aaac6b1-a32c-407e-bbce-fd083560c2f6, 2026-09-18).
-- Confirmed genuinely missing from the catalog, in v1 scope (grimdark
-- SFF). Sourced from Hardcover (hardcover_id 480938 for the book, 8472
-- for its series) via scripts/ingest-traitor-god.js, run against local
-- first -- this file mirrors that same insert for hosted, hardcover_id-
-- scoped with ON CONFLICT DO NOTHING per this project's idempotency
-- convention. cover_url points at this project's own self-hosted
-- book-covers storage bucket (per CLAUDE.md's 2026-09-18 rule), not
-- Hardcover's own CDN URL -- the actual image was uploaded once, from
-- local, via scripts/lib/self-host-cover.js; this migration only
-- records the resulting URL string.

insert into series (name, status, book_count, hardcover_id)
values ('Age of Tyranny', 'ongoing', 2, 8472)
on conflict (hardcover_id) do nothing;

insert into books
  (title, author, isbn, cover_url, synopsis, page_count,
   audiobook_duration_minutes, publication_year, hardcover_id,
   series_id, position_in_series)
select 'The Traitor God', 'Cameron Johnston', '0857667807', 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/e2be0c61-409d-4a5a-b183-e46e5caf7b9a.jpg',
  '**A city threatened by unimaginable horrors must trust their most hated outcast, or lose everything, in this crushing epic fantasy debut.**

After ten years on the run, dodging daemons and debt, reviled magician Edrin Walker returns home to avenge the brutal murder of his friend. Lynas had uncovered a terrible secret, something that threatened to devour the entire city. He tried to warn the Arcanum, the sorcerers who rule the city. He failed.

Lynas was skinned alive and Walker felt every cut. Now nothing will stop him from finding the murderer. Magi, mortals, daemons, and even the gods – Walker will burn them all if he has to.

After all, it wouldn’t be the first time he’s killed a god…

([Source][1])

[1]: https://angryrobotbooks.com/books/the-traitor-god/', 445, null, 2018,
  480938, (select id from series where hardcover_id = 8472), 1
on conflict (hardcover_id) do nothing;
