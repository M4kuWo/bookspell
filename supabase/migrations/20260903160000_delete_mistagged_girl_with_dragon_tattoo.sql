-- The Girl with the Dragon Tattoo (Stieg Larsson) was tagged with
-- book_dna.genre = ['sci_fi'] and a full trope/content-warning set, but
-- it's a straight Swedish crime/murder-mystery thriller with zero
-- speculative content (confirmed against its own synopsis) -- a
-- mistagging that let it leak into recommend()'s SFF-scoped results
-- and surface as a "Strong match" on craft/structural fields, caught
-- during a qualitative recommend() review round. Confirmed zero
-- dependent rows in rating_submissions/book_field_confidence and no
-- soft-reference in any rater's data/ratings/*.json file before
-- deleting, per this project's catalog-scope policy (out-of-scope
-- books get deleted once confirmed, not left as permanent dangling
-- rows). Deletes child rows before the books row itself, all scoped
-- by title subselect (never a raw UUID -- see CLAUDE.md).

delete from book_content_warnings
where book_id = (select id from books where title = 'The Girl with the Dragon Tattoo');

delete from book_tropes
where book_id = (select id from books where title = 'The Girl with the Dragon Tattoo');

delete from book_dna
where book_id = (select id from books where title = 'The Girl with the Dragon Tattoo');

delete from books
where title = 'The Girl with the Dragon Tattoo';
