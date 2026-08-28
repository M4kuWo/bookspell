-- Track source-system ids for dedup and future re-sync, now that step 03
-- actually pulls from an external API. Not part of the DNA schema itself.
alter table books add column hardcover_id integer unique;
alter table series add column hardcover_id integer unique;
