-- External reader feedback (2026-08-31): Empire of Silence tagged
-- first_contact, but the narrative begins well after the human-Cielcin
-- war has been established/ongoing for a long time -- it doesn't depict
-- the actual initial encounter. mutual_human_alien_war (already tagged)
-- correctly captures the ongoing conflict; first_contact specifically
-- requires depicting the initial-encounter narrative beat itself, which
-- this book doesn't. Confirmed against the book's actual plot, not just
-- taking the report at face value.
--
-- Possible broader pattern flagged for a future audit, not fixed here:
-- a handful of other first_contact-tagged books are borderline (e.g.
-- sequels in an already-first-contact-established universe) -- see
-- project-log.md 2026-08-31 for the full list reviewed.

delete from book_tropes
where trope_id = 'first_contact'
  and book_id = (select id from books where title = 'Empire of Silence');
