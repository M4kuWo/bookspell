-- Ingests "Sharp Ends" (Joe Abercrombie, 2014) -- the one confirmed
-- missing book in The First Law World continuity, flagged in
-- docs/TODO.md's shared-universe linking audit. Confirmed in-scope for
-- normal ingestion 2026-09-08 (same category as Arcanum Unbounded/The
-- Last Wish -- a continuity-forward short-story collection, already
-- fully tagged as regular novels elsewhere in this catalog).
--
-- Bibliographic data only, per this project's standard ingest-then-tag
-- split -- Book DNA tagging is a separate follow-up, not done here.
-- Author field verified clean against Hardcover's cached_contributors
-- (Joe Abercrombie only, no illustrator/translator contamination)
-- before inserting, per CLAUDE.md's mandatory ingestion policy.
--
-- Links directly to "The First Law World" universe with no series_id,
-- matching the other 3 standalones (Best Served Cold, The Heroes, Red
-- Country) linked in 20260911200000_first_law_universe.sql -- per the
-- design doc, a short-story collection set across this continuity
-- isn't "book N" of either trilogy.

insert into books (title, author, cover_url, synopsis, page_count, publication_year, hardcover_id, universe_id, work_type)
select
  'Sharp Ends',
  'Joe Abercrombie',
  'https://assets.hardcover.app/editions/30559795/7559139941140878.jpeg',
  'The Union army may be full of bastards, but there''s only one who thinks he can save the day single-handed when the Gurkish come calling: the incomparable Colonel Sand dan Glokta. Curnden Craw and his dozen are out to recover a mysterious item from beyond the Crinna. Only one small problem: no one seems to know what the item is. Shevedieh, the self styled best thief in Styria, lurches from disaster to catastrophe alongside her best friend and greatest enemy, Javre, Lioness of Hoskopp. And after years of bloodshed, the idealistic chieftain Bethod is desperate to bring peace to the North. There is only one obstacle left - his own lunatic champion, the most feared man in the North: the Bloody Nine. This book combines previously published tales with exclusive new short stories. Violence explodes, treachery abounds, and the words are as deadly as the weapons in this rogue''s gallery of side-shows, back-stories, and sharp endings from the world of the First Law.',
  372,
  2014,
  459277,
  (select id from universe where name = 'The First Law World'),
  'novel'
where not exists (select 1 from books where title = 'Sharp Ends' and author = 'Joe Abercrombie');
