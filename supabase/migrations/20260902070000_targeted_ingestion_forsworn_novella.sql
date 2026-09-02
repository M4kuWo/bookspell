-- The Powder Mage novella Mathias actually read (2026-09-02): Forsworn,
-- confirmed directly rather than guessed among several candidates (see
-- the prior Powder Mage migration's comment). Bibliographic data only,
-- not tagged -- his 'liked' rating for it can't be added until it's tagged.

insert into books (title, author, isbn, cover_url, synopsis, page_count, audiobook_duration_minutes, publication_year, hardcover_id, series_id, position_in_series) values ('Forsworn', 'Brian McClellan', '0996232303', 'https://assets.hardcover.app/external_data/59459401/2cc43f560d4e73c53d39ab7a9a80e73989c8780b.jpeg', 'Erika ja Leora is a powder mage in northern Kez, a place where that particular sorcery is punishable by death. She is only protected by her family name and her position as heir to a duchy.

When she decides to help a young commoner—a powder mage marked for death, fugitive from the law—she puts her life and family reputation at risk and sets off to deliver her new ward to the safety of Adro while playing cat and mouse with the king’s own mage hunters and their captain, Duke Nikslaus.

Occurs 35 years before the events in Promise of Blood.', 64, null, 2014, 460254, (select id from series where hardcover_id = 2962), '0.1') on conflict (hardcover_id) do nothing;
