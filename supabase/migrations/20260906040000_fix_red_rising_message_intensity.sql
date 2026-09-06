-- Red Rising was tagged message_intensity: moderate, but the repo
-- owner's own detailed, first-hand explanation of why he hated the
-- book ("felt like it was trying to teach you that all of this is
-- wrong... naive, childish and unrealistic") describes a heavy-handed
-- anti-violence/assimilationist message, not a moderate one -- about as
-- strong evidence as this project gets for correcting a subjective
-- field, since it's the actual target reader's own testimony, not an
-- inferred read. See docs/project-log.md's 2026-09-06 entry for the
-- full reasoning and its connection to the sci-fi/revenge cross-genre
-- pooling investigation this surfaced from.
update book_dna d
set message_intensity = 'heavy_handed'
from books b
where d.book_id = b.id
  and b.title = 'Red Rising'
  and b.author = 'Pierce Brown'
  and d.message_intensity = 'moderate';
