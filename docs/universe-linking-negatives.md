# Shared-universe linking audit -- confirmed negatives

A reference list, not a narrative -- kept so a future batch doesn't burn
search budget re-checking a pairing that's already been ruled out. See
`docs/TODO.md`'s "Catalog-wide shared-universe linking audit" item for
current status, and `docs/project-log.md`'s dated "shared-universe audit
batch N" entries (batches 1-9, 2026-09-11 through 2026-09-13) for the
full evidence behind each verdict below.

The candidate pool (authors with 2+ series, `universe_id` null) was
fully exhausted as of batch 9 -- every one of the 70 pairings checked
across batches 1-9 is listed as connected (see `docs/TODO.md`'s item for
the "confirmed connected, built" roster) or below. A name reappearing in
a future candidate-query re-run isn't automatically new -- check here
first; only real catalog growth (a newly-ingested series) produces
genuinely new candidates.

## Confirmed NOT connected (don't re-research)

- Brandon Sanderson -- Skyward/The Reckoners vs. his own Cosmere
- N.K. Jemisin -- Broken Earth / Inheritance Trilogy / Great Cities (all pairings vs. each other); also Dreamblood vs. Forward Collection
- Ursula K. Le Guin -- Earthsea vs. Hainish Cycle
- Stephen King -- Holly Gibney continuity (Mr. Mercedes -> The Outsider -> If It Bleeds -> Holly) vs. the Dark Tower; The Green Mile vs. the Dark Tower (thematic only)
- Robert Jackson Bennett -- Divine Cities vs. Founders Trilogy vs. Ana and Din Mysteries
- Joe Abercrombie -- Shattered Sea vs. The Devils (distinct from the already-built First Law World)
- Peter F. Hamilton -- Night's Dawn / Commonwealth Saga / Salvation Sequence (3 separate)
- Adrian Tchaikovsky -- Children of Time / Elder Race / Service Model / The Final Architecture / The Tyrant Philosophers (all separate)
- V.E. Schwab -- Monsters of Verity and Villains vs. her own Four Londons
- Timothy Zahn -- Star Wars: The Thrawn Trilogy vs. Star Wars: Thrawn (same protagonist, officially split Legends-vs-Canon, not a true merge -- flagged as a genuinely different case shape if this framing is ever worth revisiting)
- Naomi Novik -- Temeraire vs. The Scholomance
- Arthur C. Clarke -- Rama vs. Space Odyssey
- William Gibson -- Blue Ant / Jackpot / Sprawl (3 separate continuities)
- T. Kingfisher -- Sworn Soldier (What Moves the Dead) vs. her own World of the White Rat
- Mark Lawrence -- Impossible Times vs. The Library Trilogy
- John Scalzi -- Old Man's War / The Interdependency / Lock In / The Dispatcher (4 separate)
- Robert A. Heinlein -- Heinlein's Juveniles (our catalog: just Starship Troopers) vs. Stranger in a Strange Land
- C.S. Lewis -- Chronicles of Narnia vs. The Space Trilogy
- Douglas Adams -- Dirk Gently vs. The Hitchhiker's Guide to the Galaxy
- Michael Crichton -- Jurassic Park vs. The Andromeda Strain
- Dan Simmons -- Hyperion Cantos vs. Ilium
- Martha Wells -- Murderbot Diaries vs. Witch King ("The Rising World"; not the Books of the Raksura)
- Lois McMaster Bujold -- Vorkosigan Saga vs. World of the Five Gods
- Amie Kaufman & Jay Kristoff -- The Aurora Cycle vs. The Illuminae Files
- Jay Kristoff (solo) -- Empire of the Vampire vs. The Nevernight Chronicle
- Ilona Andrews -- Kate Daniels vs. Innkeeper Chronicles
- Neal Shusterman -- Arc of a Scythe vs. Unwind Dystology
- Holly Black -- The Folk of the Air vs. The Charlatan Duology / Book of Night
- Christopher Paolini -- Fractalverse / To Sleep in a Sea of Stars vs. The Inheritance Cycle
- Margaret Atwood -- MaddAddam vs. The Handmaid's Tale
- Brent Weeks -- Night Angel Trilogy vs. Lightbringer
- Becky Chambers -- Wayfarers vs. Monk & Robot
- Tahereh Mafi -- Shatter Me vs. This Woven Kingdom
- James Islington -- Hierarchy/The Will of the Many vs. The Licanius Trilogy
- Marissa Meyer -- Renegades vs. The Lunar Chronicles
- Jennifer Lynn Barnes -- The Inheritance Games vs. The Naturals
- John Gwynne -- The Bloodsworn Saga vs. The Faithful and the Fallen
- Anthony Ryan -- Covenant of Steel vs. Raven's Shadow
- Carissa Broadbent -- Crowns of Nyaxia vs. The War of Lost Hearts
- Danielle L. Jensen -- Saga of the Unfated vs. The Bridge Kingdom
- Mira Grant -- Newsflesh vs. Rolling in the Deep
- Octavia E. Butler -- Earthseed vs. Xenogenesis
- Rachel Gillig -- The Shepherd King vs. The Stonewater Kingdom
- Rebecca Roanhorse -- Between Earth and Sky vs. The Sixth World
- Rebecca Ross -- Elements of Cadence vs. Letters of Enchantment
- Samantha Shannon -- The Bone Season vs. The Roots of Chaos
- Stephen Graham Jones -- The Indian Lake Trilogy vs. The Only Good Indians
- TJ Klune -- Cerulean Chronicles vs. In the Lives of Puppets
- Veronica Roth -- Curse Bearer vs. Divergent

## Ambiguous/thin -- deliberately left unlinked, revisit only on stronger evidence

- Neil Gaiman -- American Gods vs. Neverwhere ("share a car park" per Gaiman himself -- real but too informal to model)
- Laini Taylor -- Daughter of Smoke & Bone vs. Strange the Dreamer (real textual hints + a fan-paraphrased author quote, but no firm primary-sourced confirmation of a currently-merged continuity)

## Naming calls flagged for the repo owner (connection is real, only the universe's display name is a judgment call)

- Philip Pullman -- "Lyra's World" (His Dark Materials + The Book of Dust)
- Marie Lu -- "The Legend Universe" (Legend + Warcross; The Young Elites confirmed part of the same universe per the author but not yet in the catalog)

## Data-quality issues surfaced along the way, NOT fixed by this audit (separate task, likely the `series.status`/`book_count` fix)

- Orson Scott Card's Shadow Saga split across two series rows (`The Shadow Series` and `Enderverse: Publication Order`) that look like one real series
- R.A. Salvatore's `Dark Elf Trilogy` and `Legend of Drizzt` rows look like the same trilogy fragmented across two rows; both also carry obviously-wrong `book_count` values (33, 180)
- Stale/wrong `book_count` values found on: Anthony Ryan's Raven's Shadow (10 vs. real 3), Laini Taylor's Daughter of Smoke & Bone (14 vs. real 3+1), Octavia Butler's Xenogenesis (6 vs. real 3), Rebecca Ross's Elements of Cadence (6 vs. real 2), S.A. Chakraborty's Amina al-Sirafi (3 vs. real 2), Samantha Shannon's The Bone Season (15 vs. a much smaller real count)
