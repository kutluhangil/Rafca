import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/features/capture/barcode/isbn_validator.dart';

void main() {
  group('IsbnValidator', () {
    test('cleans whitespace and hyphens', () {
      expect(IsbnValidator.clean(' 978-0-13-235088-4 '), '9780132350884');
      expect(IsbnValidator.clean('0-8044-2957-x'), '080442957X');
    });

    test('validates authentic ISBN-10 numbers with numeric and X check digits', () {
      expect(IsbnValidator.isValidIsbn10('0306406152'), isTrue);
      expect(IsbnValidator.isValidIsbn10('080442957X'), isTrue);
      expect(IsbnValidator.isValidIsbn10('097522980X'), isTrue);

      // Invalid checksum
      expect(IsbnValidator.isValidIsbn10('0306406153'), isFalse);
      // Bad length
      expect(IsbnValidator.isValidIsbn10('12345'), isFalse);
    });

    test('validates authentic ISBN-13 numbers', () {
      expect(IsbnValidator.isValidIsbn13('9780306406157'), isTrue);
      expect(IsbnValidator.isValidIsbn13('9786051850016'), isTrue);
      expect(IsbnValidator.isValidIsbn13('9780132350884'), isTrue);

      // Wrong check digit
      expect(IsbnValidator.isValidIsbn13('9780306406158'), isFalse);
      // Non 978/979 prefix
      expect(IsbnValidator.isValidIsbn13('1234567890123'), isFalse);
    });

    test('converts ISBN-10 to valid canonical ISBN-13', () {
      final isbn13 = IsbnValidator.isbn10ToIsbn13('0306406152');
      expect(isbn13, '9780306406157');
      expect(IsbnValidator.isValidIsbn13(isbn13!), isTrue);
    });

    test('normalizeToIsbn13 handles both 10 and 13 digit inputs', () {
      expect(IsbnValidator.normalizeToIsbn13('0-306-40615-2'), '9780306406157');
      expect(IsbnValidator.normalizeToIsbn13('978-0-306-40615-7'), '9780306406157');
      expect(IsbnValidator.normalizeToIsbn13('invalid-isbn'), isNull);
    });
  });
}
