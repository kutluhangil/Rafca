import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/features/capture/barcode/barcode_lookup_service.dart';

void main() {
  group('BarcodeLookupService', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('returns null immediately for invalid ISBN', () async {
      final service = BarcodeLookupService(db: db);
      final result = await service.lookupIsbn('123456');
      expect(result, isNull);
    });

    test('returns book from local catalog without network call', () async {
      // Seed local catalog
      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion(
              id: const Value(101),
              isbn13: const Value('9786051850016'),
              title: const Value('Kürk Mantolu Madonna'),
              authors: const Value(['Sabahattin Ali']),
              publisher: const Value('Yapı Kredi Yayınları'),
              publishYear: const Value(2020),
            ),
          );

      var networkCalled = false;
      final mockClient = MockClient((request) async {
        networkCalled = true;
        return http.Response('{}', 404);
      });

      final service = BarcodeLookupService(db: db, httpClient: mockClient);
      final book = await service.lookupIsbn('978-605-185-001-6');

      expect(book, isNotNull);
      expect(book!.id, equals(101));
      expect(book.title, equals('Kürk Mantolu Madonna'));
      expect(book.author, equals('Sabahattin Ali'));
      expect(book.publisher, equals('Yapı Kredi Yayınları'));
      expect(book.publishYear, equals(2020));
      expect(book.score, equals(1.0));
      expect(networkCalled, isFalse);
    });

    test('falls back to Open Library, parses and caches book in local db', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'openlibrary.org') {
          final payload = {
            'ISBN:9780140328721': {
              'title': 'Fantastic Mr Fox',
              'authors': [
                {'name': 'Roald Dahl'}
              ],
              'publishers': [
                {'name': 'Puffin Books'}
              ],
              'publish_date': '1988',
              'cover': {
                'large': 'https://covers.openlibrary.org/b/id/123-L.jpg',
              },
            }
          };
          return http.Response(jsonEncode(payload), 200);
        }
        return http.Response('{}', 404);
      });

      final service = BarcodeLookupService(db: db, httpClient: mockClient);
      final book = await service.lookupIsbn('9780140328721');

      expect(book, isNotNull);
      expect(book!.title, equals('Fantastic Mr Fox'));
      expect(book.author, equals('Roald Dahl'));
      expect(book.publisher, equals('Puffin Books'));
      expect(book.publishYear, equals(1988));
      expect(book.coverUrl, equals('https://covers.openlibrary.org/b/id/123-L.jpg'));

      // Verify cached in local SQLite
      final cached = await (db.select(db.catalogBooks)
            ..where((tbl) => tbl.isbn13.equals('9780140328721')))
          .getSingleOrNull();

      expect(cached, isNotNull);
      expect(cached!.title, equals('Fantastic Mr Fox'));
      expect(cached.authors.first, equals('Roald Dahl'));
    });

    test('falls back to Google Books when Open Library returns empty', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'openlibrary.org') {
          return http.Response('{}', 200);
        }
        if (request.url.host == 'www.googleapis.com') {
          final payload = {
            'totalItems': 1,
            'items': [
              {
                'volumeInfo': {
                  'title': 'Dune',
                  'authors': ['Frank Herbert'],
                  'publisher': 'Chilton Books',
                  'publishedDate': '1965-08-01',
                  'imageLinks': {
                    'thumbnail': 'http://books.google.com/dune.jpg',
                  },
                }
              }
            ]
          };
          return http.Response(jsonEncode(payload), 200);
        }
        return http.Response('{}', 404);
      });

      final service = BarcodeLookupService(db: db, httpClient: mockClient);
      final book = await service.lookupIsbn('9780441172719');

      expect(book, isNotNull);
      expect(book!.title, equals('Dune'));
      expect(book.author, equals('Frank Herbert'));
      expect(book.publisher, equals('Chilton Books'));
      expect(book.publishYear, equals(1965));
      expect(book.coverUrl, equals('https://books.google.com/dune.jpg'));
    });

    test('returns null when book is not found anywhere', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final service = BarcodeLookupService(db: db, httpClient: mockClient);
      final book = await service.lookupIsbn('9780000000002');
      expect(book, isNull);
    });
  });
}
