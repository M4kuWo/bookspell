-- Shared-universe linking audit, batch 4 (docs/TODO.md P2 item).
-- Two new universes built, plus a Cosmere data-gap fix. Full evidence
-- trail in docs/project-log.md's 2026-09-12 batch-4 entry.

-- 1) "Riordanverse" -- Rick Riordan's Percy Jackson and the Olympians,
-- The Heroes of Olympus, The Kane Chronicles, Magnus Chase and the Gods
-- of Asgard, and The Trials of Apollo. Confirmed via real, structural
-- crossovers, not mere thematic similarity: three official published
-- crossover novellas (The Son of Sobek, The Staff of Serapis, The Crown
-- of Ptolemy, collected in Demigods & Magicians) put Percy/Annabeth and
-- Carter/Sadie Kane in the same scenes together; Magnus Chase is
-- established as Annabeth Chase's cousin with Percy appearing directly
-- in the Magnus Chase books; The Trials of Apollo is a direct
-- continuation set at Camp Half-Blood featuring the same demigod cast.
-- No official publisher/author-coined umbrella name exists, so per the
-- established naming policy (search for a real, widely-used fan term
-- before inventing one) -- "Riordanverse" is confirmed genuine and
-- widely used (TV Tropes' own "Riordanverse (Franchise)" page, multiple
-- independent fan-blog reading-order guides, fan-wiki usage), same
-- fan-coined-but-real-term precedent already accepted for Enderverse
-- and Maasverse.
insert into universe (name)
select 'Riordanverse' where not exists (select 1 from universe where name = 'Riordanverse');

update series set universe_id = (select id from universe where name = 'Riordanverse')
where name = 'Percy Jackson and the Olympians';

update series set universe_id = (select id from universe where name = 'Riordanverse')
where name = 'The Heroes of Olympus';

update series set universe_id = (select id from universe where name = 'Riordanverse')
where name = 'The Kane Chronicles';

update series set universe_id = (select id from universe where name = 'Riordanverse')
where name = 'Magnus Chase and the Gods of Asgard';

update series set universe_id = (select id from universe where name = 'Riordanverse')
where name = 'The Trials of Apollo';

-- 2) "The Four Londons" -- V.E. Schwab's Shades of Magic trilogy and its
-- direct sequel trilogy, Threads of Power. Confirmed connected: Threads
-- of Power is explicitly set seven years after A Conjuring of Light, in
-- the same Four-Londons setting, with the same protagonists (Kell,
-- Lila, Alucard) returning. Named after the real in-world setting term
-- used throughout the books and fandom for the four parallel-world
-- Londons (Red/White/Grey/Black, connected by Antari-opened doors) --
-- same naming pattern as Westeros/Abeth/Middle-earth (a real in-world
-- place name), and avoids colliding with either trilogy's own series
-- name the way "Shades of Magic" or "Threads of Power" alone would.
--
-- Checked and confirmed NOT part of this universe, or connected to each
-- other: Schwab's Monsters of Verity duology and Villains
-- trilogy/duology. No structural connection found to Shades of Magic/
-- Threads of Power or between each other -- distinct settings (a
-- monster-plagued city vs. a contemporary EO/superpower world vs. the
-- Four Londons), distinct casts, no crossovers or shared characters
-- identified in any source checked. Left unlinked.
insert into universe (name)
select 'The Four Londons' where not exists (select 1 from universe where name = 'The Four Londons');

update series set universe_id = (select id from universe where name = 'The Four Londons')
where name = 'Shades of Magic';

update series set universe_id = (select id from universe where name = 'The Four Londons')
where name = 'Threads of Power';

-- 3) Cosmere series-level gap fix (same shape as the Elantris fix in
-- 20260911250000) -- these two series' books are already individually
-- book-level Cosmere-tagged (books.universe_id), but the series rows
-- themselves never got series.universe_id set:
--   - "Hoid's Travails" (Yumi and the Nightmare Painter) -- a mainline
--     Cosmere Secret Project starring Hoid, already Cosmere-tagged at
--     the book level.
--   - "The Mistborn Saga" (Allomancer Jak and the Pits of Eltania) --
--     confirmed Cosmere/Mistborn Era Two content (Coppermind, 17th
--     Shard, and Sanderson's own official Cosmere-collections page all
--     place it in-world with the Wax & Wayne era; collected in Arcanum
--     Unbounded, The Cosmere Collection).
-- Not touched: "Legion" (standalone thriller, correctly un-linked, no
-- Cosmere connection) and "Secret Projects" (genuinely mixed -- 2 of 3
-- books are Cosmere, 1 is not -- correctly left without a series-level
-- universe_id, per the existing note from batch 2's Elantris fix).
update series set universe_id = (select id from universe where name = 'The Cosmere')
where name = 'Hoid''s Travails';

update series set universe_id = (select id from universe where name = 'The Cosmere')
where name = 'The Mistborn Saga';
