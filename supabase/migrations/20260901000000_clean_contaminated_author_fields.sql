-- Bibliographic ingestion pulled every "contributor" credit from
-- Hardcover's API into books.author as one comma-separated string --
-- illustrators, translators, cover artists, audiobook narrators,
-- introduction/foreword/afterword writers, and editors all got mixed
-- in alongside (or instead of) the actual writer(s). Confirmed via
-- `select title, author from books where author like '%,%' or author
-- ilike '% and %' or author like '%&%'`: 73 books had a multi-name
-- author field. Each was checked individually (web search where not
-- already known) rather than assuming "keep only the first name" --
-- that blanket rule would have wrongly broken genuine co-authored
-- books.
--
-- Left untouched (genuine multi-author/co-creator credit, confirmed):
-- A Memory of Light (Sanderson completing Jordan's own drafts/notes),
-- The Gathering Storm and Towers of Midnight (same Wheel of Time
-- collaboration), Good Omens (Gaiman & Pratchett co-wrote it), Illuminae
-- (Kaufman & Kristoff co-wrote the Illuminae Files), This Is How You
-- Lose the Time War (El-Mohtar & Gladstone co-wrote it, alternating
-- chapters), Harry Potter and the Cursed Child (published playscript is
-- consistently billed "J.K. Rowling, John Tiffany, and Jack Thorne" --
-- all three credited as originating the story), and Saga, Vol. 1
-- (Vaughan/writer + Staples/artist are both universally credited
-- co-creators of the series -- for a comic, the artist is intrinsic to
-- the narrative, not a decorative cover credit like a novel's cover
-- illustrator).
--
-- Fixed below (non-author contributor removed):
--   - translators: 1Q84, A Master of Djinn, Armada, Around the World in
--     Eighty Days, Baptism of Fire, Beartown, Before the Coffee Gets
--     Cold, Blindness, Blood of Elves, Cosmos, Death's End, Earthlings,
--     Hard-Boiled Wonderland and the End of the World, Kafka on the
--     Shore, The Dark Forest, The Divine Comedy (+ intro/notes writers),
--     The Last Wish, The Master and Margarita, The Memory Police, The
--     Plague, The Shadow of the Wind, The Time of Contempt, The Tower
--     of the Swallow, Sword of Destiny, Tender Is the Flesh, We,
--     Weyward, Perfume (translator credit + narrator), Roadside Picnic
--     (translator + foreword writer -- genuine co-authors Arkady and
--     Boris Strugatsky are kept)
--   - illustrators/cover artists: A Knight of the Seven Kingdoms,
--     Alice's Adventures in Wonderland/Through the Looking-Glass (+
--     annotator), Daughter of the Moon Goddess, Dungeon Crawler Carl,
--     Empire of the Vampire, Fire & Blood, the four illustrated Narnia
--     books + The Complete Chronicles of Narnia (all Pauline Baynes),
--     the three Mary GrandPré Harry Potter volumes, Royal Assassin,
--     Stranger in a Strange Land, This Inevitable Ruin (photographer),
--     Tress of the Emerald Sea, The Graveyard Book
--   - audiobook narrators: Binti, City of Fallen Angels, House of Sky
--     and Breath, One Last Stop, The Strange Case of Dr Jekyll and Mr
--     Hyde, The Wicked King
--   - introduction/afterword/editor credits: A Clockwork Orange,
--     Atlas Shrugged, Childhood's End, Frankenstein, Mostly Harmless,
--     The Silmarillion (Christopher Tolkien is credited as editor of
--     his father's posthumous notes, not co-author)
--   - not a contributor at all, but still wrong: Dune listed Brian
--     Herbert as co-author -- he did not co-write the original 1965
--     novel (his Dune collaborations with Kevin J. Anderson are later,
--     separate prequel/sequel books); The Long Walk listed "Richard
--     Bachman, Stephen King" as two names when they are the same
--     person (King's pseudonym) -- normalized to "Stephen King" to
--     match how every other King book in this catalog is credited.

update books set author = 'Haruki Murakami' where title = '1Q84';
update books set author = 'Anthony Burgess' where title = 'A Clockwork Orange';
update books set author = 'George R.R. Martin' where title = 'A Knight of the Seven Kingdoms';
update books set author = 'P. Djèlí Clark' where title = 'A Master of Djinn';
update books set author = 'Lewis Carroll' where title = 'Alice''s Adventures in Wonderland / Through the Looking-Glass';
update books set author = 'Ernest Cline' where title = 'Armada';
update books set author = 'Jules Verne' where title = 'Around the World in Eighty Days';
update books set author = 'Ayn Rand' where title = 'Atlas Shrugged';
update books set author = 'Andrzej Sapkowski' where title = 'Baptism of Fire';
update books set author = 'Fredrik Backman' where title = 'Beartown';
update books set author = 'Toshikazu Kawaguchi' where title = 'Before the Coffee Gets Cold';
update books set author = 'Nnedi Okorafor' where title = 'Binti';
update books set author = 'José Saramago' where title = 'Blindness';
update books set author = 'Andrzej Sapkowski' where title = 'Blood of Elves';
update books set author = 'Arthur C. Clarke' where title = 'Childhood''s End';
update books set author = 'Cassandra Clare' where title = 'City of Fallen Angels';
update books set author = 'Carl Sagan' where title = 'Cosmos';
update books set author = 'Sue Lynn Tan' where title = 'Daughter of the Moon Goddess';
update books set author = 'Cixin Liu' where title = 'Death''s End';
update books set author = 'Frank Herbert' where title = 'Dune';
update books set author = 'Matt Dinniman' where title = 'Dungeon Crawler Carl';
update books set author = 'Sayaka Murata' where title = 'Earthlings';
update books set author = 'Jay Kristoff' where title = 'Empire of the Vampire';
update books set author = 'George R.R. Martin' where title = 'Fire & Blood';
update books set author = 'Mary Shelley' where title = 'Frankenstein';
update books set author = 'Haruki Murakami' where title = 'Hard-Boiled Wonderland and the End of the World';
update books set author = 'J.K. Rowling' where title = 'Harry Potter and the Goblet of Fire';
update books set author = 'J.K. Rowling' where title = 'Harry Potter and the Half-Blood Prince';
update books set author = 'J.K. Rowling' where title = 'Harry Potter and the Order of the Phoenix';
update books set author = 'Sarah J. Maas' where title = 'House of Sky and Breath';
update books set author = 'Haruki Murakami' where title = 'Kafka on the Shore';
update books set author = 'Douglas Adams' where title = 'Mostly Harmless';
update books set author = 'Casey McQuiston' where title = 'One Last Stop';
update books set author = 'Patrick Süskind' where title = 'Perfume';
update books set author = 'C. S. Lewis' where title = 'Prince Caspian';
update books set author = 'Arkady Strugatsky, Boris Strugatsky' where title = 'Roadside Picnic';
update books set author = 'Robin Hobb' where title = 'Royal Assassin';
update books set author = 'Stanisław Lem' where title = 'Solaris';
update books set author = 'Robert A. Heinlein' where title = 'Stranger in a Strange Land';
update books set author = 'Andrzej Sapkowski' where title = 'Sword of Destiny';
update books set author = 'Agustina Bazterrica' where title = 'Tender Is the Flesh';
update books set author = 'C. S. Lewis' where title = 'The Complete Chronicles of Narnia';
update books set author = 'Cixin Liu' where title = 'The Dark Forest';
update books set author = 'Dante Alighieri' where title = 'The Divine Comedy';
update books set author = 'Neil Gaiman' where title = 'The Graveyard Book';
update books set author = 'Andrzej Sapkowski' where title = 'The Last Wish';
update books set author = 'C. S. Lewis' where title = 'The Lion, the Witch and the Wardrobe';
update books set author = 'Stephen King' where title = 'The Long Walk';
update books set author = 'C. S. Lewis' where title = 'The Magician''s Nephew';
update books set author = 'Mikhail Bulgakov' where title = 'The Master and Margarita';
update books set author = 'Yoko Ogawa' where title = 'The Memory Police';
update books set author = 'Albert Camus' where title = 'The Plague';
update books set author = 'Carlos Ruiz Zafón' where title = 'The Shadow of the Wind';
update books set author = 'J.R.R. Tolkien' where title = 'The Silmarillion';
update books set author = 'C. S. Lewis' where title = 'The Silver Chair';
update books set author = 'Robert Louis Stevenson' where title = 'The Strange Case of Dr Jekyll and Mr Hyde';
update books set author = 'Andrzej Sapkowski' where title = 'The Time of Contempt';
update books set author = 'Andrzej Sapkowski' where title = 'The Tower of the Swallow';
update books set author = 'C. S. Lewis' where title = 'The Voyage of the Dawn Treader';
update books set author = 'Holly Black' where title = 'The Wicked King';
update books set author = 'Haruki Murakami' where title = 'The Wind-Up Bird Chronicle';
update books set author = 'Matt Dinniman' where title = 'This Inevitable Ruin';
update books set author = 'Brandon Sanderson' where title = 'Tress of the Emerald Sea';
update books set author = 'Yevgeny Zamyatin' where title = 'We';
update books set author = 'Emilia Hart' where title = 'Weyward';
