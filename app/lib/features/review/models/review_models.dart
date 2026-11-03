import 'package:flutter/foundation.dart';
import '../../../core/database/tables.dart';

/// One candidate book resolution returned by the matcher or selected by the user.
@immutable
class ReviewCandidateBook {
  const ReviewCandidateBook({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.publishYear,
    this.coverUrl,
    this.score = 0.0,
  });

  final int id;
  final String title;
  final String author;
  final String? publisher;
  final int? publishYear;
  final String? coverUrl;
  final double score;

  ReviewCandidateBook copyWith({
    int? id,
    String? title,
    String? author,
    String? publisher,
    int? publishYear,
    String? coverUrl,
    double? score,
  }) {
    return ReviewCandidateBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      coverUrl: coverUrl ?? this.coverUrl,
      score: score ?? this.score,
    );
  }
}

/// A scanned spine candidate item undergoing review and correction.
@immutable
class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.cropPath,
    required this.spineColor,
    required this.rawText,
    required this.confidence,
    required this.confidenceScore,
    this.selectedBook,
    this.alternatives = const [],
    this.manualTitle,
    this.manualAuthor,
    this.isDiscarded = false,
  });

  /// Stable spine identifier, e.g. `c1`, `c2`.
  final String id;

  /// Local path to the cropped spine image under `spine/captures/`.
  final String cropPath;

  /// Hex colour `#RRGGBB` extracted from the crop.
  final String spineColor;

  /// Forward read OCR text.
  final String rawText;

  /// Resolution band: matched, review, unknown.
  final MatchConfidence confidence;

  /// Match confidence score [0.0 - 1.0].
  final double confidenceScore;

  /// The currently accepted book matching this spine, if any.
  final ReviewCandidateBook? selectedBook;

  /// Alternative matching editions/books suggested for user review.
  final List<ReviewCandidateBook> alternatives;

  /// If manually typed or searched without catalog id.
  final String? manualTitle;
  final String? manualAuthor;

  /// True if user marked as "Not a book".
  final bool isDiscarded;

  String get displayTitle =>
      selectedBook?.title ?? manualTitle ?? 'Bilinmeyen Eser / Unknown Volume';

  String get displayAuthor =>
      selectedBook?.author ?? manualAuthor ?? 'Yazar Belirtilmedi';

  String? get displayCoverUrl => selectedBook?.coverUrl;

  ReviewItem copyWith({
    String? id,
    String? cropPath,
    String? spineColor,
    String? rawText,
    MatchConfidence? confidence,
    double? confidenceScore,
    ReviewCandidateBook? selectedBook,
    List<ReviewCandidateBook>? alternatives,
    String? manualTitle,
    String? manualAuthor,
    bool? isDiscarded,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      cropPath: cropPath ?? this.cropPath,
      spineColor: spineColor ?? this.spineColor,
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      selectedBook: selectedBook ?? this.selectedBook,
      alternatives: alternatives ?? this.alternatives,
      manualTitle: manualTitle ?? this.manualTitle,
      manualAuthor: manualAuthor ?? this.manualAuthor,
      isDiscarded: isDiscarded ?? this.isDiscarded,
    );
  }
}

/// The entire batch of scanned spines being reviewed.
@immutable
class ReviewBatch {
  const ReviewBatch({
    required this.scanId,
    required this.sourceImagePath,
    required this.items,
  });

  final String scanId;
  final String sourceImagePath;
  final List<ReviewItem> items;

  List<ReviewItem> get activeItems => items.where((i) => !i.isDiscarded).toList();

  List<ReviewItem> get matchedItems =>
      activeItems.where((i) => i.confidence == MatchConfidence.matched).toList();

  List<ReviewItem> get reviewItems =>
      activeItems.where((i) => i.confidence == MatchConfidence.review).toList();

  List<ReviewItem> get unknownItems =>
      activeItems.where((i) => i.confidence == MatchConfidence.unknown).toList();

  int get totalIssuesCount => reviewItems.length + unknownItems.length;

  ReviewBatch copyWith({
    String? scanId,
    String? sourceImagePath,
    List<ReviewItem>? items,
  }) {
    return ReviewBatch(
      scanId: scanId ?? this.scanId,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      items: items ?? this.items,
    );
  }
}
