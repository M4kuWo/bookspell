-- Correction to 20260908000000: "First Law World" (Best Served
-- Cold/The Heroes/Red Country) was set to book_count=3, matching how
-- many of its standalones are currently in OUR catalog -- wrong
-- standard to use. The repo owner caught it: there are 4 real published
-- standalones in that continuity (the 3 above plus Sharp Ends, a short
-- story collection), we just haven't ingested Sharp Ends yet. book_count
-- should reflect the real-world series length regardless of what we've
-- tagged so far -- confirmed Sharp Ends isn't in `books` at all (a
-- separate ingestion-scope question, not resolved by this migration).

update series set book_count = 4
where name = 'First Law World';
