-- work_type (novella/novel) on books, per user request 2026-08-29.
-- Deliberately NOT computed from page_count -- checked the data first:
-- page_count is not a reliable discriminator (Tor.com's novella imprint
-- uses a large trim/font, so Edgedancer at 272pp reads longer than full
-- novels like Fahrenheit 451 at 227pp or Piranesi at 245pp; conversely
-- The Time Machine at 144pp is a full novel, shorter than every
-- Murderbot novella). Set manually from real-world publishing
-- classification (award categories, publisher marketing) instead.
--
-- No `novelette` value -- this catalog is published SFF books, not
-- magazine-length short fiction, so that category doesn't realistically
-- occur as its own catalog entry (see book-dna.md future-fields backlog).

alter table books add column if not exists work_type text not null default 'novel'
  check (work_type in ('novella', 'novel'));

update books set work_type = 'novella' where title = 'All Systems Red';
update books set work_type = 'novella' where title = 'Artificial Condition';
update books set work_type = 'novella' where title = 'Rogue Protocol';
update books set work_type = 'novella' where title = 'Exit Strategy';
update books set work_type = 'novella' where title = 'Edgedancer';
update books set work_type = 'novella' where title = 'This Is How You Lose the Time War'; -- won the 2020 Hugo Award for Best Novella
