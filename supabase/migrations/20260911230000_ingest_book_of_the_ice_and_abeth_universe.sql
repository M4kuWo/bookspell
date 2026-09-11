-- Ingests the 3 Book of the Ice books (Mark Lawrence) and builds
-- "Abeth" as a real `universe` row linking them to the existing Book
-- of the Ancestor series -- part of the catalog-wide shared-universe
-- linking audit (docs/TODO.md).
--
-- Repo owner confirmed directly 2026-09-11: Book of the Ancestor and
-- Book of the Ice are genuinely the same world (the planet Abeth),
-- and asked for Book of the Ice to be added and tagged specifically so
-- this connection could be made properly, rather than leaving Book of
-- the Ancestor unlinked. Verified via search: no official branded name
-- exists for this shared setting beyond the planet's own name, Abeth
-- (used informally as "the Abeth universe") -- used that directly, per
-- the repo owner's own suggestion, since no better real name exists.
--
-- Also corrects a real error in this audit's original 2026-09-08 note,
-- which assumed "The Girl and the Stars" was Library Trilogy book 2 --
-- verified via search it's actually Book of the Ice book 1. The
-- Library Trilogy's real book 2 remains unidentified/unconfirmed and
-- is NOT addressed by this migration.
--
-- Author fields verified clean against Hardcover's cached_contributors
-- for all 3 books before inserting (Mark Lawrence only, no
-- contamination), per the mandatory ingestion policy. Bibliographic
-- data only in this file -- Book DNA tagging is a separate,
-- immediately-following migration, matching this project's standard
-- ingest-then-tag split.

insert into universe (name)
select 'Abeth' where not exists (select 1 from universe where name = 'Abeth');

insert into series (name, status, book_count, universe_id)
select 'Book of the Ice', 'completed', 3, (select id from universe where name = 'Abeth')
where not exists (select 1 from series where name = 'Book of the Ice');

-- Opportunistic fix while already touching this row: Book of the
-- Ancestor is a completed 3-book trilogy (Red Sister/Grey Sister/Holy
-- Sister, 2017-2019, confirmed via search), same series.status/
-- book_count display bug as docs/TODO.md's separate catalog-wide fix
-- item -- fixing it here rather than leaving it wrong for that item's
-- own future batch to rediscover.
update series set
  universe_id = (select id from universe where name = 'Abeth'),
  status = 'completed',
  book_count = 3
where name = 'Book of the Ancestor';

insert into books (title, author, cover_url, synopsis, page_count, publication_year, hardcover_id, series_id, position_in_series, work_type)
select 'The Girl and the Stars', 'Mark Lawrence',
  'https://assets.hardcover.app/external_data/32815519/a9380f9a22f2d1e71b73f07fb33932f440ab05b0.jpeg',
  'In the ice, east of the Black Rock, there is a hole into which broken children are thrown. Yaz''s people call it the Pit of the Missing and now it is drawing her in as she has always known it would.

To resist the cold, to endure the months of night when even the air itself begins to freeze, requires a special breed. Variation is dangerous, difference is fatal. And Yaz is not the same.

Yaz''s difference tears her from the only life she''s ever known, away from her family, from the boy she thought she would spend her days with, and has to carve out a new path for herself in a world whose existence she never suspected. A world full of difference and mystery and danger.

Yaz learns that Abeth is older and stranger than she had ever imagined. She learns that her weaknesses are another kind of strength and that the cruel arithmetic of survival that has always governed her people can be challenged.',
  384, 2020, 445568, (select id from series where name = 'Book of the Ice'), 1, 'novel'
where not exists (select 1 from books where title = 'The Girl and the Stars' and author = 'Mark Lawrence');

insert into books (title, author, cover_url, synopsis, page_count, publication_year, hardcover_id, series_id, position_in_series, work_type)
select 'The Girl and the Mountain', 'Mark Lawrence',
  'https://assets.hardcover.app/external_data/42501549/63de8d8aa0b55d35f18793c1a54ea27963250289.jpeg',
  'The second novel in the thrilling and epic new fantasy series from the international bestselling author of Red Sister and Prince of Thorns. On the planet Abeth there is only the ice. And the Black Rock. For generations the priests of the Black Rock have reached out from their mountain to steer the fate of the ice tribes. With their Hidden God, their magic and their iron, the priests'' rule has never been questioned. But when ice triber Yaz challenged their authority, she was torn away from the only life she had ever known, and forced to find a new path for herself. Yaz has lost her friends and found her enemies. She has a mountain to climb, and even if she can break the Hidden God''s power, her dream of a green world lies impossibly far to the south, across a vast emptiness of ice. Before the journey can even start, she has to find out what happened to the ones she loves and save those that can be saved. Abeth holds its secrets close, but the stars shine brighter for Yaz and she means to unlock the truth.',
  384, 2021, 467477, (select id from series where name = 'Book of the Ice'), 2, 'novel'
where not exists (select 1 from books where title = 'The Girl and the Mountain' and author = 'Mark Lawrence');

insert into books (title, author, cover_url, synopsis, page_count, publication_year, hardcover_id, series_id, position_in_series, work_type)
select 'The Girl and the Moon', 'Mark Lawrence',
  'https://assets.hardcover.app/edition/30425679/53c03b3b636154151f9570285673e42b26026702.jpeg',
  'In the third exhilarating novel in this dazzling epic fantasy series, a young outcast will fight against staggering odds to save her world. On the planet Abeth, a narrow Corridor of green land is surrounded on all sides by ice plains where only the strong survive. Ice triber Yaz has completed a perilous journey and arrived at the Corridor, and it exceeds and overwhelms all of her expectations. Everything seems different but some constants remain: her old enemies are still two steps ahead, bent on her destruction. She makes her way to the Convent of Sweet Mercy, where nuns train young girls who show the old gifts, but like the Corridor itself the convent is packed with peril and opportunity. Yaz has much to learn from the nuns, if they don''t decide to execute her. The fate of everyone squeezed between the Corridor''s vast walls, and ultimately the fate of those laboring to survive out on ice itself, hangs from the moon, and the battle to save the moon centers on the Ark of the Missing, buried beneath the emperor''s palace. Everyone wants Yaz to be the key that will open the Ark, the one the wise have sought for generations. But sometimes wanting isn''t enough.',
  416, 2022, 484947, (select id from series where name = 'Book of the Ice'), 3, 'novel'
where not exists (select 1 from books where title = 'The Girl and the Moon' and author = 'Mark Lawrence');
