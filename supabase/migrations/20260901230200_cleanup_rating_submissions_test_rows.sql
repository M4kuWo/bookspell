-- Removes the manual test rows inserted while verifying the
-- rating_submissions RLS policy/grant against the real hosted REST API
-- (see 20260901230000/20260901230100) -- not real submissions, safe to
-- delete, scoped to the exact test rater_name values used.
delete from rating_submissions where rater_name in ('Test RLS Check', 'Test RLS Check 2', 'Test RLS Check 3');
