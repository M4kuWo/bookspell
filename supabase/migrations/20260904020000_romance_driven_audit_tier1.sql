-- Tier 1 of the romance_driven catalog audit (tag-catalog-batch skill,
-- Step 0, 2026-09-04): reviewed all 20 books currently tagged
-- romance_heat_frequency=frequent + romance_heat_intensity=explicit but NOT
-- yet drive=romance_driven. Each judged individually against the skill's
-- test ('is the central relationship what the book is ABOUT, or a strong
-- supporting thread inside a plot/character-driven story') -- not a blanket
-- filter-and-replace. 12 reclassified below; 8 confirmed correctly unchanged
-- (2 of those -- Gravity's Rainbow, Stranger in a Strange Land -- were
-- already-resolved calibration anchors, not re-touched here; the other 6 are
-- logged in docs/project-log.md with per-book reasoning, not repeated as SQL
-- since there's nothing to update).
--
-- Also fully reviewed Tier 3 (romance-structural trope present, low/no heat --
-- catches 'clean' romantasy the heat filter misses): 19 books, zero
-- reclassifications warranted (Carmilla, Mistborn, Oathbringer, etc. all have
-- real relationship threads but aren't romance-genre in the sense this field
-- captures) -- a legitimate 'nothing to do here' outcome, not a miss, logged
-- in docs/project-log.md.
--
-- Tier 2 (~173 books, occasional heat) not attempted this pass -- left for a
-- future session per the skill's 'as budget allows' guidance.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

-- A Court of Frost and Starlight: Holiday interlude novella; structure is entirely relationship-focused (Feyre/Rhys, seeding Nesta/Cassian, Elain/Lucien) with negligible external plot.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'A Court of Frost and Starlight');

-- A Court of Mist and Fury: The book where the Feyre/Rhysand relationship becomes the actual narrative engine (the marriage-bargain dynamic, Under the Mountain trauma processed through it, the pivot away from the Tamlin relationship) -- Hybern's threat is present but secondary to this until the final chapters.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'A Court of Mist and Fury');

-- A Court of Silver Flames: Nesta's healing arc IS her romance with Cassian -- the book has very little plot beyond their relationship and the Valkyrie training subplot that serves it.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'A Court of Silver Flames');

-- A Court of Thorns and Roses: Beauty-and-the-Beast structure: Feyre's captivity-to-romance with Tamlin, then reveal, is the book's actual engine; the Amarantha trial exists to resolve that relationship, not the reverse.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'A Court of Thorns and Roses');

-- Bride: Paranormal romance marketed and structured as one: a political vampire/werewolf marriage is the entire plot.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'Bride');

-- Fourth Wing: Violet/Xaden's enemies-to-lovers arc is the book's actual emotional and narrative core; the war college/dragon-bonding plot is the backdrop it plays out against.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'Fourth Wing');

-- Iron Flame: Continues Fourth Wing's structure -- the Violet/Xaden betrayal-and-trust arc remains the central engine even as external stakes (rebellion, venin threat) escalate.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'Iron Flame');

-- One Last Stop: Contemporary/magical-realism romance novel -- August falling for Jane on the subway is literally the plot, not a subplot inside something else.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'One Last Stop');

-- Outlander: Claire/Jamie's relationship is the series' foundational engine across its entire history-spanning structure; the Jacobite politics are the setting it plays out in.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'Outlander');

-- Quicksilver: Fae romantasy, enemies-to-lovers structure -- explicitly romance-genre, central relationship drives the plot.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'Quicksilver');

-- The Serpent and the Wings of Night: Blood-tournament survival plot is real, but the Oraya/Raihn relationship is the book's actual reader-facing engine, consistent with the same author's already-confirmed Daughter of No Worlds.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'The Serpent and the Wings of Night');

-- When the Moon Hatched: Dragon-rider romantasy; Raeve/Ash's relationship is the central engine, world/dragon-war elements are the setting.
update book_dna set drive = 'romance_driven' where book_id = (select id from books where title = 'When the Moon Hatched');

