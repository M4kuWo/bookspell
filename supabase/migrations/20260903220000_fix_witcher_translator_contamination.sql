-- Author-field contamination found during a qualitative recommend()
-- review of the 2026-09-03 tagging batch: "Season of Storms" and "The
-- Lady of the Lake" (both added in that batch) had David French, the
-- English translator of the Witcher series, folded into `author` as
-- 'Andrzej Sapkowski, David   French' (note double space) -- the exact
-- contributor-contamination pattern CLAUDE.md already documents as a
-- recurring risk on newly-ingested books. The other 6 Sapkowski books
-- already in the catalog are clean (author = 'Andrzej Sapkowski' only),
-- confirmed via a direct query before writing this fix. Scoped by exact
-- title + a match on the contaminated string, so this can never touch
-- a correctly-formatted row even if rerun.

update books
set author = 'Andrzej Sapkowski'
where title in ('Season of Storms', 'The Lady of the Lake')
  and author like '%David%French%';
