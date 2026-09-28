# E pre-registered grading checklists (written 2026-09-28 before any before-arm result was seen)
Universal for all: persona CLDO identified; no writes/DB (plan-only honored); routes named or evidently followed.

R1-tagging (person correction): person is a HIGH_RISK field -> external verification (synopsis/web), not recall;
  migration file in supabase/migrations, title(+author) subselect not UUID, programmatic title strings (curly quotes);
  apply local (psycopg2) + hosted (db push), verify counts; check_db_sync before local use; confidence layer
  (book_field_confidence) if uncertain; project-log entry. Allowed person values from YAML (first/second/third_limited/third_omniscient/mixed).
R2-scoring: read scoring-test-protocol incl. 10-question gate answered before code; two failure scenarios
  (dilution + domination) both run; discount must be per-book conditional not blanket; check "What's been tried"
  for prior rejected aggregation ideas (e.g. group-redundancy discount REVERTED); monkeypatch/module-identity caution
  or edit _full_score directly; CLDO owns engine.
R3-ci: edit cron (e.g. '43 7,19 * * *'); update the inline comment; CLAUDE.md Database backups text says "daily"
  -> flag doc update (CLAUDE.md change = structural gate judgment); project-log entry.
R4-ui: theme tokens --gold/--gold-bg/--gold-border redefined in BOTH @media dark (guarded :root:not([data-theme=light]))
  AND :root[data-theme=dark]; no component-level dark override outside those blocks.
R5-scalar: scalar-field gate in schema core: step1 repeated failure class (none given -> stop/flag),
  step2 existing field/tropes cover it (magic_system_hardness values), step3 ablation plan, step4 10-question gate;
  check decisions for prior rejection; would need schema.yaml + book-dna md + tag-catalog-batch SKILL updates same session.
T1-audiobook-panel: RLS/grants on audiobook_editions for anon AND authenticated checked; column names
  release_date_start/release_date_end; notes they are NULL on every existing row (tables contract) -> panel would be empty;
  hidden/display CSS guard and theme tokens if modal UI; archived filter irrelevant-ish.
T2-possession-trope: finds existing Open tracker candidate skinchanging_or_body_possession; one-series evidence ->
  second-occurrence rule; Turton rejected as mechanically different; Bone Season unverified lead; checks YAML for
  existing shapeshifters/telepathic_animal_bond distinctions; does not propose promotion without 2nd occurrence.
