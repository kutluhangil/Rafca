import 'package:spike/eval/normalize.dart';
import 'package:test/test.dart';

void main() {
  final publishers = PublisherIndex([
    'penguin classics',
    'penguin',
    'is bankasi kultur yayinlari',
    'can yayinlari',
  ]..sort((a, b) => b.length.compareTo(a.length)));

  group('foldCase', () {
    test('folds Turkish dotted and dotless i to a single letter', () {
      expect(foldCase('İSTANBUL'), 'istanbul');
      expect(foldCase('ISTANBUL'), 'istanbul');
      expect(foldCase('ılık'), 'ilik');
    });

    test('strips Turkish diacritics', () {
      expect(foldCase('ÇĞÖŞÜ'), 'cgosu');
      expect(foldCase('Şeker Portakalı'), 'seker portakali');
    });

    test('strips common Latin diacritics', () {
      expect(foldCase('Les Misérables'), 'les miserables');
      expect(foldCase('Ölüm'), 'olum');
    });
  });

  group('normalizeQuery', () {
    test('drops the blueprint noise words', () {
      final q = normalizeQuery('SUÇ VE CEZA ROMAN CİLT 1', publishers: publishers);
      expect(q.tokens, ['suc', 've', 'ceza', '1']);
    });

    test('lifts the publisher out of the query and keeps it as a signal', () {
      final q = normalizeQuery('1984 GEORGE ORWELL PENGUIN CLASSICS',
          publishers: publishers);
      expect(q.publisherHint, 'penguin classics');
      expect(q.text, '1984 george orwell');
    });

    test('prefers the longest matching publisher name', () {
      final q = normalizeQuery('DUNE PENGUIN CLASSICS', publishers: publishers);
      expect(q.publisherHint, 'penguin classics');
    });

    test('collapses punctuation and repeated spaces', () {
      final q = normalizeQuery('  DUNE:   MESSIAH!! ', publishers: publishers);
      expect(q.text, 'dune messiah');
    });

    test('reports an all-noise query as empty', () {
      final q = normalizeQuery('KİTAP ROMAN', publishers: publishers);
      expect(q.isEmpty, isTrue);
    });
  });

  group('PublisherIndex.fromFile', () {
    test('fails loudly when the shared list is missing', () {
      expect(
        () => PublisherIndex.fromFile('does/not/exist.txt'),
        throwsA(isA<StateError>()),
      );
    });

    test('loads the list shared with the Go service', () {
      final index = PublisherIndex.fromFile('../data/publishers.txt');
      expect(index.names, isNotEmpty);
      expect(index.findIn('1984 george orwell penguin classics'),
          'penguin classics');
      expect(index.findIn('suc ve ceza'), isNull);
    });
  });
}
