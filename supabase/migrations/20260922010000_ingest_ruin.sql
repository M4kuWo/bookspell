-- Ingest "Ruin" by John Gwynne (The Faithful and the Fallen #3) -- a
-- real ingestion gap flagged by CLDA during round-5 tagging batch 5
-- (2026-09-21): the series was 3/4 in the catalog (Malice, Valor,
-- Wrath) with book 3 missing entirely. Sourced from Hardcover
-- (hardcover_id 1235599, series hardcover_id 2438, already in this
-- catalog) via scripts/ingest-ruin.js, run against local first -- this
-- file mirrors that same insert for hosted, hardcover_id-scoped with ON
-- CONFLICT DO NOTHING per this project's idempotency convention.
-- cover_url points at this project's own self-hosted book-covers
-- storage bucket (per CLAUDE.md's 2026-09-18 rule); the actual image was
-- uploaded once, from local, via scripts/lib/self-host-cover.js -- this
-- migration only records the resulting URL string.
--
-- Not yet tagged -- Book DNA tagging is a separate, research-heavy pass
-- left for the next tag-catalog-batch run (this series is now 4/4 in
-- catalog, a natural partial-series-completion pick per that skill's
-- own prioritization).

insert into books
  (title, author, isbn, cover_url, synopsis, page_count,
   audiobook_duration_minutes, publication_year, hardcover_id,
   series_id, position_in_series)
select 'Ruin', 'John Gwynne', '174353910X', 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/0a0423eb-25d4-4d72-a5e0-4fb6249c9f8e.jpg',
  'The cunning Queen Rhin has conquered the west and High King Nathair has the cauldron, most powerful of the seven treasures. At his back stands the scheming Calidus and a warband of the Kadoshim, dread demons of the Otherworld. They plan to bring Asroth and his host of the Fallen into the world of flesh, but to do so they need the seven treasures. Nathair has been deceived but now he knows the truth. He has choices to make, choices that will determine the fate of the Banished Lands.

Elsewhere the flame of resistance is growing -- Queen Edana finds allies in the swamps of Ardan. Maquin is loose in Tenebral, hunted by Lykos and his corsairs. Here he will witness the birth of a rebellion in Nathair''s own realm.
Corban has been swept along by the tide of war. He has suffered, lost loved ones, sought only safety from the darkness. But he will run no more. He has seen the face of evil and he has set his will to fight it. The question is, how?

With a disparate band gathered about him -- his family, friends, giants, fanatical warriors, an angel and a talking crow he begins the journey to Drassil, the fabled fortress hidden deep in the heart of Forn Forest. For in Drassil lies the spear of Skald, one of the seven treasures, and here it is prophesied that the Bright Star will stand against the Black Sun.', 768, null, 2015,
  1235599, (select id from series where hardcover_id = 2438), 3
on conflict (hardcover_id) do nothing;
