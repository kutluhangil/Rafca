import 'package:flutter/material.dart';

/// Predefined color families inspired by Nocturnal Archivist palette.
enum ColorFamily {
  brass,
  obsidian,
  forest,
  burgundy,
  midnight,
  parchment;

  String get defaultLabel {
    switch (this) {
      case ColorFamily.brass:
        return 'Pirinç & Kehribar';
      case ColorFamily.obsidian:
        return 'Nocturnal Obsidian';
      case ColorFamily.forest:
        return 'Orman Yeşili & Adaçayı';
      case ColorFamily.burgundy:
        return 'Bordo & Mürdüm';
      case ColorFamily.midnight:
        return 'Gece Mavisi & Çivit';
      case ColorFamily.parchment:
        return 'Fildişi & Parşömen';
    }
  }

  Color get representativeColor {
    switch (this) {
      case ColorFamily.brass:
        return const Color(0xFFC9963F);
      case ColorFamily.obsidian:
        return const Color(0xFF221F1D);
      case ColorFamily.forest:
        return const Color(0xFF304E2E);
      case ColorFamily.burgundy:
        return const Color(0xFF8B2323);
      case ColorFamily.midnight:
        return const Color(0xFF1B2631);
      case ColorFamily.parchment:
        return const Color(0xFFE9E2D6);
    }
  }
}

/// Distribution breakdown of a single color family in the user's collection.
@immutable
class ColorSpectrumEntry {
  const ColorSpectrumEntry({
    required this.family,
    required this.count,
    required this.percentage,
    required this.paletteHexes,
  });

  final ColorFamily family;
  final int count;
  final double percentage; // 0.0 - 100.0
  final List<String> paletteHexes;
}

/// Reading progress breakdown.
@immutable
class ReadingProgressSummary {
  const ReadingProgressSummary({
    required this.readCount,
    required this.readingCount,
    required this.unreadCount,
    required this.total,
  });

  final int readCount;
  final int readingCount;
  final int unreadCount;
  final int total;

  double get readRatio => total > 0 ? (readCount / total) * 100 : 0.0;
  double get readingRatio => total > 0 ? (readingCount / total) * 100 : 0.0;
  double get unreadRatio => total > 0 ? (unreadCount / total) * 100 : 0.0;
}

/// High-level poetic archetype title assigned to the archivist.
enum ArchivistArchetype {
  grandArchivist, // > 40 books
  devotedReader,  // > 60% read
  passionateCurator, // high unread / collector
  nocturnalSeeker; // balanced

  String get defaultLabel {
    switch (this) {
      case ArchivistArchetype.grandArchivist:
        return 'Büyük Arşiv Muhafızı';
      case ArchivistArchetype.devotedReader:
        return 'Edebi Gezgin';
      case ArchivistArchetype.passionateCurator:
        return 'Tutkulu Küratör';
      case ArchivistArchetype.nocturnalSeeker:
        return 'Gece Arşivcisi';
    }
  }
}

/// Formats for the shareable Wrapped infographic card.
enum WrappedCardFormat {
  story, // 9:16 vertical (Instagram / WhatsApp story)
  square, // 1:1 square (Feed / X / Threads)
}

/// Comprehensive analytics snapshot of the library collection.
@immutable
class CollectionAnalytics {
  const CollectionAnalytics({
    required this.totalBooks,
    required this.estimatedShelfMeters,
    required this.readingProgress,
    required this.colorSpectrum,
    required this.dominantColor,
    required this.uniqueAuthorsCount,
    this.topAuthor,
    this.topAuthorCount = 0,
    required this.uniquePublishersCount,
    this.topPublisher,
    this.topPublisherCount = 0,
    this.earliestPublishYear,
    this.earliestBookTitle,
    required this.activeLoansCount,
    required this.archetype,
    required this.representativeSpineColors,
  });

  final int totalBooks;
  final double estimatedShelfMeters;
  final ReadingProgressSummary readingProgress;
  final List<ColorSpectrumEntry> colorSpectrum;
  final ColorFamily dominantColor;
  final int uniqueAuthorsCount;
  final String? topAuthor;
  final int topAuthorCount;
  final int uniquePublishersCount;
  final String? topPublisher;
  final int topPublisherCount;
  final int? earliestPublishYear;
  final String? earliestBookTitle;
  final int activeLoansCount;
  final ArchivistArchetype archetype;
  final List<String> representativeSpineColors;
}
