-- Deletes 15 more out-of-scope books (2026-09-03, round 2): the
-- "genuinely uncertain" batch from the out-of-scope triage, resolved by
-- the repo owner book-by-book after a brief premise summary each (see
-- docs/project-log.md). Two titles from that same uncertain batch --
-- Platform Decay (confirmed Murderbot Diaries #8) and The Everlasting
-- (confirmed genuine time-travel SF) -- were confirmed IN scope instead
-- and are NOT deleted here; they stay untagged, ready for the next
-- tagging pass.
-- Same verification as round 1: zero dependent rows in book_dna/
-- book_tropes/book_content_warnings/book_field_confidence/
-- rating_submissions for all 15 (confirmed before writing this).
-- Individually-scoped statements, one per book.

delete from books where title = 'Lights Out';
delete from books where title = 'Yesteryear';
delete from books where title = 'After Dark';
delete from books where title = 'Earthlings';
delete from books where title = 'Ficciones';
delete from books where title = 'Her Body and Other Parties';
delete from books where title = 'Life After Life';
delete from books where title = 'Remarkably Bright Creatures';
delete from books where title = 'Steppenwolf';
delete from books where title = 'The House of the Spirits';
delete from books where title = 'The Last House on Needless Street';
delete from books where title = 'The Naked Lunch';
delete from books where title = 'The Underground Railroad';
delete from books where title = 'The Wind-Up Bird Chronicle';
delete from books where title = 'When We Cease to Understand the World';
