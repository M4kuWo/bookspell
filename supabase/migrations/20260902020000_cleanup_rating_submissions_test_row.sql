-- Removes the repo owner's own manual test submission while trying out
-- tools/rate-books/ live (rater_name 'test', a single row) -- not a real
-- submission, confirmed by the repo owner directly. Same cleanup pattern
-- as 20260901230200, scoped tightly (rater_name AND book_title) rather
-- than a bare rater_name match, since 'test' is generic enough that a
-- future real tester could plausibly reuse it.
delete from rating_submissions where rater_name = 'test' and book_title = 'The Eye of the World';
