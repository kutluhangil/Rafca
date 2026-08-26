import 'dart:convert';
import 'dart:io';

/// The four photo groups SPINE_BLUEPRINT.md 2.1 requires the dataset to cover.
/// Accuracy is reported per group, because a single average hides that thin
/// paperbacks fail where thick hardcovers do not.
enum PhotoGroup {
  /// 6 photos: good light, square on, thick spines.
  goodLight('good_light'),

  /// 6 photos: warm indoor light, 10-25 degrees off square.
  warmAngled('warm_angled'),

  /// 4 photos: thin spines and paperbacks.
  thinSpines('thin_spines'),

  /// 4 photos: mostly Turkish books.
  turkish('turkish');

  const PhotoGroup(this.id);

  final String id;

  static PhotoGroup parse(String value) {
    for (final group in PhotoGroup.values) {
      if (group.id == value) return group;
    }
    throw FormatException(
      'unknown photo group "$value"; expected one of '
      '${PhotoGroup.values.map((g) => g.id).join(', ')}',
    );
  }
}

/// One book on a shelf, as a human recorded it.
class GroundTruthBook {
  const GroundTruthBook({
    required this.title,
    required this.author,
    this.language,
    this.publisher,
  });

  final String title;
  final String author;

  /// ISO 639-2, e.g. `tur` or `eng`.
  final String? language;
  final String? publisher;

  @override
  String toString() => '$title — $author';
}

/// One annotated shelf photo.
class GroundTruthPhoto {
  const GroundTruthPhoto({
    required this.file,
    required this.group,
    required this.books,
    this.languageHint,
    this.notes,
  });

  /// File name inside `spike/dataset/`.
  final String file;
  final PhotoGroup group;

  /// Every book on the shelf, left to right.
  final List<GroundTruthBook> books;

  /// Device language at capture time, feeding the language scoring signal.
  final String? languageHint;
  final String? notes;
}

/// The annotated dataset.
class GroundTruth {
  const GroundTruth({required this.photos});

  final List<GroundTruthPhoto> photos;

  int get bookCount =>
      photos.fold(0, (total, photo) => total + photo.books.length);

  /// Reads and validates `ground_truth.json`.
  ///
  /// Validation is strict on purpose: a silently skipped photo or a book with
  /// no title would quietly inflate every rate in the report.
  factory GroundTruth.fromFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'ground truth not found at $path. Copy '
        'spike/dataset/ground_truth.example.json to '
        'spike/dataset/ground_truth.json and fill it in.',
      );
    }

    final Object? decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$path must contain a JSON object');
    }
    final version = decoded['version'];
    if (version != 1) {
      throw FormatException('$path: unsupported version $version, expected 1');
    }
    final rawPhotos = decoded['photos'];
    if (rawPhotos is! List || rawPhotos.isEmpty) {
      throw FormatException('$path: "photos" must be a non-empty array');
    }

    final photos = <GroundTruthPhoto>[];
    for (var i = 0; i < rawPhotos.length; i++) {
      final raw = rawPhotos[i];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('$path: photos[$i] must be an object');
      }
      final fileName = raw['file'];
      if (fileName is! String || fileName.isEmpty) {
        throw FormatException('$path: photos[$i].file must be a non-empty string');
      }
      final rawBooks = raw['books'];
      if (rawBooks is! List || rawBooks.isEmpty) {
        throw FormatException(
          '$path: photos[$i] ($fileName) must list at least one book',
        );
      }

      final books = <GroundTruthBook>[];
      for (var j = 0; j < rawBooks.length; j++) {
        final rawBook = rawBooks[j];
        if (rawBook is! Map<String, dynamic>) {
          throw FormatException('$path: $fileName books[$j] must be an object');
        }
        final title = rawBook['title'];
        final author = rawBook['author'];
        if (title is! String || title.trim().isEmpty) {
          throw FormatException(
            '$path: $fileName books[$j].title must be a non-empty string',
          );
        }
        if (author is! String) {
          throw FormatException(
            '$path: $fileName books[$j].author must be a string '
            '(use "" for an unattributed volume)',
          );
        }
        books.add(GroundTruthBook(
          title: title.trim(),
          author: author.trim(),
          language: rawBook['language'] as String?,
          publisher: rawBook['publisher'] as String?,
        ));
      }

      photos.add(GroundTruthPhoto(
        file: fileName,
        group: PhotoGroup.parse(raw['group'] as String? ?? ''),
        books: books,
        languageHint: raw['language_hint'] as String?,
        notes: raw['notes'] as String?,
      ));
    }

    return GroundTruth(photos: photos);
  }

  /// Warnings about dataset composition against SPINE_BLUEPRINT.md 2.1.
  /// Returned rather than thrown: a partial dataset still produces a useful
  /// report, it just cannot close the GO/NO-GO gate.
  List<String> coverageWarnings() {
    const required = {
      PhotoGroup.goodLight: 6,
      PhotoGroup.warmAngled: 6,
      PhotoGroup.thinSpines: 4,
      PhotoGroup.turkish: 4,
    };
    final counts = <PhotoGroup, int>{};
    for (final photo in photos) {
      counts[photo.group] = (counts[photo.group] ?? 0) + 1;
    }
    final warnings = <String>[];
    required.forEach((group, wanted) {
      final have = counts[group] ?? 0;
      if (have < wanted) {
        warnings.add(
          'group "${group.id}": $have of $wanted photos — the gate in '
          'SPINE_BLUEPRINT.md 2.2 needs the full set',
        );
      }
    });
    return warnings;
  }
}
