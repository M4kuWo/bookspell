-- Author-field contamination fix: The Shadow of the Wind's stored
-- author included Lucia Graves, its English translator, not a
-- co-author -- confirmed via multiple sources (Amazon's own listing
-- credits "Translated by Lucia Graves", her own bio confirms she
-- translated all 4 of Zafón's "Cemetery of Forgotten Books" novels).
-- Checked the rest of the catalog for the same author -- only this one
-- book by Zafón exists here, no other rows affected.
update books set author = 'Carlos Ruiz Zafón'
where title = 'The Shadow of the Wind'
  and author = 'Carlos Ruiz Zafón, Lucia Graves';
