import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/analytics/models/analytics_models.dart';
import 'package:rafca/features/analytics/services/collection_analytics_service.dart';
import 'package:rafca/features/library/models/library_models.dart';

void main() {
  group('CollectionAnalyticsService', () {
    const service = CollectionAnalyticsService();

    test('empty collection returns safe neutral defaults', () {
      final result = service.analyze([]);
      expect(result.totalBooks, 0);
      expect(result.estimatedShelfMeters, 0.0);
      expect(result.colorSpectrum, isEmpty);
      expect(result.uniqueAuthorsCount, 0);
      expect(result.uniquePublishersCount, 0);
      expect(result.activeLoansCount, 0);
    });

    test('color classification categorizes hex codes into correct families', () {
      expect(service.classifyHexColor('#C9963F'), ColorFamily.brass);
      expect(service.classifyHexColor('#151311'), ColorFamily.obsidian);
      expect(service.classifyHexColor('#1D1B19'), ColorFamily.obsidian);
      expect(service.classifyHexColor('#304E2E'), ColorFamily.forest);
      expect(service.classifyHexColor('#8B2323'), ColorFamily.burgundy);
      expect(service.classifyHexColor('#1B2631'), ColorFamily.midnight);
      expect(service.classifyHexColor('#F5F0E8'), ColorFamily.parchment);
    });

    test('calculates shelf meters, reading progress, and top entities accurately', () {
      final now = DateTime(2026, 11, 3);

      final books = [
        LibraryBook(
          id: '1',
          title: 'Karamazov Kardeşler',
          author: 'Dostoyevski',
          publisher: 'İletişim',
          publishYear: 1880,
          status: ReadingStatus.read,
          spineColor: '#8B2323', // Burgundy
          addedAt: now,
        ),
        LibraryBook(
          id: '2',
          title: 'Suç ve Ceza',
          author: 'Dostoyevski',
          publisher: 'İletişim',
          publishYear: 1866,
          status: ReadingStatus.read,
          spineColor: '#8B2323', // Burgundy
          addedAt: now,
        ),
        LibraryBook(
          id: '3',
          title: 'Körlük',
          author: 'Jose Saramago',
          publisher: 'Kırmızı Kedi',
          publishYear: 1995,
          status: ReadingStatus.reading,
          spineColor: '#C9963F', // Brass
          addedAt: now,
        ),
        LibraryBook(
          id: '4',
          title: 'Dune',
          author: 'Frank Herbert',
          publisher: 'İthaki',
          publishYear: 1965,
          status: ReadingStatus.unread,
          spineColor: '#304E2E', // Forest
          addedAt: now,
        ),
      ];

      final result = service.analyze(books);

      expect(result.totalBooks, 4);
      // 4 * 2.8 / 100 = 0.11 meters
      expect(result.estimatedShelfMeters, 0.11);

      // Reading progress
      expect(result.readingProgress.readCount, 2);
      expect(result.readingProgress.readingCount, 1);
      expect(result.readingProgress.unreadCount, 1);
      expect(result.readingProgress.readRatio, 50.0);

      // Top Author & Publisher
      expect(result.topAuthor, 'Dostoyevski');
      expect(result.topAuthorCount, 2);
      expect(result.uniqueAuthorsCount, 3);
      expect(result.topPublisher, 'İletişim');
      expect(result.topPublisherCount, 2);
      expect(result.uniquePublishersCount, 3);

      // Earliest year
      expect(result.earliestPublishYear, 1866);
      expect(result.earliestBookTitle, 'Suç ve Ceza');

      // Dominant color family
      expect(result.dominantColor, ColorFamily.burgundy);
      expect(result.colorSpectrum.first.family, ColorFamily.burgundy);
      expect(result.colorSpectrum.first.count, 2);
    });

    test('assigns grandArchivist archetype when collection has >= 40 books', () {
      final books = List.generate(
        42,
        (i) => LibraryBook(
          id: '$i',
          title: 'Kitap $i',
          author: 'Yazar $i',
          status: ReadingStatus.unread,
          addedAt: DateTime(2026, 11, 3),
        ),
      );

      final result = service.analyze(books);
      expect(result.archetype, ArchivistArchetype.grandArchivist);
    });
  });
}
