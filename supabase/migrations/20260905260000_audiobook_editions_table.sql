-- Real audiobook_editions table (one-to-many per book), long-deferred
-- in docs/schema/book-dna.md's Future fields backlog -- the schema
-- previously only assumed one audiobook edition per book (book_dna's
-- audiobook_native fields), which can't represent a book having both a
-- standard single-narrator audiobook AND a separate GraphicAudio
-- full-cast dramatized production, or multiple editions across
-- publishers/re-releases.
--
-- release_status/parts_released/parts_total/last_verified_date exist
-- because dramatized full-cast productions (GraphicAudio in
-- particular, confirmed real via direct research: Wind and Truth's
-- GraphicAudio adaptation released across 5 parts between roughly
-- late 2025 and March 2026) are frequently released episodically over
-- months, not all at once -- a lookup done mid-release would correctly
-- find "yes, a GraphicAudio exists" while incompletely reflecting
-- reality (only some parts out). Repo owner's own explicit point:
-- this needs its own status field, not a boolean, and needs a
-- reminder that this data goes stale and must be periodically
-- re-verified -- same "refreshed from metadata sources periodically,
-- never set once at tagging time" pattern this project already uses
-- for series.status/book_count.
create table audiobook_editions (
  id uuid primary key default gen_random_uuid(),
  book_id uuid not null references books(id) on delete cascade,
  edition_type text not null check (edition_type in ('standard', 'dramatized_full_cast', 'abridged', 'other')),
  narrators text[],
  production_company text,
  runtime_minutes integer,
  release_status text not null default 'fully_released'
    check (release_status in ('fully_released', 'in_progress', 'announced')),
  parts_released integer,
  parts_total integer,
  source_url text,
  last_verified_date date not null default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index audiobook_editions_book_id_idx on audiobook_editions(book_id);

-- Seed with one real, directly-verified example (not synthetic) --
-- Wind and Truth's GraphicAudio production, confirmed via direct
-- research: released in 5 parts, the final part (5 of 5) landing
-- March 2026 -- as of this migration's date (2026-09-05), fully
-- released; this row's own last_verified_date is the mechanism that
-- tells a future session whether to trust that or re-check.
insert into audiobook_editions (book_id, edition_type, production_company, release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast', 'GraphicAudio', 'fully_released', 5, 5,
  'https://www.graphicaudio.net/the-stormlight-archive-5-wind-and-truth-series-set.html', '2026-09-05'
from books b where b.title = 'Wind and Truth' and b.author = 'Brandon Sanderson'
on conflict do nothing;
