-- 5 new trope CONCEPTS (6 values -- the queer-romance concept split into
-- sapphic_romance/mlm_romance rather than one combined value, per the
-- sweep's primary recommendation) from a catalog-wide gap sweep, each
-- verified against 2+ real catalog books currently sharing ZERO
-- trope-level signal despite being the same recognizable subgenre/
-- device -- see docs/project-log.md for the full per-trope evidence
-- (2+ concrete books, "changes what gets recommended" justification)
-- and the candidates considered and rejected for not clearing that bar.
insert into tropes (id, group_name, spoiler) values
  ('sapphic_romance', 'romance_relationships', false),
  ('mlm_romance', 'romance_relationships', false),
  ('infiltration_or_undercover_plot', 'plot_devices', false),
  ('alternate_history', 'setting_worldbuilding', false),
  ('multi_generational_saga', 'plot_devices', false),
  ('cosmic_horror', 'craft_devices', false)
on conflict (id) do nothing;
