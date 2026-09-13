-- Optional "why did you feel this way" on a rating (feedback item #12,
-- 2026-09-13 real-user testing pass) -- a single free-text column
-- rather than a separate structured-tag + free-text pair, since the
-- frontend just needs one value to store regardless of whether it came
-- from picking a dropdown option or typing into its "Other" field.
-- Genuinely optional -- nullable, no default, no NOT NULL.
alter table ratings add column if not exists reason text;
