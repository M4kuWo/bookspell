-- Final 6 stragglers from 20260918220000: those 6 UPDATEs matched
-- zero rows on hosted because they were keyed on LOCAL's `author`
-- value, which turned out to be stale/contaminated for these exact 6
-- books (translator/narrator/cover-artist names appended -- e.g.
-- local still has "Carlos Ruiz Zafon, Lucia Graves" where Lucia
-- Graves is the English translator, not a co-author) -- hosted
-- already has the clean, correct single-author value for all 6, from
-- a prior author-contamination fix that evidently never made it back
-- to local. That's a separate, real local/hosted drift bug (author
-- field, not cover_url), not fixed here -- flagged in
-- docs/project-log.md instead. Matched by title alone here, safe
-- since each of these 6 titles is unique in the catalog regardless
-- of author-field drift.

update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/65700889-6eb4-45c8-9dd9-4ceb3bdcabb3.jpg', updated_at = now() where title = 'Acceptance';
update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/c02035b4-49c0-4aa0-9b37-1d8d8e1b1210.jpg', updated_at = now() where title = 'The Eyre Affair';
update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/1287c1c8-3651-43ec-a59e-0e25e6d94e55.jpg', updated_at = now() where title = 'The Shadow of the Wind';
update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/a89cdf58-15f2-4276-ac7d-02da5052266a.jpg', updated_at = now() where title = 'Doomsday Book';
update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/b98cf571-6aa4-4f32-a341-9638f4292662.jpg', updated_at = now() where title = 'Nine Princes in Amber';
update books set cover_url = 'https://yhvubjqstswxvctdikbc.supabase.co/storage/v1/object/public/book-covers/covers/74c3339b-7c50-44eb-ab72-99cd88e77108.jpg', updated_at = now() where title = 'Shadows for Silence in the Forests of Hell';
