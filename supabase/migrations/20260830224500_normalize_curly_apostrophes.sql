-- Data-quality fix: normalizes curly/smart apostrophes (U+2019) to plain
-- ASCII apostrophes in books.title and series.name, matching the
-- straight-apostrophe convention every other title in the catalog uses
-- (e.g. "Tiamat's Wrath", "Assassin's Quest"). Surfaced by "The Ultimate
-- Hitchhiker's Guide" rendering as a mojibake replacement character in a
-- terminal that couldn't display U+2019 -- the underlying data wasn't
-- corrupted, just inconsistent with the rest of the catalog. A full-table
-- scan (books.title, series.name) for curly single/double quotes found
-- two more affected titles: "The Time Traveler's Wife" (book + series)
-- and "Miss Peregrine's Home for Peculiar Children".

update books
set title = replace(title, '’', '''')
where title ~ '[‘’“”]';

update series
set name = replace(name, '’', '''')
where name ~ '[‘’“”]';
