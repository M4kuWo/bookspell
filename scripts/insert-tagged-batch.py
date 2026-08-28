import json
import psycopg2

with open('/private/tmp/claude-501/-Users-mathiaskurin-Documents-bookspell/f173174a-693b-46aa-b5db-b1f5fe9e49bc/scratchpad/test_batch_tagged.json') as f:
    books = json.load(f)

conn = psycopg2.connect('postgresql://postgres:postgres@127.0.0.1:54322/postgres')
cur = conn.cursor()

def book_length_bucket(pages):
    if pages is None:
        return None
    if pages < 350:
        return 'short'
    if pages <= 500:
        return 'standard'
    if pages <= 700:
        return 'long'
    return 'epic'

def audiobook_length_bucket(minutes):
    if minutes is None:
        return None
    hours = minutes / 60
    if hours < 8:
        return 'short'
    if hours <= 15:
        return 'standard'
    if hours <= 25:
        return 'long'
    return 'epic'

pov_fields = ['pov_count', 'person', 'narrator_reliability', 'timeline', 'form']
pacing_fields = ['overall_pace', 'pace_shape', 'drive', 'darkness', 'humor_level', 'emotional_register', 'message_intensity']
content_scalar_fields = ['romance_heat_frequency', 'romance_heat_intensity', 'violence_frequency',
                         'violence_intensity', 'worldbuilding_density', 'narrative_closure',
                         'emotional_resolution', 'ends_on_cliffhanger']
craft_scalar_fields = ['magic_system_hardness', 'scifi_hardness']

inserted = 0
for b in books:
    cur.execute('select page_count, audiobook_duration_minutes from books where id = %s', (b['id'],))
    row = cur.fetchone()
    page_count, audio_minutes = row if row else (None, None)
    book_length = book_length_bucket(page_count)
    audiobook_length = audiobook_length_bucket(audio_minutes)

    ps = b['pov_structure']
    pt = b['pacing_tone']
    cs = b['content_shape']
    tc = b['tropes_craft']

    cols = ['book_id', 'genre', 'age_category', 'book_length', 'audiobook_length']
    vals = [b['id'], b['genre'], b['age_category'], book_length, audiobook_length]
    for f in pov_fields:
        cols.append(f); vals.append(ps.get(f))
    for f in pacing_fields:
        cols.append(f); vals.append(pt.get(f))
    for f in content_scalar_fields:
        cols.append(f); vals.append(cs.get(f))
    for f in craft_scalar_fields:
        cols.append(f); vals.append(tc.get(f))

    placeholders = ', '.join(['%s'] * len(vals))
    col_str = ', '.join(cols)
    cur.execute(f'insert into book_dna ({col_str}) values ({placeholders})', vals)

    for t in tc.get('tropes', []) or []:
        cur.execute('insert into book_tropes (book_id, trope_id) values (%s, %s)', (b['id'], t))

    for w in cs.get('content_warnings', []) or []:
        cur.execute(
            'insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) values (%s, %s, %s, %s)',
            (b['id'], w['id'], w['severity'], w.get('reveals_spoiler', False))
        )
    inserted += 1

conn.commit()
print(f'Inserted book_dna + tropes + content_warnings for {inserted} books.')

cur.execute('select count(*) from book_dna')
print('Total book_dna rows now:', cur.fetchone()[0])
cur.execute("select book_length, count(*) from books b join book_dna bd on bd.book_id=b.id where b.id = any(%s) group by book_length", ([b['id'] for b in books],))
print('book_length distribution for this batch:', cur.fetchall())
cur.execute("select audiobook_length, count(*) from books b join book_dna bd on bd.book_id=b.id where b.id = any(%s) group by audiobook_length", ([b['id'] for b in books],))
print('audiobook_length distribution for this batch:', cur.fetchall())

cur.close()
conn.close()
