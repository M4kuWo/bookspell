-- Catalog-wide shared-universe linking audit, batch 9 (CLDA session, 2026-09-13).
-- 15 new-candidate authors researched this batch (Anthony Ryan, Carissa
-- Broadbent, Danielle L. Jensen, Laini Taylor, Marie Lu, Mira Grant,
-- Octavia E. Butler, Rachel Gillig, Rebecca Roanhorse, Rebecca Ross, S. A.
-- Chakraborty, Samantha Shannon, Stephen Graham Jones, TJ Klune, Veronica
-- Roth). 2 confirmed genuinely connected per the audit's strict structural-
-- connection bar (a cameo/thematic echo is not enough); 12 confirmed NOT
-- connected (no action, no row here, see docs/TODO.md batch 9 entry for
-- full per-pairing evidence); 1 (Laini Taylor, Daughter of Smoke & Bone vs
-- Strange the Dreamer) is a real authorial gesture toward a shared
-- multiverse but not a confirmed merged continuity today -- deliberately
-- NOT linked, flagged as ambiguous/thin, same treatment as the earlier
-- Gaiman American Gods/Neverwhere case.

-- 1) S. A. Chakraborty -- "Daevabad": The Adventures of Amina al-Sirafi
-- (+ its 2026 sequel The Tapestry of Fate) is confirmed set in the same
-- djinn/marid world and cosmology as The Daevabad Trilogy, centuries
-- before The City of Brass, with intentional Daevabad-reader Easter eggs
-- (multiple independent review sources: NPR, Kirkus, Goodreads editorial
-- coverage). Named directly after the real in-world city/place itself
-- (matching the Westeros/Abeth/Elan pattern) rather than the "Daevabad
-- universe" review-copy phrase, since that phrase's scope (whether it's
-- meant to include the Amina sub-series specifically, vs. just the
-- Trilogy + its companion story collection) wasn't independently
-- confirmed across sources -- the bare place name sidesteps that
-- ambiguity and needs no naming-policy flag.
insert into universe (name)
select 'Daevabad' where not exists (select 1 from universe where name = 'Daevabad');

update series set universe_id = (select id from universe where name = 'Daevabad')
where name = 'Amina al-Sirafi';

update series set universe_id = (select id from universe where name = 'Daevabad')
where name = 'The Daevabad Trilogy';

-- 2) Marie Lu -- "The Legend Universe": direct, first-person, primary-
-- sourced author confirmation (Marie Lu, r/IAmA Reddit AMA, 2018):
-- "I have this scheme in my head where Legend and The Young Elites are
-- actually set in the same universe. Warcross is also part of that
-- universe. Someday, I will explain everything." This explicitly names
-- Warcross alongside Legend as one shared universe -- comparable in
-- directness to the Garber/Goodreads-Q&A precedent already built as
-- Meridian Empire. (The Young Elites is also named in that same quote
-- but isn't in our catalog at all currently -- checked live, no series
-- or books under that name exist yet, so nothing further to link; a
-- future ingestion of The Young Elites should link it here too.)
-- NAMING FLAG for the repo owner, same shape as Lyra's World: no
-- official franchise term and no widely-used multi-source fan term
-- turned up (checked "Legendverse"/"Luniverse"/"Marieverse" -- none
-- established), and no single confirmed in-world place name spans all
-- three properties either (Legend's setting is "the Republic"; Warcross
-- and Young Elites have their own distinct named settings) -- fan-
-- documented Antarctica/flood parallels between Legend and Warcross
-- exist but were flagged by the researching agent as speculation, not
-- canon-confirmed, so not used as the basis for the name. "The Legend
-- Universe" (series-title + generic-suffix fallback, same shape as "The
-- Broken Empire World") is this session's own naming call, not a
-- confirmed brand -- please sanity-check, easy to rename later.
insert into universe (name)
select 'The Legend Universe' where not exists (select 1 from universe where name = 'The Legend Universe');

update series set universe_id = (select id from universe where name = 'The Legend Universe')
where name = 'Legend';

update series set universe_id = (select id from universe where name = 'The Legend Universe')
where name = 'Warcross';
