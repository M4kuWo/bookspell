import hashlib
import json
from pathlib import Path
import tempfile
import unittest
import measure_context_load as counter
import read_full

A = 'First source contains six distinct words here.\nSecond line explains its unique reading obligation fully.\n'
B = 'Other source describes another independent requirement in detail.\nFinal sentence preserves the complete separate instruction here.\n'
class Reference:
    def get(self, path):
        return {'docs/a.md': A, 'docs/b.md': B}.get(path)

class ProposalTests(unittest.TestCase):
    def test_combined_sources_and_overhead(self):
        text = A + '\nmetadata words\n' + B
        parts, spans, full = counter.attribute(text, ['docs/a.md','docs/b.md'], Reference())
        self.assertEqual(parts['docs/a.md'], counter.words(A))
        self.assertEqual(parts['docs/b.md'], counter.words(B))
        self.assertEqual(sum(parts.values()), counter.words(text))
        self.assertEqual(set(full), {'docs/a.md','docs/b.md'})
    def test_numbered_delivery(self):
        text = ''.join(f'{i}\t{line}\n' for i,line in enumerate(A.splitlines(),1))
        parts, _, full = counter.attribute(text, ['docs/a.md'], Reference(), True)
        self.assertEqual(parts['<delivery overhead>'],2)
        self.assertEqual(full,['docs/a.md'])
    def test_missing_revision_and_ambiguous_text(self):
        parts, _, full = counter.attribute(A,['missing'],Reference())
        self.assertEqual(parts,{'<mixed/unattributed>':counter.words(A)})
        self.assertEqual(full,[])
        class Same:
            def get(self,path): return A
        parts, _, _ = counter.attribute(A,['one','two'],Same())
        self.assertEqual(parts,{'<mixed/unattributed>':counter.words(A)})
    def test_candidates_late_and_relative(self):
        command = 'cd docs; cat "a.md"; ' + 'echo padding; '*25 + 'cat b.md'
        self.assertTrue({'docs/a.md','docs/b.md'} <= set(counter.candidates('Bash',{'command':command})))
    def test_persistence_errors_and_repeated_injection(self):
        rows=[]
        for _ in range(2):
            rows.append({'type':'attachment','attachment':{'type':'instructions','files':[{'path':'CLAUDE.md','content':'two words'}]}})
        def pair(i,name,inp,text,error=False):
            rows.extend([{'type':'assistant','message':{'content':[{'type':'tool_use','id':i,'name':name,'input':inp}]}}, {'type':'user','message':{'content':[{'type':'tool_result','tool_use_id':i,'content':text,'is_error':error}]}}])
        pair('a','Bash',{'command':'cat docs/a.md'},'Full output saved to: /tmp/result.txt\nPreview only')
        pair('b','Read',{'file_path':'/tmp/result.txt'},A)
        pair('c','Read',{'file_path':'docs/a.md'},'permission denied',True)
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'test.jsonl'; p.write_text('\n'.join(map(json.dumps,rows)))
            result=counter.measure(str(p))
        self.assertEqual(result['injected_words']['CLAUDE.md'],4)
        self.assertEqual(result['events'][1]['origin_tool_use_id'],'a')
        self.assertEqual(result['events'][1]['candidate_sources'],['docs/a.md'])
        self.assertEqual(result['events'][0]['full_source_matches'],[])
        self.assertEqual(result['events'][2]['attribution'],{'<error output>':2})
        self.assertEqual(result['total_words'],4+sum(e['words'] for e in result['events']))
    def test_lossless_unicode_and_word_boundaries(self):
        for text in ['éclair שלום words '*90, 'short\n'*100, 'last line without newline']:
            data=text.encode(); chunks=read_full.pages(data,64)
            self.assertEqual(b''.join(c[2] for c in chunks),data)
            self.assertEqual(sum(counter.words(c[2].decode()) for c in chunks),counter.words(text))
            self.assertTrue(all(len(c[2])<=64 for c in chunks))
            for i in range(len(chunks)):
                body=read_full.render('source',data,i+1,64).split(b'\n',1)[1]
                self.assertEqual(body,chunks[i][2])
    def test_unbroken_token_fails_closed(self):
        with self.assertRaises(ValueError): read_full.pages(b'x'*100,64)
    def test_hash_mismatch_cli(self):
        import subprocess,sys
        with tempfile.TemporaryDirectory() as tmp:
            f=Path(tmp)/'input'; f.write_text(A)
            proc=subprocess.run([sys.executable,str(Path(read_full.__file__)),str(f),'--part','1','--expect-sha','wrong'],capture_output=True)
            self.assertNotEqual(proc.returncode,0)
            self.assertEqual(proc.stdout,b'')

if __name__ == '__main__': unittest.main(verbosity=2)
