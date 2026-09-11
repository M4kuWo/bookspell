-- Builds "Westeros" as a real `universe` row, linking George R.R.
-- Martin's A Song of Ice and Fire (6 books), A Targaryen History (Fire
-- & Blood), and The Tales of Dunk and Egg (A Knight of the Seven
-- Kingdoms) -- part of the catalog-wide shared-universe linking audit
-- (docs/TODO.md).
--
-- Confirmed via search: all three are explicitly the same Westeros
-- continuity, not a loose/cameo reference -- Fire & Blood is an
-- in-universe Targaryen history covering centuries before A Game of
-- Thrones, and the Dunk and Egg novellas are a direct prequel set ~90
-- years before the main series (featuring a young Aegon V Targaryen).
-- Both are official companion works, part of the same book-continuity
-- canon as the main series -- the clearest, most explicit case checked
-- in this audit so far.
--
-- Naming: "Westeros" (the actual in-world continent/setting name),
-- matching the existing pattern of naming a universe after the place
-- itself rather than the flagship series title (Middle-earth, Abeth) --
-- avoids the same "collides with an existing series name" problem The
-- Broken Empire World's naming hit.
--
-- Also checked and confirmed NOT connected this same session, despite
-- being a plausible single-author candidate: Robert Jackson Bennett's
-- Divine Cities, Founders Trilogy, and Ana and Din Mysteries. Verified
-- via search -- Divine Cities and Founders Trilogy are explicitly
-- described as "entirely separate worlds and narratives," and Ana and
-- Din Mysteries is introduced as "a wholly original fantasy world"
-- (biopunk, titan-blood magic) with no connection mentioned to either.
-- All 3 stay separate, unlinked series -- no action taken for Bennett.

insert into universe (name)
select 'Westeros' where not exists (select 1 from universe where name = 'Westeros');

update series set universe_id = (select id from universe where name = 'Westeros')
where name = 'A Song of Ice and Fire';

update series set universe_id = (select id from universe where name = 'Westeros')
where name = 'A Targaryen History';

update series set universe_id = (select id from universe where name = 'Westeros')
where name = 'The Tales of Dunk and Egg';
