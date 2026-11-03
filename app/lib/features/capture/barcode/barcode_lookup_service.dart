import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/app_database.dart';
import '../../review/models/review_models.dart';
import 'isbn_validator.dart';

final barcodeLookupServiceProvider = Provider<BarcodeLookupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BarcodeLookupService(db: db);
});

/// Local-first ISBN lookup service querying local SQLite, then falling back to
/// Open Library and Google Books APIs, with local catalog caching.
class BarcodeLookupService {
  BarcodeLookupService({
    required this.db,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final AppDatabase db;
  final http.Client _client;

  /// Looks up book metadata by ISBN.
  ///
  /// Steps:
  /// 1. Normalizes ISBN (ISBN-10 -> ISBN-13). Returns null if invalid checksum.
  /// 2. Checks local SQLite `CatalogBooks` where `isbn13 = cleanIsbn`.
  /// 3. Falls back to Open Library Books API (`jscmd=data`).
  /// 4. Falls back to Google Books API (`q=isbn:{isbn}`).
  /// 5. Caches successful remote matches in local `CatalogBooks`.
  Future<ReviewCandidateBook?> lookupIsbn(String rawIsbn) async {
    final cleanIsbn = IsbnValidator.normalizeToIsbn13(rawIsbn);
    if (cleanIsbn == null) return null;

    // 1. Local catalog hit (zero-network)
    final localBook = await _lookupLocal(cleanIsbn);
    if (localBook != null) return localBook;

    // 2. Open Library Books API
    try {
      final olBook = await _lookupOpenLibrary(cleanIsbn);
      if (olBook != null) {
        await _cacheCatalogBook(cleanIsbn, olBook);
        return olBook;
      }
    } catch (_) {
      // Continue to Google Books fallback
    }

    // 3. Google Books API
    try {
      final gbBook = await _lookupGoogleBooks(cleanIsbn);
      if (gbBook != null) {
        await _cacheCatalogBook(cleanIsbn, gbBook);
        return gbBook;
      }
    } catch (_) {
      // Network or parsing failure
    }

    return null;
  }

  Future<ReviewCandidateBook?> _lookupLocal(String isbn13) async {
    final row = await (db.select(db.catalogBooks)
          ..where((tbl) => tbl.isbn13.equals(isbn13))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;

    return ReviewCandidateBook(
      id: row.id,
      title: row.title,
      author: row.authors.isNotEmpty ? row.authors.first : '',
      publisher: row.publisher,
      publishYear: row.publishYear,
      coverUrl: row.coverUrl,
      score: 1.0,
    );
  }

  Future<ReviewCandidateBook?> _lookupOpenLibrary(String isbn13) async {
    final uri = Uri.parse(
      'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn13&format=json&jscmd=data',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) return null;

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final key = 'ISBN:$isbn13';
    if (!jsonMap.containsKey(key)) return null;

    final bookData = jsonMap[key] as Map<String, dynamic>;
    final title = bookData['title'] as String? ?? '';
    if (title.isEmpty) return null;

    var author = '';
    final authorsList = bookData['authors'] as List<dynamic>?;
    if (authorsList != null && authorsList.isNotEmpty) {
      final first = authorsList.first as Map<String, dynamic>;
      author = first['name'] as String? ?? '';
    }

    var publisher = '';
    final publishersList = bookData['publishers'] as List<dynamic>?;
    if (publishersList != null && publishersList.isNotEmpty) {
      final first = publishersList.first as Map<String, dynamic>;
      publisher = first['name'] as String? ?? '';
    }

    int? publishYear;
    final publishDate = bookData['publish_date'] as String?;
    if (publishDate != null) {
      final match = RegExp(r'\b(19\d\d|20\d\d)\b').firstMatch(publishDate);
      if (match != null) {
        publishYear = int.tryParse(match.group(1)!);
      }
    }

    String? coverUrl;
    final coverMap = bookData['cover'] as Map<String, dynamic>?;
    if (coverMap != null) {
      coverUrl = coverMap['large'] as String? ??
          coverMap['medium'] as String? ??
          coverMap['small'] as String?;
    }

    final id = isbn13.hashCode & 0x7FFFFFFF;
    return ReviewCandidateBook(
      id: id,
      title: title,
      author: author,
      publisher: publisher.isNotEmpty ? publisher : null,
      publishYear: publishYear,
      coverUrl: coverUrl,
      score: 1.0,
    );
  }

  Future<ReviewCandidateBook?> _lookupGoogleBooks(String isbn13) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn13',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) return null;

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final totalItems = jsonMap['totalItems'] as int? ?? 0;
    if (totalItems == 0) return null;

    final items = jsonMap['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    final firstItem = items.first as Map<String, dynamic>;
    final volumeInfo = firstItem['volumeInfo'] as Map<String, dynamic>?;
    if (volumeInfo == null) return null;

    final title = volumeInfo['title'] as String? ?? '';
    if (title.isEmpty) return null;

    var author = '';
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    if (authorsList != null && authorsList.isNotEmpty) {
      author = authorsList.first as String? ?? '';
    }

    final publisher = volumeInfo['publisher'] as String?;

    int? publishYear;
    final publishedDate = volumeInfo['publishedDate'] as String?;
    if (publishedDate != null) {
      final match = RegExp(r'\b(19\d\d|20\d\d)\b').firstMatch(publishedDate);
      if (match != null) {
        publishYear = int.tryParse(match.group(1)!);
      }
    }

    String? coverUrl;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    if (imageLinks != null) {
      var thumb = imageLinks['thumbnail'] as String? ??
          imageLinks['smallThumbnail'] as String?;
      if (thumb != null && thumb.startsWith('http://')) {
        thumb = thumb.replaceFirst('http://', 'https://');
      }
      coverUrl = thumb;
    }

    final id = isbn13.hashCode & 0x7FFFFFFF;
    return ReviewCandidateBook(
      id: id,
      title: title,
      author: author,
      publisher: publisher,
      publishYear: publishYear,
      coverUrl: coverUrl,
      score: 1.0,
    );
  }

  Future<void> _cacheCatalogBook(String isbn13, ReviewCandidateBook book) async {
    try {
      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion(
              id: Value(book.id),
              isbn13: Value(isbn13),
              title: Value(book.title),
              authors: Value([book.author]),
              publisher: Value(book.publisher),
              publishYear: Value(book.publishYear),
              coverUrl: Value(book.coverUrl),
            ),
            mode: InsertMode.insertOrReplace,
          );
    } catch (_) {
      // Non-critical local cache failure
    }
  }
}
