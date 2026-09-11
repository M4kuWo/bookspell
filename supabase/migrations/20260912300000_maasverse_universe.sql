-- Resolves the naming-policy question flagged in the prior batch
-- (docs/project-log.md's 2026-09-12 shared-universe audit batch 3
-- entry): Sarah J. Maas's A Court of Thorns and Roses, Throne of
-- Glass, and Crescent City are a real, author-confirmed connection
-- (character crossovers between all three worlds, Maas's own
-- "multiverse" quote) with no single unifying in-world place name to
-- fall back on the way Abeth/Westeros/Middle-earth allowed.
--
-- Repo owner's call (2026-09-12, has not read the books, asked for a
-- web check first): search for a common fan term before inventing one.
-- Confirmed real and widely used across fan wikis, reading-order
-- guides, and book blogs (not a single source's one-off coinage) --
-- "the Maasverse". Not an official Maas/publisher term, same as
-- "Enderverse" itself was flagged as fan/jacket-copy-originated rather
-- than author-coined and is still used as this schema's real universe
-- name -- consistent precedent for accepting a well-established fan
-- term as a real name here too. Repo owner's own explicit fallback if
-- this name doesn't hold up in use: revisit on user feedback.

insert into universe (name)
select 'Maasverse' where not exists (select 1 from universe where name = 'Maasverse');

update series set universe_id = (select id from universe where name = 'Maasverse')
where name = 'A Court of Thorns and Roses';

update series set universe_id = (select id from universe where name = 'Maasverse')
where name = 'Throne of Glass';

update series set universe_id = (select id from universe where name = 'Maasverse')
where name = 'Crescent City';
