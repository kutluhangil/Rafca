import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/library/models/library_models.dart';
import 'package:rafca/features/settings/services/export_service.dart';

void main() {
  group('ExportService', () {
    const service = ExportService();
    final now = DateTime(2026, 11, 3, 12, 0, 0);

    final books = [
      LibraryBook(
        id: 'ub_1',
        title: 'Saatleri Ayarlama Enstitüsü',
        author: 'Ahmet Hamdi Tanpınar',
        publisher: 'Dergâh Yayınları',
        publishYear: 1961,
        status: ReadingStatus.read,
        confidence: MatchConfidence.matched,
        spineColor: '#304E2E',
        shelfId: 'shelf_1',
        shelfName: 'Klasikler',
        addedAt: now,
      ),
      LibraryBook(
        id: 'ub_2',
        title: 'Körlük, "Özel Baskı"',
        author: 'José Saramago',
        status: ReadingStatus.reading,
        confidence: MatchConfidence.matched,
        addedAt: now,
      ),
    ];

    test('generateCsv formats books correctly and escapes commas/quotes', () {
      final csv = service.generateCsv(books);
      final lines = csv.trim().split('\n');

      expect(lines.length, 3);
      expect(lines[0], 'id,title,author,publisher,publish_year,status,shelf_name,confidence,added_at');
      expect(lines[1], contains('Saatleri Ayarlama Enstitüsü'));
      expect(lines[1], contains('Ahmet Hamdi Tanpınar'));
      expect(lines[1], contains('Dergâh Yayınları'));
      expect(lines[1], contains('1961'));
      expect(lines[1], contains('read'));
      expect(lines[1], contains('Klasikler'));

      // Line 2 has title with comma and quotes: should be escaped
      expect(lines[2], contains('"Körlük, ""Özel Baskı"""'));
      expect(lines[2], contains('José Saramago'));
      expect(lines[2], contains('reading'));
    });

    test('generateJson outputs valid parseable JSON list', () {
      final jsonStr = service.generateJson(books);
      final list = json.decode(jsonStr) as List<dynamic>;

      expect(list.length, 2);
      final first = list[0] as Map<String, dynamic>;
      expect(first['id'], 'ub_1');
      expect(first['title'], 'Saatleri Ayarlama Enstitüsü');
      expect(first['author'], 'Ahmet Hamdi Tanpınar');
      expect(first['publisher'], 'Dergâh Yayınları');
      expect(first['publish_year'], 1961);
      expect(first['status'], 'read');
      expect(first['shelf_name'], 'Klasikler');
      expect(first['confidence'], 'matched');
      expect(first['spine_color'], '#304E2E');

      final second = list[1] as Map<String, dynamic>;
      expect(second['id'], 'ub_2');
      expect(second['title'], 'Körlük, "Özel Baskı"');
      expect(second['status'], 'reading');
    });
  });
}
