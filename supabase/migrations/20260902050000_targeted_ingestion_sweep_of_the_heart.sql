-- One more targeted title (2026-09-02, same session as ...030000): Sweep
-- of the Heart, Osnat's one remaining flagged catalog gap (see
-- data/ratings/osnat.json's _meta) -- added to
-- scripts/ingest-targeted-titles-2.js after the fact rather than folded
-- into the earlier migration, which had already been generated and applied.

insert into series (name, status, book_count, hardcover_id) values ('Innkeeper Chronicles', 'ongoing', 12, 5966) on conflict (hardcover_id) do nothing;

insert into books (title, author, isbn, cover_url, synopsis, page_count, audiobook_duration_minutes, publication_year, hardcover_id, series_id, position_in_series) values ('Sweep of the Heart', 'Ilona Andrews', '9798364351043', 'https://assets.hardcover.app/external_data/59626213/9c40731a6818a3cd57d6ca8f6cdbd3260f4048a4.jpeg', '"Life is busier than ever for Innkeeper, Dina DeMille and Sean Evans. But it''s about to get even more chaotic when Sean''s werewolf mentor is kidnapped. To find him, they must host an intergalactic spouse-search for one of the most powerful rulers in the Galaxy. Dina is never one to back down from a challenge. That is, if she can manage her temperamental Red Cleaver chef; the consequences of her favorite Galactic ex-tyrant''s dark history; the tangled politics of an interstellar nation, and oh, yes, keep the wedding candidates from a dozen alien species from killing each other. Not to mention the Costco lady. They say love is a battlefield; but Dina and Sean are determined to limit the casualties"--', 456, 668, 2022, 589890, (select id from series where hardcover_id = 5966), '5') on conflict (hardcover_id) do nothing;
