"""Reproduce the uncommitted proposal from the saved baseline."""
import ast, collections, json, symtable
from pathlib import Path
E = Path(__file__).resolve().parent
root = E.parents[2]
source = (E / 'recommend.before.py').read_text()
lines = source.splitlines(keepends=True)
tree = ast.parse(source)
groups = {
'pipeline': '_redundancy_adjusted_weight _iter_book_factors score_book explain_book _ordinal_field_separation _nominal_field_separation _trope_separation field_or_trope_separation validated_dealbreaker_fields dealbreaker_flags _apply_series_repeat _series_trajectory_penalty_factor _apply_series_trajectory_penalty _apply_dealbreaker_veto _apply_dealbreaker_veto_graduated score_candidate user_calibrated_poor_threshold',
'series': 'compute_series_dna describe_series_trajectory book_similarity series_repeat_worst_similarity series_position_ready _series_deduped _series_deduped_id_to_magnitude',
'cold_start': 'reader_experience_fraction cold_start_weight',
'calibration': 'get_confidence scoring_confidence match_label',
'explanations': 'phrase_field phrase_trope describe _join_list natural_sentence dealbreaker_sentence',
'prevalence': 'build_prevalence_lookup build_prevalence_lookup_grouped',
'profile': '_split_by_sign _n_independent_clusters build_profile _resolve_profile',
'rules': 'parse_user_rule_key normalize_user_rules _matches_rule_target apply_user_rules list_user_rule_targets',
'feedback': 'book_feedback_options feedback_to_fatigue_overrides log_feedback',
'audit': '_audit_attribute_nominal_or_trope _audit_attribute_ordinal audit_book_score print_score_audit',
'experimental': 'build_profile_trope_shrinkage build_profile_trope_backoff _dedup_factor_for_field build_profile_series_field_dedup _dedup_factor_plain build_profile_series_field_dedup_protected build_profile_per_value score_book_per_value explain_book_per_value',
'catalog': 'load_catalog',
'api': 'recommend explain_match series_dnf_outlook',
'encoding': 'nominal_similarity ordinal_position',
}
groups['series'] = groups['series'].replace(' _series_deduped _series_deduped_id_to_magnitude', '')
groups['profile'] += ' _series_deduped _series_deduped_id_to_magnitude'
homes = {name: mod for mod, names in groups.items() for name in names.split()}
for node in tree.body:
    if isinstance(node, ast.Assign):
        for target in node.targets:
            assert isinstance(target, ast.Name)
            homes[target.id] = 'constants'
assert set(homes) == {n.name for n in tree.body if isinstance(n, ast.FunctionDef)} | {t.id for n in tree.body if isinstance(n, ast.Assign) for t in n.targets}
chunks = collections.defaultdict(list)
needs = collections.defaultdict(set)
previous = 0
cli = ''
for node in tree.body:
    chunk = ''.join(lines[previous:node.end_lineno])
    previous = node.end_lineno
    if isinstance(node, (ast.Import, ast.ImportFrom)) or isinstance(node, ast.Expr):
        continue
    if isinstance(node, ast.If):
        cli = chunk
        continue
    name = node.name if isinstance(node, ast.FunctionDef) else node.targets[0].id
    mod = homes[name]
    chunks[mod].append(chunk)
    # Symbol-table globals include nested functions/comprehensions, excluding shadowed locals.
    st = symtable.symtable(ast.get_source_segment(source, node), '<moved>', 'exec')
    def collect(table):
        for symbol in table.get_symbols():
            if symbol.is_referenced() and symbol.is_global():
                needs[mod].add(symbol.get_name())
        for child in table.get_children():
            collect(child)
    collect(st)
# Preserve the feedback default's original scripts/ location after moving constants.
chunks['constants'] = [c.replace('os.path.dirname(__file__), "feedback_log.jsonl"', 'os.path.dirname(os.path.dirname(__file__)), "feedback_log.jsonl"') for c in chunks['constants']]
external = {'os': 'import os', 'psycopg2': 'import psycopg2\nimport psycopg2.extras'}
graph = {}
package = root / 'scripts/scoring'
assert not list(package.glob('*.py')), 'Refusing to overwrite existing source'
package.mkdir(exist_ok=True)
(package / '__init__.py').write_text('"""Scoring engine implementation; recommend.py retains the compatibility API."""\n')
for mod in sorted(chunks):
    imports = collections.defaultdict(list)
    extras = []
    for name in sorted(needs[mod]):
        if name in homes and homes[name] != mod:
            imports[homes[name]].append(name)
        elif name in external:
            extras.append(external[name])
    graph[mod] = sorted(imports)
    header = f'"""{mod.replace("_", " ").capitalize()} components of the recommendation engine."""\n\n'
    header += '\n'.join(extras) + '\n'
    for dep, names in sorted(imports.items()):
        header += f'from .{dep} import (\n' + ''.join(f'    {n},\n' for n in names) + ')\n'
    (package / f'{mod}.py').write_text(header + ''.join(chunks[mod]) + '\n')
# Explicit exports include every original definition, including private experiment helpers.
exports = collections.defaultdict(list)
for name, mod in homes.items():
    exports[mod].append(name)
def export_block(prefix):
    return ''.join(f'    from {prefix}{mod} import (\n' + ''.join(f'        {n},\n' for n in sorted(names)) + '    )\n' for mod, names in sorted(exports.items()))
shim = ast.get_source_segment(source, tree.body[0]) + '\n\n# Support both direct script execution and package imports.\nif __package__:\n' + export_block('.scoring.') + 'else:\n' + export_block('scoring.') + cli + '\n'
(root / 'scripts/recommend.py').write_text(shim)
# Detect cycles without importing anything (all edges are ordinary module-level imports).
def visit(mod, active, done):
    assert mod not in active, ('Circular imports', active, mod)
    if mod in done: return
    for dep in graph[mod]: visit(dep, active + [mod], done)
    done.add(mod)
done = set()
for mod in graph: visit(mod, [], done)
(E / 'module-map.json').write_text(json.dumps({'definitions': homes, 'dependencies': graph}, indent=2) + '\n')
print(f'Created {len(chunks)} implementation modules; dependency graph acyclic; {len(homes)} definitions re-exported')
