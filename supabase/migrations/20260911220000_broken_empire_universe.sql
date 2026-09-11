-- Builds "The Broken Empire World" as a real `universe` row, linking
-- The Broken Empire (Prince/King/Emperor of Thorns) and The Red Queen's
-- War (Prince of Fools/The Liar's Key/The Wheel of Osheim), per the
-- catalog-wide shared-universe linking audit (docs/TODO.md).
--
-- Scope confirmed directly by the repo owner 2026-09-11 (correcting an
-- earlier assumption this audit's own research had made): these two
-- series genuinely share one world -- concurrent timelines, same
-- planet, different locations, confirmed via search as "the Broken
-- Empire" world with overlapping characters. Book of the Ancestor and
-- The Library Trilogy are explicitly NOT part of this universe --
-- Book of the Ancestor's real connection is to Book of the Ice (a
-- separate universe, see the companion migration ingesting those 3
-- books), and The Library Trilogy isn't confirmed connected to either.
--
-- Naming: "the Broken Empire" is the real, search-confirmed name press/
-- fandom use for this world -- but using that exact string as the
-- universe name would collide with "The Broken Empire" series name
-- already in this catalog (ambiguous which one a query means). Used
-- "The Broken Empire World" instead (repo owner's own fallback
-- suggestion), same "World" suffix pattern as "The First Law World".

insert into universe (name) values ('The Broken Empire World');

update series set universe_id = (select id from universe where name = 'The Broken Empire World')
where name = 'The Broken Empire';

update series set universe_id = (select id from universe where name = 'The Broken Empire World')
where name = 'The Red Queen''s War';
