-- The Wise Man's Fear was missing sexism_or_misogyny_depicted despite a
-- specific, detailed reader complaint about it (surfaced analyzing
-- Mathias's own Goodreads review text): "all the women in this book are
-- described in a very shallow and sexist way... pictured as
-- seductresses, manipulative or simply objectified by men."
insert into book_content_warnings (book_id, warning_id, severity)
select b.id, 'sexism_or_misogyny_depicted', 'moderate'
from books b where b.title = 'The Wise Man''s Fear' and b.author = 'Patrick Rothfuss'
on conflict do nothing;
