-- Completes a real gap left by the 2026-09-08 Cosmere universe-linking
-- fix: that fix set `universe_id` correctly on individual BOOKS (The
-- Emperor's Soul, The Hope of Elantris) but never on the `Elantris`
-- SERIES row itself. Confirmed safe (not mixed like Secret Projects
-- below): both of Elantris's 2 books are already Cosmere-tagged at the
-- book level, so the series as a whole is cleanly 100% Cosmere.
--
-- Deliberately NOT touching "Secret Projects" the same way -- checked
-- directly and it's a genuinely MIXED series (The Sunlit Man/Isles of
-- the Emberdark are Cosmere, The Frugal Wizard's Handbook for Surviving
-- Medieval England is deliberately excluded per the original 2026-09-08
-- decision) -- setting a series-level universe_id there would wrongly
-- imply blanket membership for a book that isn't part of the Cosmere.
-- Already-correct as null; not a bug to fix.

update series set universe_id = (select id from universe where name = 'The Cosmere')
where name = 'Elantris';
