import 'package:flutter/material.dart';

/// Status of a book detected in the live AR viewfinder.
enum ArBookStatus {
  /// Book is in the user's library and marked as read (Green badge).
  ownedRead,

  /// Book is in the user's library and marked as unread or currently reading (Amber badge).
  ownedUnread,

  /// Book is not in the user's library (Brass/White badge with quick add action).
  notOwned,
}

/// An item detected by the live AR camera stream and classified against the local library.
@immutable
class ArDetectedItem {
  const ArDetectedItem({
    required this.id,
    required this.rawText,
    required this.normalizedRect,
    required this.status,
    this.matchedTitle,
    this.matchedAuthor,
    this.catalogBookId,
    this.similarity = 0.0,
  });

  /// Unique identifier for this detection instance.
  final String id;

  /// Raw OCR text recognized on the book spine or cover.
  final String rawText;

  /// Normalized bounding box coordinates (0.0 to 1.0 relative to camera preview).
  final Rect normalizedRect;

  /// Ownership and reading status.
  final ArBookStatus status;

  /// Matched title from user library or catalog, if known.
  final String? matchedTitle;

  /// Matched author from user library or catalog, if known.
  final String? matchedAuthor;

  /// ID in `catalog_books`, if matched.
  final int? catalogBookId;

  /// Trigram similarity score (0.0 to 1.0).
  final double similarity;

  ArDetectedItem copyWith({
    String? id,
    String? rawText,
    Rect? normalizedRect,
    ArBookStatus? status,
    String? matchedTitle,
    String? matchedAuthor,
    int? catalogBookId,
    double? similarity,
  }) {
    return ArDetectedItem(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      normalizedRect: normalizedRect ?? this.normalizedRect,
      status: status ?? this.status,
      matchedTitle: matchedTitle ?? this.matchedTitle,
      matchedAuthor: matchedAuthor ?? this.matchedAuthor,
      catalogBookId: catalogBookId ?? this.catalogBookId,
      similarity: similarity ?? this.similarity,
    );
  }
}

/// State of the Live AR Shelf Lens engine.
@immutable
class ArLensState {
  const ArLensState({
    this.isActive = false,
    this.isProcessing = false,
    this.items = const [],
    this.lastProcessedAt,
  });

  final bool isActive;
  final bool isProcessing;
  final List<ArDetectedItem> items;
  final DateTime? lastProcessedAt;

  ArLensState copyWith({
    bool? isActive,
    bool? isProcessing,
    List<ArDetectedItem>? items,
    DateTime? lastProcessedAt,
  }) {
    return ArLensState(
      isActive: isActive ?? this.isActive,
      isProcessing: isProcessing ?? this.isProcessing,
      items: items ?? this.items,
      lastProcessedAt: lastProcessedAt ?? this.lastProcessedAt,
    );
  }
}
