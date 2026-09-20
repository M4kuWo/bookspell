-- book_suggestions had a real status column and no way for the repo
-- owner to actually see incoming suggestions -- the existing "select
-- own suggestions"/"insert own suggestions" policies only ever let a
-- submitter see THEIR OWN rows, so the only way to review a suggestion
-- was querying the table directly (see docs/TODO.md's 2026-09-18
-- entry, closed by this migration + app/suggestions.html).
--
-- No role/admin system exists in this project yet, and building one
-- for a single real admin account would be over-engineering -- these
-- two policies are scoped directly to the repo owner's real Supabase
-- Auth user id (confirmed 2026-09-18 via profiles.format_preference =
-- 'audiobook', matching his known preference), the same way a real
-- per-user hosted-only feature (ratings/user_rules) already works in
-- this project. Additive (a second permissive policy per action,
-- ORed with the existing per-submitter one), so ordinary users' own
-- "select/insert own suggestions" access is completely unchanged.

grant update on book_suggestions to authenticated;

create policy "admin select all suggestions" on book_suggestions
  for select using (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351');

create policy "admin update suggestion status" on book_suggestions
  for update using (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351')
  with check (auth.uid() = '16977c74-4432-41c4-aa15-494f38e31351');
