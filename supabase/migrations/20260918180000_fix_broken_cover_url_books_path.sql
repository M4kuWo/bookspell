-- Fixes 7 books whose `cover_url` used Hardcover's legacy
-- `assets.hardcover.app/books/<id>/...` asset path -- caught 2026-09-18
-- when the repo owner reported broken-image icons on his phone for two
-- of them (The Desert Spear, The Gunslinger) during a real mobile
-- click-through. Confirmed via direct HTTP check that every `/books/`-
-- path URL in the catalog now 403s (Hardcover appears to have retired
-- this path), while the newer `/edition/`, `/editions/`, and
-- `/external_data/` paths (863 + 305 books respectively) still resolve
-- fine -- this was an isolated data-quality gap (7 of 1256 books), not
-- a systemic app/frontend bug.
--
-- Replacement URLs looked up directly against Hardcover's real GraphQL
-- API (`books_by_pk(id).editions[].image.url`), the same data source
-- `scripts/ingest-seed-catalog.js` already uses, then each one verified
-- with a real HTTP HEAD/GET returning 200 before being written here --
-- not guessed. One book (The Girl with the Dragon Tattoo) turned up a
-- second, separate data-quality wrinkle along the way: the numeric id
-- embedded in its old `/books/379085/...` URL does NOT correspond to
-- its own Hardcover book id -- looking it up directly returned an
-- unrelated Portuguese-title book record. Found the correct book id
-- (1218611) via a fresh Hardcover search instead and used one of ITS
-- real editions. This migration only touches `cover_url`; it does not
-- attempt to correct whatever originally caused that id mismatch, and
-- doesn't change any other column.

update books set cover_url = 'https://assets.hardcover.app/editions/32191696/4a8ea147-0dee-469f-b398-4c8f1c459d66.jpg', updated_at = now()
where title = 'The Gunslinger' and author = 'Stephen King';

update books set cover_url = 'https://assets.hardcover.app/edition/32236798/bcede2b493a153e96a29ca396c7a317c3cb0dddf.jpeg', updated_at = now()
where title = 'The Desert Spear' and author = 'Peter V. Brett';

update books set cover_url = 'https://assets.hardcover.app/edition/661671/58ee6b26f5ba355e46d78b61933fc8889dbc3b65.jpeg', updated_at = now()
where title = 'The Girl with the Dragon Tattoo' and author = 'Stieg Larsson';

update books set cover_url = 'https://assets.hardcover.app/edition/30732541/53c6825f5926087d2462aaa30e56a0fbbd9a5a7f.jpeg', updated_at = now()
where title = 'Winter' and author = 'Marissa Meyer';

update books set cover_url = 'https://assets.hardcover.app/edition/8933780/d9539c74508e4c3e21cd40e2dcbe4ddf009ed53e.jpeg', updated_at = now()
where title = 'Ignite Me' and author = 'Tahereh Mafi';

update books set cover_url = 'https://assets.hardcover.app/external_data/24979632/4c8b847fe13dd43a91a01c249ad4e4e47b6e96e3.jpeg', updated_at = now()
where title = 'The Kingdom of Copper' and author = 'S. A. Chakraborty';

update books set cover_url = 'https://assets.hardcover.app/edition/4207950/af2df60fe2a05276dd5500aa871dbd9e0de9d510.jpeg', updated_at = now()
where title = 'Mortal Engines' and author = 'Philip Reeve';
