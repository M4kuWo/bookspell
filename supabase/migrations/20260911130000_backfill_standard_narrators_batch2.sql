-- Second batch of the audiobook_editions standard-narrator backfill,
-- covering the books flagged/skipped by the first pass
-- (20260911120000_backfill_standard_narrators.sql).
--
-- Why these needed a second pass: the original flagging heuristic
-- (flag any second narrator group with Hardcover users_count <= 2)
-- was too conservative. Verified live via web search on 6 sample
-- cases (Name of the Wind/Rupert Degas, Hitchhiker's Guide/Stephen
-- Moore, Assassin's Apprentice/Joe Eyre, Outlander/Geraldine James,
-- Best Served Cold/Steven Pacey, Watership Down/Ralph Cosham) --
-- ALL 6 turned out to be genuine distinct editions (a UK vs. US
-- market release, an abridged vs. unabridged edition, or an older
-- historical release) that Hardcover's community simply hasn't
-- logged much, not data noise. The real noise signal is a TYPO
-- variant of the same person's name (confirmed case: Mistborn: The
-- Final Empire's "Michael Krammer" vs "Michael Kramer"), not low
-- popularity -- scripts/backfill-standard-narrators.js was updated
-- to merge typo-variant groups (Levenshtein distance) instead of
-- flagging on raw popularity, and to merge a group whose narrator
-- set is a proper SUBSET of another group's set for the same book
-- (a mis-tagged duplicate missing a co-narrator credit, e.g. A
-- Crown of Swords' solo "Kate Reading" record next to its real
-- "Kate Reading + Michael Kramer" record).
--
-- 144 of the 291 previously-flagged/no-data books now resolve
-- cleanly (254 rows, since some have 2 genuine narrations, e.g.
-- the same UK/US pattern found on The Eye of the World in the
-- first pass). The remaining 147 are still deliberately NOT
-- inserted: 64 have 3+ distinct real groups (mostly public-domain
-- classics with many historical narrations, needing an actual
-- human pick of which to record -- see docs/TODO.md), 65 have no
-- narrator-labeled contributor in Hardcover's data, 18 have no
-- audio edition listed.
--
-- Every insert is title/author-scoped and idempotent via the
-- existing unique (book_id, source_url) constraint, per this
-- project's standing convention. Verified: every one of these 144
-- books' title/author pairs matches exactly one books row before
-- this file was generated (zero mismatches on a direct DB check).

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ralph Cosham', 'Simon Prebble']::text[], ' Blackstone Audio', null, 'https://hardcover.app/books/1984-animal-farm-1945/editions/20355456', current_date
from books where title = '1984 / Animal Farm' and author = 'George Orwell'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Fry']::text[], 'Audible Studios', null, 'https://hardcover.app/books/1984-animal-farm-1945/editions/31377745', current_date
from books where title = '1984 / Animal Farm' and author = 'George Orwell'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alison Hiroto', 'Marc Vietor']::text[], 'Brilliance Audio', 2805, 'https://hardcover.app/books/1q84/editions/32359000', current_date
from books where title = '1Q84' and author = 'Haruki Murakami'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Allison Hiroto', 'Marc Vietor', 'Mark Boyett']::text[], 'Audible Studios', 2805, 'https://hardcover.app/books/1q84/editions/32746720', current_date
from books where title = '1Q84' and author = 'Haruki Murakami'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Amanda Leigh Cobb']::text[], 'Recorded Books', 383, 'https://hardcover.app/books/a-court-of-frost-and-starlight/editions/20079416', current_date
from books where title = 'A Court of Frost and Starlight' and author = 'Sarah J. Maas'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Elizabeth Evans']::text[], 'Recorded Books', 365, 'https://hardcover.app/books/a-court-of-frost-and-starlight/editions/31446278', current_date
from books where title = 'A Court of Frost and Starlight' and author = 'Sarah J. Maas'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kate Reading', 'Michael Kramer']::text[], 'Audio Renaissance', 1825, 'https://hardcover.app/books/a-crown-of-swords/editions/29074612', current_date
from books where title = 'A Crown of Swords' and author = 'Robert Jordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Helena Coppejans']::text[], null, null, 'https://hardcover.app/books/a-discovery-of-witches/editions/32680557', current_date
from books where title = 'A Discovery of Witches' and author = 'Deborah Harkness'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jennifer Ikeda']::text[], 'Penguin Audio', 1439, 'https://hardcover.app/books/a-discovery-of-witches/editions/31714042', current_date
from books where title = 'A Discovery of Witches' and author = 'Deborah Harkness'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Eliza Foss', 'Jennifer Pickens']::text[], 'Macmillan Audio', 692, 'https://hardcover.app/books/a-sorceress-comes-to-call/editions/31621574', current_date
from books where title = 'A Sorceress Comes to Call' and author = 'T. Kingfisher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Zoe Mills']::text[], 'W. F. Howes Ltd ', 669, 'https://hardcover.app/books/a-sorceress-comes-to-call/editions/31698919', current_date
from books where title = 'A Sorceress Comes to Call' and author = 'T. Kingfisher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Barbara Caruso']::text[], 'Recorded Books', null, 'https://hardcover.app/books/a-wrinkle-in-time/editions/9582409', current_date
from books where title = 'A Wrinkle in Time' and author = 'Madeleine L''Engle'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Hope Davis']::text[], 'Listening Library', null, 'https://hardcover.app/books/a-wrinkle-in-time/editions/30761915', current_date
from books where title = 'A Wrinkle in Time' and author = 'Madeleine L''Engle'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Page']::text[], 'The Classic Collection', 351, 'https://hardcover.app/books/alices-adventures-in-wonderland-through-the-looking-glass/editions/33123473', current_date
from books where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass' and author = 'Lewis Carroll'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Cybill Shepherd', 'Lynn Redgrave']::text[], 'New Millennium Audio', null, 'https://hardcover.app/books/alices-adventures-in-wonderland-through-the-looking-glass/editions/8642903', current_date
from books where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass' and author = 'Lewis Carroll'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Aaron Stanford', 'Emma Galvin']::text[], 'Harper Fire', 711, 'https://hardcover.app/books/allegiant/editions/32761842', current_date
from books where title = 'Allegiant' and author = 'Veronica Roth'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Recorded Books, LLC', null, 'https://hardcover.app/books/american-gods/editions/13357334', current_date
from books where title = 'American Gods' and author = 'Neil Gaiman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Daniel Oreskes', 'Dennis Boutskiaris', 'Ron McLarty', 'Sarah Jones']::text[], 'Headline Digital', null, 'https://hardcover.app/books/american-gods/editions/31697933', current_date
from books where title = 'American Gods' and author = 'Neil Gaiman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Marie-Isabel Walke', 'Nicolás Artajo']::text[], 'Hörbuch Hamburg', 605, 'https://hardcover.app/books/an-absolutely-remarkable-thing/editions/32062653', current_date
from books where title = 'An Absolutely Remarkable Thing' and author = 'Hank Green'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Hank Green', 'Kristen Sieh']::text[], 'Orion Publishing Group', 565, 'https://hardcover.app/books/an-absolutely-remarkable-thing/editions/30390450', current_date
from books where title = 'An Absolutely Remarkable Thing' and author = 'Hank Green'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Fiona Hardingham', 'Steve West']::text[], null, 922, 'https://hardcover.app/books/an-ember-in-the-ashes/editions/32597362', current_date
from books where title = 'An Ember in the Ashes' and author = 'Sabaa Tahir'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Aysha Kala', 'Jack Farrar']::text[], 'HarperCollins Publishers', null, 'https://hardcover.app/books/an-ember-in-the-ashes/editions/33253930', current_date
from books where title = 'An Ember in the Ashes' and author = 'Sabaa Tahir'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Carolyn McCormick', 'January LaVoy']::text[], ' Blackstone Audio', null, 'https://hardcover.app/books/annihilation/editions/30403831', current_date
from books where title = 'Annihilation' and author = 'Jeff VanderMeer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Paul Boehmer']::text[], null, 1039, 'https://hardcover.app/books/assassins-apprentice/editions/30581272', current_date
from books where title = 'Assassin''s Apprentice' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Joe Eyre']::text[], 'Harper Voyager', 995, 'https://hardcover.app/books/assassins-apprentice/editions/33136524', current_date
from books where title = 'Assassin''s Apprentice' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Paul Boehmer']::text[], 'Tantor Audio', 2255, 'https://hardcover.app/books/assassins-quest/editions/31606270', current_date
from books where title = 'Assassin''s Quest' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Joe Eyre']::text[], 'Harper Voyager', 2266, 'https://hardcover.app/books/assassins-quest/editions/33144449', current_date
from books where title = 'Assassin''s Quest' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Steven Pacey']::text[], 'Gollancz', 1588, 'https://hardcover.app/books/best-served-cold/editions/32800531', current_date
from books where title = 'Best Served Cold' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Page']::text[], 'Orion', 1589, 'https://hardcover.app/books/best-served-cold/editions/30949701', current_date
from books where title = 'Best Served Cold' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Julia Whelan', 'Katie Leung', 'Marisa Calen']::text[], 'Macmillan Audio', 1106, 'https://hardcover.app/books/bury-our-bones-in-the-midnight-soil/editions/32104840', current_date
from books where title = 'Bury Our Bones in the Midnight Soil' and author = 'V. E. Schwab'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jeff Hays']::text[], 'Audible Studios', 688, 'https://hardcover.app/books/carls-doomsday-scenario/editions/32126838', current_date
from books where title = 'Carl''s Doomsday Scenario' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ana Fernández', 'Íñigo Álvarez de Lara']::text[], 'Audible Studios', 816, 'https://hardcover.app/books/carls-doomsday-scenario/editions/33108870', current_date
from books where title = 'Carl''s Doomsday Scenario' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 573, 'https://hardcover.app/books/carpe-jugulum/editions/17385851', current_date
from books where title = 'Carpe Jugulum' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi', null, 'https://hardcover.app/books/carpe-jugulum/editions/31740849', current_date
from books where title = 'Carpe Jugulum' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jonathan Davis']::text[], 'Audible Studios', 689, 'https://hardcover.app/books/count-zero/editions/32879153', current_date
from books where title = 'Count Zero' and author = 'William Gibson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alix Wilton Regan', 'Kyle Soller', 'Sebastián Sebastián Capitán Viveros']::text[], 'W. F. Howes Ltd', 596, 'https://hardcover.app/books/count-zero/editions/33276934', current_date
from books where title = 'Count Zero' and author = 'William Gibson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Suzy Jackson']::text[], 'Audible Studios', 796, 'https://hardcover.app/books/cytonic/editions/32046786', current_date
from books where title = 'Cytonic' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sophie Aldred']::text[], 'Gollancz', 868, 'https://hardcover.app/books/cytonic/editions/32607915', current_date
from books where title = 'Cytonic' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Aldrich Barrett']::text[], 'Audible Studios', 560, 'https://hardcover.app/books/dawn/editions/33014273', current_date
from books where title = 'Dawn ' and author = 'Octavia E. Butler'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Julienne Irons']::text[], 'Grand Central Publishing', 506, 'https://hardcover.app/books/dawn/editions/31171670', current_date
from books where title = 'Dawn ' and author = 'Octavia E. Butler'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Francesc Belda']::text[], null, 1621, 'https://hardcover.app/books/deaths-end/editions/31465903', current_date
from books where title = 'Death''s End' and author = 'Cixin Liu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['P. J. Ochlan']::text[], 'Macmillan Audio', 1731, 'https://hardcover.app/books/deaths-end/editions/31984629', current_date
from books where title = 'Death''s End' and author = 'Cixin Liu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sophie Aldred']::text[], 'Gollancz', 924, 'https://hardcover.app/books/defiant/editions/32627434', current_date
from books where title = 'Defiant' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Suzy Jackson']::text[], 'Dragonsteel', 829, 'https://hardcover.app/books/defiant/editions/31313475', current_date
from books where title = 'Defiant' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Douglas Adams']::text[], 'New Millennium Audio', 399, 'https://hardcover.app/books/dirk-gentlys-holistic-detective-agency/editions/23653347', current_date
from books where title = 'Dirk Gently''s Holistic Detective Agency' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Mangan']::text[], 'Pan Macmillan', null, 'https://hardcover.app/books/dirk-gentlys-holistic-detective-agency/editions/30385738', current_date
from books where title = 'Dirk Gently''s Holistic Detective Agency' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dick Hill']::text[], 'Brilliance Audio', 554, 'https://hardcover.app/books/dragonflight/editions/32337691', current_date
from books where title = 'Dragonflight' and author = 'Anne McCaffrey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sophie Aldred']::text[], 'Del Rey', null, 'https://hardcover.app/books/dragonflight/editions/30710828', current_date
from books where title = 'Dragonflight' and author = 'Anne McCaffrey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Evan Morton', 'Orlagh Cassidy', 'Scott Brick', 'Simon Vance']::text[], 'Audio Renaissance', null, 'https://hardcover.app/books/dune/editions/11346122', current_date
from books where title = 'Dune' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Recorded Books, LLC', 1367, 'https://hardcover.app/books/dune/editions/31481794', current_date
from books where title = 'Dune' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Euan Morton', 'Katharine Kellgren', 'Scott Brick', 'Simon Vance']::text[], 'Macmillan Audio', 535, 'https://hardcover.app/books/dune-messiah/editions/30805902', current_date
from books where title = 'Dune Messiah' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Euan Morton', 'Katherine Kellgren (narrator)', 'Scott Brick', 'Simon Vance']::text[], 'Macmillan Audio', 537, 'https://hardcover.app/books/dune-messiah/editions/31922659', current_date
from books where title = 'Dune Messiah' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ana Fernández', 'Íñigo Álvarez de Lara']::text[], 'Audible Studios', 1058, 'https://hardcover.app/books/dungeon-crawler-carl/editions/33108868', current_date
from books where title = 'Dungeon Crawler Carl' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jeff Hays']::text[], 'Audible Studios', 811, 'https://hardcover.app/books/dungeon-crawler-carl/editions/31923605', current_date
from books where title = 'Dungeon Crawler Carl' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jack Garrett']::text[], 'Clipper Audiobooks', 1722, 'https://hardcover.app/books/elantris/editions/30405435', current_date
from books where title = 'Elantris' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ell Potter', 'Michael Dodds']::text[], 'Del Rey', 725, 'https://hardcover.app/books/emily-wildes-encyclopaedia-of-faeries-2022/editions/31830539', current_date
from books where title = 'Emily Wilde''s Encyclopaedia of Faeries' and author = 'Heather Fawcett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Joe Jameson']::text[], 'HarperCollins UK', 904, 'https://hardcover.app/books/emperor-of-thorns/editions/32286874', current_date
from books where title = 'Emperor of Thorns' and author = 'Mark Lawrence'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['James Clamp']::text[], 'Recorded Books', 827, 'https://hardcover.app/books/emperor-of-thorns/editions/32533868', current_date
from books where title = 'Emperor of Thorns' and author = 'Mark Lawrence'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Samuel Roukin']::text[], 'Recorded Books, Inc.', 1558, 'https://hardcover.app/books/empire-of-silence/editions/31484601', current_date
from books where title = 'Empire of Silence' and author = 'Christopher Ruocchio'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Lee']::text[], 'Orion', 1558, 'https://hardcover.app/books/empire-of-silence/editions/32855862', current_date
from books where title = 'Empire of Silence' and author = 'Christopher Ruocchio'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Cast', 'Harlan Ellison', 'Stefan Rudnicki']::text[], 'Sound Library', 717, 'https://hardcover.app/books/enders-game/editions/21645157', current_date
from books where title = 'Ender''s Game' and author = 'Orson Scott Card'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gabrielle de Cuir', 'Harlan Ellison', 'Stefan Rudnicki']::text[], 'Macmillan Audio', 717, 'https://hardcover.app/books/enders-game/editions/31159004', current_date
from books where title = 'Ender''s Game' and author = 'Orson Scott Card'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gabrielle de Cuir', 'Scott Brick']::text[], 'Macmillan Audio', 942, 'https://hardcover.app/books/enders-shadow/editions/30403656', current_date
from books where title = 'Ender''s Shadow' and author = 'Orson Scott Card'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Gross']::text[], 'Audio Literature', null, 'https://hardcover.app/books/enders-shadow/editions/29782200', current_date
from books where title = 'Ender''s Shadow' and author = 'Orson Scott Card'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Seth Numrich', 'Stephen King']::text[], 'Simon & Schuster Audio', 1446, 'https://hardcover.app/books/fairy-tale-2022/editions/30665278', current_date
from books where title = 'Fairy Tale' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jeff Woodman']::text[], 'Recorded Books', 538, 'https://hardcover.app/books/flowers-for-algernon/editions/31546158', current_date
from books where title = 'Flowers for Algernon' and author = 'Daniel Keyes'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Adam Sims']::text[], 'Orion', 506, 'https://hardcover.app/books/flowers-for-algernon/editions/32424516', current_date
from books where title = 'Flowers for Algernon' and author = 'Daniel Keyes'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Larry McKeever']::text[], 'Random House Audio', 969, 'https://hardcover.app/books/forward-the-foundation/editions/32096577', current_date
from books where title = 'Forward the Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 928, 'https://hardcover.app/books/forward-the-foundation/editions/33019056', current_date
from books where title = 'Forward the Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Larry McKeever']::text[], 'Random House Audio', 1117, 'https://hardcover.app/books/foundation-and-earth/editions/32096519', current_date
from books where title = 'Foundation and Earth' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 1059, 'https://hardcover.app/books/foundation-and-earth/editions/33019055', current_date
from books where title = 'Foundation and Earth' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 975, 'https://hardcover.app/books/foundations-edge/editions/32096518', current_date
from books where title = 'Foundation''s Edge' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 1012, 'https://hardcover.app/books/foundations-edge/editions/33019083', current_date
from books where title = 'Foundation''s Edge' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['James Marsters']::text[], 'Penguin Audio', 1056, 'https://hardcover.app/books/ghost-story/editions/32737892', current_date
from books where title = 'Ghost Story' and author = 'Jim Butcher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Glover']::text[], 'Penguin Audio', 1075, 'https://hardcover.app/books/ghost-story/editions/32737832', current_date
from books where title = 'Ghost Story' and author = 'Jim Butcher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Katherine Kellgren', 'Scott Brick', 'Simon Vance']::text[], 'Macmillan Audio', 948, 'https://hardcover.app/books/god-emperor-of-dune/editions/30854545', current_date
from books where title = 'God Emperor of Dune' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'HarperAudio', 683, 'https://hardcover.app/books/going-postal/editions/31736269', current_date
from books where title = 'Going Postal' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bill Nighy', 'Peter Serafinowicz', 'Richard Coyle']::text[], 'Harper', 816, 'https://hardcover.app/books/going-postal/editions/33078680', current_date
from books where title = 'Going Postal' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Hugh Laurie']::text[], 'Penguin Audiobooks', null, 'https://hardcover.app/books/gullivers-travels/editions/8621403', current_date
from books where title = 'Gulliver''s Travels' and author = 'Jonathan Swift, Malvina G. Vogel'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['David Case']::text[], 'Tantor Media', null, 'https://hardcover.app/books/gullivers-travels/editions/11226960', current_date
from books where title = 'Gulliver''s Travels' and author = 'Jonathan Swift, Malvina G. Vogel'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ben Elliot']::text[], 'HarperCollins Publishers', 566, 'https://hardcover.app/books/half-a-king/editions/32879209', current_date
from books where title = 'Half a King' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Keating']::text[], 'Recorded Books', 557, 'https://hardcover.app/books/half-a-king/editions/30615265', current_date
from books where title = 'Half a King' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick', 'Simon Vance']::text[], 'Macmillan Audio', 1084, 'https://hardcover.app/books/heretics-of-dune/editions/33078621', current_date
from books where title = 'Heretics of Dune' and author = 'Frank Herbert'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 587, 'https://hardcover.app/books/hogfather/editions/11351588', current_date
from books where title = 'Hogfather' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bill Nighy', 'Peter Serafinowicz', 'Sian Clifford']::text[], 'Penguin Audio', 618, 'https://hardcover.app/books/hogfather/editions/31965435', current_date
from books where title = 'Hogfather' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jay Aaseng', 'Mikhaila Aaseng']::text[], 'Books on Tape', 780, 'https://hardcover.app/books/how-to-sell-a-haunted-house/editions/30613956', current_date
from books where title = 'How to Sell a Haunted House' and author = 'Grady Hendrix'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Danny Burstein', 'Steven Weber', 'Will Patton']::text[], 'Simon & Schuster Audio', 912, 'https://hardcover.app/books/if-it-bleeds/editions/30402936', current_date
from books where title = 'If It Bleeds' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Johnathan McClain', 'Lincoln Hoppe', 'Olivia Taylor Dudley']::text[], 'Listening Library', null, 'https://hardcover.app/books/illuminae/editions/14619974', current_date
from books where title = 'Illuminae' and author = 'Amie Kaufman, Jay Kristoff'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Beata Poźniak']::text[], 'Listening Library', 701, 'https://hardcover.app/books/illuminae/editions/30480225', current_date
from books where title = 'Illuminae' and author = 'Amie Kaufman, Jay Kristoff'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michelle Zauner', 'Sean Pratt']::text[], 'Hachette Audio', 3851, 'https://hardcover.app/books/infinite-jest/editions/31540287', current_date
from books where title = 'Infinite Jest' and author = 'David Foster Wallace'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Aedin Moloney', 'John Curless', 'Julian Elfer', 'Tim Gerard Reynolds']::text[], 'Recorded Books', 1403, 'https://hardcover.app/books/iron-gold/editions/31466618', current_date
from books where title = 'Iron Gold' and author = 'Pierce Brown'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Pierce Brown']::text[], 'Recorded Books, Inc.', null, 'https://hardcover.app/books/iron-gold/editions/31544250', current_date
from books where title = 'Iron Gold' and author = 'Pierce Brown'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Oliver Le Seuer', 'Seán Barrett']::text[], 'Naxos of America', null, 'https://hardcover.app/books/kafka-on-the-shore/editions/24599359', current_date
from books where title = 'Kafka on the Shore' and author = 'Haruki Murakami'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Mariel Stern', 'Steven Kaplan']::text[], 'Penguin Audio', null, 'https://hardcover.app/books/legend/editions/8130563', current_date
from books where title = 'Legend' and author = 'Marie Lu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Grace Grant', 'Sebastian York']::text[], null, 468, 'https://hardcover.app/books/legend/editions/33070946', current_date
from books where title = 'Legend' and author = 'Marie Lu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Julien ALLOUF']::text[], null, null, 'https://hardcover.app/books/legends-lattes/editions/32214128', current_date
from books where title = 'Legends & Lattes' and author = 'Travis Baldree'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Travis Baldree']::text[], 'Macmillan Audio', 439, 'https://hardcover.app/books/legends-lattes/editions/30648259', current_date
from books where title = 'Legends & Lattes' and author = 'Travis Baldree'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Amber Benson']::text[], 'Audible Studios', 656, 'https://hardcover.app/books/lock-in-2001/editions/32853103', current_date
from books where title = 'Lock In' and author = 'John Scalzi'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Wil Wheaton']::text[], 'Audible Studios', 596, 'https://hardcover.app/books/lock-in-2001/editions/31811977', current_date
from books where title = 'Lock In' and author = 'John Scalzi'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Kramer']::text[], 'Orion Publishing Group Limited', null, 'https://hardcover.app/books/mistborn/editions/30405361', current_date
from books where title = 'Mistborn: The Final Empire' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Crystal Clarke', 'Haruka Abe', 'Jill Winternitz', 'Joshua Collins']::text[], 'W. F. Howes Ltd', 622, 'https://hardcover.app/books/mona-lisa-overdrive/editions/33207684', current_date
from books where title = 'Mona Lisa Overdrive' and author = 'William Gibson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jonathan Davis']::text[], 'Audible Studios', 650, 'https://hardcover.app/books/mona-lisa-overdrive/editions/32879152', current_date
from books where title = 'Mona Lisa Overdrive' and author = 'William Gibson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'HarperAudio', 697, 'https://hardcover.app/books/monstrous-regiment/editions/31720601', current_date
from books where title = 'Monstrous Regiment' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bill Nighy', 'Katherine Parkinson', 'Peter Serafinowicz']::text[], 'Harper', 687, 'https://hardcover.app/books/monstrous-regiment/editions/32770706', current_date
from books where title = 'Monstrous Regiment' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Martin Freeman']::text[], 'RH Audio', 393, 'https://hardcover.app/books/mostly-harmless/editions/10041830', current_date
from books where title = 'Mostly Harmless' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rosalyn Landor']::text[], 'Random House Audio', 580, 'https://hardcover.app/books/never-let-me-go/editions/31881626', current_date
from books where title = 'Never Let Me Go' and author = 'Kazuo Ishiguro'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kerry Fox']::text[], 'Faber & Faber', 566, 'https://hardcover.app/books/never-let-me-go/editions/32498654', current_date
from books where title = 'Never Let Me Go' and author = 'Kazuo Ishiguro'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Thérèse Plummer']::text[], 'Macmillan Audio', null, 'https://hardcover.app/books/nevernight/editions/6577059', current_date
from books where title = 'Nevernight' and author = 'Jay Kristoff'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Holter Graham']::text[], 'Macmillan Audio', 1210, 'https://hardcover.app/books/nevernight/editions/32312978', current_date
from books where title = 'Nevernight' and author = 'Jay Kristoff'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gary Bakewell']::text[], 'BBC Audiobooks Ltd', null, 'https://hardcover.app/books/neverwhere/editions/32161502', current_date
from books where title = 'Neverwhere' and author = 'Neil Gaiman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Neil Gaiman']::text[], null, 828, 'https://hardcover.app/books/neverwhere/editions/31738385', current_date
from books where title = 'Neverwhere' and author = 'Neil Gaiman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Gardners Books', null, 'https://hardcover.app/books/night-watch/editions/11999868', current_date
from books where title = 'Night Watch' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'Isis Audio Books', 645, 'https://hardcover.app/books/night-watch/editions/31747233', current_date
from books where title = 'Night Watch' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alessandro Juliani']::text[], 'Audible Frontiers', 331, 'https://hardcover.app/books/nine-princes-in-amber/editions/30403779', current_date
from books where title = 'Nine Princes in Amber' and author = 'Roger Zelazny, Tim          White'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Eric Jason Martin']::text[], 'Recorded Books, Inc.', 377, 'https://hardcover.app/books/nine-princes-in-amber/editions/33139108', current_date
from books where title = 'Nine Princes in Amber' and author = 'Roger Zelazny, Tim          White'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ray Porter']::text[], 'Audible Originals', 702, 'https://hardcover.app/books/not-till-we-are-lost/editions/31113374', current_date
from books where title = 'Not Till We Are Lost' and author = 'Dennis E. Taylor'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Antonio Raluy']::text[], null, null, 'https://hardcover.app/books/not-till-we-are-lost/editions/32691597', current_date
from books where title = 'Not Till We Are Lost' and author = 'Dennis E. Taylor'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Lee']::text[], 'Buck 50 Productions and Blackstone Audio', 840, 'https://hardcover.app/books/one-hundred-years-of-solitude/editions/31689962', current_date
from books where title = 'One Hundred Years of Solitude' and author = 'Gabriel García Márquez'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['F. Murray Abraham']::text[], null, null, 'https://hardcover.app/books/one-hundred-years-of-solitude/editions/32206680', current_date
from books where title = 'One Hundred Years of Solitude' and author = 'Gabriel García Márquez'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jasmin Walker', 'Justis Bolding', 'Rebecca Soler', 'Teddy Hamilton']::text[], 'Recorded Books', 1432, 'https://hardcover.app/books/onyx-storm/editions/31812548', current_date
from books where title = 'Onyx Storm' and author = 'Rebecca Yarros'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Campbell Scott']::text[], 'Random House Audio', 630, 'https://hardcover.app/books/oryx-and-crake/editions/31629711', current_date
from books where title = 'Oryx and Crake' and author = 'Margaret Atwood'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Chancer']::text[], 'Bolinda audio', null, 'https://hardcover.app/books/oryx-and-crake/editions/31847097', current_date
from books where title = 'Oryx and Crake' and author = 'Margaret Atwood'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Davina Porter']::text[], 'Recorded Books', 1962, 'https://hardcover.app/books/outlander/editions/1175248', current_date
from books where title = 'Outlander' and author = 'Diana Gabaldon'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Geraldine James']::text[], 'Random House Audio', null, 'https://hardcover.app/books/outlander/editions/5668433', current_date
from books where title = 'Outlander' and author = 'Diana Gabaldon'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Cameron Beierle']::text[], 'Books In Motion', 625, 'https://hardcover.app/books/pawn-of-prophecy/editions/30570681', current_date
from books where title = 'Pawn of Prophecy' and author = 'David Eddings'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Brian Wiggins']::text[], 'Tantor Media', 614, 'https://hardcover.app/books/pawn-of-prophecy/editions/32665403', current_date
from books where title = 'Pawn of Prophecy' and author = 'David Eddings'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Seán Barrett']::text[], 'Penguin Books', null, 'https://hardcover.app/books/perfume-a-historia-de-um-assassino-1985/editions/32412544', current_date
from books where title = 'Perfume' and author = 'Patrick Süskind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Patterson']::text[], 'HighBridge, a division of Recorded Books', 540, 'https://hardcover.app/books/perfume-a-historia-de-um-assassino-1985/editions/31881611', current_date
from books where title = 'Perfume' and author = 'Patrick Süskind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Max Meyers']::text[], 'Random House Audio', 564, 'https://hardcover.app/books/pines/editions/30896809', current_date
from books where title = 'Pines' and author = 'Blake Crouch'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Paul Michael Garcia']::text[], 'Brilliance Audio', 513, 'https://hardcover.app/books/pines/editions/30570667', current_date
from books where title = 'Pines' and author = 'Blake Crouch'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Page']::text[], 'Tantor Media', 1534, 'https://hardcover.app/books/red-seas-under-red-skies/editions/31780029', current_date
from books where title = 'Red Seas Under Red Skies' and author = 'Scott Lynch'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Toby Longworth']::text[], 'Audible Studios', 545, 'https://hardcover.app/books/rendezvous-with-rama/editions/33133561', current_date
from books where title = 'Rendezvous with Rama' and author = 'Arthur C. Clarke'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Peter Ganim', 'Robert J. Sawyer - introduction']::text[], 'Brilliance Audio', 441, 'https://hardcover.app/books/rendezvous-with-rama/editions/30433067', current_date
from books where title = 'Rendezvous with Rama' and author = 'Arthur C. Clarke'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Paul Boehmer']::text[], 'Tantor Audio', 1757, 'https://hardcover.app/books/royal-assassin/editions/31764220', current_date
from books where title = 'Royal Assassin' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Joe Eyre']::text[], 'Harper Voyager', 1682, 'https://hardcover.app/books/royal-assassin/editions/33144451', current_date
from books where title = 'Royal Assassin' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alex Wingfield', 'Rebecca Norfolk']::text[], 'Macmillan Audio', 847, 'https://hardcover.app/books/ruthless-vows/editions/31671899', current_date
from books where title = 'Ruthless Vows' and author = 'Rebecca Ross'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Mary Robinette Kowal', 'Will Damron']::text[], 'Brilliance Audio', 1915, 'https://hardcover.app/books/seveneves/editions/30399254', current_date
from books where title = 'Seveneves' and author = 'Neal Stephenson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Peter Brooke']::text[], 'HarperCollins Publishers', 1960, 'https://hardcover.app/books/seveneves/editions/31877555', current_date
from books where title = 'Seveneves' and author = 'Neal Stephenson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Anne Flosnik']::text[], 'HarperCollins Publishers', 2019, 'https://hardcover.app/books/ship-of-destiny/editions/32138928', current_date
from books where title = 'Ship of Destiny' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Lucy Tregear']::text[], 'Harper Voyager', 2063, 'https://hardcover.app/books/ship-of-destiny/editions/33225818', current_date
from books where title = 'Ship of Destiny' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Anne Flosnik']::text[], 'Voyager', 2121, 'https://hardcover.app/books/ship-of-magic/editions/30762831', current_date
from books where title = 'Ship of Magic' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Lucy Tregear']::text[], 'Harper Voyager', 2005, 'https://hardcover.app/books/ship-of-magic/editions/33198133', current_date
from books where title = 'Ship of Magic' and author = 'Robin Hobb'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Roger Clark']::text[], 'Audible Studios on Brilliance Audio', null, 'https://hardcover.app/books/six-of-crows/editions/27883598', current_date
from books where title = 'Six of Crows' and author = 'Leigh Bardugo'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jay Snyder']::text[], 'Audible Studios', 904, 'https://hardcover.app/books/six-of-crows/editions/31422082', current_date
from books where title = 'Six of Crows' and author = 'Leigh Bardugo'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sophie Aldred']::text[], 'Gollancz', 914, 'https://hardcover.app/books/skyward/editions/32495053', current_date
from books where title = 'Skyward' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Suzy Jackson']::text[], 'Audible Studios', 929, 'https://hardcover.app/books/skyward/editions/32879250', current_date
from books where title = 'Skyward' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Lloyd James']::text[], 'Blackstone Audiobooks', 593, 'https://hardcover.app/books/starship-troopers/editions/19746923', current_date
from books where title = 'Starship Troopers' and author = 'Robert A. Heinlein'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['R.C. Bray']::text[], 'Blackstone Publishing', 495, 'https://hardcover.app/books/starship-troopers/editions/32820631', current_date
from books where title = 'Starship Troopers' and author = 'Robert A. Heinlein'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sophie Aldred']::text[], 'Orion Publishing Group, Limited', 860, 'https://hardcover.app/books/starsight/editions/32607912', current_date
from books where title = 'Starsight' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Suzy Jackson']::text[], 'Audible Studios', 870, 'https://hardcover.app/books/starsight/editions/32186211', current_date
from books where title = 'Starsight' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['David Morse']::text[], 'Brilliance Audio', 495, 'https://hardcover.app/books/the-andromeda-strain/editions/22313410', current_date
from books where title = 'The Andromeda Strain' and author = 'Michael Crichton'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Chris Noth']::text[], 'Random House Audio', null, 'https://hardcover.app/books/the-andromeda-strain/editions/32032654', current_date
from books where title = 'The Andromeda Strain' and author = 'Michael Crichton'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gerry O''Brien']::text[], 'Puffin', 408, 'https://hardcover.app/books/the-arctic-incident/editions/32803402', current_date
from books where title = 'The Arctic Incident' and author = 'Eoin Colfer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nathaniel Parker']::text[], 'Listening Library', null, 'https://hardcover.app/books/the-arctic-incident/editions/32023963', current_date
from books where title = 'The Arctic Incident' and author = 'Eoin Colfer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Simon Vance']::text[], 'Little, Brown Audio', 1286, 'https://hardcover.app/books/the-black-prism/editions/33053874', current_date
from books where title = 'The Black Prism' and author = 'Brent Weeks'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Cristofer Jean']::text[], 'Hachette Audio', null, 'https://hardcover.app/books/the-black-prism/editions/33230844', current_date
from books where title = 'The Black Prism' and author = 'Brent Weeks'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nicolas Justamon']::text[], null, 1558, 'https://hardcover.app/books/the-blade-itself/editions/33069549', current_date
from books where title = 'The Blade Itself' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Steven Pacey']::text[], 'Orion Publishing Group Ltd.', 1335, 'https://hardcover.app/books/the-blade-itself/editions/32177449', current_date
from books where title = 'The Blade Itself' and author = 'Joe Abercrombie'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jessica Whittaker']::text[], 'Voyager', 1348, 'https://hardcover.app/books/the-book-that-wouldn-t-burn/editions/31112845', current_date
from books where title = 'The Book That Wouldn’t Burn' and author = 'Mark Lawrence'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Manon Jomain']::text[], null, null, 'https://hardcover.app/books/the-book-that-wouldn-t-burn/editions/32680551', current_date
from books where title = 'The Book That Wouldn’t Burn' and author = 'Mark Lawrence'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Marin Ireland', 'Owen Teale', 'Shane Ghostkeeper']::text[], 'Simon & Schuster Audio', 940, 'https://hardcover.app/books/the-buffalo-hunter-hunter/editions/32140536', current_date
from books where title = 'The Buffalo Hunter Hunter' and author = 'Stephen Graham Jones'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Dufris']::text[], 'Tantor Media', null, 'https://hardcover.app/books/the-caves-of-steel/editions/13238671', current_date
from books where title = 'The Caves of Steel' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 510, 'https://hardcover.app/books/the-caves-of-steel/editions/32349955', current_date
from books where title = 'The Caves of Steel' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Christopher Lee']::text[], 'HarperCollins UK', 471, 'https://hardcover.app/books/the-children-of-hurin/editions/11944830', current_date
from books where title = 'The Children of Hurin' and author = 'J.R.R. Tolkien, Christopher Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['P. J. Ochlan']::text[], 'Macmillan Audio', 1356, 'https://hardcover.app/books/the-dark-forest/editions/30932180', current_date
from books where title = 'The Dark Forest' and author = 'Cixin Liu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Don Leslie']::text[], 'HarperAudio', 805, 'https://hardcover.app/books/the-dispossessed/editions/31538940', current_date
from books where title = 'The Dispossessed' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Roddy Doyle', 'Tim Treloar']::text[], 'Gateway', 747, 'https://hardcover.app/books/the-dispossessed/editions/31597439', current_date
from books where title = 'The Dispossessed' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edoardo Ballerini']::text[], 'Audible Studios', 878, 'https://hardcover.app/books/the-divine-comedy/editions/33230794', current_date
from books where title = 'The Divine Comedy' and author = 'Dante Alighieri'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ralph Cosham']::text[], ' Blackstone Audio', 798, 'https://hardcover.app/books/the-divine-comedy/editions/30828606', current_date
from books where title = 'The Divine Comedy' and author = 'Dante Alighieri'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kate Reading', 'Michael Kramer']::text[], 'Macmillan Audio', 1500, 'https://hardcover.app/books/the-dragon-reborn/editions/32638915', current_date
from books where title = 'The Dragon Reborn' and author = 'Robert Jordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rosamund Pike']::text[], 'Macmillan Audio', null, 'https://hardcover.app/books/the-dragon-reborn/editions/32872929', current_date
from books where title = 'The Dragon Reborn' and author = 'Robert Jordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Penguin Audio', null, 'https://hardcover.app/books/the-drawing-of-the-three/editions/9330130', current_date
from books where title = 'The Drawing of the Three' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ana Fernández', 'Íñigo Álvarez de Lara']::text[], 'Audible Studios', 1178, 'https://hardcover.app/books/the-dungeon-anarchists-cookbook/editions/33108871', current_date
from books where title = 'The Dungeon Anarchist''s Cookbook' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jeff Hays', 'The Critical Drinker']::text[], 'Audible Studios', 1014, 'https://hardcover.app/books/the-dungeon-anarchists-cookbook/editions/31386209', current_date
from books where title = 'The Dungeon Anarchist''s Cookbook' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kate Reading', 'Michael Kramer']::text[], 'Macmillan Audio', 238, 'https://hardcover.app/books/the-emperors-soul/editions/32117269', current_date
from books where title = 'The Emperor''s Soul' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Angela Lin']::text[], ' Orion', 235, 'https://hardcover.app/books/the-emperors-soul/editions/31849585', current_date
from books where title = 'The Emperor''s Soul' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'ISIS Audio Books', 645, 'https://hardcover.app/books/the-fifth-elephant/editions/31845983', current_date
from books where title = 'The Fifth Elephant' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi', null, 'https://hardcover.app/books/the-fifth-elephant/editions/29188382', current_date
from books where title = 'The Fifth Elephant' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George K. Wilson']::text[], 'Recorded Books', 558, 'https://hardcover.app/books/the-forever-war/editions/31736284', current_date
from books where title = 'The Forever War' and author = 'Joe Haldeman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Wilson']::text[], 'Recorded Books', 558, 'https://hardcover.app/books/the-forever-war/editions/31545947', current_date
from books where title = 'The Forever War' and author = 'Joe Haldeman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ana Fernández', 'Rocio Agost', 'Íñigo Álvarez de Lara']::text[], 'Audible Studios', 1285, 'https://hardcover.app/books/the-gate-of-the-feral-gods/editions/33108873', current_date
from books where title = 'The Gate of the Feral Gods' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jeff Hays']::text[], 'Soundbooth Theater ', 1083, 'https://hardcover.app/books/the-gate-of-the-feral-gods/editions/30407840', current_date
from books where title = 'The Gate of the Feral Gods' and author = 'Matt Dinniman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Kramer']::text[], 'Simon & Schuster Audio', 1297, 'https://hardcover.app/books/the-grace-of-kings/editions/31094783', current_date
from books where title = 'The Grace of Kings' and author = 'Ken Liu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kevin Shen']::text[], 'Head of Zeus', 1387, 'https://hardcover.app/books/the-grace-of-kings/editions/33063505', current_date
from books where title = 'The Grace of Kings' and author = 'Ken Liu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Simon & Schuster Audio', 834, 'https://hardcover.app/books/the-green-mile/editions/31435325', current_date
from books where title = 'The Green Mile' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Simon & Schuster', 480, 'https://hardcover.app/books/the-gunslinger/editions/30399193', current_date
from books where title = 'The Gunslinger' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Penguin Audio', null, 'https://hardcover.app/books/the-gunslinger/editions/1999036', current_date
from books where title = 'The Gunslinger' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Fry']::text[], 'Random House Audio', 351, 'https://hardcover.app/books/the-hitchhikers-guide-to-the-galaxy/editions/31707748', current_date
from books where title = 'The Hitchhiker''s Guide to the Galaxy' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Moore']::text[], 'DH Audio', null, 'https://hardcover.app/books/the-hitchhikers-guide-to-the-galaxy/editions/21048953', current_date
from books where title = 'The Hitchhiker''s Guide to the Galaxy' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alex Jennings']::text[], 'HarperCollins Publishers', null, 'https://hardcover.app/books/the-horse-and-his-boy/editions/31507487', current_date
from books where title = 'The Horse and His Boy' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Casaundra Freeman', 'N. K. Jemisin']::text[], 'Hachette Audio', 708, 'https://hardcover.app/books/the-hundred-thousand-kingdoms/editions/33255914', current_date
from books where title = 'The Hundred Thousand Kingdoms' and author = 'N. K. Jemisin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jonathan Kent']::text[], 'Tantor Media', 247, 'https://hardcover.app/books/the-island-of-doctor-moreau/editions/32715875', current_date
from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gordon Griffin']::text[], 'Dreamscape Media', null, 'https://hardcover.app/books/the-island-of-doctor-moreau/editions/32004477', current_date
from books where title = 'The Island of Doctor Moreau' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Patrick Stewart']::text[], 'HarperCollins Publishers', 289, 'https://hardcover.app/books/the-last-battle/editions/32655892', current_date
from books where title = 'The Last Battle' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['David Suchet', 'Paul Scofield', 'Ron Moody']::text[], 'Tyndale Entertainment', null, 'https://hardcover.app/books/the-last-battle/editions/12294879', current_date
from books where title = 'The Last Battle' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Recorded Books', 408, 'https://hardcover.app/books/the-lathe-of-heaven/editions/31846688', current_date
from books where title = 'The Lathe of Heaven' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Adam Sims']::text[], 'Gollancz', 408, 'https://hardcover.app/books/the-lathe-of-heaven/editions/32803908', current_date
from books where title = 'The Lathe of Heaven' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jesse Bernstein']::text[], 'Random House Audio', null, 'https://hardcover.app/books/the-lightning-thief/editions/30903112', current_date
from books where title = 'The Lightning Thief' and author = 'Rick Riordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Walter Lewis']::text[], 'Puffin Audio', null, 'https://hardcover.app/books/the-lightning-thief/editions/31609680', current_date
from books where title = 'The Lightning Thief' and author = 'Rick Riordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Fenton-Stevens']::text[], 'HarperAudio', 690, 'https://hardcover.app/books/the-long-earth/editions/31969213', current_date
from books where title = 'The Long Earth' and author = 'Terry Pratchett, Stephen Baxter'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Clipper Audiobooks', 809, 'https://hardcover.app/books/the-lost-world-1995/editions/32516271', current_date
from books where title = 'The Lost World' and author = 'Michael Crichton'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 918, 'https://hardcover.app/books/the-lost-world-1995/editions/31780160', current_date
from books where title = 'The Lost World' and author = 'Michael Crichton'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alice Sebold']::text[], 'Little Brown Company', 630, 'https://hardcover.app/books/the-lovely-bones/editions/32784884', current_date
from books where title = 'The Lovely Bones' and author = 'Alice Sebold'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alyssa Bresnahan']::text[], 'Hachette Audio', null, 'https://hardcover.app/books/the-lovely-bones/editions/12887028', current_date
from books where title = 'The Lovely Bones' and author = 'Alice Sebold'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Claire Bloom']::text[], 'HarperChildrensAudio', null, 'https://hardcover.app/books/the-magicians-nephew/editions/18090147', current_date
from books where title = 'The Magician''s Nephew' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kenneth Branagh']::text[], 'HarperCollins Publishers', null, 'https://hardcover.app/books/the-magicians-nephew/editions/32292852', current_date
from books where title = 'The Magician''s Nephew' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Tantor Media', null, 'https://hardcover.app/books/the-martian-chronicles/editions/31520396', current_date
from books where title = 'The Martian Chronicles' and author = 'Ray Bradbury'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Mark Boyett']::text[], 'Audible Studios', 463, 'https://hardcover.app/books/the-martian-chronicles/editions/31878734', current_date
from books where title = 'The Martian Chronicles' and author = 'Ray Bradbury'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Julian Rhind-Tutt']::text[], 'Naxos Audiobooks', 1012, 'https://hardcover.app/books/the-master-and-margarita/editions/21951110', current_date
from books where title = 'The Master and Margarita' and author = 'Mikhail Bulgakov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Recorded Books', null, 'https://hardcover.app/books/the-master-and-margarita/editions/19231027', current_date
from books where title = 'The Master and Margarita' and author = 'Mikhail Bulgakov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Dufris']::text[], 'Tantor Media', null, 'https://hardcover.app/books/the-naked-sun/editions/12292924', current_date
from books where title = 'The Naked Sun' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 501, 'https://hardcover.app/books/the-naked-sun/editions/32849381', current_date
from books where title = 'The Naked Sun' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nick Podehl']::text[], null, null, 'https://hardcover.app/books/the-name-of-the-wind/editions/32634777', current_date
from books where title = 'The Name of the Wind' and author = 'Patrick Rothfuss'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rupert Degas']::text[], 'Gollancz', 1684, 'https://hardcover.app/books/the-name-of-the-wind/editions/31754262', current_date
from books where title = 'The Name of the Wind' and author = 'Patrick Rothfuss'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edward Herrmann']::text[], 'Random House Audio', null, 'https://hardcover.app/books/the-passage/editions/12478287', current_date
from books where title = 'The Passage' and author = 'Justin Cronin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Abby Craden', 'Adenrele Ojo', 'Scott Brick']::text[], 'Random House Audio', 2209, 'https://hardcover.app/books/the-passage/editions/16737842', current_date
from books where title = 'The Passage' and author = 'Justin Cronin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Adjoa Andoh', 'Emma Fenney', 'Phil Nightingale', 'Thomas Judd']::text[], 'Hachette Audio', 720, 'https://hardcover.app/books/the-power/editions/30403942', current_date
from books where title = 'The Power' and author = 'Naomi Alderman'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Grace Capeless', 'James Fouhey']::text[], 'Disney Hyperion', 873, 'https://hardcover.app/books/the-red-pyramid/editions/32144326', current_date
from books where title = 'The Red Pyramid' and author = 'Rick Riordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Katherine Kellgren', 'Kevin R. Free']::text[], 'Brilliance Audio', null, 'https://hardcover.app/books/the-red-pyramid/editions/31663408', current_date
from books where title = 'The Red Pyramid' and author = 'Rick Riordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Martin Freeman']::text[], 'Random House Audio', null, 'https://hardcover.app/books/the-restaurant-at-the-end-of-the-universe/editions/7898917', current_date
from books where title = 'The Restaurant at the End of the Universe' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Zannie Adams']::text[], 'Macmillan Digital Audio', 348, 'https://hardcover.app/books/the-restaurant-at-the-end-of-the-universe/editions/32082363', current_date
from books where title = 'The Restaurant at the End of the Universe' and author = 'Douglas Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tom Stechschulte']::text[], 'Recorded Books', 399, 'https://hardcover.app/books/the-road/editions/8129', current_date
from books where title = 'The Road' and author = 'Cormac McCarthy'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Krzysztof Gosztyła']::text[], null, null, 'https://hardcover.app/books/the-road/editions/32580790', current_date
from books where title = 'The Road' and author = 'Cormac McCarthy'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kate Reading', 'Michael Kramer']::text[], 'Macmillan Audio', 2473, 'https://hardcover.app/books/the-shadow-rising/editions/32635394', current_date
from books where title = 'The Shadow Rising' and author = 'Robert Jordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rosamund Pike']::text[], 'Macmillan Audio', 2431, 'https://hardcover.app/books/the-shadow-rising/editions/31495219', current_date
from books where title = 'The Shadow Rising' and author = 'Robert Jordan'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dennis Boutsikaris', 'Jay Snyder']::text[], 'Audible Studios', 560, 'https://hardcover.app/books/the-sirens-of-titan/editions/31847201', current_date
from books where title = 'The Sirens of Titan' and author = 'Kurt Vonnegut'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nick J. Russo']::text[], 'Graphic Audio LLC', 610, 'https://hardcover.app/books/the-sunlit-man/editions/32482617', current_date
from books where title = 'The Sunlit Man' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William DeMeritt']::text[], 'Dragonsteel', 671, 'https://hardcover.app/books/the-sunlit-man/editions/31479375', current_date
from books where title = 'The Sunlit Man' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Penguin Random House Audio', 1581, 'https://hardcover.app/books/the-sword-of-shannara/editions/33149527', current_date
from books where title = 'The Sword of Shannara' and author = 'Terry Brooks'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Charles Keating']::text[], 'Random House Audio', null, 'https://hardcover.app/books/the-sword-of-shannara/editions/9213949', current_date
from books where title = 'The Sword of Shannara' and author = 'Terry Brooks'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Simon & Schuster Audio', null, 'https://hardcover.app/books/the-talisman/editions/32031500', current_date
from books where title = 'The Talisman' and author = 'Stephen King, Peter Straub'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'ISIS Audio Books', 611, 'https://hardcover.app/books/the-truth-1995/editions/30654958', current_date
from books where title = 'The Truth' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi', null, 'https://hardcover.app/books/the-truth-1995/editions/1290503', current_date
from books where title = 'The Truth' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Simon & Schuster Audio', 1091, 'https://hardcover.app/books/the-waste-lands/editions/30550363', current_date
from books where title = 'The Waste Lands' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'HarperAudio', 430, 'https://hardcover.app/books/the-wee-free-men/editions/30459432', current_date
from books where title = 'The Wee Free Men' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bill Nighy', 'Indira Varma', 'Steven Cree']::text[], 'Penguin Audio', 528, 'https://hardcover.app/books/the-wee-free-men/editions/32761848', current_date
from books where title = 'The Wee Free Men' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Euan Morton']::text[], 'Audible Studios', 1694, 'https://hardcover.app/books/the-will-of-the-many-2023/editions/32497041', current_date
from books where title = 'The Will of the Many' and author = 'James Islington'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stefan Kaminski']::text[], null, 1723, 'https://hardcover.app/books/the-will-of-the-many-2023/editions/33114120', current_date
from books where title = 'The Will of the Many' and author = 'James Islington'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nick Podehl']::text[], 'Brilliance Audio', 2575, 'https://hardcover.app/books/the-wise-mans-fear/editions/32032180', current_date
from books where title = 'The Wise Man''s Fear' and author = 'Patrick Rothfuss'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rupert Degas']::text[], 'Gollancz', 2569, 'https://hardcover.app/books/the-wise-mans-fear/editions/32507169', current_date
from books where title = 'The Wise Man''s Fear' and author = 'Patrick Rothfuss'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Anna Fields']::text[], 'Blackstone Audiobooks', null, 'https://hardcover.app/books/the-wonderful-wizard-of-oz/editions/31530996', current_date
from books where title = 'The Wonderful Wizard of Oz' and author = 'L. Frank Baum'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Anne Hathaway']::text[], 'Audible Studios', 229, 'https://hardcover.app/books/the-wonderful-wizard-of-oz/editions/33214796', current_date
from books where title = 'The Wonderful Wizard of Oz' and author = 'L. Frank Baum'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['John Bedford Lloyd']::text[], 'Random House Audio', 904, 'https://hardcover.app/books/timeline/editions/31877558', current_date
from books where title = 'Timeline' and author = 'Michael Crichton'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Brittany Pressley']::text[], 'HarperAudio', 270, 'https://hardcover.app/books/to-be-taught-if-fortunate/editions/31937321', current_date
from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Patricia Rodriguez']::text[], 'Hodder & Stoughton', 288, 'https://hardcover.app/books/to-be-taught-if-fortunate/editions/32879146', current_date
from books where title = 'To Be Taught, If Fortunate' and author = 'Becky Chambers'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ilyana Kadushin', 'Michael Crouch']::text[], 'Little, Brown Book Group', 771, 'https://hardcover.app/books/twilight/editions/20875054', current_date
from books where title = 'Twilight' and author = 'Stephenie Meyer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Peter Capaldi']::text[], 'Blackstone Publishing', 1051, 'https://hardcover.app/books/watership-down/editions/30457643', current_date
from books where title = 'Watership Down' and author = 'Richard Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ralph Cosham']::text[], ' Blackstone Audio', 954, 'https://hardcover.app/books/watership-down/editions/32863231', current_date
from books where title = 'Watership Down' and author = 'Richard Adams'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Louise Brealey', 'Toby Jones']::text[], 'McClelland & Stewart', 553, 'https://hardcover.app/books/we/editions/33009020', current_date
from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Grover Gardner']::text[], 'Tantor Audio', 411, 'https://hardcover.app/books/we/editions/32715608', current_date
from books where title = 'We' and author = 'Yevgeny Zamyatin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Andy Ingalls']::text[], 'W. F. Howes Ltd', null, 'https://hardcover.app/books/what-moves-the-dead/editions/32569847', current_date
from books where title = 'What Moves the Dead' and author = 'T. Kingfisher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Avi Roque']::text[], 'Macmillan Audio ', 271, 'https://hardcover.app/books/what-moves-the-dead/editions/31547412', current_date
from books where title = 'What Moves the Dead' and author = 'T. Kingfisher'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Frank Muller']::text[], 'Simon & Schuster Audio', 1657, 'https://hardcover.app/books/wizard-and-glass/editions/30550380', current_date
from books where title = 'Wizard And Glass' and author = 'Stephen King'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bridget Bordeaux', 'Jake Bordeaux']::text[], 'Independently Published', 587, 'https://hardcover.app/books/zodiac-academy-the-awakening-2019/editions/31761782', current_date
from books where title = 'Zodiac Academy: The Awakening' and author = 'Caroline Peckham, Susanne Valenti'
on conflict (book_id, source_url) do nothing;
