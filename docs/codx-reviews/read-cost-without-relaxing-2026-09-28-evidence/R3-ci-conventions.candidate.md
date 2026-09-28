# Database backups

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*


Supabase's own automatic backups/PITR are a paid-tier feature this
project doesn't use (checked 2026-09-11: `pitr_enabled: false`, empty
backup list on the free tier). A separate repo,
[`bookspell-backups`](https://github.com/M4kuWo/bookspell-backups)
(cloned locally as a sibling to this repo, e.g.
`../bookspell-backups`), holds periodic manual snapshots instead — see
its own README for the exact `supabase db dump` commands and restore
notes. **Deliberately a separate repo, not a `db_backups/` folder in
this one** — a real backup was lost once already (2026-09-05) because
it only ever lived on one local disk and nothing forced it to be
pushed anywhere; a second repo makes "did this get committed and
pushed" the only thing that matters, same discipline as every other
change in this project.

No fixed cadence yet — take a new snapshot whenever a meaningful
amount of new data has landed or before anything genuinely risky, and
note it in this repo's `docs/project-log.md` (not just in the backups
repo) so it's discoverable from either side. **The log entry's dated H2
heading must contain the literal phrase "database backup"
(case-insensitive)** — `.github/workflows/backup-reminder.yml` (added
2026-09-25, after a real 9-day-stale snapshot went unnoticed with no
forcing function) greps for exactly that phrase daily and warns if a
snapshot is overdue by either signal: more than 14 days since the last
one, or more than 15 distinct migration-day timestamps have landed
since. It's a reminder, not enforcement — nothing blocks work if it
fires, but don't let it fire and then ignore it.
