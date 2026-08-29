-- books.author had gotten contaminated at step 03 ingestion time --
-- Hardcover's "contributions" field mixes actual authors with
-- narrators, illustrators, translators, and editors, and the
-- ingestion script pulled it straight through unfiltered. Confirmed
-- example: Words of Radiance's author field read "Brandon Sanderson,
-- Michael Kramer, Kate Reading" -- the latter two are the audiobook's
-- narrators, not co-authors. Add a proper narrators field rather than
-- just deleting the names outright, since real narrator data has
-- independent value (surfaced separately in the roadmap: full
-- audiobook-edition data including runtime/narrator per edition,
-- including GraphicAudio dramatizations). This migration only fixes
-- the one confirmed case; a full narrator-data pass is future work.

alter table books add column narrators text[];

update books set author = 'Brandon Sanderson', narrators = array['Michael Kramer', 'Kate Reading']
where title = 'Words of Radiance';
