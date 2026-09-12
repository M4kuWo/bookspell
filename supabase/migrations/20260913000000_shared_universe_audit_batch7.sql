-- Shared-universe linking audit, batch 7 (docs/TODO.md P2 item).
-- One new universe built. Full evidence trail in docs/project-log.md's
-- 2026-09-12 batch-7 entry.

-- "Wizarding World" -- J.K. Rowling's Harry Potter and Hogwarts Library.
-- Confirmed connected, and about as structurally explicit a case as this
-- audit has found: "Hogwarts Library" (our catalog's series row for
-- Fantastic Beasts and Where to Find Them / Quidditch Through the Ages /
-- The Tales of Beedle the Bard) isn't a separate fictional world at all --
-- these are presented as genuine in-universe Hogwarts textbooks. Fantastic
-- Beasts carries a real foreword from Albus Dumbledore describing it as "an
-- approved textbook at Hogwarts School of Witchcraft and Wizardry," and
-- both Fantastic Beasts and Quidditch Through the Ages are referenced as
-- books Hogwarts students actually use within the main seven-book series
-- itself; The Tales of Beedle the Bard is the book Dumbledore bequeaths to
-- Hermione in Deathly Hallows and which she reads from within the story.
-- Named after the real, official franchise umbrella term J.K. Rowling and
-- Warner Bros. use (harrypotter.com's own site is "the official home of
-- Harry Potter, Fantastic Beasts, and the Wizarding World") -- not
-- invented, no naming-policy question.
insert into universe (name)
select 'Wizarding World' where not exists (select 1 from universe where name = 'Wizarding World');

update series set universe_id = (select id from universe where name = 'Wizarding World')
where name = 'Harry Potter';

update series set universe_id = (select id from universe where name = 'Wizarding World')
where name = 'Hogwarts Library';
