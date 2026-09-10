# Pending approvals (cross-session destructive-action gate)

See CLAUDE.md's "Cross-session destructive-action gate" section for the
full rule this file supports. Short version: CLDA (the tagging/data
session) must stop and request approval here — not proceed — before any
destructive or irreversible action that isn't already spelled out,
step-by-step, in a skill file it's following. CLDO (the primary session)
reviews and answers here. There is no live channel between the two
sessions — this file, checked by CLDO at the start of every repo sync,
is the actual mechanism.

**CLDA**: when you hit a case like this, add a new entry under "Open"
below with today's date, then stop — do not execute the action, do not
work around this file (e.g. by deciding it's "probably fine" and
proceeding anyway). Tell the user directly too, so they know to bring it
to CLDO.

**CLDO**: check this file for anything under "Open" at the start of
every sync. Move an answered entry to "Resolved" with your verdict and
reasoning, don't just delete it.

---

## Open

*(none currently)*

## Resolved

*(none yet — this file was just created, 2026-09-10)*
