import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/ar_lens/models/ar_lens_models.dart';
import 'package:rafca/features/ar_lens/services/ar_matching_engine.dart';
import 'package:rafca/features/library/models/library_models.dart';

void main() {
  group('ArMatchingEngine', () {
    late ArMatchingEngine engine;

    final testBooks = [
      LibraryBook(
        id: 'book_1',
        title: 'Kara Kitap',
        author: 'Orhan Pamuk',
        status: ReadingStatus.read,
        confidence: MatchConfidence.matched,
        addedAt: DateTime(2026, 1, 1),
      ),
      LibraryBook(
        id: 'book_2',
        title: 'Kürk Mantolu Madonna',
        author: 'Sabahattin Ali',
        status: ReadingStatus.unread,
        confidence: MatchConfidence.matched,
        addedAt: DateTime(2026, 1, 2),
      ),
    ];

    setUp(() {
      engine = ArMatchingEngine();
      engine.updateIndex(testBooks);
    });

    test('makeTrigrams handles Turkish characters and whitespace', () {
      final grams = ArMatchingEngine.makeTrigrams('Şeker Portakalı');
      expect(grams, isNotEmpty);
      expect(grams.any((g) => g.contains('şek')), isTrue);
    });

    test('trigramSimilarity returns expected values', () {
      final a = ArMatchingEngine.makeTrigrams('Kürk Mantolu Madonna');
      final b = ArMatchingEngine.makeTrigrams('Kurk Mantolu Madonna'); // Minor OCR typo
      final c = ArMatchingEngine.makeTrigrams('Suç ve Ceza');

      expect(ArMatchingEngine.trigramSimilarity(a, a), equals(1.0));
      expect(ArMatchingEngine.trigramSimilarity(a, b), greaterThan(0.70));
      expect(ArMatchingEngine.trigramSimilarity(a, c), lessThan(0.15));
    });

    test('classifyText identifies owned read book', () {
      final result = engine.classifyText(
        id: 'det_1',
        rawText: 'KARA KİTAP\nORHAN PAMUK\nİletişim',
        normalizedRect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.6),
      );

      expect(result.status, equals(ArBookStatus.ownedRead));
      expect(result.matchedTitle, equals('Kara Kitap'));
      expect(result.matchedAuthor, equals('Orhan Pamuk'));
      expect(result.similarity, greaterThan(0.50));
    });

    test('classifyText identifies owned unread book', () {
      final result = engine.classifyText(
        id: 'det_2',
        rawText: 'KÜRK MANTOLU MADONNA\nSABAHATTİN ALİ',
        normalizedRect: const Rect.fromLTWH(0.4, 0.1, 0.2, 0.6),
      );

      expect(result.status, equals(ArBookStatus.ownedUnread));
      expect(result.matchedTitle, equals('Kürk Mantolu Madonna'));
      expect(result.matchedAuthor, equals('Sabahattin Ali'));
    });

    test('classifyText marks unowned book as notOwned', () {
      final result = engine.classifyText(
        id: 'det_3',
        rawText: 'DUNE\nFRANK HERBERT\nSarmal',
        normalizedRect: const Rect.fromLTWH(0.7, 0.1, 0.2, 0.6),
      );

      expect(result.status, equals(ArBookStatus.notOwned));
      expect(result.matchedTitle, contains('DUNE'));
    });
  });
}
