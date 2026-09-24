"""Synthetic scoring mechanics, not a recommendation-quality benchmark.

Run from the repo root: python3 scripts/scoring/tests/test_fixtures.py
Standard library only: deliberately do not import catalog, api, or the live
scoring_tests benchmark. Optional scoring adjustments are neutral in this
first slice; their behavior belongs in the next fixture-test task.
"""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from scoring import pipeline, profile
from scoring.encoding import nominal_similarity


def make_book(book_id, **changes):
    """Fresh load_catalog-shaped record, using the schema's real vocabulary.

    Explicit defaults keep fixture expectations independent of engine constants.
    Confidence 1 for the two isolated scoring fields removes uncertainty from
    their hand-computed similarity checks. No real catalog data is used.
    """
    book = {
        'id': book_id, 'book_id': book_id, 'title': f'Fixture {book_id}',
        'author': 'Synthetic Author', 'series_id': None, 'series_name': None,
        'position_in_series': None,
        'genre': ['fantasy'], 'age_category': 'adult',
        'book_length': 'standard', 'audiobook_length': 'standard',
        'pov_count': 'single', 'person': 'third_limited',
        'narrator_reliability': 'reliable', 'timeline': 'linear',
        'form': 'standard_prose', 'prose_density': 'moderate',
        'prose_complexity': 'accessible', 'overall_pace': 'medium',
        'pace_shape': 'consistent', 'drive': 'balanced', 'darkness': 'moderate',
        'humor_level': 'light', 'emotional_register': 'bittersweet',
        'message_intensity': 'subtle', 'intellectual_weight': 'moderate',
        'romance_heat_frequency': 'none', 'romance_heat_intensity': 'na',
        'romance_tone': None, 'violence_frequency': 'occasional',
        'violence_intensity': 'moderate', 'worldbuilding_density': 'moderate',
        'worldbuilding_delivery': None, 'stakes_scope': 'regional',
        'personal_stakes': 'high', 'narrative_closure': 'self_contained',
        'emotional_resolution': 'bittersweet', 'ends_on_cliffhanger': 'resolved',
        'narrator_performance': None, 'narrator_cast': None,
        'narration_pace_vs_prose': None, 'accent_authenticity': None,
        'production_quality': None, 'magic_system_hardness': 'soft',
        'scifi_hardness': 'na', 'genre_accessibility': 'accessible',
        'created_at': None, 'updated_at': None,
        'tropes': [], '_trope_confidence': {},
        '_field_confidence': {'overall_pace': 1.0, 'person': 1.0},
    }
    book.update(changes)
    return book


def fixture_catalog():
    """15 deliberate books: three pace probes, six learners, three POV
    probes, and a three-installment series. Learners differ only in pace
    (apart from identity); they are independent standalones.
    """
    books = [make_book(f'pace-{pace}', overall_pace=pace)
             for pace in ('slow', 'medium', 'fast')]
    books += [make_book(f'{group}-{i}', overall_pace=pace)
              for group, pace in (('slow-training', 'slow'),
                                  ('fast-training', 'fast'))
              for i in range(3)]
    books += [make_book(f'person-{person}', person=person)
              for person in ('first', 'third_limited', 'third_omniscient')]
    books += [make_book(f'series-{i}', series_id='fixture-trilogy',
                        series_name='Fixture Trilogy', position_in_series=i)
              for i in (1, 2, 3)]
    return {book['id']: book for book in books}


class ScoringFixtures(unittest.TestCase):
    def setUp(self):
        self.catalog = fixture_catalog()

    def candidate(self, book_id, policy, ratings=None):
        # Medium pace against fast target: normalized distance 1/2, score 1/2.
        # Empty series DNA/validation, no prevalence, zero cold start and no
        # rules keep deferred adjustments inactive. Eligibility is still real.
        return pipeline.score_candidate(
            self.catalog, book_id, {'overall_pace': 1.0},
            {'overall_pace': 1.0}, {} if ratings is None else ratings,
            policy=policy, validated_fields=set(), series_dna={},
            field_prevalence=None, trope_prevalence=None, poor_threshold=0.35,
            cold_start=0.0, matches_genre=lambda bid: True,
        )

    def test_ordinal_similarity_uses_normalized_distance(self):
        # Three-position scale: distance 0 -> 1, adjacent -> .5, end-to-end -> 0.
        # Check both directions; expected values are not computed by the engine.
        for target, expected in (
            (0.0, {'slow': 1.0, 'medium': 0.5, 'fast': 0.0}),
            (1.0, {'slow': 0.0, 'medium': 0.5, 'fast': 1.0}),
        ):
            for pace, similarity in expected.items():
                with self.subTest(target=target, pace=pace):
                    score, _ = pipeline.score_book(
                        self.catalog[f'pace-{pace}'],
                        {'overall_pace': target}, {'overall_pace': 1.0})
                    self.assertAlmostEqual(score, similarity)

    def test_nominal_exact_partial_and_mismatch(self):
        cases = (
            ('first', 'first', 1.0),
            ('first', 'third_limited', 0.0),
            ('third_limited', 'first', 0.0),
            ('third_limited', 'third_omniscient', 0.5),
            ('third_omniscient', 'third_limited', 0.5),
        )
        for value, target, expected in cases:
            with self.subTest(value=value, target=target):
                self.assertEqual(nominal_similarity('person', value, target), expected)
                score, _ = pipeline.score_book(
                    self.catalog[f'person-{value}'], {'person': target}, {'person': 1.0})
                self.assertAlmostEqual(score, expected)

    def test_profile_learns_separating_field_in_both_directions(self):
        for preferred, rejected in (('slow', 'fast'), ('fast', 'slow')):
            with self.subTest(preferred=preferred):
                ratings = {f'{preferred}-training-{i}': 1.0 for i in range(3)}
                ratings.update({f'{rejected}-training-{i}': -1.0 for i in range(3)})
                centroid, weights = profile.build_profile(self.catalog, ratings)
                # Scalar weights measure importance, not signed aversion.
                # Reversing taste must reverse the target, not negate weight.
                self.assertGreater(weights['overall_pace'], 0.1)
                expected_target = 0.0 if preferred == 'slow' else 1.0
                self.assertAlmostEqual(centroid['overall_pace'], expected_target)
                good, _ = pipeline.score_book(self.catalog[f'pace-{preferred}'], centroid, weights)
                bad, _ = pipeline.score_book(self.catalog[f'pace-{rejected}'], centroid, weights)
                self.assertGreater(good, bad)

    def test_policies_agree_on_scores_with_optional_adjustments_inactive(self):
        common = ('base', 'series_repeat', 'veto', 'trajectory')
        sequences = {
            'ranking': common + ('diversity', 'cold_start', 'user_rules'),
            'explanation': common,
            'evaluation': common,
            'audit': common + ('cold_start', 'user_rules'),
        }
        for policy, expected_stages in sequences.items():
            with self.subTest(policy=policy):
                result = self.candidate('pace-medium', policy)
                self.assertEqual(result['stage_sequence'], expected_stages)
                self.assertEqual(result['exclusions'], [])
                self.assertFalse(result['excluded_by_user_rule'])
                # A skipped optional stage carries forward its input; no None
                # scores or unexpected adjustments for any of the four policies.
                self.assertEqual(set(result['scores']), {
                    'base', 'after_series_repeat', 'after_veto', 'after_trajectory',
                    'after_diversity', 'after_cold_start', 'final'})
                for stage, score in result['scores'].items():
                    with self.subTest(stage=stage):
                        self.assertAlmostEqual(score, 0.5)

    def test_only_ranking_short_circuits_series_ineligibility(self):
        ranking = self.candidate('series-2', 'ranking')
        self.assertEqual(ranking['exclusions'], ['series_position'])
        self.assertTrue(all(score is None for score in ranking['scores'].values()))
        self.assertIsNone(ranking['match_label'])
        for key in ('factors', 'contributions', 'matches', 'mismatches', 'dealbreaker_flags'):
            self.assertEqual(ranking[key], [])
        for policy in ('explanation', 'evaluation', 'audit'):
            with self.subTest(policy=policy):
                result = self.candidate('series-2', policy)
                self.assertEqual(result['exclusions'], [])
                self.assertAlmostEqual(result['scores']['base'], 0.5)
                self.assertAlmostEqual(result['scores']['final'], 0.5)

    def test_series_position_requires_every_earlier_installment(self):
        cases = (
            ('series-1', {}, True),
            ('series-2', {}, False),
            ('series-2', {'pace-slow': 1.0}, False),
            ('series-2', {'series-1': 1.0}, True),
            ('series-3', {'series-1': 1.0}, False),
            ('series-3', {'series-2': 1.0}, False),
            ('series-3', {'series-1': 1.0, 'series-2': 1.0}, True),
        )
        for book_id, ratings, eligible in cases:
            with self.subTest(book_id=book_id, ratings=ratings):
                result = self.candidate(book_id, 'ranking', ratings)
                self.assertEqual(result['exclusions'], [] if eligible else ['series_position'])
                if eligible:
                    self.assertAlmostEqual(result['scores']['final'], 0.5)
                else:
                    self.assertTrue(all(s is None for s in result['scores'].values()))


if __name__ == '__main__':
    unittest.main(verbosity=2)
