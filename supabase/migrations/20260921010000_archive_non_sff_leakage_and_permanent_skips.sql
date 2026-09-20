-- Introduce a books.archived mechanism so out-of-scope/not-currently-relevant
-- catalog rows can be kept (real bibliographic data, potentially useful if
-- scope ever expands) while being excluded from user-facing search/browse --
-- an alternative to outright deletion for the round-4 non-SFF leakage pool,
-- per the repo owner's explicit request 2026-09-21.
--
-- Every UPDATE is scoped by (title, author), not title alone -- a real
-- duplicate-title collision was caught during this migration's own rolled-
-- back-transaction test ('Quicksilver' matches both Callie Hart's already-
-- tagged fantasy romance AND Neal Stephenson's untagged Baroque Cycle novel;
-- a title-only WHERE would have silently archived the wrong, already-tagged
-- book too). Same class of bug this project's tag-catalog-batch skill already
-- documents for exactly this reason.
--
-- Three real categories archived here, each with its own archived_reason:
--   'non_sff_genre_leakage' -- literary fiction/thriller/nonfiction/classics
--     pulled in by Hardcover's broad genre search, confirmed not sci-fi/
--     fantasy (same pattern CLAUDE.md's catalog-scope section documents --
--     see also the already-deleted Shogun/original Screwtape Letters cases).
--     Includes 'The Screwtape Letters' itself -- re-ingested 2026-09-11 despite
--     being deliberately deleted 2026-09-09 for the exact same reason; archived
--     rather than re-deleted so there's a durable record instead of a repeat
--     silent disappearance.
--   'graphic_novel' -- comics/graphic novels, out of v1 scope per CLAUDE.md's
--     catalog-scope section (no format/medium field distinguishes visual comics
--     from prose, and several fields mean something different for a comic).
--   'unpublished' -- not yet released, nothing to tag yet (will need a future
--     un-archive once published).
--   'omnibus_duplicate' -- a combined edition of books already individually
--     catalogued and (mostly) tagged.
--
-- Deliberately NOT archived, left as open questions per their existing flags
-- (see docs/TODO.md): Holly (Stephen King, open SFF-scope question), The Lottery
-- and The Egg (Shirley Jackson / Andy Weir, likely short-story/book format
-- mismatches -- may need deletion rather than archival once resolved, a
-- different situation from a real book that's just out of genre scope).

alter table books add column if not exists archived boolean not null default false;
alter table books add column if not exists archived_reason text;
alter table books add column if not exists archived_at timestamptz;

-- ===== Non-SFF genre leakage (96) =====
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'A Farewell to Arms' and author = 'Ernest Hemingway' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'A Tale for the Time Being' and author = 'Ruth Ozeki' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'A Tree Grows in Brooklyn' and author = 'Betty Smith' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'After Dark' and author = 'Haruki Murakami, Jay Rubin' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'American War' and author = 'Omar El Akkad' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Aristotle and Dante Discover the Secrets of the Universe' and author = 'Benjamin Alire Sáenz' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Around the World in Eighty Days' and author = 'Jules Verne, Henry Frith' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Atlas Shrugged' and author = 'Ayn Rand, Leonard Peikoff' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Atmosphere: A Love Story' and author = 'Taylor Jenkins Reid' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Beartown' and author = 'Fredrik Backman, Neil Smith' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Billy Summers' and author = 'Stephen King' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Bridge to Terabithia' and author = 'Katherine Paterson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Butcher & Blackbird' and author = 'Brynne Weaver' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Colorless Tsukuru Tazaki and His Years of Pilgrimage' and author = 'Haruki Murakami, Philip Gabriel' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Cosmos' and author = 'Carl Sagan, Paulo Geiger' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Deception Point' and author = 'Dan Brown' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Digital Fortress' and author = 'Dan Brown' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Earthlings' and author = 'Sayaka Murata, Ginny Tapley Takemori' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Exit West' and author = 'Mohsin Hamid' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Fangirl' and author = 'Rainbow Rowell' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Fifty Shades of Grey' and author = 'E.L. James' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Firekeeper''s Daughter' and author = 'Angeline Boulley' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Foucault''s Pendulum' and author = 'Umberto Eco' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Franny and Zooey' and author = 'J. D. Salinger' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Haunting Adeline' and author = 'H. D. Carlton' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Her Body and Other Parties' and author = 'Carmen Maria Machado' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Home Before Dark' and author = 'Riley Sager' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Hooked' and author = 'Emily McIntire' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'If We Were Villains' and author = 'M.L. Rio' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'If on a Winter''s Night a Traveler' and author = 'Italo Calvino' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Inferno' and author = 'Dan Brown' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Invisible Cities' and author = 'Italo Calvino, Anthony Doerr, Karina Maria Puente Frantzen' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Invisible Man' and author = 'Ralph Ellison' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Lights Out' and author = 'Navessa Allen' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Mere Christianity' and author = 'C. S. Lewis, Kathleen Norris' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Mother Night' and author = 'Kurt Vonnegut' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Nimona' and author = 'ND Stevenson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Nuclear War: A Scenario' and author = 'Annie Jacobsen' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Number the Stars' and author = 'Lois Lowry' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Origin' and author = 'Dan Brown' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Our Missing Hearts' and author = 'Celeste Ng' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Paradise Lost' and author = 'John Milton, John      Leonard' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Pattern Recognition' and author = 'William Gibson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Pride and Prejudice and Zombies' and author = 'Seth Grahame-Smith, Jane Austen' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Prophet Song' and author = 'Paul Lynch' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Quicksilver' and author = 'Neal Stephenson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Randomize' and author = 'Andy Weir' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Reamde' and author = 'Neal Stephenson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Remarkably Bright Creatures' and author = 'Shelby Van Pelt' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'S.' and author = 'Doug Dorst, J.J. Abrams' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Shōgun' and author = 'James Clavell' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Sophie''s World' and author = 'Jostein Gaarder, Paulette Møller' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Steppenwolf' and author = 'Hermann Hesse, Basil Creighton' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Superintelligence: Paths, Dangers, Strategies' and author = 'Nick Bostrom, Napoleon Ryan' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Tenth of December' and author = 'George Saunders' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Amazing Adventures of Kavalier & Clay' and author = 'Michael Chabon' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Blind Assassin' and author = 'Margaret Atwood' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Bluest Eye' and author = 'Toni Morrison' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Brief Wondrous Life of Oscar Wao' and author = 'Junot Díaz' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Casual Vacancy' and author = 'J.K. Rowling' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Crying of Lot 49' and author = 'Thomas Pynchon' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Final Gambit' and author = 'Jennifer Lynn Barnes' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Fountainhead' and author = 'Ayn Rand' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Gentleman''s Guide to Vice and Virtue' and author = 'Mackenzi Lee, Christian Coulson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Girl with the Dragon Tattoo' and author = 'Stieg Larsson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Glass Castle' and author = 'Jeannette Walls' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Godfather' and author = 'Mario Puzo' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Hawthorne Legacy' and author = 'Jennifer Lynn Barnes' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The House Across the Lake' and author = 'Riley Sager' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Hunchback of Notre Dame' and author = 'Victor Hugo, Tim Wynne-Jones' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Inheritance Games' and author = 'Jennifer Lynn Barnes' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Lost Apothecary' and author = 'Sarah Penner' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Maidens' and author = 'Alex Michaelides' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Mysterious Benedict Society' and author = 'Trenton Lee Stewart, Carson Ellis' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Naked Lunch' and author = 'William S. Burroughs' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Naturals' and author = 'Jennifer Lynn Barnes' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Overstory' and author = 'Richard Powers' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Phantom of the Opera' and author = 'Gaston Leroux' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Pillars of the Earth' and author = 'Ken Follett' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Plague' and author = 'Albert Camus, Stuart Gilbert' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Screwtape Letters' and author = 'C. S. Lewis' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Secret of Secrets' and author = 'Dan Brown, Fernanda Abreu' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Shadow of the Wind' and author = 'Carlos Ruiz Zafón' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Three Musketeers' and author = 'Alexandre Dumas' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Wasp Factory' and author = 'Iain Banks' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Wind-Up Bird Chronicle' and author = 'Haruki Murakami, Jay Rubin' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'The Yellow Wallpaper' and author = 'Charlotte Perkins Gilman' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'There There' and author = 'Tommy Orange' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Think Again: The Power of Knowing What You Don''t Know' and author = 'Adam M. Grant' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Truly Devious' and author = 'Maureen Johnson' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Twisted Love' and author = 'Ana Huang' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'When We Cease to Understand the World' and author = 'Benjamín Labatut, Adrian Nathan West' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'White Noise' and author = 'Don DeLillo, Richard Powers' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Wonder' and author = 'R. J. Palacio' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'World Without End' and author = 'Ken Follett' and archived = false;
update books set archived = true, archived_reason = 'non_sff_genre_leakage', archived_at = now() where title = 'Yesteryear' and author = 'Caro Claire Burke' and archived = false;

-- ===== Graphic novels (out of v1 scope) (11) =====
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Monstress, Vol. 1: Awakening' and author = 'Marjorie M. Liu, Sana Takeda, Rus Wooton, Jennifer M. Smith' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Paper Girls, Vol. 1' and author = 'Brian K. Vaughan, Cliff Chiang' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Saga, Vol. 1' and author = 'Fiona Staples, Brian K. Vaughan' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Saga, Vol. 2' and author = 'Fiona Staples, Brian K. Vaughan' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Saga, Vol. 3' and author = 'Brian K. Vaughan, Fiona Staples' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Saga, Vol. 4' and author = 'Fiona Staples, Brian K. Vaughan' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'The Sandman, Vol. 1: Preludes & Nocturnes' and author = 'Neil Gaiman' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'The Walking Dead, Vol. 1: Days Gone Bye' and author = 'Robert Kirkman, Tony Moore' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Watchmen' and author = 'Alan Moore' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'White Sand, Vol. 1' and author = 'Brandon Sanderson, Rik Hoskin, Julius Gopez' and archived = false;
update books set archived = true, archived_reason = 'graphic_novel', archived_at = now() where title = 'Y: The Last Man Vol, 1 Unmanned' and author = 'Brian K. Vaughan, Pia Guerra, José Marzán Jr.' and archived = false;

-- ===== Unpublished (3) =====
update books set archived = true, archived_reason = 'unpublished', archived_at = now() where title = 'Red God' and author = 'Pierce Brown' and archived = false;
update books set archived = true, archived_reason = 'unpublished', archived_at = now() where title = 'The Doors of Stone' and author = 'Patrick Rothfuss' and archived = false;
update books set archived = true, archived_reason = 'unpublished', archived_at = now() where title = 'The Winds of Winter' and author = 'George R.R. Martin' and archived = false;

-- ===== Omnibus duplicates (5) =====
update books set archived = true, archived_reason = 'omnibus_duplicate', archived_at = now() where title = 'Monk and Robot' and author = 'Becky Chambers' and archived = false;
update books set archived = true, archived_reason = 'omnibus_duplicate', archived_at = now() where title = 'The Farseer Trilogy' and author = 'Robin Hobb' and archived = false;
update books set archived = true, archived_reason = 'omnibus_duplicate', archived_at = now() where title = 'The Foundation Trilogy' and author = 'Isaac Asimov' and archived = false;
update books set archived = true, archived_reason = 'omnibus_duplicate', archived_at = now() where title = 'The Hobbit & The Lord of the Rings' and author = 'J.R.R. Tolkien, Alan Lee' and archived = false;
update books set archived = true, archived_reason = 'omnibus_duplicate', archived_at = now() where title = 'Villains Duology' and author = 'V. E. Schwab' and archived = false;

