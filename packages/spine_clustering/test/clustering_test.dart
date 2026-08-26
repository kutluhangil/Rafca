import 'package:spine_clustering/spine_clustering.dart';
import 'package:test/test.dart';

import 'shelf_fixture.dart';

void main() {
  group('segmentSpines', () {
    test('returns nothing for no input', () {
      expect(segmentSpines(const []), isEmpty);
    });

    test('finds one candidate per spine on a clean shelf', () {
      final elements = shelf([
        ['THE', 'SILENT', 'PAGES'],
        ['1984', 'ORWELL'],
        ['DUNE', 'HERBERT'],
        ['MOBY', 'DICK'],
        ['THE', 'TRIAL', 'KAFKA'],
      ]);

      final spines = segmentSpines(elements);

      expect(spines, hasLength(5));
      expect(spines.map((s) => s.id), ['c1', 'c2', 'c3', 'c4', 'c5']);
      expect(spines[0].rawTextForward, 'THE SILENT PAGES');
      expect(spines[1].rawTextForward, '1984 ORWELL');
      expect(spines[4].rawTextForward, 'THE TRIAL KAFKA');
    });

    test('emits the reverse reading order as well', () {
      final spines = segmentSpines(shelf([
        ['DUNE', 'FRANK', 'HERBERT'],
        ['1984', 'ORWELL'],
      ]));

      expect(spines[0].rawTextForward, 'DUNE FRANK HERBERT');
      expect(spines[0].rawTextReverse, 'HERBERT FRANK DUNE');
    });

    test('orders candidates left to right along the shelf', () {
      final elements = shelf([
        ['ALPHA'],
        ['BETA'],
        ['GAMMA'],
      ]);
      // Feed them in scrambled order; segmentation must still sort by
      // position, not by input order.
      final scrambled = elements.reversed.toList();

      final spines = segmentSpines(scrambled);

      expect(
        spines.map((s) => s.rawTextForward),
        ['ALPHA', 'BETA', 'GAMMA'],
      );
    });

    test('collapses the same word detected at several rotations', () {
      final base = shelf([
        ['DUNE', 'HERBERT'],
      ]);
      // The 180 degree pass finds the same two words in the same place.
      final duplicated = [
        ...base,
        for (final e in base)
          OcrTextElement(
            text: e.text,
            corners: e.corners,
            sourceRotation: 180,
            confidence: 0.4,
          ),
      ];

      final spines = segmentSpines(duplicated);

      expect(spines, hasLength(1));
      expect(spines.single.elements, hasLength(2));
      expect(spines.single.rawTextForward, 'DUNE HERBERT');
    });

    test('keeps the higher confidence reading of a duplicated word', () {
      final strong = word(
        'ORWELL',
        centerX: 200,
        centerY: 1200,
        angle: spineTextAngle,
        alongLength: 140,
        acrossHeight: 50,
        confidence: 0.9,
      );
      final weak = OcrTextElement(
        text: 'QRWELL',
        corners: strong.corners,
        sourceRotation: 180,
        confidence: 0.3,
      );
      final neighbour = word(
        '1984',
        centerX: 200,
        centerY: 1100,
        angle: spineTextAngle,
        alongLength: 96,
        acrossHeight: 50,
        confidence: 0.9,
      );

      final spines = segmentSpines([weak, strong, neighbour]);

      expect(spines.single.rawTextForward, 'ORWELL 1984');
    });

    test('drops single characters and punctuation noise', () {
      final elements = [
        ...shelf([
          ['KAFKA', 'TRIAL'],
        ]),
        word(
          '.',
          centerX: 205,
          centerY: 900,
          angle: spineTextAngle,
          alongLength: 10,
          acrossHeight: 50,
        ),
        word(
          '|',
          centerX: 205,
          centerY: 800,
          angle: spineTextAngle,
          alongLength: 10,
          acrossHeight: 50,
        ),
      ];

      final spines = segmentSpines(elements);

      expect(spines.single.rawTextForward, 'KAFKA TRIAL');
    });

    test('drops text far smaller than the median glyph height', () {
      final elements = [
        ...shelf([
          ['DUNE', 'HERBERT'],
          ['1984', 'ORWELL'],
        ]),
        // A publisher logo caption at a tenth of the lettering size.
        word(
          'penguin',
          centerX: 200,
          centerY: 950,
          angle: spineTextAngle,
          alongLength: 30,
          acrossHeight: 5,
        ),
      ];

      final spines = segmentSpines(elements);

      expect(spines.map((s) => s.rawTextForward), ['DUNE HERBERT', '1984 ORWELL']);
    });

    test('keeps a two line spine together and reads title before author', () {
      // Title on one line, author on a second line 60px across the spine —
      // well inside a 140px spine.
      final elements = [
        word('DUNE', centerX: 180, centerY: 1200, angle: spineTextAngle,
            alongLength: 96, acrossHeight: 50),
        word('MESSIAH', centerX: 180, centerY: 1090, angle: spineTextAngle,
            alongLength: 168, acrossHeight: 50),
        word('HERBERT', centerX: 240, centerY: 1200, angle: spineTextAngle,
            alongLength: 168, acrossHeight: 50),
        ...shelf([
          ['1984', 'ORWELL'],
        ], firstSpineX: 340),
      ];

      final spines = segmentSpines(elements);

      expect(spines, hasLength(2));
      expect(spines[0].rawTextForward, 'DUNE MESSIAH HERBERT');
      expect(spines[1].rawTextForward, '1984 ORWELL');
    });

    test('splits two thin spines that merged into one wide candidate', () {
      // Nine well separated spines plus a tenth cluster twice as wide, which
      // is really two touching paperbacks.
      final elements = [
        ...shelf([
          for (var i = 0; i < 9; i++) ['BOOK$i', 'AUTHOR$i'],
        ]),
        word('THIN', centerX: 1500, centerY: 1200, angle: spineTextAngle,
            alongLength: 96, acrossHeight: 50),
        word('ONE', centerX: 1505, centerY: 1100, angle: spineTextAngle,
            alongLength: 72, acrossHeight: 50),
        word('THIN', centerX: 1560, centerY: 1200, angle: spineTextAngle,
            alongLength: 96, acrossHeight: 50),
        word('TWO', centerX: 1565, centerY: 1100, angle: spineTextAngle,
            alongLength: 72, acrossHeight: 50),
      ];

      final spines = segmentSpines(elements);

      expect(spines, hasLength(11));
      expect(spines[9].rawTextForward, 'THIN ONE');
      expect(spines[10].rawTextForward, 'THIN TWO');
    });

    test('reports a pixel box that covers every element of the spine', () {
      final spines = segmentSpines(shelf([
        ['DUNE', 'HERBERT'],
      ]));

      final box = spines.single.bbox;
      for (final element in spines.single.elements) {
        for (final corner in element.corners) {
          expect(corner.x, greaterThanOrEqualTo(box.left - 0.001));
          expect(corner.x, lessThanOrEqualTo(box.right + 0.001));
          expect(corner.y, greaterThanOrEqualTo(box.top - 0.001));
          expect(corner.y, lessThanOrEqualTo(box.bottom + 0.001));
        }
      }
    });
  });

  group('GapStrategy.otsu', () {
    const otsu = ClusteringConfig(gapStrategy: GapStrategy.otsu);

    test('segments a clean shelf the same way the blueprint rule does', () {
      final elements = shelf([
        ['THE', 'SILENT', 'PAGES'],
        ['1984', 'ORWELL'],
        ['DUNE', 'HERBERT'],
        ['MOBY', 'DICK'],
        ['THE', 'TRIAL', 'KAFKA'],
      ]);

      final spines = segmentSpines(elements, config: otsu);

      expect(spines.map((s) => s.rawTextForward), [
        'THE SILENT PAGES',
        '1984 ORWELL',
        'DUNE HERBERT',
        'MOBY DICK',
        'THE TRIAL KAFKA',
      ]);
    });

    test('survives spines whose lettering sits on two lines', () {
      // Every spine carries a title line and an author line 60px apart, which
      // is what pulls the blueprint width estimate down.
      final elements = <OcrTextElement>[];
      for (var s = 0; s < 6; s++) {
        final x = 200 + s * 200.0;
        elements.addAll([
          word('TITLE$s', centerX: x, centerY: 1200, angle: spineTextAngle,
              alongLength: 140, acrossHeight: 50),
          word('WORDS$s', centerX: x, centerY: 1080, angle: spineTextAngle,
              alongLength: 140, acrossHeight: 50),
          word('AUTHOR$s', centerX: x + 60, centerY: 1200,
              angle: spineTextAngle, alongLength: 168, acrossHeight: 50),
        ]);
      }

      final spines = segmentSpines(elements, config: otsu);

      expect(spines, hasLength(6));
      expect(spines[0].rawTextForward, 'TITLE0 WORDS0 AUTHOR0');
    });
  });
}
