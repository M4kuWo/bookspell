-- Builds "Foundation universe" as a real `universe` row, linking Isaac
-- Asimov's Foundation (8 books) and Robot (3 books) series -- part of
-- the catalog-wide shared-universe linking audit (docs/TODO.md).
--
-- Confirmed via search, not assumed from "same author, similar genre":
-- Asimov explicitly merged these into one continuity starting with
-- Foundation's Edge, via R. Daneel Olivaw (the Robot series' central
-- character) being retconned as the secret founder of the Galactic
-- Empire and the hidden guiding hand behind Hari Seldon's psychohistory
-- -- a real, plotted, author-confirmed structural connection, not a
-- cameo/easter-egg reference (see the same session's Gaiman decision
-- below for the contrast).
--
-- Naming: "Foundation universe" is the real, encyclopedic term for this
-- merged continuity (matches the Wikipedia article title), not an
-- invented label.
--
-- Deliberately NOT linking Neil Gaiman's American Gods/Neverwhere
-- (also candidates from this audit batch) -- confirmed via search and
-- repo owner judgment that the connection there is Gaiman's own
-- admittedly loose, non-committal aside ("I think so, yes. Or at least
-- they all share a car park"), the same tier as Stephen King's Man in
-- Black/Crimson King motif recurring across his catalog (e.g. From a
-- Buick 8's cameo) without those books being "the same universe" as
-- The Dark Tower. A real, reusable distinction for the rest of this
-- audit: a cameo/thematic reference isn't enough on its own, it needs
-- an actual structural connection (a merged/explicit continuity, or a
-- recurring protagonist across books) the way Foundation/Robot and
-- Mark Lawrence's Broken Empire/Red Queen's War both have.
--
-- Also confirmed NOT connected this same session, despite superficially
-- looking like single-author multi-series candidates -- no action
-- needed, logged so these aren't re-investigated later: Brandon
-- Sanderson's Skyward/The Reckoners (both explicitly confirmed separate
-- from the Cosmere and from each other, per Sanderson's own FAQ), all
-- 3 of N.K. Jemisin's major series (Broken Earth/Inheritance
-- Trilogy/Great Cities -- confirmed independent, separate worlds), and
-- Ursula K. Le Guin's Earthsea/Hainish Cycle (confirmed via Le Guin's
-- own words: "Earthsea definitely does not exist in the same universe
-- as the Hainish").

insert into universe (name)
select 'Foundation universe' where not exists (select 1 from universe where name = 'Foundation universe');

update series set universe_id = (select id from universe where name = 'Foundation universe')
where name = 'Foundation';

update series set universe_id = (select id from universe where name = 'Foundation universe')
where name = 'Robot';
