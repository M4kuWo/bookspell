-- execution-DNA trope sweep, worldbuilding_woven_into_narrative batch 1
-- of the candidate pool (see .claude/skills/tag-catalog-batch/
-- SKILL.md Step 0). 17 well-known dense-worldbuilding books reviewed
-- for real discourse specifically about HOW lore is delivered
-- (character discovery/dialogue vs. narrator exposition) -- distinct
-- from worldbuilding_density (how much lore exists).
--
-- Also closes the real gap the skill flagged: this trope previously had
-- NO negative counterpart, so it could only ever reinforce a match,
-- never catch a mismatch. Found 4 real, well-documented catalog books
-- whose own reviews describe the opposite delivery style -- narrator/
-- footnote-based exposition rather than woven-in discovery -- clearing
-- the "2+ real books, changes what gets recommended" bar this project
-- requires for new vocabulary. Adding `worldbuilding_via_exposition_dump`
-- as the negative counterpart, same group as its positive sibling.
insert into tropes (id, group_name, spoiler) values
  ('worldbuilding_via_exposition_dump', 'setting_worldbuilding', false)
on conflict (id) do nothing;

-- worldbuilding_woven_into_narrative --------------------------------

-- "dropped right into the world with hardly any exposition... words
-- and actions filling in the gaps" -- direct, specific.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Dune', 'Frank Herbert')
on conflict do nothing;

-- "dodged traps of excessive infodumped worldbuilding effortlessly" --
-- direct, explicit contrast against infodumping.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Fifth Season', 'N.K. Jemisin')
on conflict do nothing;

-- "thrown in the deep end," no explanatory exposition, "discover the
-- truth alongside her" -- the mechanism (zero narrator info-dumps,
-- pure in-scene discovery) is confirmed even though the resulting
-- confusion is separately, genuinely disputed as a quality/execution
-- matter -- those are different axes.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Gideon the Ninth', 'Tamsyn Muir')
on conflict do nothing;

-- "natural and accessible... without overwhelming exposition,"
-- "name-it and drop-it" approach specifically described and named by
-- multiple reviewers.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Game of Thrones', 'George R.R. Martin')
on conflict do nothing;

-- "rises up around the reader without you even realising," "happened
-- naturally and cleverly... had to really think about it to spot
-- where it was being done" -- clean, specific, direct evidence.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Poppy War', 'R.F. Kuang')
on conflict do nothing;

-- "avoids over-exposition," "not overwhelming," built through history,
-- language, and character rather than told outright.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Memory Called Empire', 'Arkady Martine')
on conflict do nothing;

-- "very little exposition," worldbuilding via "small hints and
-- tidbits" picked up through character interaction rather than told.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Blade Itself', 'Joe Abercrombie')
on conflict do nothing;

-- "delivers necessary exposition when the reader is ready for it and
-- never before," "just enough information through dialogue... without
-- writing pages of exposition" -- direct and specific to this book.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Way of Kings', 'Brandon Sanderson')
on conflict do nothing;

-- Same pattern as Gideon the Ninth: "thrown into the middle of a war...
-- already understand a world the reader does not" -- overwhelming
-- because there is no narrator exposition at all, not because there's
-- too much of it. The mechanism is woven/discovery-based even where
-- readers found the result disorienting.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Gardens of the Moon', 'Steven Erikson')
on conflict do nothing;

-- Genuinely disputed: "presents everything when and where you need it,
-- not overwhelmed" and "worldbuilding woven throughout" directly
-- contradicted by "pages of exposition regarding the finer points of
-- Allomancy... lectured about the magic system." Real split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Mistborn: The Final Empire', 'Brandon Sanderson')
on conflict do nothing;

-- Genuinely disputed within the SAME source: "laid out implicitly,
-- released in casual observations" vs. explicit acknowledgment that
-- "by chapter 2, clear-cut explanations arrive when the narrator
-- spells out information" and the author "deliberately" chooses to
-- tell rather than show at points.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ancillary Justice', 'Ann Leckie')
on conflict do nothing;

-- worldbuilding_via_exposition_dump (new, negative counterpart) ------

-- Extremely well-documented pattern: "endless pages of expository
-- dialogue," "exposition-heavy dialogue," most exposition delivered
-- via one character explaining things to another ("eavesdropping on
-- the clever guy"), plus literal embedded exposition text (quotes from
-- the in-world Encyclopedia Galactica). One of the clearest possible
-- examples of this device.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Foundation', 'Isaac Asimov')
on conflict do nothing;

-- Well-documented, repeated criticism: footnotes "insert too much
-- direct information in a way that doesn't feel natural," "the text
-- doesn't trust the reader," "just an opportunity to inject more
-- historical or linguistic facts" -- a formalized, named
-- exposition-delivery device distinct from in-scene discovery.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Babel, or The Necessity of Violence: An Arcane History of the Oxford Translators'' Revolution', 'R.F. Kuang')
on conflict do nothing;

-- Direct, specific: flashbacks used "to explain context that could
-- have been inferred," a character "appears and interrupts the main
-- story just to explain what it is, breaking narrative flow,"
-- described by multiple reviewers as "mini exposition dumps."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Lies of Locke Lamora', 'Scott Lynch')
on conflict do nothing;

-- Weaker/mixed: real, specific evidence for BOTH directions in the
-- same source (dialogue/description praised as exposition-free
-- alongside "extensive exposition, particularly historical and
-- genealogical information... overwhelming and tedious"). Tagged at
-- low confidence rather than the clean 0.6 the three books above earned.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Fellowship of the Ring', 'J.R.R. Tolkien')
on conflict do nothing;
