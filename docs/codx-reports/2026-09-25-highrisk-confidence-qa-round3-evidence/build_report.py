"""Build proposal tables from the preserved read-only snapshot; no network I/O."""
import json
from collections import Counter
from pathlib import Path

here = Path(__file__).resolve().parent
data = json.loads((here / 'hosted.json').read_text())
changes = {
    2: ('confirmed-correct', 'regional', .85),
    6: ('likely-wrong', 'third_limited', .9),
    11: ('confirmed-correct', 'low', .8),
    15: ('confirmed-correct', 'soft', .8),
    16: ('confirmed-correct', 'cosmic', .95),
    17: ('likely-wrong', 'global', .8),
    18: ('confirmed-correct', 'requires_series', .8),
    19: ('likely-wrong', 'third_omniscient', .8),
}
rows = []
for i, pair in enumerate(data['pairs'], 1):
    outcome, value, confidence = changes.get(i, ('genuinely-inconclusive', pair['value'], pair['confidence']))
    rows.append(dict(number=i, **pair, outcome=outcome, proposed_value=value, proposed_confidence=confidence))
(here / 'recommendations.json').write_text(json.dumps(rows, indent=2, ensure_ascii=False) + '\n')

intro = '''# Task 20 — HIGH_RISK_FIELDS confidence QA, round 3

2026-09-25 · CODX · proposal only · reviewed repository revision `0794845`.

Completed all **22 assigned pairs across 16 distinct books**. The assignment's claim of 20 books is a counting error; no pairs were omitted or added. Propose **3 value corrections and 5 confidence-only increases**. Leave **14 genuinely inconclusive pairs exactly unchanged**. No schema/format mismatch was established. No catalog, confidence, scoring, migration, commit, or push changes were made.

## Method and limits

Used the same definitions and outcome categories as rounds 1–2, after reading their reports, the schema and the tagging skill's evidence guidance. Independently checked hosted identity and current fields before research. Research combined authorized excerpts, publisher descriptions, editorial reviews and identified reader reviews. Full books were not read. Confidence numbers are review judgments, not measured probabilities. Sources support a particular field only: a plausible value is insufficient to increase confidence.

POV count means significant recurring viewpoints (single 1; dual 2; few 3–4; several 5–7; ensemble 8+), not audio performers or cast size. Narrative person depends on narrative threads, not dialogue or occasional reader address. Reliability ambiguity means deliberate uncertainty about the account, not a protagonist learning secrets. Magic hardness depends on rules revealed in this book, not franchise lore or sequel explanations. Stakes concern the actual conflict; setting size and time travel alone do not establish cosmic stakes. Closure depends on unresolved central plot. Heat concerns on-page sexual detail, not frequency, pepper ratings, sexual violence or romance prominence.

## Hosted identity and value verification

Snapshot: `2026-09-25T15:23:51.791677+00:00`. Public anon REST GETs selected one exact title/author match per book; all 16 are unarchived. All 22 live values and confidences matched the assignment: confidence **0.4**, source **ai_inferred**. Full UUIDs, synopses, DNA rows, confidence rows and request parameters are preserved in [hosted.json](2026-09-25-highrisk-confidence-qa-round3-evidence/hosted.json). Below are the **stored** identifiers/year, not claims of independently validated edition metadata.

| Book | Author | Hardcover ID | Stored ISBN | Stored year |
|---|---|---|---|---|
'''
for book in data['books']:
    intro += '| ' + ' | '.join(str(book[k]) if book[k] is not None else 'null' for k in ('title','author','hardcover_id','isbn','publication_year')) + ' |\n'
intro += '''
Identity caveats: Wexler's stored year is 2023 while the reviewed publication is 2024; title, author and Davi premise match. Ken Liu is identified by the publisher as translator of Baoshu's work; the table preserves the catalog author string. *The Salvation* lacks Hardcover ID, ISBN and synopsis: the existing Audible-original ingestion record, official launch release and Audible listing establish Justin Lockey's 2023 eight-part time-travel drama. These are metadata caveats, not proposed changes. No Hardcover API call was needed for this assignment; stored IDs were read from hosted data.

## Recommendations at a glance

Every current confidence is 0.4. “Unchanged” preserves both value and confidence; it does **not** certify correctness. All changes below require CLDO's independent review.

| # | Book | Field | Current value | Outcome | Proposed value / confidence |
|---|---|---|---|---|---|
'''
for row in rows:
    final = f"`{row['proposed_value']}` / {row['proposed_confidence']:g}"
    if row['outcome'] == 'genuinely-inconclusive':
        final += ' unchanged'
    intro += f"| {row['number']} | {row['title']} | `{row['field']}` | `{row['value']}` | {row['outcome']} | {final} |\n"
intro += '\n## Individual findings\n\n'
report = here.parent / '2026-09-25-highrisk-confidence-qa-round3.md'
report.write_text(intro + (here / 'findings.md').read_text())
print(json.dumps(dict(pairs=len(rows), books=len(data['books']), outcomes=dict(Counter(r['outcome'] for r in rows))), sort_keys=True))
print(report)
