-- Re-adds the two execution-DNA validation-probe tropes reverted earlier
-- today (see docs/scoring-test-protocol.md's "Execution-DNA validation
-- probe" entry for the full story) -- repo owner's explicit call: since
-- they're genuinely inert (zero regression, just zero learnable signal
-- with only one real-world instance) rather than actively harmful, keep
-- them tagged as a dormant, harmless data point rather than deleting
-- real, accurate information about a book. Left catalog-wide rollout
-- untouched (still just this one book) -- this is still a validation
-- probe, not a decision that the concept is proven; a second rater's
-- account of the same pattern is what would actually let it be tested.
insert into tropes (id, group_name, spoiler) values
  ('protagonist_undermined_or_diminished', 'craft_devices', false),
  ('narrative_favoritism_between_co_leads', 'craft_devices', false)
on conflict (id) do nothing;

insert into book_tropes (book_id, trope_id, source)
select b.id, t.trope_id, 'ai_inferred'
from books b, (values
  ('protagonist_undermined_or_diminished'),
  ('narrative_favoritism_between_co_leads')
) as t(trope_id)
where (b.title, b.author) = ('The True Bastards', 'Jonathan French')
on conflict do nothing;
