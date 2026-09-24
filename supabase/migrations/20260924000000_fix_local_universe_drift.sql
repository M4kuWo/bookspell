-- Real local/hosted drift found 2026-09-24 while confirming the
-- Legend Universe/Lyra's World naming calls with the repo owner:
-- 3 universe rows (from the 2026-09-13 shared-universe-audit batches
-- 8 and 9) existed on hosted but not on local -- Meridian Empire,
-- Daevabad, and The Legend Universe. check_db_sync.py doesn't monitor
-- the `universe` table (only books/book_dna/book_tropes/tropes/
-- content_warning_types/audiobook_editions), so this had been silently
-- drifting since 2026-09-13 with nothing catching it. The two original
-- migrations that created these rows had no `on conflict` guard at
-- all (there's no unique constraint on `universe.name`, only a PK on
-- `id` -- confirmed directly), so this file uses `where not exists`
-- instead, which is idempotent without needing a schema change.
insert into universe (name)
select 'Meridian Empire' where not exists (select 1 from universe where name = 'Meridian Empire');
insert into universe (name)
select 'Daevabad' where not exists (select 1 from universe where name = 'Daevabad');
insert into universe (name)
select 'The Legend Universe' where not exists (select 1 from universe where name = 'The Legend Universe');

-- The corresponding series.universe_id links were verified against
-- hosted directly (not assumed) before writing these -- exactly the 6
-- series batches 8/9 actually linked, scoped by series name per this
-- project's own convention, guarded by `universe_id is null` so this
-- is a safe no-op if a series was somehow already linked.
update series set universe_id = (select id from universe where name = 'Meridian Empire')
where name = 'Caraval' and universe_id is null;
update series set universe_id = (select id from universe where name = 'Meridian Empire')
where name = 'Once Upon a Broken Heart' and universe_id is null;
update series set universe_id = (select id from universe where name = 'Daevabad')
where name = 'The Daevabad Trilogy' and universe_id is null;
update series set universe_id = (select id from universe where name = 'Daevabad')
where name = 'Amina al-Sirafi' and universe_id is null;
update series set universe_id = (select id from universe where name = 'The Legend Universe')
where name = 'Legend' and universe_id is null;
update series set universe_id = (select id from universe where name = 'The Legend Universe')
where name = 'Warcross' and universe_id is null;
