-- Two real cover-image defects CODX found during its Task 16 QA pass
-- (docs/codx-reports/2026-09-22-post-round5-qa.md, landed as
-- docs/codx-reviews/2026-09-22-post-round5-qa.md) -- both self-hosted
-- successfully (HTTP 200, decoded fine) so the 2026-09-22 backfill's own
-- URL-health check couldn't have caught either one. Both are genuine
-- content/identity or quality defects, not broken links.

-- "Just One Damned Thing After Another" (Jodi Taylor) was showing a
-- 10-book Chronicles of St Mary's BOX SET cover, not the individual
-- novel -- confirmed by viewing the actual image, not just trusting the
-- report. Turns out to be Hardcover's own primary listing image for
-- this book id, not a CLDA/CLDO selection error. Replacement sourced
-- from a different edition on the same Hardcover book id (326x500,
-- correct individual-book cover, visually confirmed).
update books
set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/cc009412-5e14-4b7e-afbf-9a2679961531-fix.jpg'
where hardcover_id = 428569;

-- "War Storm" (Victoria Aveyard) had the correct cover but at only
-- 98x150px -- visibly blurred at real display size. Replaced with a
-- 500x500 edition image (an audiobook-edition cover, but same title/
-- author/art, clearly legible) sourced from the same Hardcover book id.
update books
set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/4d418915-adba-471d-9c4c-12fb7e799ecc-fix.jpg'
where hardcover_id = 429081;
