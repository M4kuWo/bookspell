-- Removes protagonist_undermined_or_diminished and
-- narrative_favoritism_between_co_leads for real this time (added
-- 20260905160000, reverted 20260905160000-adjacent same day, RE-ADDED
-- dormant via 20260905170000 on the repo owner's own call that an inert
-- tag shouldn't be deleted just for lacking test evidence -- then, on
-- further reflection the same day, the repo owner reconsidered the
-- CONCEPT itself, not just the evidence: both fields read as too
-- niche/sequel-specific to work as general schema fields, and neither
-- actually names what bothered him about The True Bastards. His
-- sharper description: Jackal isn't a diminished CO-LEAD in book 2 (the
-- favoritism framing assumed two comparably-positioned leads) -- he
-- undergoes outright character assassination, a previously-established,
-- competent lead actively torn down within a single book. This is a
-- real, more precise idea than either field captured, kept in
-- docs/schema/book-dna.md's backlog for a future, better-scoped
-- attempt rather than built speculatively on one account. See
-- docs/scoring-test-protocol.md for the full trajectory.
delete from book_tropes where trope_id in (
  'protagonist_undermined_or_diminished',
  'narrative_favoritism_between_co_leads'
);

delete from tropes where id in (
  'protagonist_undermined_or_diminished',
  'narrative_favoritism_between_co_leads'
);
