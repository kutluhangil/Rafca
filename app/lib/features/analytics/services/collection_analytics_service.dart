import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/tables.dart';
import '../../library/data/library_repository.dart';
import '../../library/models/library_models.dart';
import '../models/analytics_models.dart';

class CollectionAnalyticsService {
  const CollectionAnalyticsService();

  /// Analyzes a list of library books and returns a complete [CollectionAnalytics] snapshot.
  CollectionAnalytics analyze(List<LibraryBook> books, {int? explicitActiveLoans}) {
    if (books.isEmpty) {
      return const CollectionAnalytics(
        totalBooks: 0,
        estimatedShelfMeters: 0.0,
        readingProgress: ReadingProgressSummary(
          readCount: 0,
          readingCount: 0,
          unreadCount: 0,
          total: 0,
        ),
        colorSpectrum: [],
        dominantColor: ColorFamily.brass,
        uniqueAuthorsCount: 0,
        uniquePublishersCount: 0,
        activeLoansCount: 0,
        archetype: ArchivistArchetype.nocturnalSeeker,
        representativeSpineColors: [],
      );
    }

    final total = books.length;

    // 1. Estimated shelf meters (2.8 cm average spine thickness)
    final shelfMeters = double.parse(((total * 2.8) / 100).toStringAsFixed(2));

    // 2. Reading progress
    var readCount = 0;
    var readingCount = 0;
    var unreadCount = 0;

    for (final b in books) {
      switch (b.status) {
        case ReadingStatus.read:
          readCount++;
        case ReadingStatus.reading:
          readingCount++;
        case ReadingStatus.unread:
          unreadCount++;
      }
    }

    final readingProgress = ReadingProgressSummary(
      readCount: readCount,
      readingCount: readingCount,
      unreadCount: unreadCount,
      total: total,
    );

    // 3. Color spectrum classification
    final familyCounts = <ColorFamily, int>{};
    final familyHexes = <ColorFamily, List<String>>{};

    for (final family in ColorFamily.values) {
      familyCounts[family] = 0;
      familyHexes[family] = [];
    }

    for (final b in books) {
      final hex = b.spineColor;
      if (hex == null || hex.isEmpty) continue;
      final family = classifyHexColor(hex);
      familyCounts[family] = (familyCounts[family] ?? 0) + 1;
      familyHexes[family]!.add(hex);
    }

    final totalColored = familyCounts.values.fold<int>(0, (a, b) => a + b);
    final spectrumEntries = <ColorSpectrumEntry>[];

    for (final family in ColorFamily.values) {
      final count = familyCounts[family] ?? 0;
      if (count > 0 && totalColored > 0) {
        final percentage = double.parse(((count / totalColored) * 100).toStringAsFixed(1));
        spectrumEntries.add(
          ColorSpectrumEntry(
            family: family,
            count: count,
            percentage: percentage,
            paletteHexes: familyHexes[family]!,
          ),
        );
      }
    }

    spectrumEntries.sort((a, b) => b.count.compareTo(a.count));

    final dominantColor = spectrumEntries.isNotEmpty
        ? spectrumEntries.first.family
        : ColorFamily.brass;

    // 4. Authors
    final authorFreq = <String, int>{};
    for (final b in books) {
      final a = b.author.trim();
      if (a.isNotEmpty && a != 'Bilinmeyen Yazar') {
        authorFreq[a] = (authorFreq[a] ?? 0) + 1;
      }
    }

    String? topAuthor;
    var topAuthorCount = 0;
    for (final entry in authorFreq.entries) {
      if (entry.value > topAuthorCount) {
        topAuthor = entry.key;
        topAuthorCount = entry.value;
      }
    }

    // 5. Publishers
    final publisherFreq = <String, int>{};
    for (final b in books) {
      final p = b.publisher?.trim();
      if (p != null && p.isNotEmpty) {
        publisherFreq[p] = (publisherFreq[p] ?? 0) + 1;
      }
    }

    String? topPublisher;
    var topPublisherCount = 0;
    for (final entry in publisherFreq.entries) {
      if (entry.value > topPublisherCount) {
        topPublisher = entry.key;
        topPublisherCount = entry.value;
      }
    }

    // 6. Earliest publish year
    int? earliestYear;
    String? earliestTitle;
    for (final b in books) {
      final y = b.publishYear;
      if (y != null && y > 0 && y <= DateTime.now().year) {
        if (earliestYear == null || y < earliestYear) {
          earliestYear = y;
          earliestTitle = b.title;
        }
      }
    }

    // 7. Active loans count
    final activeLoans = explicitActiveLoans ?? books.where((b) => b.isOnLoan).length;

    // 8. Archetype
    final readRatio = readCount / total;
    final unreadRatio = unreadCount / total;
    final ArchivistArchetype archetype;

    if (total >= 40) {
      archetype = ArchivistArchetype.grandArchivist;
    } else if (readRatio >= 0.55) {
      archetype = ArchivistArchetype.devotedReader;
    } else if (unreadRatio >= 0.60) {
      archetype = ArchivistArchetype.passionateCurator;
    } else {
      archetype = ArchivistArchetype.nocturnalSeeker;
    }

    // 9. Representative spine colors (up to 20)
    final representativeColors = books
        .map((b) => b.spineColor)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .take(20)
        .toList();

    return CollectionAnalytics(
      totalBooks: total,
      estimatedShelfMeters: shelfMeters,
      readingProgress: readingProgress,
      colorSpectrum: spectrumEntries,
      dominantColor: dominantColor,
      uniqueAuthorsCount: authorFreq.keys.length,
      topAuthor: topAuthor,
      topAuthorCount: topAuthorCount,
      uniquePublishersCount: publisherFreq.keys.length,
      topPublisher: topPublisher,
      topPublisherCount: topPublisherCount,
      earliestPublishYear: earliestYear,
      earliestBookTitle: earliestTitle,
      activeLoansCount: activeLoans,
      archetype: archetype,
      representativeSpineColors: representativeColors,
    );
  }

  /// Maps a hex color string (e.g. `#C9963F`) to a [ColorFamily] via HSV space.
  ColorFamily classifyHexColor(String hex) {
    try {
      var clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        clean = 'FF$clean';
      }
      final intVal = int.parse(clean, radix: 16);
      final color = Color(intVal);

      final r = (color.r * 255.0).round().clamp(0, 255);
      final g = (color.g * 255.0).round().clamp(0, 255);
      final b = (color.b * 255.0).round().clamp(0, 255);

      final hsv = HSVColor.fromColor(Color.fromARGB(255, r, g, b));
      final hue = hsv.hue; // 0.0 - 360.0
      final sat = hsv.saturation; // 0.0 - 1.0
      final val = hsv.value; // 0.0 - 1.0

      // Near-achromatic check:
      if (sat < 0.15) {
        if (val < 0.40) return ColorFamily.obsidian;
        if (val > 0.65) return ColorFamily.parchment;
      }

      // Very deep pure blacks
      if (val < 0.12) {
        return ColorFamily.obsidian;
      }

      // Hue ranges:
      if (hue >= 20 && hue < 55) {
        return ColorFamily.brass;
      } else if (hue >= 55 && hue < 165) {
        return ColorFamily.forest;
      } else if (hue >= 165 && hue < 265) {
        return ColorFamily.midnight;
      } else if (hue >= 265 && hue < 345) {
        return ColorFamily.burgundy;
      } else {
        // hue >= 345 or hue < 20
        return ColorFamily.burgundy;
      }
    } catch (_) {
      return ColorFamily.brass;
    }
  }
}

final collectionAnalyticsServiceProvider = Provider<CollectionAnalyticsService>((ref) {
  return const CollectionAnalyticsService();
});

final collectionAnalyticsProvider = Provider.autoDispose<CollectionAnalytics>((ref) {
  final service = ref.watch(collectionAnalyticsServiceProvider);
  final booksAsync = ref.watch(
    libraryBooksProvider(
      (
        shelfId: null,
        statusFilter: null,
        onLoanFilter: null,
        sortOption: null,
        search: null,
      ),
    ),
  );
  final books = booksAsync.valueOrNull ?? const [];
  return service.analyze(books);
});

