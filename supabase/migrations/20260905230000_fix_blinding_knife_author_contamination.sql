-- The Blinding Knife (Lightbringer #2) author field was contaminated
-- with the audiobook narrator "Simon Vance" appended as a second
-- author -- Simon Vance is a well-known audiobook narrator, not a
-- co-author; Brent Weeks is the sole author. Same recurring pattern
-- CLAUDE.md already tracks (Death Masks/James Marsters earlier this
-- session; Sapkowski/David French before that). Surfaced by the
-- romance_driven Tier 2 audit's batch 3 agent while reviewing this
-- book for an unrelated question -- flagged rather than silently
-- fixed inline, per instructions, then fixed directly here as a small,
-- well-scoped single-book change.
update books
set author = 'Brent Weeks'
where title = 'The Blinding Knife' and author = 'Brent Weeks, Simon Vance';
