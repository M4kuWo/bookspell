-- Resolves an open scope question raised 2026-09-03 (docs/project-log.md:
-- "whether comics/graphic novels are in v1 scope at all") that was left
-- unresolved rather than decided either way -- the schema has no format/
-- medium field distinguishing visual comics from prose, and several fields
-- (page/word-count-driven pacing signals in particular) mean something
-- different for a comic than for a novel. The repo owner has now decided:
-- graphic novels are OUT of v1 scope, same category as the existing
-- non-SFF-genre out-of-scope triage.
--
-- Despite the question being flagged as open (not silently resolved), two
-- more graphic novels were tagged as if the answer were "in scope" during
-- normal batch tagging after that entry was written (Saga, Vol. 2 and The
-- Sandman, Vol. 1, both following the precedent of an already-tagged Saga,
-- Vol. 1 without re-checking the still-open question first) -- removing
-- all three's Book DNA here, not just the two added since.
--
-- Scoped per book via title subselects, never a blanket delete. Leaves the
-- `books` rows themselves in place (untagged, not deleted) -- these are
-- genuine SFF works, just out of scope for this schema/medium, the same
-- treatment as any other confirmed-out-of-scope-but-not-deleted case.
-- Checked before writing this migration: no other comics/graphic novels
-- are currently tagged or sitting untagged in the catalog under this same
-- gap (searched title patterns like "Vol." / "Volume" for anything
-- missed -- only these three matched, plus La Belle Sauvage which is a
-- genuine prose novel despite "Volume One" in its subtitle).

delete from book_tropes
where book_id = (select id from books where title = 'Saga, Vol. 1');
delete from book_content_warnings
where book_id = (select id from books where title = 'Saga, Vol. 1');
delete from book_field_confidence
where book_id = (select id from books where title = 'Saga, Vol. 1');
delete from book_dna
where book_id = (select id from books where title = 'Saga, Vol. 1');

delete from book_tropes
where book_id = (select id from books where title = 'Saga, Vol. 2');
delete from book_content_warnings
where book_id = (select id from books where title = 'Saga, Vol. 2');
delete from book_field_confidence
where book_id = (select id from books where title = 'Saga, Vol. 2');
delete from book_dna
where book_id = (select id from books where title = 'Saga, Vol. 2');

delete from book_tropes
where book_id = (select id from books where title = 'The Sandman, Vol. 1: Preludes & Nocturnes');
delete from book_content_warnings
where book_id = (select id from books where title = 'The Sandman, Vol. 1: Preludes & Nocturnes');
delete from book_field_confidence
where book_id = (select id from books where title = 'The Sandman, Vol. 1: Preludes & Nocturnes');
delete from book_dna
where book_id = (select id from books where title = 'The Sandman, Vol. 1: Preludes & Nocturnes');
