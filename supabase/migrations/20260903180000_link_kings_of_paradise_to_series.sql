-- Kings of Paradise (Richard Nell) came in from Hardcover with
-- series_id = NULL (Hardcover's own record has no featured_series for
-- this specific book), but its two sequels -- ingested 2026-09-03 in
-- 20260903170000_targeted_ingestion_mathias_priority_list.sql -- ARE
-- linked to the new "Ash and Sand" series row, leaving the trilogy
-- inconsistently linked (book 1 orphaned, books 2-3 linked). Flagged
-- as an optional follow-up in that migration; repo owner asked for it
-- to be fixed. Single row, scoped by exact title match.

update books
set series_id = (select id from series where hardcover_id = 1470),
    position_in_series = '1'
where title = 'Kings of Paradise' and series_id is null;
