-- Builds three real `universe` rows from this batch of the catalog-wide
-- shared-universe linking audit (docs/TODO.md): "Realm of the Elderlings"
-- (Robin Hobb), "Grishaverse" (Leigh Bardugo), and "Enderverse" (Orson
-- Scott Card). Also resolves the standing open question from the prior
-- batch (Mark Lawrence's Impossible Times/Library Trilogy) as NOT
-- connected -- no migration piece for that, see docs/project-log.md.
--
-- ROBIN HOBB -- "Realm of the Elderlings", CONFIRMED CONNECTED.
-- The Farseer Trilogy, The Liveship Traders, The Tawny Man, The Rain
-- Wild Chronicles, and Fitz and the Fool are all one continuous shared
-- world and cast across generations -- explicitly not independent
-- trilogies (the Rain Wild Chronicles ties Liveship's elderling threads
-- forward into Fitz and the Fool). "Realm of the Elderlings" is the
-- real umbrella term used consistently across publisher marketing and
-- every reading-order guide (first appeared in print around the Legends
-- II "Homecoming" era) -- not an invented label, and no collision with
-- any of the 5 series' own names.
--
-- LEIGH BARDUGO -- "Grishaverse", CONFIRMED CONNECTED (King of Scars,
-- Six of Crows, The Shadow and Bone Trilogy only -- Ninth House is
-- CONFIRMED NOT connected, see below). Official reading order runs
-- Shadow and Bone Trilogy -> Six of Crows -> King of Scars, with the
-- King of Scars duology explicitly continuing Nikolai Lantsov's arc and
-- pulling in returning characters from both earlier series. "Grishaverse"
-- is Bardugo's own coined, publisher-used term for this continuity --
-- real name, no collision with any of the 3 series' own names.
--
-- ORSON SCOTT CARD -- "Enderverse", CONFIRMED CONNECTED (Ender's Saga,
-- The Shadow Series, Enderverse:  Publication Order). The Shadow Saga
-- (Ender's Shadow / Shadow of the Hegemon / Shadow Puppets / Shadow of
-- the Giant) is an explicit parallel timeline to Ender's Saga -- Ender's
-- Shadow retells Ender's Game's own events from Bean's POV, and the two
-- lines converge and are jointly resolved in The Last Shadow (not in our
-- catalog). "Enderverse" is Card's own used term (e.g. his own
-- collection "First Meetings: Three Stories from the Enderverse") --
-- real, not invented.
-- NOTE, flagged for the repo owner rather than fixed here: the Shadow
-- Saga's 4 novels are currently split across TWO separate series rows
-- in this catalog -- "The Shadow Series" (Shadow of the Hegemon, Shadow
-- Puppets) and "Enderverse:  Publication Order" (Ender's Shadow, Shadow
-- of the Giant) -- which looks like a genuine series-grouping data
-- problem (one real series represented as two rows), not a
-- universe-linking question. Left as-is per this audit's scope (not
-- authorized to restructure/merge existing series rows without a
-- judgment call from the repo owner) -- both rows are linked to the new
-- Enderverse universe so the connection is captured regardless of which
-- series row a given book sits under.
--
-- CONFIRMED NOT CONNECTED this batch (no action, logged so these aren't
-- re-researched):
-- * Leigh Bardugo's Ninth House (Alex Stern, Yale-set adult contemporary
--   fantasy) -- explicitly a separate, unrelated universe from the
--   Grishaverse, confirmed via multiple sources.
-- * Jim Butcher's Codex Alera, The Cinder Spires, and The Dresden Files
--   -- three distinct, unconnected worlds (Roman-flavored elemental
--   fantasy; steampunk airship war; contemporary Chicago urban fantasy).
--   No official crossover confirmed despite fan interest.
-- * James S. A. Corey's The Captive's War and The Expanse -- explicitly
--   NOT the same universe per the authors' own statements ("the other
--   side of space opera from The Expanse"); the only real connection is
--   shared production company/TV team, not shared fiction.
-- * Timothy Zahn's Star Wars: The Thrawn Trilogy and Star Wars: Thrawn
--   -- both feature Grand Admiral Thrawn as protagonist but are
--   OFFICIALLY split, mutually incompatible continuities (the original
--   trilogy is Legends, retired from canon by Disney's 2014 reset; the
--   newer Thrawn books are new-canon prequels with a different
--   backstory for the same character). A recurring protagonist alone
--   doesn't make these "one shared universe" here -- they're explicitly
--   a non-merged reboot relationship, and linking them via universe_id
--   would misrepresent two contradictory continuities as one continuous
--   story. Distinct from every other confirmed-connected case in this
--   audit, all of which are additive/non-contradictory.
--
-- CONFIRMED CONNECTED but NOT built this batch -- a real naming-policy
-- question for the repo owner, same shape as the still-open Mark
-- Lawrence question:
-- * Sarah J. Maas's A Court of Thorns and Roses, Throne of Glass, and
--   Crescent City are a real, strong, author-confirmed connection --
--   actual character travel/interaction across the three book-worlds
--   (Aelin passing through Crescent City's world at the end of Kingdom
--   of Ash; Bryce traveling into Prythian at the end of House of Sky and
--   Breath; Azriel appearing as a real character in Crescent City), not
--   a cameo. Maas herself: "I had planted seeds in all my series about
--   the possibility of it being a multiverse. The worlds exist, but
--   they're planets and light-years away." But there is NO official
--   branded name -- "Maasverse" is fan-coined only, and unlike Abeth/
--   Westeros/Middle-earth there is no single unifying in-world place
--   (ACOTAR is set in Prythian, Throne of Glass in Erilea, Crescent City
--   on a separate world/planet again -- three genuinely different
--   planets linked by portal travel, not one place with one name).
--   Neither established fallback (a real unambiguous place name, or an
--   "X World"-suffixed name avoiding a collision) cleanly applies here,
--   because there is no natural name to begin with, not just a collision
--   to work around. Per this audit's standing instruction, not inventing
--   one -- skipping the migration piece, flagging for the repo owner.
--
-- Resolves the standing open question from the prior batch: Mark
-- Lawrence's Impossible Times and Library Trilogy are CONFIRMED NOT
-- connected to each other. Lawrence's own "Guide to Lawrence" post lists
-- only two connected pairs (Broken Empire/Red Queen's War, and Book of
-- the Ancestor/Book of the Ice) and explicitly does not list Library
-- Trilogy or Impossible Times as connected to anything ("my other
-- trilogies are not required reading"). A Grimdark Magazine interview
-- describes The Book That Wouldn't Burn as "a wholly original tale set
-- in a new world with a brand-new cast of characters... there's no
-- connection between this trilogy and his other work" -- the Library's
-- premise (an infinite library that conceptually "contains" every book)
-- is a thematic device, not a real structural link, the same category
-- already ruled out for Gaiman's American Gods/Neverwhere and King's Man
-- in Black motif. No migration action for this pairing.

insert into universe (name)
select 'Realm of the Elderlings' where not exists (select 1 from universe where name = 'Realm of the Elderlings');

insert into universe (name)
select 'Grishaverse' where not exists (select 1 from universe where name = 'Grishaverse');

insert into universe (name)
select 'Enderverse' where not exists (select 1 from universe where name = 'Enderverse');

update series set universe_id = (select id from universe where name = 'Realm of the Elderlings')
where name = 'The Farseer Trilogy';

update series set universe_id = (select id from universe where name = 'Realm of the Elderlings')
where name = 'The Liveship Traders';

update series set universe_id = (select id from universe where name = 'Realm of the Elderlings')
where name = 'The Tawny Man';

update series set universe_id = (select id from universe where name = 'Realm of the Elderlings')
where name = 'The Rain Wild Chronicles';

update series set universe_id = (select id from universe where name = 'Realm of the Elderlings')
where name = 'Fitz and the Fool';

update series set universe_id = (select id from universe where name = 'Grishaverse')
where name = 'The Shadow and Bone Trilogy';

update series set universe_id = (select id from universe where name = 'Grishaverse')
where name = 'Six of Crows';

update series set universe_id = (select id from universe where name = 'Grishaverse')
where name = 'King of Scars';

update series set universe_id = (select id from universe where name = 'Enderverse')
where name = 'Ender''s Saga';

update series set universe_id = (select id from universe where name = 'Enderverse')
where name = 'The Shadow Series';

update series set universe_id = (select id from universe where name = 'Enderverse')
where name = 'Enderverse:  Publication Order';
