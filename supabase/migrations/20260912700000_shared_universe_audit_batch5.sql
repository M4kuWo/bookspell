-- Shared-universe linking audit, batch 5 (docs/TODO.md P2 item).
-- Three new universes built. Full evidence trail in docs/project-log.md's
-- 2026-09-12 batch-5 entry.

-- 1) "Elan" -- Michael J. Sullivan's Legends of the First Empire and The
-- Riyria Revelations. Confirmed connected: both are explicitly set in the
-- same fictional world, Elan, per the author's own site (organizes all his
-- work under "The Elan Saga" / "World of Elan"), just ~3,000 years apart on
-- a shared timeline. Not a mere shared-geography coincidence -- the actual
-- structural link is that characters who appear only as historical/legendary
-- figures in Riyria are met directly, in person, in Legends (and vice versa
-- in terms of in-universe chronology), the same "recurring character across
-- books" bar used for Foundation/Robot and Westeros. Named after the real
-- in-world place (the whole world is called Elan) -- same pattern as
-- Westeros/Abeth/Middle-earth, no naming-policy question.
insert into universe (name)
select 'Elan' where not exists (select 1 from universe where name = 'Elan');

update series set universe_id = (select id from universe where name = 'Elan')
where name = 'The Legends of the First Empire';

update series set universe_id = (select id from universe where name = 'Elan')
where name = 'The Riyria Revelations (Omnibus)';

-- 2) "The Shadowhunter Chronicles" -- Cassandra Clare's The Infernal Devices
-- and The Mortal Instruments. Confirmed connected: The Infernal Devices is
-- an explicit prequel to The Mortal Instruments (set ~130 years earlier in
-- the same Shadowhunter/Downworlder world), with direct ancestor/descendant
-- character links (e.g. Infernal Devices' Will and Tessa Herondale are
-- Mortal Instruments protagonist Jace's direct ancestors, referenced by
-- name). Named after the real, official umbrella term Clare and her
-- publisher use for this whole franchise (own Wikipedia article, "The
-- Shadowhunter Chronicles") -- not invented.
insert into universe (name)
select 'The Shadowhunter Chronicles' where not exists (select 1 from universe where name = 'The Shadowhunter Chronicles');

update series set universe_id = (select id from universe where name = 'The Shadowhunter Chronicles')
where name = 'The Infernal Devices';

update series set universe_id = (select id from universe where name = 'The Shadowhunter Chronicles')
where name = 'The Mortal Instruments';

-- 3) "The World of the White Rat" -- T. Kingfisher's The Saint of Steel and
-- Swordheart. Confirmed connected: Swordheart explicitly shares its setting
-- with the Saint of Steel novels and the Clocktaur War duology, with
-- recurring characters from those books making appearances. Named after the
-- real in-world/fandom term (the Temple of the White Rat, a recurring
-- in-world institution across these books; matches goodreads' own "The
-- World of the White Rat" series grouping and a dedicated fan wiki of the
-- same name) -- not invented.
-- NOT included: "Sworn Soldier" (What Moves the Dead and its sequels) --
-- checked specifically and confirmed NOT part of this universe. It's a
-- separate Poe-retelling horror novella series with its own cast (Alex
-- Easton) and setting; the only connection to the White Rat books is that
-- the author reused a pronoun-by-caste linguistic concept she'd originated
-- there, not a shared setting or characters. Left unlinked.
insert into universe (name)
select 'The World of the White Rat' where not exists (select 1 from universe where name = 'The World of the White Rat');

update series set universe_id = (select id from universe where name = 'The World of the White Rat')
where name = 'The Saint of Steel';

update series set universe_id = (select id from universe where name = 'The World of the White Rat')
where name = 'Swordheart';

-- 4) "Lyra's World" -- Philip Pullman's His Dark Materials and The Book of
-- Dust. Confirmed connected: Pullman describes The Book of Dust as an
-- "equel" (not quite prequel or sequel) to His Dark Materials, set in the
-- same world with the same protagonist, Lyra Belacqua, across both
-- trilogies. NAMING FLAG for the repo owner: unlike the other three
-- universes in this batch, no official publisher/author-coined umbrella
-- name and no single widely-used fan term turned up across multiple
-- independent sources for the combined two-trilogy franchise (TV Tropes,
-- fan sites, and press all just say "His Dark Materials and The Book of
-- Dust" rather than using one brand name). "Lyra's World" is an in-world
-- term used within the books themselves to distinguish Lyra's home world
-- from Will's world and the other worlds of the multiverse (matching the
-- Four Londons/Abeth/Westeros in-world-place-name pattern), and is echoed
-- loosely by press/fan writeups describing Book of Dust as returning to
-- "Lyra's world" -- but this is this session's own call, not a confirmed
-- established brand the way Riordanverse/Maasverse/Elan/Shadowhunter
-- Chronicles are. Please sanity-check and rename later if it reads wrong.
insert into universe (name)
select 'Lyra''s World' where not exists (select 1 from universe where name = 'Lyra''s World');

update series set universe_id = (select id from universe where name = 'Lyra''s World')
where name = 'His Dark Materials';

update series set universe_id = (select id from universe where name = 'Lyra''s World')
where name = 'The Book of Dust';
