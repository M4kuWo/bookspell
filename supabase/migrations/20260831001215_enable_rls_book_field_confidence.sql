-- Fixes the TODO logged in docs/project-log.md (2026-08-30): book_field_confidence
-- was added after 20260829000000_enable_rls_public_read.sql and never got
-- included in that pass, so it was the one catalog table still running
-- with RLS off while genuinely internet-reachable. Same pattern as every
-- other catalog table: public read, write stays restricted to the
-- service role.

alter table book_field_confidence enable row level security;

create policy "public read access" on book_field_confidence for select using (true);
