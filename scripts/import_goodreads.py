"""Import a Goodreads "export library" CSV into a Bookspell rater file.

Usage:
    DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres \
      python3 scripts/import_goodreads.py <path-to-goodreads-export.csv> <rater-name>

Produces data/ratings/<rater-name>.json (matched books only) plus a
console report of unmatched titles, so a human can decide whether any
are worth ingesting into the catalog.

## Where this data comes from

Goodreads shut down its public API in 2020 -- this does NOT scrape or
hit any API. It parses the CSV a user can export themselves from their
own account (My Books -> Import/Export -> Export Library), which is a
standard, ToS-compliant, user-initiated data export, the same format
countless other book-tracking tools already build against. Expected
columns (Goodreads' own stable format): Title, Author, Author l-f,
ISBN, ISBN13, My Rating, Average Rating, Number of Pages, Year
Published, Original Publication Year, Date Read, Date Added,
Bookshelves, Exclusive Shelf, My Review, Read Count.

NOT YET TESTED against a real Goodreads export file (none was
available when this was written, only the documented format) -- see
docs/project-log.md's 2026-09-04 entry. Test against a real export
before fully trusting this for anyone's actual data; a synthetic
fixture matching the documented column format is used for the
mechanical self-check in this file's __main__ block instead.

## Fable

NOT built. Unlike Goodreads' well-documented CSV export, this session
has no confident, verified knowledge of what data-export or API
capability Fable actually offers its users -- asserting a specific
mechanism here without verifying it first would be exactly the kind of
confidently-wrong claim this project's own standing policy warns
against. Needs real research (check Fable's own settings/help docs,
or ask a Fable user directly) before building anything for it.

## A real, non-technical consideration this raises

Importing a GOODREADS ACCOUNT means importing another real person's
reading history and opinions, not just book metadata -- get their
explicit consent before running this on their export, the same way
this project already treats Mathias's/Osnat's/Dandan's/Gabriel's own
rating data as real, attributed, human-sourced information, not
disposable test fixtures. Consider whether a friend's ratings should
be committed to a shared repo under their real name at all, or need
anonymizing first -- not resolved here, a real product/privacy
decision for the repo owner to make before this is used on a real
friend's export, not something to default silently one way or another.
"""
import sys
import os
import csv
import json
import re
import difflib

sys.path.insert(0, os.path.dirname(__file__))
import recommend as R

# Goodreads' own 1-5 star scale, mapped by POSITION to this project's
# 5-tier scale -- not by Goodreads' own (somewhat confusing) star-label
# text, which most users don't read literally anyway (a straightforward
# 1st-lowest-to-5th-highest mapping is what anyone exporting their data
# would expect, and matches this project's own RATING_LABELS ordering).
GOODREADS_STAR_TO_LABEL = {
    1: "hated",
    2: "disliked",
    3: "it_was_okay",
    4: "liked",
    5: "loved",
}

# Below this ratio, two titles are NOT considered a match -- picked
# conservatively (a false match silently corrupts a rating; a missed
# match just leaves a title in the "unmatched" report for manual
# review, a much cheaper failure mode). Revisit against real data.
FUZZY_MATCH_THRESHOLD = 0.90


def normalize_title(title):
    """Strips Goodreads' own series-suffix convention ("Title (Series,
    #3)") and normalizes case/punctuation for comparison. Does NOT strip
    subtitles after a colon -- too aggressive, real title collisions
    across different books are a bigger risk than a missed match on a
    long subtitle."""
    title = re.sub(r"\s*\([^)]*#[\d.]+\)\s*$", "", title)
    title = re.sub(r"[^\w\s]", "", title.lower())
    return re.sub(r"\s+", " ", title).strip()


def normalize_isbn(raw):
    """Goodreads wraps ISBN columns in ="1234567890" (an Excel-formula
    escape to preserve leading zeros) -- strips that plus any hyphens."""
    if not raw:
        return None
    cleaned = re.sub(r'^="?|"?$', "", raw.strip())
    cleaned = cleaned.replace("-", "").strip()
    return cleaned or None


def fetch_isbns_by_book_id():
    """R.load_catalog()'s own SELECT deliberately doesn't include
    `books.isbn` (it's bibliographic data, not something any scoring
    field uses) -- fetched here as a separate, minimal query instead of
    changing that shared, heavily-used function for a need specific to
    this one script."""
    import psycopg2
    conn = psycopg2.connect(R.DATABASE_URL)
    cur = conn.cursor()
    cur.execute("select id, isbn from books where isbn is not null")
    return {str(bid): isbn for bid, isbn in cur.fetchall()}


def build_catalog_index(catalog, isbns_by_book_id=None):
    """Returns (isbn_index, title_author_index, titles_by_author) for
    matching -- built once, reused across every row in the export.
    isbns_by_book_id: {book_id: raw_isbn}, from fetch_isbns_by_book_id()
    -- optional (the __main__ self-check's synthetic catalog carries
    isbn inline instead, for a simpler fixture)."""
    isbn_index = {}
    title_author_index = {}
    titles_by_author = {}
    for bid, book in catalog.items():
        raw_isbn = book.get("isbn") or (isbns_by_book_id or {}).get(str(bid))
        isbn = normalize_isbn(raw_isbn)
        if isbn:
            isbn_index[isbn] = book["title"]
        norm_title = normalize_title(book["title"])
        norm_author = normalize_title(book["author"])
        title_author_index[(norm_title, norm_author)] = book["title"]
        titles_by_author.setdefault(norm_author, []).append((norm_title, book["title"]))
    return isbn_index, title_author_index, titles_by_author


def match_book(row, isbn_index, title_author_index, titles_by_author):
    """Returns (matched_title, method) or (None, reason) -- method/reason
    are for the report, not used programmatically elsewhere."""
    for isbn_col in ("ISBN13", "ISBN"):
        isbn = normalize_isbn(row.get(isbn_col, ""))
        if isbn and isbn in isbn_index:
            return isbn_index[isbn], "isbn"

    norm_title = normalize_title(row.get("Title", ""))
    norm_author = normalize_title(row.get("Author", ""))
    key = (norm_title, norm_author)
    if key in title_author_index:
        return title_author_index[key], "exact_title_author"

    candidates = titles_by_author.get(norm_author, [])
    if candidates:
        best_ratio, best_title = 0.0, None
        for cand_norm_title, cand_real_title in candidates:
            ratio = difflib.SequenceMatcher(None, norm_title, cand_norm_title).ratio()
            if ratio > best_ratio:
                best_ratio, best_title = ratio, cand_real_title
        if best_ratio >= FUZZY_MATCH_THRESHOLD:
            return best_title, f"fuzzy_{best_ratio:.2f}"

    return None, "no_match"


def import_goodreads_csv(csv_path, catalog, isbns_by_book_id=None):
    """Returns (ratings: {title: label}, matched_rows: [...], unmatched_rows: [...]).
    Only processes rows on the 'read' shelf with a real My Rating (1-5,
    0 = unrated on Goodreads and skipped -- there's nothing to import
    for a book with no rating)."""
    isbn_index, title_author_index, titles_by_author = build_catalog_index(catalog, isbns_by_book_id)

    ratings = {}
    matched_rows = []
    unmatched_rows = []

    with open(csv_path, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("Exclusive Shelf", "").strip() != "read":
                continue
            try:
                stars = int(row.get("My Rating", "0") or "0")
            except ValueError:
                stars = 0
            if stars not in GOODREADS_STAR_TO_LABEL:
                continue

            matched_title, method = match_book(row, isbn_index, title_author_index, titles_by_author)
            if matched_title:
                ratings[matched_title] = GOODREADS_STAR_TO_LABEL[stars]
                matched_rows.append((row.get("Title"), matched_title, method))
            else:
                unmatched_rows.append((row.get("Title"), row.get("Author"), row.get("Average Rating")))

    return ratings, matched_rows, unmatched_rows


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 scripts/import_goodreads.py <goodreads-export.csv> <rater-name>")
        sys.exit(1)
    csv_path, rater_name = sys.argv[1], sys.argv[2]

    catalog = R.load_catalog()
    isbns_by_book_id = fetch_isbns_by_book_id()
    ratings, matched_rows, unmatched_rows = import_goodreads_csv(csv_path, catalog, isbns_by_book_id)

    print(f"Matched {len(matched_rows)} rated-and-read books against the catalog.")
    print(f"Unmatched (not in catalog, or below the fuzzy-match threshold): {len(unmatched_rows)}")

    out_path = os.path.join(os.path.dirname(__file__), "..", "data", "ratings", f"{rater_name}.json")
    out_data = {
        "_meta": {
            "rater": rater_name,
            "role": "imported via Goodreads export",
            "notes": (
                f"Imported from a Goodreads library export ({len(matched_rows)} matched of "
                f"{len(matched_rows) + len(unmatched_rows)} rated-and-read titles). Star ratings "
                "mapped 1:1 by position to this project's 5-tier scale (1=hated...5=loved), not "
                "Goodreads' own star-label text. NOT yet reviewed by a human for accuracy -- "
                "treat as a draft rating set, not verified data, until spot-checked."
            ),
        },
        "ratings": ratings,
    }
    with open(out_path, "w") as f:
        json.dump(out_data, f, indent=2)
    print(f"Wrote {out_path}")

    if unmatched_rows:
        print("\nTop 20 unmatched titles by Goodreads' own average rating (a rough 'well-known enough to maybe ingest' signal):")
        def avg_rating(row):
            try:
                return float(row[2] or 0)
            except ValueError:
                return 0.0
        for title, author, avg in sorted(unmatched_rows, key=avg_rating, reverse=True)[:20]:
            print(f"  {title} by {author} (Goodreads avg: {avg})")


if __name__ == "__main__":
    if len(sys.argv) == 1:
        # Mechanical self-check against a SYNTHETIC fixture matching
        # Goodreads' documented export format -- NOT a real export, see
        # this file's module docstring. Confirms the parser/matcher
        # logic works against the known column shape; does not confirm
        # it survives every real-world quirk (encoding oddities,
        # unusual series-suffix formatting, etc.) a real file might have.
        import tempfile

        fixture_csv = '''Book Id,Title,Author,Author l-f,ISBN,ISBN13,My Rating,Average Rating,Publisher,Binding,Number of Pages,Year Published,Original Publication Year,Date Read,Date Added,Bookshelves,Bookshelves with positions,Exclusive Shelf,My Review,Spoiler,Private Notes,Read Count,Owned Copies
1,The Way of Kings,Brandon Sanderson,"Sanderson, Brandon",="0765326353",="9780765326355",5,4.65,Tor Books,Hardcover,1007,2010,2010,2020/01/15,2020/01/01,read,read (#1),read,,,,1,0
2,"Mistborn: The Final Empire (Mistborn, #1)",Brandon Sanderson,"Sanderson, Brandon",="",="",4,4.47,Tor Books,Paperback,541,2006,2006,2019/06/01,2019/05/20,read,read (#2),read,,,,1,0
3,Some Totally Unknown Book,Nobody Famous,"Famous, Nobody",="",="",3,3.10,Nobody Press,Paperback,200,2015,2015,2018/01/01,2017/12/01,read,read (#3),read,,,,1,0
4,Unread Currently Reading Book,Someone Else,"Else, Someone",="",="",0,4.00,Somewhere Press,Paperback,300,2021,2021,,2021/01/01,currently-reading,currently-reading (#1),currently-reading,,,,0,0
'''
        with tempfile.NamedTemporaryFile(mode="w", suffix=".csv", delete=False) as tmp:
            tmp.write(fixture_csv)
            tmp_path = tmp.name

        test_catalog = {
            "id1": {"title": "The Way of Kings", "author": "Brandon Sanderson", "isbn": "9780765326355"},
            "id2": {"title": "Mistborn: The Final Empire", "author": "Brandon Sanderson", "isbn": "0765350386"},
        }
        ratings, matched, unmatched = import_goodreads_csv(tmp_path, test_catalog)
        os.unlink(tmp_path)

        print("=== Self-check against a synthetic fixture (NOT a real Goodreads export) ===")
        print("Ratings parsed:", ratings)
        print("Matched:", matched)
        print("Unmatched:", unmatched)
        assert ratings == {"The Way of Kings": "loved", "Mistborn: The Final Empire": "liked"}, "self-check FAILED"
        assert len(unmatched) == 1 and unmatched[0][0] == "Some Totally Unknown Book", "self-check FAILED"
        print("Self-check PASSED: exact ISBN match, series-suffix-stripped exact title match, "
              "unmatched book correctly reported, currently-reading/unrated row correctly skipped.")
    else:
        main()
