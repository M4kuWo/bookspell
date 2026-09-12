-- Shared-universe linking audit, batch 8 (docs/TODO.md P2 item).
-- One new universe built. Full evidence trail in docs/project-log.md's
-- 2026-09-13 batch-8 entry.

-- "Meridian Empire" -- Stephanie Garber's Caraval + Once Upon a Broken
-- Heart. Confirmed connected by the author herself (Goodreads Q&A:
-- "it's set in the same Universe as Caraval"), with a real structural
-- link, not just a shared-vibe claim -- Jacks (Caraval's antagonist)
-- is the male lead of Once Upon a Broken Heart, and Scarlett/Tella from
-- Caraval make a direct in-story appearance in it. Named after the real
-- in-world place name for the shared setting (Flatiron's official "The
-- World of Caraval" companion site, and the "Spectacular" novella both
-- use "Meridian Empire" directly) -- matches the established place-name
-- pattern (Westeros/Abeth/Middle-earth/Elan), no fan-coined umbrella
-- term was found to exist instead.
insert into universe (name)
select 'Meridian Empire' where not exists (select 1 from universe where name = 'Meridian Empire');

update series set universe_id = (select id from universe where name = 'Meridian Empire')
where name = 'Caraval';

update series set universe_id = (select id from universe where name = 'Meridian Empire')
where name = 'Once Upon a Broken Heart';
