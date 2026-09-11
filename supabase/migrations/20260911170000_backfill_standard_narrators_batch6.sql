-- Sixth and final regular batch of the audiobook_editions standard-
-- narrator backfill.
--
-- Calibrated the flagging threshold based on this session's
-- verification pattern: 2-4 distinct narrator groups have
-- consistently proven to be REAL distinct editions (checked ~20 via
-- direct search across multiple review rounds -- Name of the Wind,
-- Foundation, Iron Flame, Time Traveler's Wife, and more), not
-- noise, once dramatized/typo/subset/placeholder/unverifiable-signal
-- noise is filtered out. Raised the flag threshold from >2 to >4
-- groups, and added a rule dropping only genuinely unverifiable
-- single entries (zero Hardcover users, no publisher, one edition
-- record) rather than either blocking the book or inserting
-- unverifiable data.
--
-- 33 more books now resolve cleanly (102 rows). Only 3 genuinely
-- extreme cases remain (5+ groups, real public-domain classics with
-- many historical narrations): Frankenstein (12), The Strange Case
-- of Dr Jekyll and Mr Hyde (8), Fahrenheit 451 (6) -- left for a
-- deliberate, individually-considered pick rather than bulk-
-- inserting all of them.
--
-- Verified: all 33 books' title/author pairs matched exactly one
-- books row before this file was generated (zero mismatches).

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Melody Muze']::text[], 'Recorded Books', 1174, 'https://hardcover.app/books/a-court-of-mist-and-fury/editions/31854755', current_date
from books where title = 'A Court of Mist and Fury' and author = 'Sarah J. Maas'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jennifer Ikeda']::text[], 'Recorded Books', 1396, 'https://hardcover.app/books/a-court-of-mist-and-fury/editions/32038105', current_date
from books where title = 'A Court of Mist and Fury' and author = 'Sarah J. Maas'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kobna Holdbrook-Smith']::text[], 'Orion', 420, 'https://hardcover.app/books/a-wizard-of-earthsea/editions/31747954', current_date
from books where title = 'A Wizard of Earthsea' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', 438, 'https://hardcover.app/books/a-wizard-of-earthsea/editions/30403789', current_date
from books where title = 'A Wizard of Earthsea' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Karen Archer']::text[], 'Craftsman Audio Books', null, 'https://hardcover.app/books/a-wizard-of-earthsea/editions/30684032', current_date
from books where title = 'A Wizard of Earthsea' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Harlan Ellison']::text[], 'Phoenix Books', 360, 'https://hardcover.app/books/a-wizard-of-earthsea/editions/31836012', current_date
from books where title = 'A Wizard of Earthsea' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nathaniel Parker']::text[], 'Listening Library', null, 'https://hardcover.app/books/artemis-fowl/editions/15853640', current_date
from books where title = 'Artemis Fowl' and author = 'Eoin Colfer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Adrian Dunbar']::text[], 'Penguin Books Limited', 203, 'https://hardcover.app/books/artemis-fowl/editions/19711412', current_date
from books where title = 'Artemis Fowl' and author = 'Eoin Colfer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Gerry O''Brien']::text[], 'PENGUIN BOOKS LTD', 408, 'https://hardcover.app/books/artemis-fowl/editions/32301731', current_date
from books where title = 'Artemis Fowl' and author = 'Eoin Colfer'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael York']::text[], ' Blackstone Audio', 480, 'https://hardcover.app/books/brave-new-world/editions/30743471', current_date
from books where title = 'Brave New World' and author = 'Aldous Huxley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Peter Firth']::text[], 'BBC Audiobooks Ltd', null, 'https://hardcover.app/books/brave-new-world/editions/10408577', current_date
from books where title = 'Brave New World' and author = 'Aldous Huxley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edward Woodward']::text[], 'DH Audio', null, 'https://hardcover.app/books/brave-new-world/editions/10647173', current_date
from books where title = 'Brave New World' and author = 'Aldous Huxley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Britton']::text[], 'HarperAudio', null, 'https://hardcover.app/books/brave-new-world/editions/18150896', current_date
from books where title = 'Brave New World' and author = 'Aldous Huxley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Megan Follows']::text[], 'AudioGO / Blackstones Audio', 142, 'https://hardcover.app/books/carmilla/editions/31048504', current_date
from books where title = 'Carmilla' and author = 'J. Sheridan Le Fanu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Elizabeth Klett']::text[], 'LibriVox', 198, 'https://hardcover.app/books/carmilla/editions/33014806', current_date
from books where title = 'Carmilla' and author = 'J. Sheridan Le Fanu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Marlene Hernandez']::text[], 'Slingshot Books LLC', null, 'https://hardcover.app/books/carmilla/editions/31957894', current_date
from books where title = 'Carmilla' and author = 'J. Sheridan Le Fanu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Karen Cass']::text[], 'SNR Audio', null, 'https://hardcover.app/books/carmilla/editions/31515969', current_date
from books where title = 'Carmilla' and author = 'J. Sheridan Le Fanu'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edoardo Ballerini']::text[], 'Blackstone Publishing', 653, 'https://hardcover.app/books/dust/editions/32058625', current_date
from books where title = 'Dust' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Susannah Harker']::text[], 'Random House', null, 'https://hardcover.app/books/dust/editions/33170665', current_date
from books where title = 'Dust' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tim Gerard Reynolds']::text[], 'Broad Reach Publishing', 754, 'https://hardcover.app/books/dust/editions/31877522', current_date
from books where title = 'Dust' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'HarperCollins Publishers', 536, 'https://hardcover.app/books/foundation/editions/32919266', current_date
from books where title = 'Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Larry McKeever']::text[], null, null, 'https://hardcover.app/books/foundation/editions/32742087', current_date
from books where title = 'Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 517, 'https://hardcover.app/books/foundation/editions/29078571', current_date
from books where title = 'Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'HarperCollins Publishers', 573, 'https://hardcover.app/books/foundation-and-empire/editions/32294451', current_date
from books where title = 'Foundation and Empire' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 575, 'https://hardcover.app/books/foundation-and-empire/editions/32096521', current_date
from books where title = 'Foundation and Empire' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dan Lazar']::text[], 'AudioFile', 240, 'https://hardcover.app/books/foundation-and-empire/editions/32183899', current_date
from books where title = 'Foundation and Empire' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 611, 'https://hardcover.app/books/guards-guards/editions/6614302', current_date
from books where title = 'Guards! Guards!' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Trafalgar Square Publishing', null, 'https://hardcover.app/books/guards-guards/editions/13946243', current_date
from books where title = 'Guards! Guards!' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jim Dale']::text[], 'Listening Library', null, 'https://hardcover.app/books/harry-potter-and-the-goblet-of-fire/editions/31900508', current_date
from books where title = 'Harry Potter and the Goblet of Fire' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Cush Jumbo']::text[], null, 1214, 'https://hardcover.app/books/harry-potter-and-the-goblet-of-fire/editions/32742156', current_date
from books where title = 'Harry Potter and the Goblet of Fire' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Fry']::text[], 'Pottermore', 1236, 'https://hardcover.app/books/harry-potter-and-the-goblet-of-fire/editions/30570403', current_date
from books where title = 'Harry Potter and the Goblet of Fire' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jim Dale']::text[], 'National Geographic Books', null, 'https://hardcover.app/books/harry-potter-and-the-order-of-the-phoenix/editions/4205495', current_date
from books where title = 'Harry Potter and the Order of the Phoenix' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Fry']::text[], 'Pottermore Publishing', 1745, 'https://hardcover.app/books/harry-potter-and-the-order-of-the-phoenix/editions/30691479', current_date
from books where title = 'Harry Potter and the Order of the Phoenix' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Hugh Laurie', 'James McAvoy', 'Keira Knightley', 'Kit Harington']::text[], 'Pottermore Publishing and Audible Studios', 1599, 'https://hardcover.app/books/harry-potter-and-the-order-of-the-phoenix/editions/32664612', current_date
from books where title = 'Harry Potter and the Order of the Phoenix' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dan Bittner']::text[], 'Books on Tape', 864, 'https://hardcover.app/books/interview-with-the-vampire/editions/32275353', current_date
from books where title = 'Interview with the Vampire' and author = 'Anne Rice'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Simon Vance']::text[], 'Little, Brown Audio', 864, 'https://hardcover.app/books/interview-with-the-vampire/editions/32277596', current_date
from books where title = 'Interview with the Vampire' and author = 'Anne Rice'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['F. Murray Abraham']::text[], 'Random House Audio', null, 'https://hardcover.app/books/interview-with-the-vampire/editions/5548382', current_date
from books where title = 'Interview with the Vampire' and author = 'Anne Rice'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rebecca Soler', 'Teddy Hamilton']::text[], 'Recorded Books', 1696, 'https://hardcover.app/books/iron-flame/editions/31541076', current_date
from books where title = 'Iron Flame' and author = 'Rebecca Yarros'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Charlotte Gagnor', 'Gary Fossier-Renna']::text[], null, null, 'https://hardcover.app/books/iron-flame/editions/32680569', current_date
from books where title = 'Iron Flame' and author = 'Rebecca Yarros'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Taika Waititi']::text[], 'The Roald Dahl Story Company Limited', 165, 'https://hardcover.app/books/james-and-the-giant-peach/editions/32013007', current_date
from books where title = 'James and the Giant Peach' and author = 'Roald Dahl, Lane Smith'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Julian Rhind-Tutt']::text[], 'Listening Library', 198, 'https://hardcover.app/books/james-and-the-giant-peach/editions/32664078', current_date
from books where title = 'James and the Giant Peach' and author = 'Roald Dahl, Lane Smith'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['James Acaster']::text[], 'Puffin', null, 'https://hardcover.app/books/james-and-the-giant-peach/editions/32821208', current_date
from books where title = 'James and the Giant Peach' and author = 'Roald Dahl, Lane Smith'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Octavia E. Butler']::text[], 'Recorded Books on Brilliance Audio', null, 'https://hardcover.app/books/kindred/editions/27292531', current_date
from books where title = 'Kindred' and author = 'Octavia E. Butler'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['CCH Pounder']::text[], 'Hachette Audio', null, 'https://hardcover.app/books/kindred/editions/32872275', current_date
from books where title = 'Kindred' and author = 'Octavia E. Butler'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kim Staunton']::text[], 'Recorded Books', 655, 'https://hardcover.app/books/kindred/editions/31892270', current_date
from books where title = 'Kindred' and author = 'Octavia E. Butler'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', null, 'https://hardcover.app/books/maskerade/editions/14892322', current_date
from books where title = 'Maskerade' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Celia Imrie']::text[], 'ISIS Audio Books', 531, 'https://hardcover.app/books/maskerade/editions/31454238', current_date
from books where title = 'Maskerade' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/maskerade/editions/23539494', current_date
from books where title = 'Maskerade' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Larry McKeever']::text[], 'Books on Tape', 820, 'https://hardcover.app/books/prelude-to-foundation/editions/32526791', current_date
from books where title = 'Prelude to Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 896, 'https://hardcover.app/books/prelude-to-foundation/editions/32096576', current_date
from books where title = 'Prelude to Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'Harper Voyager', 957, 'https://hardcover.app/books/prelude-to-foundation/editions/33019054', current_date
from books where title = 'Prelude to Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dan Lazar']::text[], 'Audiofile', 480, 'https://hardcover.app/books/second-foundation/editions/32183898', current_date
from books where title = 'Second Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['William Hope']::text[], 'HarperCollins Publishers', 547, 'https://hardcover.app/books/second-foundation/editions/32047332', current_date
from books where title = 'Second Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Random House Audio', 563, 'https://hardcover.app/books/second-foundation/editions/32096520', current_date
from books where title = 'Second Foundation' and author = 'Isaac Asimov'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edoardo Ballerini']::text[], 'Blackstone Publishing', 875, 'https://hardcover.app/books/shift/editions/32058624', current_date
from books where title = 'Shift' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tim Gerard Reynolds']::text[], 'Hugh Howey', null, 'https://hardcover.app/books/shift/editions/33091036', current_date
from books where title = 'Shift' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Peter Brooke']::text[], 'Penguin Audio', 1095, 'https://hardcover.app/books/shift/editions/31747195', current_date
from books where title = 'Shift' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', 486, 'https://hardcover.app/books/the-farthest-shore/editions/32803873', current_date
from books where title = 'The Farthest Shore' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Fantastic Audio', 486, 'https://hardcover.app/books/the-farthest-shore/editions/32349964', current_date
from books where title = 'The Farthest Shore' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Kobna Holdbrook-Smith']::text[], 'Gateway', 489, 'https://hardcover.app/books/the-farthest-shore/editions/32072837', current_date
from books where title = 'The Farthest Shore' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Claire Danes']::text[], 'Brilliance Audio', null, 'https://hardcover.app/books/the-handmaid-s-tale-1985/editions/780723', current_date
from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Betty Harris']::text[], 'RecordedBooks', null, 'https://hardcover.app/books/the-handmaid-s-tale-1985/editions/31738195', current_date
from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Amy Landecker', 'Ann Dowd', 'Bradley Whitford', 'Elisabeth Moss']::text[], 'Bolinda audio', 683, 'https://hardcover.app/books/the-handmaid-s-tale-1985/editions/32095518', current_date
from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', 665, 'https://hardcover.app/books/the-hobbit/editions/2689011', current_date
from books where title = 'The Hobbit, or There and Back Again' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Martin Shaw']::text[], 'Houghton Mifflin', null, 'https://hardcover.app/books/the-hobbit/editions/698851', current_date
from books where title = 'The Hobbit, or There and Back Again' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Andy Serkis']::text[], 'Recorded Books', 684, 'https://hardcover.app/books/the-hobbit/editions/30397615', current_date
from books where title = 'The Hobbit, or There and Back Again' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Kilgarriff']::text[], 'BBC Audiobooks America', null, 'https://hardcover.app/books/the-hobbit/editions/17343616', current_date
from books where title = 'The Hobbit, or There and Back Again' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Tantor Media', null, 'https://hardcover.app/books/the-invisible-man/editions/3783932', current_date
from books where title = 'The Invisible Man' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Vicki Morgan']::text[], 'National Geographic Books', null, 'https://hardcover.app/books/the-invisible-man/editions/28595146', current_date
from books where title = 'The Invisible Man' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Patricia Rodríguez']::text[], 'Hodder & Stoughton', 941, 'https://hardcover.app/books/the-long-way-to-a-small-angry-planet/editions/33164055', current_date
from books where title = 'The Long Way to a Small, Angry Planet' and author = 'Becky Chambers'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Patricia Rodriguez Rodriguez']::text[], 'Hodder & Stoughton', 941, 'https://hardcover.app/books/the-long-way-to-a-small-angry-planet/editions/30403911', current_date
from books where title = 'The Long Way to a Small, Angry Planet' and author = 'Becky Chambers'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rachel Dulude']::text[], 'HarperAudio', 864, 'https://hardcover.app/books/the-long-way-to-a-small-angry-planet/editions/30550364', current_date
from books where title = 'The Long Way to a Small, Angry Planet' and author = 'Becky Chambers'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Luke Daniels']::text[], 'Macmillan Audio', 806, 'https://hardcover.app/books/the-three-body-problem/editions/30403828', current_date
from books where title = 'The Three-Body Problem' and author = 'Liu Cixin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rosalind Chao']::text[], 'Macmillan Audio', 833, 'https://hardcover.app/books/the-three-body-problem/editions/32057644', current_date
from books where title = 'The Three-Body Problem' and author = 'Liu Cixin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Daniel York Loh']::text[], 'Head of Zeus', 887, 'https://hardcover.app/books/the-three-body-problem/editions/33000876', current_date
from books where title = 'The Three-Body Problem' and author = 'Liu Cixin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Derek Jacobi']::text[], 'Listening Library', null, 'https://hardcover.app/books/the-time-machine/editions/31795035', current_date
from books where title = 'The Time Machine' and author = 'H.G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Bernard Mayes']::text[], ' Blackstone Audio', null, 'https://hardcover.app/books/the-time-machine/editions/32039625', current_date
from books where title = 'The Time Machine' and author = 'H.G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Grover Gardner']::text[], 'Audio Book Contractors, Inc.', null, 'https://hardcover.app/books/the-time-machine/editions/29325248', current_date
from books where title = 'The Time Machine' and author = 'H.G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Mark Nelson']::text[], 'Gildan Media LLC aka G&D Media', null, 'https://hardcover.app/books/the-time-machine/editions/30394664', current_date
from books where title = 'The Time Machine' and author = 'H.G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Christopher Burns', 'Maggi-Meg Reed']::text[], 'Highbridge Audio', null, 'https://hardcover.app/books/the-time-travelers-wife-c0fa6909-31fc-47da-8c79-fa75a05594a7/editions/19986237', current_date
from books where title = 'The Time Traveler''s Wife' and author = 'Audrey Niffenegger'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Laurel Lefkow', 'William Hope']::text[], 'Chivers Audio Books', null, 'https://hardcover.app/books/the-time-travelers-wife-c0fa6909-31fc-47da-8c79-fa75a05594a7/editions/30381702', current_date
from books where title = 'The Time Traveler''s Wife' and author = 'Audrey Niffenegger'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Fred Berman', 'Phoebe Strole']::text[], 'Harvest / Harcourt, Inc.', 509, 'https://hardcover.app/books/the-time-travelers-wife-c0fa6909-31fc-47da-8c79-fa75a05594a7/editions/30399688', current_date
from books where title = 'The Time Traveler''s Wife' and author = 'Audrey Niffenegger'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ursula K. Le Guin']::text[], 'Audio Literature, Fantastic Audio', 347, 'https://hardcover.app/books/the-tombs-of-atuan/editions/32689236', current_date
from books where title = 'The Tombs of Atuan' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Aysha Kala']::text[], 'Gateway', 341, 'https://hardcover.app/books/the-tombs-of-atuan/editions/32072836', current_date
from books where title = 'The Tombs of Atuan' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Antonella Civale']::text[], null, null, 'https://hardcover.app/books/the-tombs-of-atuan/editions/32570343', current_date
from books where title = 'The Tombs of Atuan' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', 328, 'https://hardcover.app/books/the-tombs-of-atuan/editions/32349963', current_date
from books where title = 'The Tombs of Atuan' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Flo Gibson']::text[], 'Audio Book Contractors', null, 'https://hardcover.app/books/the-war-of-the-worlds/editions/11954007', current_date
from books where title = 'The War of the Worlds' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Leonard Nimoy']::text[], 'Caedmon Audio Cassette', null, 'https://hardcover.app/books/the-war-of-the-worlds/editions/29203608', current_date
from books where title = 'The War of the Worlds' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Simon Vance']::text[], null, 356, 'https://hardcover.app/books/the-war-of-the-worlds/editions/32498730', current_date
from books where title = 'The War of the Worlds' and author = 'H. G. Wells'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Prichard']::text[], 'Tantor Media', null, 'https://hardcover.app/books/twenty-thousand-leagues-under-the-sea/editions/1648290', current_date
from books where title = 'Twenty Thousand Leagues Under the Sea' and author = 'Jules Verne'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['David Linski']::text[], ' Blackstone Audio', 673, 'https://hardcover.app/books/twenty-thousand-leagues-under-the-sea/editions/31706891', current_date
from books where title = 'Twenty Thousand Leagues Under the Sea' and author = 'Jules Verne'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Kramer']::text[], 'Audio Book Contractors', null, 'https://hardcover.app/books/twenty-thousand-leagues-under-the-sea/editions/4384275', current_date
from books where title = 'Twenty Thousand Leagues Under the Sea' and author = 'Jules Verne'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alyssa Bresnahan']::text[], 'Recorded Books', 1496, 'https://hardcover.app/books/warbreaker/editions/32038354', current_date
from books where title = 'Warbreaker' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Kramer']::text[], 'Library of Congress', 1422, 'https://hardcover.app/books/warbreaker/editions/32720737', current_date
from books where title = 'Warbreaker' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['James Yaegashi']::text[], null, 1492, 'https://hardcover.app/books/warbreaker/editions/33005660', current_date
from books where title = 'Warbreaker' and author = 'Brandon Sanderson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Sam Tsoutsouvas']::text[], 'Brilliance Audio', 2046, 'https://hardcover.app/books/wizards-first-rule/editions/32468845', current_date
from books where title = 'Wizard''s First Rule' and author = 'Terry Goodkind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jim Bond']::text[], 'Brilliance Audio on CD Unabridged', null, 'https://hardcover.app/books/wizards-first-rule/editions/6852689', current_date
from books where title = 'Wizard''s First Rule' and author = 'Terry Goodkind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dick Hill']::text[], 'Nova Audio Books', null, 'https://hardcover.app/books/wizards-first-rule/editions/25428136', current_date
from books where title = 'Wizard''s First Rule' and author = 'Terry Goodkind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nick Sullivan']::text[], 'National Library Service for the Blind and Print Disabled', 1820, 'https://hardcover.app/books/wizards-first-rule/editions/32596433', current_date
from books where title = 'Wizard''s First Rule' and author = 'Terry Goodkind'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Edoardo Ballerini']::text[], 'Blackstone Publishing', 900, 'https://hardcover.app/books/wool/editions/31877632', current_date
from books where title = 'Wool' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Amanda Sayle', 'Susannah Harker']::text[], 'Random House', 1000, 'https://hardcover.app/books/wool/editions/31747196', current_date
from books where title = 'Wool' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Minnie Goode']::text[], 'Broad Reach Publishing', null, 'https://hardcover.app/books/wool/editions/33253567', current_date
from books where title = 'Wool' and author = 'Hugh Howey'
on conflict (book_id, source_url) do nothing;
