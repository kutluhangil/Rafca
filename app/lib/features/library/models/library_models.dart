import 'package:flutter/foundation.dart';
import '../../../core/database/tables.dart';

/// A unified view of a book in the user's library, joining `UserBooks`, `CatalogBooks`
/// and optionally `Shelves`.
@immutable
class LibraryBook {
  const LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    this.catalogBookId,
    this.publisher,
    this.publishYear,
    this.coverUrl,
    this.status = ReadingStatus.unread,
    this.confidence = MatchConfidence.matched,
    this.spineColor,
    this.capturePath,
    this.shelfId,
    this.shelfName,
    required this.addedAt,
  });

  /// UserBook table primary key (e.g. `scanId_c1`).
  final String id;

  /// Foreign key to CatalogBooks, null for custom manual entries.
  final int? catalogBookId;

  /// Display title from catalog or manual entry.
  final String title;

  /// Display author from catalog or manual entry.
  final String author;

  final String? publisher;
  final int? publishYear;
  final String? coverUrl;
  final ReadingStatus status;
  final MatchConfidence confidence;

  /// Hex `#RRGGBB` extracted from the physical spine crop.
  final String? spineColor;

  /// Local path to the cropped spine image under `spine/captures/`.
  final String? capturePath;

  /// Assigned shelf ID, if any.
  final String? shelfId;

  /// Assigned shelf name, if joined.
  final String? shelfName;

  final DateTime addedAt;

  LibraryBook copyWith({
    String? id,
    int? catalogBookId,
    String? title,
    String? author,
    String? publisher,
    int? publishYear,
    String? coverUrl,
    ReadingStatus? status,
    MatchConfidence? confidence,
    String? spineColor,
    String? capturePath,
    String? shelfId,
    String? shelfName,
    DateTime? addedAt,
  }) {
    return LibraryBook(
      id: id ?? this.id,
      catalogBookId: catalogBookId ?? this.catalogBookId,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      spineColor: spineColor ?? this.spineColor,
      capturePath: capturePath ?? this.capturePath,
      shelfId: shelfId ?? this.shelfId,
      shelfName: shelfName ?? this.shelfName,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

/// A shelf containing books with metadata for rendering mini ShelfStrips.
@immutable
class LibraryShelf {
  const LibraryShelf({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    required this.createdAt,
    this.bookCount = 0,
    this.spineColors = const [],
  });

  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final int bookCount;

  /// Colors of books on this shelf for the mini ShelfStrip.
  final List<String> spineColors;
}
