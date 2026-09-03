-- Adds genre_accessibility: how much genre fluency/patience a book
-- assumes of its reader, independent of raw craft difficulty --
-- distinct from prose_complexity/overall_pace/etc (which measure craft
-- difficulty on their own), this is meant to also capture things like
-- premise familiarity that no existing field reduces to (a book can
-- have simple prose and still assume comfort with invented magic
-- terminology or slow-burn multi-book payoffs).
--
-- Deliberately NOT added to recommend.py's ORDINAL_FIELDS / the normal
-- per-user weighted average -- it powers a separate cold-start fallback
-- mechanism instead (see recommend.py), not another vote in the main
-- scoring path. Folding it into the normal average would risk diluting
-- real signal for users who already have a rating history, the same
-- failure mode this project has already hit and fixed once for other
-- fields (see docs/scoring-test-protocol.md's aggregation-shape design
-- discussion).
--
-- Backfilled here for all existing tagged books via a formula over
-- fields that already existed (prose_complexity, overall_pace,
-- worldbuilding_density, pov_count, intellectual_weight) -- a real,
-- free bonus requiring zero new tagging work for the 563 already-tagged
-- books. This formula captures craft difficulty only, NOT premise
-- familiarity (which nothing existing captures) -- so it's a real but
-- incomplete proxy, a documented, deliberate first pass, not a claim
-- this fully replaces a tagger's judgment. Sanity-checked before
-- landing: Steelheart/Firefight (Reckoners, the repo owner's own
-- "recommend to newbies" example) land at 0.300 (accessible tier);
-- Gardens of the Moon (his "never recommend to a newbie" example) lands
-- at 0.800 (right at the veteran_only boundary) -- directionally
-- correct on both named examples before trusting it across the catalog.
-- Going forward, `tag-catalog-batch/SKILL.md` has taggers start from
-- this computed baseline and adjust for premise-familiarity specifically,
-- rather than reassigning from scratch.

alter table book_dna add column genre_accessibility text
  check (genre_accessibility in ('gateway', 'accessible', 'moderate', 'demanding', 'veteran_only'));

update book_dna set genre_accessibility = (
  case
    when demand_score < 0.2 then 'gateway'
    when demand_score < 0.4 then 'accessible'
    when demand_score < 0.6 then 'moderate'
    when demand_score < 0.8 then 'demanding'
    else 'veteran_only'
  end
)
from (
  select book_id,
    (
      (case prose_complexity when 'accessible' then 0.0 when 'moderate' then 0.5 when 'dense' then 1.0 end) +
      (1.0 - (case overall_pace when 'slow' then 0.0 when 'medium' then 0.5 when 'fast' then 1.0 end)) +
      (case worldbuilding_density when 'light' then 0.0 when 'moderate' then 0.5 when 'dense' then 1.0 end) +
      (case pov_count when 'single' then 0.0 when 'dual' then 0.25 when 'few' then 0.5 when 'several' then 0.75 when 'ensemble' then 1.0 end) +
      (case intellectual_weight when 'escapist' then 0.0 when 'moderate' then 0.5 when 'cerebral' then 1.0 end)
    ) / 5.0 as demand_score
  from book_dna
) computed
where book_dna.book_id = computed.book_id;
