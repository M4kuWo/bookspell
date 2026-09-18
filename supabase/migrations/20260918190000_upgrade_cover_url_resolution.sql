-- Follow-up to 20260918180000_fix_broken_cover_url_books_path.sql: the
-- repo owner pointed out (correctly) that the emergency replacement
-- URLs picked there were likely thumbnail-resolution, not full cover
-- art. Confirmed directly: the original picks ranged 323x500-500x409
-- pixels, while several of the SAME books have other Hardcover
-- editions with genuinely high-resolution scans (up to 1691x2560) that
-- were simply never checked against at the time (the first non-403
-- candidate was picked, not the best one). Re-queried every affected
-- book's full edition list, sorted by width*height, and picked the
-- largest one that ALSO returns a real HTTP 200 -- resolution metadata
-- alone isn't trustworthy here, since some high-resolution-looking
-- edition records still point at the same dead `/books/<id>/...` path
-- (e.g. one Kingdom of Copper edition claims 1600x2416 but is the
-- exact same 403ing URL fixed in the prior migration).
--
-- The Gunslinger is NOT touched here -- its prior fix (1400x1400) was
-- already the best real option found for that book.
-- Winter's best available option across ALL of Hardcover's editions
-- for this book is still only 500x409 -- not a meaningful upgrade from
-- before, but included for completeness since it IS the genuine best.

update books set cover_url = 'https://assets.hardcover.app/editions/31450239/5692220072002716.jpg', updated_at = now()
where title = 'The Desert Spear' and author = 'Peter V. Brett';

update books set cover_url = 'https://assets.hardcover.app/edition/32257918/b1439989-b598-46e6-97af-6f6d4094a2b1.jpg', updated_at = now()
where title = 'The Girl with the Dragon Tattoo' and author = 'Stieg Larsson';

update books set cover_url = 'https://assets.hardcover.app/edition/31484503/1c0ff1c7fb3a3eb4a022e05c433b63826b8fceda.jpeg', updated_at = now()
where title = 'Winter' and author = 'Marissa Meyer';

update books set cover_url = 'https://assets.hardcover.app/external_data/4248330/b90adb3cb92f1a5e35fc3fc6aeef442dcbf81d93.jpeg', updated_at = now()
where title = 'Ignite Me' and author = 'Tahereh Mafi';

update books set cover_url = 'https://assets.hardcover.app/external_data/4232669/4ebf8b51d277300509b0f6a4f75875b20d31e6c5.jpeg', updated_at = now()
where title = 'The Kingdom of Copper' and author = 'S. A. Chakraborty';

update books set cover_url = 'https://assets.hardcover.app/editions/31450227/2206411719887838.jpg', updated_at = now()
where title = 'Mortal Engines' and author = 'Philip Reeve';
