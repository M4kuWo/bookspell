-- Follow-up to 20260901230000: the anon role had no base INSERT
-- privilege on rating_submissions (a fresh table doesn't inherit this
-- automatically the way the pre-existing catalog tables apparently did
-- from an earlier project-setup step) -- an RLS policy alone doesn't
-- grant the underlying privilege it's restricting, and every insert via
-- the public REST API was silently rejected until this was caught by
-- testing against hosted's real API before trusting the tool built on
-- top of it. Separate migration (not editing 20260901230000 in place)
-- since hosted's migration-tracking table already marked that version
-- applied by the time this was caught -- editing it wouldn't re-run.

grant insert on rating_submissions to anon;
