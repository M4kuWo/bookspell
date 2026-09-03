-- Backfills genre_accessibility (see 20260903000000) for the 20 books
-- tagged in 20260903120000 -- that batch was tagged (by a session on a
-- different machine) after the accessibility backfill had already run
-- against the then-current 563 tagged books, so these 20 were missed.
-- Same formula, scoped to only rows still NULL so this is safe to rerun.

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
  where genre_accessibility is null
) computed
where book_dna.book_id = computed.book_id;
