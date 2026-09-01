-- Data-quality fix: "The Warded Man" was ingested with its Hardcover
-- subtitle baked into the title field ("The Warded Man: Book One of The
-- Demon Cycle"), unlike every other book in the series (The Desert Spear,
-- The Daylight War, etc.) which stores just the bare title. Reported by
-- the repo owner while cross-referencing his own ratings against the
-- catalog. Scoped to this single row (never a blanket UPDATE).
update books
set title = 'The Warded Man'
where title = 'The Warded Man: Book One of The Demon Cycle'
  and author = 'Peter V. Brett';
