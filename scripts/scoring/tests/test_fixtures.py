"""Synthetic scoring mechanics, not a recommendation-quality benchmark.

Run from the repo root: python3 scripts/scoring/tests/test_fixtures.py
Standard library only: deliberately do not import catalog, api, or the live
scoring_tests benchmark. Includes the optional scoring adjustments added in Task 19.
"""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from scoring import pipeline, profile, series, cold_start, rules, explanations
from scoring.constants import (PREVALENCE_DISCOUNT_FLOOR, REDUNDANCY_DISCOUNTS,
                               SERIES_REPEAT_WEIGHT, DEALBREAKER_VETO_CAP)
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

    def candidate(self, book_id, policy, ratings=None, **overrides):
        # Medium pace against fast target: normalized distance 1/2, score 1/2.
        # Empty series DNA/validation, no prevalence, zero cold start and no
        # rules keep deferred adjustments inactive. Eligibility is still real.
        options = dict(validated_fields=set(), series_dna={},
                       field_prevalence=None, trope_prevalence=None, poor_threshold=0.35,
                       cold_start=0.0, matches_genre=lambda bid: True)
        options.update(overrides)
        return pipeline.score_candidate(
            self.catalog, book_id, {'overall_pace': 1.0},
            {'overall_pace': 1.0}, {} if ratings is None else ratings,
            policy=policy, **options,
        )

    def test_prevalence_discounts_field_and_trope_weights_with_floor(self):
        common = make_book('common', overall_pace='slow', tropes=['found_family'])
        rare = make_book('rare', overall_pace='fast', tropes=['found_family'])
        centroid = {'overall_pace': 0.5}
        weights = {'overall_pace': 1.0, 'tropes': {'found_family': 1.0}}
        fp = {'overall_pace': {'slow': 0.8, 'fast': 0.1}}
        for book, expected in ((common, 0.2), (rare, 0.9)):
            factors = {f[0]: f for f in pipeline._iter_book_factors(
                book, centroid, weights, fp, {'found_family': 1.0})}
            self.assertEqual(factors['overall_pace'][2], 1.0)
            self.assertAlmostEqual(factors['overall_pace'][3], expected)
            self.assertEqual(factors['trope:found_family'][3], PREVALENCE_DISCOUNT_FLOOR)
        for frequency, expected in ((0.1, 0.9), (0.8, 0.2), (1.0, PREVALENCE_DISCOUNT_FLOOR)):
            factors = list(pipeline._iter_book_factors(
                common, centroid, weights, {'overall_pace': {'slow': frequency}},
                {'found_family': frequency}))
            for _, _, raw, effective, _ in factors:
                self.assertEqual(raw, 1.0)
                self.assertAlmostEqual(effective, expected)

    def test_redundancy_discount_is_candidate_conditional(self):
        for (dependent, trigger, value), discount in REDUNDANCY_DISCOUNTS.items():
            with self.subTest(dependent=dependent):
                other = 'third_limited' if trigger == 'person' else 'resolved'
                hit = make_book('correlated', **{trigger: value})
                miss = make_book('unrelated', **{trigger: other})
                for book, expected in ((hit, 1 - discount), (miss, 1.0)):
                    book['_field_confidence'][dependent] = 1.0
                    self.assertAlmostEqual(pipeline._redundancy_adjusted_weight(
                        book, dependent, 1.0), expected)
                    target = 0.0 if dependent == 'pov_count' else 'self_contained'
                    factor = next(pipeline._iter_book_factors(
                        book, {dependent: target}, {dependent: 1.0}))
                    self.assertAlmostEqual(factor[3], expected)
                    self.assertEqual(pipeline._redundancy_adjusted_weight(
                        book, 'overall_pace', 1.0), 1.0)

    def test_series_repeat_penalizes_disliked_not_liked_mates(self):
        book = self.catalog['series-2']
        disliked = {'series-1': -1.0}
        # Empty trope sets contribute zero Jaccard similarity, not one.
        # Supply a shared real trope to make all three components identical.
        for bid in ('series-1', 'series-2'):
            self.catalog[bid]['tropes'] = ['found_family']
        self.assertAlmostEqual(series.series_repeat_worst_similarity(
            self.catalog, disliked, book), 1.0)
        after = pipeline._apply_series_repeat(self.catalog, disliked, book, 0.8)
        self.assertAlmostEqual(after, (1 - SERIES_REPEAT_WEIGHT) * 0.8)
        self.assertLess(after, 0.8)
        for ratings in ({}, {'series-1': 1.0}):
            self.assertIsNone(series.series_repeat_worst_similarity(self.catalog, ratings, book))
            self.assertEqual(pipeline._apply_series_repeat(self.catalog, ratings, book, 0.8), 0.8)
        self.assertEqual(pipeline._apply_series_repeat(
            self.catalog, disliked, self.catalog['pace-medium'], 0.8), 0.8)

    def test_trajectory_penalizes_divergent_entry_only(self):
        for shifting in (True, False):
            with self.subTest(shifting=shifting):
                books = [make_book(f'arc-{i}', series_id='arc', series_name='Fixture Arc',
                                   position_in_series=i, narrative_closure='requires_series',
                                   overall_pace='fast' if shifting and i == 2 else 'slow')
                         for i in (1, 2)]
                dna = series.compute_series_dna({b['id']: b for b in reversed(books)})
                self.assertEqual(dna['arc']['trajectories']['overall_pace']['trend'],
                                 'increases' if shifting else 'stable')
                centroid, weights = {'overall_pace': 0.0}, {'overall_pace': 1.0}
                factor = pipeline._series_trajectory_penalty_factor(dna, books[0], centroid, weights)
                after = pipeline._apply_series_trajectory_penalty(dna, books[0], centroid, weights, 0.8)
                if shifting:
                    self.assertGreaterEqual(factor, 0.0)
                    self.assertLess(factor, 1.0)
                    self.assertLess(after, 0.8)
                else:
                    self.assertEqual(factor, 1.0)
                    self.assertEqual(after, 0.8)
                self.assertAlmostEqual(after, 0.8 * factor)
                self.assertEqual(pipeline._series_trajectory_penalty_factor(
                    dna, books[1], centroid, weights), 1.0)
                books[0]['narrative_closure'] = 'self_contained'
                self.assertEqual(pipeline._series_trajectory_penalty_factor(
                    dna, books[0], centroid, weights), 1.0)

    def test_cold_start_count_and_experience_components(self):
        self.assertEqual(cold_start.cold_start_weight(self.catalog, {}), 1.0)
        # 12 independent gateway books isolate the count fade from experience.
        books = {str(i): make_book(str(i), genre_accessibility='gateway') for i in range(12)}
        self.assertAlmostEqual(cold_start.cold_start_weight(books, {'0': 1.0}), 11 / 12)
        self.assertEqual(cold_start.cold_start_weight(books, {bid: 1.0 for bid in books}), 0.0)
        books['0']['genre_accessibility'] = 'veteran_only'
        for magnitude in (1.0, 0.0):
            self.assertEqual(cold_start.reader_experience_fraction(books, {'0': magnitude}), 1.0)
            self.assertEqual(cold_start.cold_start_weight(books, {'0': magnitude}), 0.0)
        self.assertEqual(cold_start.reader_experience_fraction(books, {'0': -1.0}), 0.0)
        self.assertAlmostEqual(cold_start.cold_start_weight(books, {'0': -1.0}), 11 / 12)
        # Multiple rated installments still supply just one independent cluster.
        for i in ('series-1', 'series-2', 'series-3'):
            self.catalog[i]['genre_accessibility'] = 'gateway'
        self.assertAlmostEqual(cold_start.cold_start_weight(
            self.catalog, {f'series-{i}': 1.0 for i in (1, 2, 3)}), 11 / 12)

    def test_cold_start_applies_only_to_ranking_and_audit(self):
        for policy in ('ranking', 'audit', 'explanation', 'evaluation'):
            for book_id in ('pace-slow', 'pace-fast'):
                with self.subTest(policy=policy, book=book_id):
                    warm = self.candidate(book_id, policy, cold_start=0.0)
                    cold = self.candidate(book_id, policy, cold_start=1.0)
                    half = self.candidate(book_id, policy, cold_start=0.5)
                    base = warm['scores']['base']
                    self.assertEqual(warm['scores']['final'].hex(), base.hex())
                    expected = 0.75 if policy in ('ranking', 'audit') else base
                    self.assertEqual(cold['scores']['base'], base)
                    self.assertEqual(cold['scores']['final'], expected)
                    self.assertEqual(half['scores']['final'], (base + expected) / 2)

    def test_user_rules_exclude_reduce_and_leave_nonmatches_unchanged(self):
        self.catalog['pace-slow']['tropes'] = ['found_family']
        for key in ('overall_pace:slow', 'found_family'):
            for kind in ('exclude', 'reduce'):
                raw = {kind: [key] if kind == 'exclude' else [{'key': key, 'strength': 0.25}]}
                normalized = rules.normalize_user_rules(raw)
                self.assertEqual(len(normalized[kind]), 1)
                for book_id, matches in (('pace-slow', True), ('pace-fast', False)):
                    with self.subTest(key=key, kind=kind, book=book_id):
                        expected = 0.6 if matches and kind == 'reduce' else 0.8
                        score, excluded = rules.apply_user_rules(self.catalog[book_id], 0.8, normalized)
                        self.assertAlmostEqual(score, expected)
                        self.assertEqual(excluded, matches and kind == 'exclude')
                        for policy in ('ranking', 'audit', 'explanation', 'evaluation'):
                            # Use medium target here so the matching slow candidate
                            # has nonzero score: reducing zero proves nothing.
                            result = pipeline.score_candidate(
                                self.catalog, book_id, {'overall_pace': 0.5}, {'overall_pace': 1.0}, {},
                                policy=policy, validated_fields=set(), series_dna={}, field_prevalence=None,
                                trope_prevalence=None, poor_threshold=0.35, cold_start=0.0,
                                matches_genre=lambda bid: True, normalized_rules=normalized)
                            active = policy in ('ranking', 'audit') and matches
                            self.assertEqual(result['exclusions'], ['user_rule'] if active and kind == 'exclude' else [])
                            self.assertEqual(result['excluded_by_user_rule'], active and kind == 'exclude')
                            if active and kind == 'exclude':
                                self.assertEqual(result['match_label'], 'Excluded by user rule')
                            self.assertEqual(result['scores']['final'], 0.375 if active and kind == 'reduce' else 0.5)

    def test_explanations_preserve_match_and_mismatch_direction(self):
        book = make_book('phrases', overall_pace='fast', tropes=['found_family', 'revenge'])
        matches, mismatches = pipeline.explain_book(book, {'overall_pace': 1.0},
            {'overall_pace': 1.0, 'tropes': {'found_family': 0.5, 'revenge': -0.5}})
        self.assertIn('trope:found_family', dict(matches))
        self.assertNotIn('trope:found_family', dict(mismatches))
        self.assertIn('trope:revenge', dict(mismatches))
        self.assertNotIn('trope:revenge', dict(matches))
        # Both output lists contain positive magnitudes; list membership carries sign.
        for entries, positive in ((matches, True), (mismatches, False)):
            phrases = [(label, explanations.describe(label, book)) for label, _ in entries]
            self.assertTrue(all(magnitude > 0 for _, magnitude in entries))
            self.assertTrue(all(isinstance(phrase, str) and phrase.strip() for _, phrase in phrases))
            sentence = explanations.natural_sentence(phrases, positive)
            self.assertTrue(sentence.strip())
            for _, phrase in phrases:
                self.assertIn(phrase, sentence)
            # Assert polarity changes rendering without pinning the English template.
            self.assertNotEqual(sentence, explanations.natural_sentence(phrases, not positive))
        warning = explanations.dealbreaker_sentence(phrases)
        self.assertIn(explanations.describe('trope:revenge', book), warning)
        self.assertNotEqual(warning, explanations.natural_sentence(phrases, False))
        self.assertEqual(explanations.natural_sentence([], True), '')
        self.assertEqual(explanations.dealbreaker_sentence([]), '')

    def test_dealbreaker_modes_and_veto(self):
        book = make_book('veto', overall_pace='fast', person='first')
        centroid = {'overall_pace': 0.0, 'person': 'third_limited'}
        weights = {'overall_pace': 0.2, 'person': 0.4}
        def flags(validated):
            return dict(pipeline.dealbreaker_flags(book, centroid, weights, validated_fields=validated))
        self.assertEqual(set(flags(set())), {'person'})  # fixed fallback >= .3
        self.assertEqual(set(flags({'overall_pace'})), {'overall_pace'})  # validated >= .15
        self.assertEqual(flags({'darkness'}), {})  # no fallback for a nonempty set
        for validated, expected in ((set(), 0.9), ({'darkness'}, 0.9),
                                    ({'overall_pace'}, DEALBREAKER_VETO_CAP)):
            actual = pipeline._apply_dealbreaker_veto({}, {}, validated, book, centroid, weights, 0.9)
            self.assertEqual(actual, expected)
        # Capping must never raise a score already below the cap.
        self.assertEqual(pipeline._apply_dealbreaker_veto(
            {}, {}, {'overall_pace'}, book, centroid, weights, 0.2), 0.2)

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
