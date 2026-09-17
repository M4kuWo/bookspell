"""Catalog components of the recommendation engine."""

import psycopg2
import psycopg2.extras
from .constants import (
    DATABASE_URL,
)


def load_catalog():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        select b.id, b.title, b.author, b.series_id, s.name as series_name,
               b.position_in_series, d.*
        from books b
        join book_dna d on d.book_id = b.id
        left join series s on s.id = b.series_id
    """)
    books = [dict(row) for row in cur.fetchall()]

    cur.execute("""
        select book_id, array_agg(trope_id) as tropes
        from book_tropes group by book_id
    """)
    tropes_by_book = {row["book_id"]: row["tropes"] for row in cur.fetchall()}

    # Confidence layer (2026-08-30) -- see book_field_confidence's
    # migration comment. Absence of a row means "unassessed"; get_confidence()
    # below defaults to full trust (1.0) rather than penalizing the vast
    # majority of tags that were never explicitly flagged as uncertain.
    cur.execute("select book_id, trope_id, confidence from book_tropes where confidence is not null")
    trope_confidence_by_book = {}
    for row in cur.fetchall():
        trope_confidence_by_book.setdefault(row["book_id"], {})[row["trope_id"]] = float(row["confidence"])

    cur.execute("select book_id, field_name, confidence from book_field_confidence")
    field_confidence_by_book = {}
    for row in cur.fetchall():
        field_confidence_by_book.setdefault(row["book_id"], {})[row["field_name"]] = float(row["confidence"])

    cur.close()
    conn.close()

    for b in books:
        b["tropes"] = tropes_by_book.get(b["id"], [])
        b["_trope_confidence"] = trope_confidence_by_book.get(b["id"], {})
        b["_field_confidence"] = field_confidence_by_book.get(b["id"], {})
    return {b["id"]: b for b in books}

