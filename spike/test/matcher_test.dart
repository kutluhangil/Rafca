import 'package:spike/eval/catalog.dart';
import 'package:spike/eval/matcher.dart';
import 'package:spike/eval/normalize.dart';
import 'package:test/test.dart';

void main() {
  final publishers = PublisherIndex(['penguin classics', 'chilton books']);

  final catalog = Catalog(
    [
      CatalogEntry(
        id: 'b1',
        title: '1984',
        authors: ['George Orwell'],
        language: 'eng',
        publisher: 'Penguin Classics',
      ),
      CatalogEntry(
        id: 'b2',
        title: 'Dune',
        authors: ['Frank Herbert'],
        language: 'eng',
        publisher: 'Chilton Books',
      ),
      // Same title and author, different edition — the blueprint's
      // "Dune 1965" against "Dune 50th Anniversary".
      CatalogEntry(
        id: 'b3',
        title: 'Dune',
        authors: ['Frank Herbert'],
        language: 'eng',
        publisher: 'Ace Books',
      ),
      CatalogEntry(
        id: 'b4',
        title: 'Suç ve Ceza',
        authors: ['Fyodor Dostoyevski'],
        language: 'tur',
      ),
    ],
    provenance: 'test fixture',
  );

  group('trigramSimilarity', () {
    test('is 1 for identical strings', () {
      expect(trigramSimilarity(trigrams('dune'), trigrams('dune')), 1.0);
    });

    test('is 0 when nothing is shared', () {
      expect(trigramSimilarity(trigrams('dune'), trigrams('xyz')), 0.0);
    });

    test('survives a single character OCR error', () {
      final similarity =
          trigramSimilarity(trigrams('dune herbert'), trigrams('dune herbcrt'));
      expect(similarity, greaterThan(0.5));
    });

    test('is 0 against an empty set', () {
      expect(trigramSimilarity(trigrams(''), trigrams('dune')), 0.0);
    });
  });

  group('approximateTextRank', () {
    test('rewards a query that covers a short entry exactly', () {
      final exact = approximateTextRank(['dune'], {'dune'});
      final buried = approximateTextRank(
        ['dune'],
        {'dune', 'messiah', 'frank', 'herbert', 'chilton'},
      );
      expect(exact, greaterThan(buried));
    });

    test('is 0 when no token matches', () {
      expect(approximateTextRank(['dune'], {'orwell'}), 0.0);
    });
  });

  group('bandFor', () {
    test('a strong score with a clear gap is MATCHED', () {
      expect(bandFor(0.90, 0.20), Confidence.matched);
    });

    test('a strong score with a close runner up drops to REVIEW', () {
      // "Dune 1965" against "Dune 50th Anniversary".
      expect(bandFor(0.90, 0.05), Confidence.review);
    });

    test('a middling score is REVIEW', () {
      expect(bandFor(0.60, 0.40), Confidence.review);
    });

    test('a weak score is UNKNOWN', () {
      expect(bandFor(0.30, 0.30), Confidence.unknown);
    });

    test('the band edges land where the blueprint puts them', () {
      expect(bandFor(0.45, 0.50), Confidence.review);
      expect(bandFor(0.4499, 0.50), Confidence.unknown);
      expect(bandFor(0.82, 0.12), Confidence.matched);
      expect(bandFor(0.82, 0.1199), Confidence.review);
    });
  });

  group('matchSpine', () {
    test('resolves a clean spine to the right book', () {
      final result = matchSpine(
        forwardText: '1984 GEORGE ORWELL',
        reverseText: 'ORWELL GEORGE 1984',
        catalog: catalog,
        publishers: publishers,
        languageHint: 'eng',
      );
      expect(result.best!.entry.id, 'b1');
      expect(result.confidence, isNot(Confidence.unknown));
    });

    test('keeps the reading direction that scores higher', () {
      // A spine where the forward reading only caught part of the title.
      final result = matchSpine(
        forwardText: 'SUÇ VE',
        reverseText: 'SUÇ VE CEZA DOSTOYEVSKI',
        catalog: catalog,
        publishers: publishers,
        languageHint: 'tur',
      );
      expect(result.best!.entry.id, 'b4');
      expect(result.query.raw, 'SUÇ VE CEZA DOSTOYEVSKI');
    });

    test('scores both directions the same when they are a pure reordering', () {
      // Trigram similarity pads each word separately and the text rank stand-in
      // is set based, so neither notices word order. Reversing the reading
      // order therefore changes nothing at this layer, and the forward reading
      // wins the tie. Recorded as a test because it means the reverse query is
      // only earning its keep once Postgres ts_rank, which is position aware,
      // is doing the ranking in Faz 5.
      final result = matchSpine(
        forwardText: 'DOSTOYEVSKI CEZA VE SUÇ',
        reverseText: 'SUÇ VE CEZA DOSTOYEVSKI',
        catalog: catalog,
        publishers: publishers,
        languageHint: 'tur',
      );
      expect(result.best!.entry.id, 'b4');
      expect(result.query.raw, 'DOSTOYEVSKI CEZA VE SUÇ');
    });

    test('two editions of one title do not come back as MATCHED', () {
      final result = matchSpine(
        forwardText: 'DUNE FRANK HERBERT',
        reverseText: 'HERBERT FRANK DUNE',
        catalog: catalog,
        publishers: publishers,
        languageHint: 'eng',
      );
      // Both editions carry the same title and author, so they score
      // identically and neither can be picked with confidence.
      expect({result.hits[0].entry.id, result.hits[1].entry.id}, {'b2', 'b3'});
      expect(result.bestScore, greaterThanOrEqualTo(0.82));
      expect(result.margin, lessThan(0.12));
      expect(result.confidence, Confidence.review);
    });

    test('unreadable text comes back UNKNOWN', () {
      final result = matchSpine(
        forwardText: 'XQ ZZW',
        reverseText: 'ZZW XQ',
        catalog: catalog,
        publishers: publishers,
      );
      expect(result.confidence, Confidence.unknown);
    });

    test('an empty query yields no hits at all', () {
      final result = matchSpine(
        forwardText: 'KİTAP',
        reverseText: 'KİTAP',
        catalog: catalog,
        publishers: publishers,
      );
      expect(result.hits, isEmpty);
      expect(result.confidence, Confidence.unknown);
    });

    test('returns at most three candidates', () {
      final result = matchSpine(
        forwardText: 'DUNE',
        reverseText: 'DUNE',
        catalog: catalog,
        publishers: publishers,
      );
      expect(result.hits.length, lessThanOrEqualTo(3));
    });
  });
}
