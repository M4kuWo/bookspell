-- Only 3 of Sanderson's real Cosmere books (Elantris, Tress of the
-- Emerald Sea, Warbreaker) were actually linked to the existing "The
-- Cosmere" universe row -- Mistborn (both eras) and the entire
-- Stormlight Archive, arguably the two most central Cosmere series,
-- weren't linked at all. Separately, a DUPLICATE "The Cosmere" series
-- row existed (distinct from the universe row) holding Arcanum
-- Unbounded and Sixth of the Dusk -- same book_count-from-raw-Hardcover
-- bug as everywhere else (45, see 20260908000000's root-cause writeup).
--
-- Per book-dna.md's own universe/series/book design: a book can belong
-- to BOTH a series and a universe at once (Mistborn/Stormlight books
-- keep their existing series_id, universe_id is additive), or to a
-- universe with NO series at all (Arcanum Unbounded/Sixth of the Dusk,
-- matching how Elantris/Tress/Warbreaker are already modeled).
--
-- Deliberately does NOT include every book in the "Secret Projects"
-- series: The Frugal Wizard's Handbook for Surviving Medieval England
-- is explicitly NOT part of the Cosmere (a separate, unrelated
-- standalone) despite sharing a series grouping with two real Cosmere
-- entries (Isles of the Emberdark, The Sunlit Man) -- checked
-- individually, not assumed from the series as a whole.

update books set universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where title in (
  'The Emperor''s Soul', 'The Hope of Elantris',
  'Yumi and the Nightmare Painter',
  'Mistborn: Secret History', 'Mistborn: The Final Empire',
  'The Eleventh Metal', 'The Hero of Ages', 'The Well of Ascension',
  'Shadows of Self', 'The Alloy of Law', 'The Bands of Mourning', 'The Lost Metal',
  'Isles of the Emberdark', 'The Sunlit Man',
  'Dawnshard', 'Edgedancer', 'Oathbringer', 'Rhythm of War',
  'The Way of Kings', 'Wind and Truth', 'Words of Radiance'
) and author = 'Brandon Sanderson';

-- Arcanum Unbounded / Sixth of the Dusk: move off the duplicate
-- "Cosmere" series onto the real universe, matching the
-- Elantris/Tress/Warbreaker standalone-in-universe pattern.
update books set universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e', series_id = null
where title in ('Arcanum Unbounded: The Cosmere Collection', 'Sixth of the Dusk')
  and author = 'Brandon Sanderson';

-- Now safe to remove: the duplicate series row has zero books left
-- referencing it (verified in the same session this migration was
-- written, not assumed). The real Cosmere lives only in `universe`,
-- so no legitimate `series` row named this should exist at all.
delete from series where name = 'The Cosmere';
