/// Utility for cleaning, validating, and converting ISBN-10 and ISBN-13 numbers.
abstract final class IsbnValidator {
  const IsbnValidator._();

  /// Strips formatting characters (hyphens, spaces) and uppercases.
  static String clean(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase().trim();
  }

  /// Validates standard ISBN-10 checksum (Modulo 11).
  static bool isValidIsbn10(String clean) {
    if (clean.length != 10) return false;

    var sum = 0;
    for (var i = 0; i < 9; i++) {
      final code = clean.codeUnitAt(i);
      if (code < 48 || code > 57) return false; // Not a digit
      sum += (code - 48) * (10 - i);
    }

    final lastChar = clean[9];
    if (lastChar == 'X') {
      sum += 10;
    } else {
      final code = lastChar.codeUnitAt(0);
      if (code < 48 || code > 57) return false;
      sum += (code - 48);
    }

    return sum % 11 == 0;
  }

  /// Validates standard ISBN-13 / EAN-13 checksum (Modulo 10 with 1,3 weights).
  static bool isValidIsbn13(String clean) {
    if (clean.length != 13) return false;
    if (!clean.startsWith('978') && !clean.startsWith('979')) return false;

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final code = clean.codeUnitAt(i);
      if (code < 48 || code > 57) return false;
      final digit = code - 48;
      sum += (i.isEven) ? digit : digit * 3;
    }

    final lastCode = clean.codeUnitAt(12);
    if (lastCode < 48 || lastCode > 57) return false;
    final checkDigit = lastCode - 48;

    final expectedCheckDigit = (10 - (sum % 10)) % 10;
    return checkDigit == expectedCheckDigit;
  }

  /// Checks if the raw string is a valid ISBN-10 or ISBN-13.
  static bool isValid(String raw) {
    final c = clean(raw);
    if (c.length == 10) return isValidIsbn10(c);
    if (c.length == 13) return isValidIsbn13(c);
    return false;
  }

  /// Converts a valid 10-digit ISBN into a canonical 13-digit EAN (ISBN-13).
  static String? isbn10ToIsbn13(String isbn10) {
    final c = clean(isbn10);
    if (!isValidIsbn10(c)) return null;

    final core = '978${c.substring(0, 9)}';
    var sum = 0;
    for (var i = 0; i < core.length; i++) {
      final digit = core.codeUnitAt(i) - 48;
      sum += (i.isEven) ? digit : digit * 3;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return '$core$checkDigit';
  }

  /// Normalizes any valid ISBN (10 or 13 digits) into a canonical 13-digit string.
  static String? normalizeToIsbn13(String raw) {
    final c = clean(raw);
    if (isValidIsbn13(c)) return c;
    if (isValidIsbn10(c)) return isbn10ToIsbn13(c);
    return null;
  }

  /// Formats an ISBN-13 with hyphens for legible presentation.
  static String format(String isbn13) {
    final c = clean(isbn13);
    if (c.length != 13) return isbn13;
    // Standard grouping: Prefix(3) - Registration Group(1-3) - Registrant(2-6) - Publication(1-5) - Check(1)
    // E.g. 978-605-185-123-4 or 978-0-123456-78-9
    return '${c.substring(0, 3)}-${c.substring(3, 6)}-${c.substring(6, 12)}-${c.substring(12)}';
  }
}
