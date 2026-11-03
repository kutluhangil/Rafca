// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CatalogBooksTable extends CatalogBooks
    with TableInfo<$CatalogBooksTable, CatalogBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _olKeyMeta = const VerificationMeta('olKey');
  @override
  late final GeneratedColumn<String> olKey = GeneratedColumn<String>(
    'ol_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbn13Meta = const VerificationMeta('isbn13');
  @override
  late final GeneratedColumn<String> isbn13 = GeneratedColumn<String>(
    'isbn13',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> authors =
      GeneratedColumn<String>(
        'authors',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CatalogBooksTable.$converterauthors);
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishYearMeta = const VerificationMeta(
    'publishYear',
  );
  @override
  late final GeneratedColumn<int> publishYear = GeneratedColumn<int>(
    'publish_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    olKey,
    isbn13,
    title,
    subtitle,
    authors,
    publisher,
    publishYear,
    language,
    coverUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ol_key')) {
      context.handle(
        _olKeyMeta,
        olKey.isAcceptableOrUnknown(data['ol_key']!, _olKeyMeta),
      );
    }
    if (data.containsKey('isbn13')) {
      context.handle(
        _isbn13Meta,
        isbn13.isAcceptableOrUnknown(data['isbn13']!, _isbn13Meta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('publish_year')) {
      context.handle(
        _publishYearMeta,
        publishYear.isAcceptableOrUnknown(
          data['publish_year']!,
          _publishYearMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      olKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ol_key'],
      ),
      isbn13: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn13'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      authors: $CatalogBooksTable.$converterauthors.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authors'],
        )!,
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publishYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publish_year'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
    );
  }

  @override
  $CatalogBooksTable createAlias(String alias) {
    return $CatalogBooksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterauthors =
      const StringListConverter();
}

class CatalogBook extends DataClass implements Insertable<CatalogBook> {
  /// `books_index.id`. Server-assigned, so this table is never written to
  /// before a match has come back.
  final int id;
  final String? olKey;
  final String? isbn13;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? publisher;
  final int? publishYear;
  final String? language;
  final String? coverUrl;
  const CatalogBook({
    required this.id,
    this.olKey,
    this.isbn13,
    required this.title,
    this.subtitle,
    required this.authors,
    this.publisher,
    this.publishYear,
    this.language,
    this.coverUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || olKey != null) {
      map['ol_key'] = Variable<String>(olKey);
    }
    if (!nullToAbsent || isbn13 != null) {
      map['isbn13'] = Variable<String>(isbn13);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    {
      map['authors'] = Variable<String>(
        $CatalogBooksTable.$converterauthors.toSql(authors),
      );
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publishYear != null) {
      map['publish_year'] = Variable<int>(publishYear);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    return map;
  }

  CatalogBooksCompanion toCompanion(bool nullToAbsent) {
    return CatalogBooksCompanion(
      id: Value(id),
      olKey: olKey == null && nullToAbsent
          ? const Value.absent()
          : Value(olKey),
      isbn13: isbn13 == null && nullToAbsent
          ? const Value.absent()
          : Value(isbn13),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      authors: Value(authors),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publishYear: publishYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publishYear),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
    );
  }

  factory CatalogBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogBook(
      id: serializer.fromJson<int>(json['id']),
      olKey: serializer.fromJson<String?>(json['olKey']),
      isbn13: serializer.fromJson<String?>(json['isbn13']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      authors: serializer.fromJson<List<String>>(json['authors']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publishYear: serializer.fromJson<int?>(json['publishYear']),
      language: serializer.fromJson<String?>(json['language']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'olKey': serializer.toJson<String?>(olKey),
      'isbn13': serializer.toJson<String?>(isbn13),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'authors': serializer.toJson<List<String>>(authors),
      'publisher': serializer.toJson<String?>(publisher),
      'publishYear': serializer.toJson<int?>(publishYear),
      'language': serializer.toJson<String?>(language),
      'coverUrl': serializer.toJson<String?>(coverUrl),
    };
  }

  CatalogBook copyWith({
    int? id,
    Value<String?> olKey = const Value.absent(),
    Value<String?> isbn13 = const Value.absent(),
    String? title,
    Value<String?> subtitle = const Value.absent(),
    List<String>? authors,
    Value<String?> publisher = const Value.absent(),
    Value<int?> publishYear = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
  }) => CatalogBook(
    id: id ?? this.id,
    olKey: olKey.present ? olKey.value : this.olKey,
    isbn13: isbn13.present ? isbn13.value : this.isbn13,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    authors: authors ?? this.authors,
    publisher: publisher.present ? publisher.value : this.publisher,
    publishYear: publishYear.present ? publishYear.value : this.publishYear,
    language: language.present ? language.value : this.language,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
  );
  CatalogBook copyWithCompanion(CatalogBooksCompanion data) {
    return CatalogBook(
      id: data.id.present ? data.id.value : this.id,
      olKey: data.olKey.present ? data.olKey.value : this.olKey,
      isbn13: data.isbn13.present ? data.isbn13.value : this.isbn13,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      authors: data.authors.present ? data.authors.value : this.authors,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publishYear: data.publishYear.present
          ? data.publishYear.value
          : this.publishYear,
      language: data.language.present ? data.language.value : this.language,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBook(')
          ..write('id: $id, ')
          ..write('olKey: $olKey, ')
          ..write('isbn13: $isbn13, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors, ')
          ..write('publisher: $publisher, ')
          ..write('publishYear: $publishYear, ')
          ..write('language: $language, ')
          ..write('coverUrl: $coverUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    olKey,
    isbn13,
    title,
    subtitle,
    authors,
    publisher,
    publishYear,
    language,
    coverUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogBook &&
          other.id == this.id &&
          other.olKey == this.olKey &&
          other.isbn13 == this.isbn13 &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.authors == this.authors &&
          other.publisher == this.publisher &&
          other.publishYear == this.publishYear &&
          other.language == this.language &&
          other.coverUrl == this.coverUrl);
}

class CatalogBooksCompanion extends UpdateCompanion<CatalogBook> {
  final Value<int> id;
  final Value<String?> olKey;
  final Value<String?> isbn13;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<List<String>> authors;
  final Value<String?> publisher;
  final Value<int?> publishYear;
  final Value<String?> language;
  final Value<String?> coverUrl;
  const CatalogBooksCompanion({
    this.id = const Value.absent(),
    this.olKey = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.authors = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishYear = const Value.absent(),
    this.language = const Value.absent(),
    this.coverUrl = const Value.absent(),
  });
  CatalogBooksCompanion.insert({
    this.id = const Value.absent(),
    this.olKey = const Value.absent(),
    this.isbn13 = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    this.authors = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishYear = const Value.absent(),
    this.language = const Value.absent(),
    this.coverUrl = const Value.absent(),
  }) : title = Value(title);
  static Insertable<CatalogBook> custom({
    Expression<int>? id,
    Expression<String>? olKey,
    Expression<String>? isbn13,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? authors,
    Expression<String>? publisher,
    Expression<int>? publishYear,
    Expression<String>? language,
    Expression<String>? coverUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (olKey != null) 'ol_key': olKey,
      if (isbn13 != null) 'isbn13': isbn13,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (authors != null) 'authors': authors,
      if (publisher != null) 'publisher': publisher,
      if (publishYear != null) 'publish_year': publishYear,
      if (language != null) 'language': language,
      if (coverUrl != null) 'cover_url': coverUrl,
    });
  }

  CatalogBooksCompanion copyWith({
    Value<int>? id,
    Value<String?>? olKey,
    Value<String?>? isbn13,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<List<String>>? authors,
    Value<String?>? publisher,
    Value<int?>? publishYear,
    Value<String?>? language,
    Value<String?>? coverUrl,
  }) {
    return CatalogBooksCompanion(
      id: id ?? this.id,
      olKey: olKey ?? this.olKey,
      isbn13: isbn13 ?? this.isbn13,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authors: authors ?? this.authors,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      language: language ?? this.language,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (olKey.present) {
      map['ol_key'] = Variable<String>(olKey.value);
    }
    if (isbn13.present) {
      map['isbn13'] = Variable<String>(isbn13.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(
        $CatalogBooksTable.$converterauthors.toSql(authors.value),
      );
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publishYear.present) {
      map['publish_year'] = Variable<int>(publishYear.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogBooksCompanion(')
          ..write('id: $id, ')
          ..write('olKey: $olKey, ')
          ..write('isbn13: $isbn13, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors, ')
          ..write('publisher: $publisher, ')
          ..write('publishYear: $publishYear, ')
          ..write('language: $language, ')
          ..write('coverUrl: $coverUrl')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortOrder,
    createdAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelf extends DataClass implements Insertable<Shelf> {
  /// Generated on the device so the row keeps its identity through the sync.
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  /// True while this row differs from what the server has.
  ///
  /// The queue in [SyncQueueEntries] is what the drainer walks; this flag is
  /// what a screen reads to show a row as not yet synced. [SyncQueueDao] writes
  /// both in one transaction so they cannot disagree.
  final bool pendingSync;
  const Shelf({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory Shelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelf(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Shelf copyWith({
    String? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    bool? pendingSync,
  }) => Shelf(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  Shelf copyWithCompanion(ShelvesCompanion data) {
    return Shelf(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelf(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, createdAt, pendingSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelf &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.pendingSync == this.pendingSync);
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelvesCompanion.insert({
    required String id,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Shelf> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelvesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return ShelvesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserBooksTable extends UserBooks
    with TableInfo<$UserBooksTable, UserBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_books (id)',
    ),
  );
  static const VerificationMeta _manualTitleMeta = const VerificationMeta(
    'manualTitle',
  );
  @override
  late final GeneratedColumn<String> manualTitle = GeneratedColumn<String>(
    'manual_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualAuthorMeta = const VerificationMeta(
    'manualAuthor',
  );
  @override
  late final GeneratedColumn<String> manualAuthor = GeneratedColumn<String>(
    'manual_author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<String> shelfId = GeneratedColumn<String>(
    'shelf_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReadingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ReadingStatus.unread.name),
      ).withConverter<ReadingStatus>($UserBooksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<MatchConfidence, String>
  confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MatchConfidence>($UserBooksTable.$converterconfidence);
  static const VerificationMeta _spineColorMeta = const VerificationMeta(
    'spineColor',
  );
  @override
  late final GeneratedColumn<String> spineColor = GeneratedColumn<String>(
    'spine_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturePathMeta = const VerificationMeta(
    'capturePath',
  );
  @override
  late final GeneratedColumn<String> capturePath = GeneratedColumn<String>(
    'capture_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfPositionMeta = const VerificationMeta(
    'shelfPosition',
  );
  @override
  late final GeneratedColumn<int> shelfPosition = GeneratedColumn<int>(
    'shelf_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    manualTitle,
    manualAuthor,
    shelfId,
    status,
    confidence,
    spineColor,
    capturePath,
    shelfPosition,
    addedAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('manual_title')) {
      context.handle(
        _manualTitleMeta,
        manualTitle.isAcceptableOrUnknown(
          data['manual_title']!,
          _manualTitleMeta,
        ),
      );
    }
    if (data.containsKey('manual_author')) {
      context.handle(
        _manualAuthorMeta,
        manualAuthor.isAcceptableOrUnknown(
          data['manual_author']!,
          _manualAuthorMeta,
        ),
      );
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    }
    if (data.containsKey('spine_color')) {
      context.handle(
        _spineColorMeta,
        spineColor.isAcceptableOrUnknown(data['spine_color']!, _spineColorMeta),
      );
    }
    if (data.containsKey('capture_path')) {
      context.handle(
        _capturePathMeta,
        capturePath.isAcceptableOrUnknown(
          data['capture_path']!,
          _capturePathMeta,
        ),
      );
    }
    if (data.containsKey('shelf_position')) {
      context.handle(
        _shelfPositionMeta,
        shelfPosition.isAcceptableOrUnknown(
          data['shelf_position']!,
          _shelfPositionMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      ),
      manualTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_title'],
      ),
      manualAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_author'],
      ),
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_id'],
      ),
      status: $UserBooksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      confidence: $UserBooksTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      spineColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spine_color'],
      ),
      capturePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_path'],
      ),
      shelfPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_position'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $UserBooksTable createAlias(String alias) {
    return $UserBooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReadingStatus, String, String> $converterstatus =
      const EnumNameConverter<ReadingStatus>(ReadingStatus.values);
  static JsonTypeConverter2<MatchConfidence, String, String>
  $converterconfidence = const EnumNameConverter<MatchConfidence>(
    MatchConfidence.values,
  );
}

class UserBook extends DataClass implements Insertable<UserBook> {
  final String id;

  /// Null for a hand-typed book that is not in the catalogue.
  final int? bookId;
  final String? manualTitle;
  final String? manualAuthor;
  final String? shelfId;
  final ReadingStatus status;
  final MatchConfidence confidence;

  /// `#RRGGBB`, the colour `ShelfStrip` draws this spine with.
  final String? spineColor;

  /// Path to the spine crop under `ApplicationDocumentsDirectory/spine/captures/`.
  ///
  /// Device-only, and it has no column on the server: images never sync
  /// (SPINE_BLUEPRINT.md 5). The one exception, "Enhance", uploads a single
  /// crop for one request and stores nothing.
  final String? capturePath;

  /// Left-to-right position of this book along the physical shelf (1-based index).
  /// Derived from `SpineCandidate.bbox.left` during scan review.
  final int? shelfPosition;
  final DateTime addedAt;
  final bool pendingSync;
  const UserBook({
    required this.id,
    this.bookId,
    this.manualTitle,
    this.manualAuthor,
    this.shelfId,
    required this.status,
    required this.confidence,
    this.spineColor,
    this.capturePath,
    this.shelfPosition,
    required this.addedAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    if (!nullToAbsent || manualTitle != null) {
      map['manual_title'] = Variable<String>(manualTitle);
    }
    if (!nullToAbsent || manualAuthor != null) {
      map['manual_author'] = Variable<String>(manualAuthor);
    }
    if (!nullToAbsent || shelfId != null) {
      map['shelf_id'] = Variable<String>(shelfId);
    }
    {
      map['status'] = Variable<String>(
        $UserBooksTable.$converterstatus.toSql(status),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $UserBooksTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || spineColor != null) {
      map['spine_color'] = Variable<String>(spineColor);
    }
    if (!nullToAbsent || capturePath != null) {
      map['capture_path'] = Variable<String>(capturePath);
    }
    if (!nullToAbsent || shelfPosition != null) {
      map['shelf_position'] = Variable<int>(shelfPosition);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  UserBooksCompanion toCompanion(bool nullToAbsent) {
    return UserBooksCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      manualTitle: manualTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(manualTitle),
      manualAuthor: manualAuthor == null && nullToAbsent
          ? const Value.absent()
          : Value(manualAuthor),
      shelfId: shelfId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfId),
      status: Value(status),
      confidence: Value(confidence),
      spineColor: spineColor == null && nullToAbsent
          ? const Value.absent()
          : Value(spineColor),
      capturePath: capturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(capturePath),
      shelfPosition: shelfPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfPosition),
      addedAt: Value(addedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory UserBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBook(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      manualTitle: serializer.fromJson<String?>(json['manualTitle']),
      manualAuthor: serializer.fromJson<String?>(json['manualAuthor']),
      shelfId: serializer.fromJson<String?>(json['shelfId']),
      status: $UserBooksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      confidence: $UserBooksTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      spineColor: serializer.fromJson<String?>(json['spineColor']),
      capturePath: serializer.fromJson<String?>(json['capturePath']),
      shelfPosition: serializer.fromJson<int?>(json['shelfPosition']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<int?>(bookId),
      'manualTitle': serializer.toJson<String?>(manualTitle),
      'manualAuthor': serializer.toJson<String?>(manualAuthor),
      'shelfId': serializer.toJson<String?>(shelfId),
      'status': serializer.toJson<String>(
        $UserBooksTable.$converterstatus.toJson(status),
      ),
      'confidence': serializer.toJson<String>(
        $UserBooksTable.$converterconfidence.toJson(confidence),
      ),
      'spineColor': serializer.toJson<String?>(spineColor),
      'capturePath': serializer.toJson<String?>(capturePath),
      'shelfPosition': serializer.toJson<int?>(shelfPosition),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  UserBook copyWith({
    String? id,
    Value<int?> bookId = const Value.absent(),
    Value<String?> manualTitle = const Value.absent(),
    Value<String?> manualAuthor = const Value.absent(),
    Value<String?> shelfId = const Value.absent(),
    ReadingStatus? status,
    MatchConfidence? confidence,
    Value<String?> spineColor = const Value.absent(),
    Value<String?> capturePath = const Value.absent(),
    Value<int?> shelfPosition = const Value.absent(),
    DateTime? addedAt,
    bool? pendingSync,
  }) => UserBook(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    manualTitle: manualTitle.present ? manualTitle.value : this.manualTitle,
    manualAuthor: manualAuthor.present ? manualAuthor.value : this.manualAuthor,
    shelfId: shelfId.present ? shelfId.value : this.shelfId,
    status: status ?? this.status,
    confidence: confidence ?? this.confidence,
    spineColor: spineColor.present ? spineColor.value : this.spineColor,
    capturePath: capturePath.present ? capturePath.value : this.capturePath,
    shelfPosition: shelfPosition.present
        ? shelfPosition.value
        : this.shelfPosition,
    addedAt: addedAt ?? this.addedAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  UserBook copyWithCompanion(UserBooksCompanion data) {
    return UserBook(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      manualTitle: data.manualTitle.present
          ? data.manualTitle.value
          : this.manualTitle,
      manualAuthor: data.manualAuthor.present
          ? data.manualAuthor.value
          : this.manualAuthor,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      status: data.status.present ? data.status.value : this.status,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      spineColor: data.spineColor.present
          ? data.spineColor.value
          : this.spineColor,
      capturePath: data.capturePath.present
          ? data.capturePath.value
          : this.capturePath,
      shelfPosition: data.shelfPosition.present
          ? data.shelfPosition.value
          : this.shelfPosition,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBook(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('manualTitle: $manualTitle, ')
          ..write('manualAuthor: $manualAuthor, ')
          ..write('shelfId: $shelfId, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('spineColor: $spineColor, ')
          ..write('capturePath: $capturePath, ')
          ..write('shelfPosition: $shelfPosition, ')
          ..write('addedAt: $addedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    manualTitle,
    manualAuthor,
    shelfId,
    status,
    confidence,
    spineColor,
    capturePath,
    shelfPosition,
    addedAt,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBook &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.manualTitle == this.manualTitle &&
          other.manualAuthor == this.manualAuthor &&
          other.shelfId == this.shelfId &&
          other.status == this.status &&
          other.confidence == this.confidence &&
          other.spineColor == this.spineColor &&
          other.capturePath == this.capturePath &&
          other.shelfPosition == this.shelfPosition &&
          other.addedAt == this.addedAt &&
          other.pendingSync == this.pendingSync);
}

class UserBooksCompanion extends UpdateCompanion<UserBook> {
  final Value<String> id;
  final Value<int?> bookId;
  final Value<String?> manualTitle;
  final Value<String?> manualAuthor;
  final Value<String?> shelfId;
  final Value<ReadingStatus> status;
  final Value<MatchConfidence> confidence;
  final Value<String?> spineColor;
  final Value<String?> capturePath;
  final Value<int?> shelfPosition;
  final Value<DateTime> addedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const UserBooksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.manualTitle = const Value.absent(),
    this.manualAuthor = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.status = const Value.absent(),
    this.confidence = const Value.absent(),
    this.spineColor = const Value.absent(),
    this.capturePath = const Value.absent(),
    this.shelfPosition = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBooksCompanion.insert({
    required String id,
    this.bookId = const Value.absent(),
    this.manualTitle = const Value.absent(),
    this.manualAuthor = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.status = const Value.absent(),
    required MatchConfidence confidence,
    this.spineColor = const Value.absent(),
    this.capturePath = const Value.absent(),
    this.shelfPosition = const Value.absent(),
    required DateTime addedAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       confidence = Value(confidence),
       addedAt = Value(addedAt);
  static Insertable<UserBook> custom({
    Expression<String>? id,
    Expression<int>? bookId,
    Expression<String>? manualTitle,
    Expression<String>? manualAuthor,
    Expression<String>? shelfId,
    Expression<String>? status,
    Expression<String>? confidence,
    Expression<String>? spineColor,
    Expression<String>? capturePath,
    Expression<int>? shelfPosition,
    Expression<DateTime>? addedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (manualTitle != null) 'manual_title': manualTitle,
      if (manualAuthor != null) 'manual_author': manualAuthor,
      if (shelfId != null) 'shelf_id': shelfId,
      if (status != null) 'status': status,
      if (confidence != null) 'confidence': confidence,
      if (spineColor != null) 'spine_color': spineColor,
      if (capturePath != null) 'capture_path': capturePath,
      if (shelfPosition != null) 'shelf_position': shelfPosition,
      if (addedAt != null) 'added_at': addedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBooksCompanion copyWith({
    Value<String>? id,
    Value<int?>? bookId,
    Value<String?>? manualTitle,
    Value<String?>? manualAuthor,
    Value<String?>? shelfId,
    Value<ReadingStatus>? status,
    Value<MatchConfidence>? confidence,
    Value<String?>? spineColor,
    Value<String?>? capturePath,
    Value<int?>? shelfPosition,
    Value<DateTime>? addedAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return UserBooksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      manualTitle: manualTitle ?? this.manualTitle,
      manualAuthor: manualAuthor ?? this.manualAuthor,
      shelfId: shelfId ?? this.shelfId,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      spineColor: spineColor ?? this.spineColor,
      capturePath: capturePath ?? this.capturePath,
      shelfPosition: shelfPosition ?? this.shelfPosition,
      addedAt: addedAt ?? this.addedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (manualTitle.present) {
      map['manual_title'] = Variable<String>(manualTitle.value);
    }
    if (manualAuthor.present) {
      map['manual_author'] = Variable<String>(manualAuthor.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<String>(shelfId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $UserBooksTable.$converterstatus.toSql(status.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $UserBooksTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (spineColor.present) {
      map['spine_color'] = Variable<String>(spineColor.value);
    }
    if (capturePath.present) {
      map['capture_path'] = Variable<String>(capturePath.value);
    }
    if (shelfPosition.present) {
      map['shelf_position'] = Variable<int>(shelfPosition.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBooksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('manualTitle: $manualTitle, ')
          ..write('manualAuthor: $manualAuthor, ')
          ..write('shelfId: $shelfId, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('spineColor: $spineColor, ')
          ..write('capturePath: $capturePath, ')
          ..write('shelfPosition: $shelfPosition, ')
          ..write('addedAt: $addedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScansTable extends Scans with TableInfo<$ScansTable, Scan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedCountMeta = const VerificationMeta(
    'detectedCount',
  );
  @override
  late final GeneratedColumn<int> detectedCount = GeneratedColumn<int>(
    'detected_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedCountMeta = const VerificationMeta(
    'matchedCount',
  );
  @override
  late final GeneratedColumn<int> matchedCount = GeneratedColumn<int>(
    'matched_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturePathMeta = const VerificationMeta(
    'capturePath',
  );
  @override
  late final GeneratedColumn<String> capturePath = GeneratedColumn<String>(
    'capture_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    detectedCount,
    matchedCount,
    capturePath,
    createdAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('detected_count')) {
      context.handle(
        _detectedCountMeta,
        detectedCount.isAcceptableOrUnknown(
          data['detected_count']!,
          _detectedCountMeta,
        ),
      );
    }
    if (data.containsKey('matched_count')) {
      context.handle(
        _matchedCountMeta,
        matchedCount.isAcceptableOrUnknown(
          data['matched_count']!,
          _matchedCountMeta,
        ),
      );
    }
    if (data.containsKey('capture_path')) {
      context.handle(
        _capturePathMeta,
        capturePath.isAcceptableOrUnknown(
          data['capture_path']!,
          _capturePathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      detectedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_count'],
      ),
      matchedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matched_count'],
      ),
      capturePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $ScansTable createAlias(String alias) {
    return $ScansTable(attachedDatabase, alias);
  }
}

class Scan extends DataClass implements Insertable<Scan> {
  final String id;
  final int? detectedCount;
  final int? matchedCount;

  /// The raw shelf photo. Device-only, for the same reason as
  /// [UserBooks.capturePath] — this is the "PROOF OF CAPTURE" image, read from
  /// the local file and never uploaded.
  final String? capturePath;
  final DateTime createdAt;
  final bool pendingSync;
  const Scan({
    required this.id,
    this.detectedCount,
    this.matchedCount,
    this.capturePath,
    required this.createdAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || detectedCount != null) {
      map['detected_count'] = Variable<int>(detectedCount);
    }
    if (!nullToAbsent || matchedCount != null) {
      map['matched_count'] = Variable<int>(matchedCount);
    }
    if (!nullToAbsent || capturePath != null) {
      map['capture_path'] = Variable<String>(capturePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  ScansCompanion toCompanion(bool nullToAbsent) {
    return ScansCompanion(
      id: Value(id),
      detectedCount: detectedCount == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedCount),
      matchedCount: matchedCount == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedCount),
      capturePath: capturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(capturePath),
      createdAt: Value(createdAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory Scan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scan(
      id: serializer.fromJson<String>(json['id']),
      detectedCount: serializer.fromJson<int?>(json['detectedCount']),
      matchedCount: serializer.fromJson<int?>(json['matchedCount']),
      capturePath: serializer.fromJson<String?>(json['capturePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'detectedCount': serializer.toJson<int?>(detectedCount),
      'matchedCount': serializer.toJson<int?>(matchedCount),
      'capturePath': serializer.toJson<String?>(capturePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Scan copyWith({
    String? id,
    Value<int?> detectedCount = const Value.absent(),
    Value<int?> matchedCount = const Value.absent(),
    Value<String?> capturePath = const Value.absent(),
    DateTime? createdAt,
    bool? pendingSync,
  }) => Scan(
    id: id ?? this.id,
    detectedCount: detectedCount.present
        ? detectedCount.value
        : this.detectedCount,
    matchedCount: matchedCount.present ? matchedCount.value : this.matchedCount,
    capturePath: capturePath.present ? capturePath.value : this.capturePath,
    createdAt: createdAt ?? this.createdAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  Scan copyWithCompanion(ScansCompanion data) {
    return Scan(
      id: data.id.present ? data.id.value : this.id,
      detectedCount: data.detectedCount.present
          ? data.detectedCount.value
          : this.detectedCount,
      matchedCount: data.matchedCount.present
          ? data.matchedCount.value
          : this.matchedCount,
      capturePath: data.capturePath.present
          ? data.capturePath.value
          : this.capturePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scan(')
          ..write('id: $id, ')
          ..write('detectedCount: $detectedCount, ')
          ..write('matchedCount: $matchedCount, ')
          ..write('capturePath: $capturePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    detectedCount,
    matchedCount,
    capturePath,
    createdAt,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scan &&
          other.id == this.id &&
          other.detectedCount == this.detectedCount &&
          other.matchedCount == this.matchedCount &&
          other.capturePath == this.capturePath &&
          other.createdAt == this.createdAt &&
          other.pendingSync == this.pendingSync);
}

class ScansCompanion extends UpdateCompanion<Scan> {
  final Value<String> id;
  final Value<int?> detectedCount;
  final Value<int?> matchedCount;
  final Value<String?> capturePath;
  final Value<DateTime> createdAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const ScansCompanion({
    this.id = const Value.absent(),
    this.detectedCount = const Value.absent(),
    this.matchedCount = const Value.absent(),
    this.capturePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScansCompanion.insert({
    required String id,
    this.detectedCount = const Value.absent(),
    this.matchedCount = const Value.absent(),
    this.capturePath = const Value.absent(),
    required DateTime createdAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<Scan> custom({
    Expression<String>? id,
    Expression<int>? detectedCount,
    Expression<int>? matchedCount,
    Expression<String>? capturePath,
    Expression<DateTime>? createdAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (detectedCount != null) 'detected_count': detectedCount,
      if (matchedCount != null) 'matched_count': matchedCount,
      if (capturePath != null) 'capture_path': capturePath,
      if (createdAt != null) 'created_at': createdAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScansCompanion copyWith({
    Value<String>? id,
    Value<int?>? detectedCount,
    Value<int?>? matchedCount,
    Value<String?>? capturePath,
    Value<DateTime>? createdAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return ScansCompanion(
      id: id ?? this.id,
      detectedCount: detectedCount ?? this.detectedCount,
      matchedCount: matchedCount ?? this.matchedCount,
      capturePath: capturePath ?? this.capturePath,
      createdAt: createdAt ?? this.createdAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (detectedCount.present) {
      map['detected_count'] = Variable<int>(detectedCount.value);
    }
    if (matchedCount.present) {
      map['matched_count'] = Variable<int>(matchedCount.value);
    }
    if (capturePath.present) {
      map['capture_path'] = Variable<String>(capturePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScansCompanion(')
          ..write('id: $id, ')
          ..write('detectedCount: $detectedCount, ')
          ..write('matchedCount: $matchedCount, ')
          ..write('capturePath: $capturePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntity, String> entity =
      GeneratedColumn<String>(
        'entity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncEntity>($SyncQueueEntriesTable.$converterentity);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperation, String> operation =
      GeneratedColumn<String>(
        'operation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOperation>(
        $SyncQueueEntriesTable.$converteroperation,
      );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> enqueuedAt = GeneratedColumn<DateTime>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    rowId,
    operation,
    enqueuedAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entity, rowId},
  ];
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity: $SyncQueueEntriesTable.$converterentity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity'],
        )!,
      ),
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      operation: $SyncQueueEntriesTable.$converteroperation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation'],
        )!,
      ),
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enqueued_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEntity, String, String> $converterentity =
      const EnumNameConverter<SyncEntity>(SyncEntity.values);
  static JsonTypeConverter2<SyncOperation, String, String> $converteroperation =
      const EnumNameConverter<SyncOperation>(SyncOperation.values);
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final SyncEntity entity;

  /// Primary key of the row in the mirrored table.
  final String rowId;
  final SyncOperation operation;
  final DateTime enqueuedAt;
  final int attempts;

  /// The last failure, kept verbatim so a stuck queue can be explained rather
  /// than guessed at.
  final String? lastError;
  const SyncQueueEntry({
    required this.id,
    required this.entity,
    required this.rowId,
    required this.operation,
    required this.enqueuedAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['entity'] = Variable<String>(
        $SyncQueueEntriesTable.$converterentity.toSql(entity),
      );
    }
    map['row_id'] = Variable<String>(rowId);
    {
      map['operation'] = Variable<String>(
        $SyncQueueEntriesTable.$converteroperation.toSql(operation),
      );
    }
    map['enqueued_at'] = Variable<DateTime>(enqueuedAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      entity: Value(entity),
      rowId: Value(rowId),
      operation: Value(operation),
      enqueuedAt: Value(enqueuedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entity: $SyncQueueEntriesTable.$converterentity.fromJson(
        serializer.fromJson<String>(json['entity']),
      ),
      rowId: serializer.fromJson<String>(json['rowId']),
      operation: $SyncQueueEntriesTable.$converteroperation.fromJson(
        serializer.fromJson<String>(json['operation']),
      ),
      enqueuedAt: serializer.fromJson<DateTime>(json['enqueuedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(
        $SyncQueueEntriesTable.$converterentity.toJson(entity),
      ),
      'rowId': serializer.toJson<String>(rowId),
      'operation': serializer.toJson<String>(
        $SyncQueueEntriesTable.$converteroperation.toJson(operation),
      ),
      'enqueuedAt': serializer.toJson<DateTime>(enqueuedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    SyncEntity? entity,
    String? rowId,
    SyncOperation? operation,
    DateTime? enqueuedAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    operation: operation ?? this.operation,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      operation: data.operation.present ? data.operation.value : this.operation,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    rowId,
    operation,
    enqueuedAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.operation == this.operation &&
          other.enqueuedAt == this.enqueuedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<SyncEntity> entity;
  final Value<String> rowId;
  final Value<SyncOperation> operation;
  final Value<DateTime> enqueuedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.operation = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required SyncEntity entity,
    required String rowId,
    required SyncOperation operation,
    required DateTime enqueuedAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId),
       operation = Value(operation),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? rowId,
    Expression<String>? operation,
    Expression<DateTime>? enqueuedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (operation != null) 'operation': operation,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<SyncEntity>? entity,
    Value<String>? rowId,
    Value<SyncOperation>? operation,
    Value<DateTime>? enqueuedAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      operation: operation ?? this.operation,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(
        $SyncQueueEntriesTable.$converterentity.toSql(entity.value),
      );
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
        $SyncQueueEntriesTable.$converteroperation.toSql(operation.value),
      );
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<DateTime>(enqueuedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $BookLoansTable extends BookLoans
    with TableInfo<$BookLoansTable, BookLoan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookLoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userBookIdMeta = const VerificationMeta(
    'userBookId',
  );
  @override
  late final GeneratedColumn<String> userBookId = GeneratedColumn<String>(
    'user_book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_books (id)',
    ),
  );
  static const VerificationMeta _borrowerNameMeta = const VerificationMeta(
    'borrowerName',
  );
  @override
  late final GeneratedColumn<String> borrowerName = GeneratedColumn<String>(
    'borrower_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borrowerContactMeta = const VerificationMeta(
    'borrowerContact',
  );
  @override
  late final GeneratedColumn<String> borrowerContact = GeneratedColumn<String>(
    'borrower_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanedAtMeta = const VerificationMeta(
    'loanedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loanedAt = GeneratedColumn<DateTime>(
    'loaned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _returnedAtMeta = const VerificationMeta(
    'returnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> returnedAt = GeneratedColumn<DateTime>(
    'returned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userBookId,
    borrowerName,
    borrowerContact,
    loanedAt,
    dueDate,
    returnedAt,
    notes,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookLoan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_book_id')) {
      context.handle(
        _userBookIdMeta,
        userBookId.isAcceptableOrUnknown(
          data['user_book_id']!,
          _userBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userBookIdMeta);
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
        _borrowerNameMeta,
        borrowerName.isAcceptableOrUnknown(
          data['borrower_name']!,
          _borrowerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('borrower_contact')) {
      context.handle(
        _borrowerContactMeta,
        borrowerContact.isAcceptableOrUnknown(
          data['borrower_contact']!,
          _borrowerContactMeta,
        ),
      );
    }
    if (data.containsKey('loaned_at')) {
      context.handle(
        _loanedAtMeta,
        loanedAt.isAcceptableOrUnknown(data['loaned_at']!, _loanedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loanedAtMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('returned_at')) {
      context.handle(
        _returnedAtMeta,
        returnedAt.isAcceptableOrUnknown(data['returned_at']!, _returnedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookLoan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookLoan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_book_id'],
      )!,
      borrowerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_name'],
      )!,
      borrowerContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_contact'],
      ),
      loanedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}loaned_at'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      returnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}returned_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $BookLoansTable createAlias(String alias) {
    return $BookLoansTable(attachedDatabase, alias);
  }
}

class BookLoan extends DataClass implements Insertable<BookLoan> {
  final String id;
  final String userBookId;
  final String borrowerName;
  final String? borrowerContact;
  final DateTime loanedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;
  final String? notes;
  final bool pendingSync;
  const BookLoan({
    required this.id,
    required this.userBookId,
    required this.borrowerName,
    this.borrowerContact,
    required this.loanedAt,
    this.dueDate,
    this.returnedAt,
    this.notes,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_book_id'] = Variable<String>(userBookId);
    map['borrower_name'] = Variable<String>(borrowerName);
    if (!nullToAbsent || borrowerContact != null) {
      map['borrower_contact'] = Variable<String>(borrowerContact);
    }
    map['loaned_at'] = Variable<DateTime>(loanedAt);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || returnedAt != null) {
      map['returned_at'] = Variable<DateTime>(returnedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  BookLoansCompanion toCompanion(bool nullToAbsent) {
    return BookLoansCompanion(
      id: Value(id),
      userBookId: Value(userBookId),
      borrowerName: Value(borrowerName),
      borrowerContact: borrowerContact == null && nullToAbsent
          ? const Value.absent()
          : Value(borrowerContact),
      loanedAt: Value(loanedAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      returnedAt: returnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      pendingSync: Value(pendingSync),
    );
  }

  factory BookLoan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookLoan(
      id: serializer.fromJson<String>(json['id']),
      userBookId: serializer.fromJson<String>(json['userBookId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      borrowerContact: serializer.fromJson<String?>(json['borrowerContact']),
      loanedAt: serializer.fromJson<DateTime>(json['loanedAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      returnedAt: serializer.fromJson<DateTime?>(json['returnedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userBookId': serializer.toJson<String>(userBookId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'borrowerContact': serializer.toJson<String?>(borrowerContact),
      'loanedAt': serializer.toJson<DateTime>(loanedAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'returnedAt': serializer.toJson<DateTime?>(returnedAt),
      'notes': serializer.toJson<String?>(notes),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  BookLoan copyWith({
    String? id,
    String? userBookId,
    String? borrowerName,
    Value<String?> borrowerContact = const Value.absent(),
    DateTime? loanedAt,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> returnedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? pendingSync,
  }) => BookLoan(
    id: id ?? this.id,
    userBookId: userBookId ?? this.userBookId,
    borrowerName: borrowerName ?? this.borrowerName,
    borrowerContact: borrowerContact.present
        ? borrowerContact.value
        : this.borrowerContact,
    loanedAt: loanedAt ?? this.loanedAt,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
    notes: notes.present ? notes.value : this.notes,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  BookLoan copyWithCompanion(BookLoansCompanion data) {
    return BookLoan(
      id: data.id.present ? data.id.value : this.id,
      userBookId: data.userBookId.present
          ? data.userBookId.value
          : this.userBookId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      borrowerContact: data.borrowerContact.present
          ? data.borrowerContact.value
          : this.borrowerContact,
      loanedAt: data.loanedAt.present ? data.loanedAt.value : this.loanedAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnedAt: data.returnedAt.present
          ? data.returnedAt.value
          : this.returnedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookLoan(')
          ..write('id: $id, ')
          ..write('userBookId: $userBookId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerContact: $borrowerContact, ')
          ..write('loanedAt: $loanedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('notes: $notes, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userBookId,
    borrowerName,
    borrowerContact,
    loanedAt,
    dueDate,
    returnedAt,
    notes,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookLoan &&
          other.id == this.id &&
          other.userBookId == this.userBookId &&
          other.borrowerName == this.borrowerName &&
          other.borrowerContact == this.borrowerContact &&
          other.loanedAt == this.loanedAt &&
          other.dueDate == this.dueDate &&
          other.returnedAt == this.returnedAt &&
          other.notes == this.notes &&
          other.pendingSync == this.pendingSync);
}

class BookLoansCompanion extends UpdateCompanion<BookLoan> {
  final Value<String> id;
  final Value<String> userBookId;
  final Value<String> borrowerName;
  final Value<String?> borrowerContact;
  final Value<DateTime> loanedAt;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> returnedAt;
  final Value<String?> notes;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const BookLoansCompanion({
    this.id = const Value.absent(),
    this.userBookId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.borrowerContact = const Value.absent(),
    this.loanedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookLoansCompanion.insert({
    required String id,
    required String userBookId,
    required String borrowerName,
    this.borrowerContact = const Value.absent(),
    required DateTime loanedAt,
    this.dueDate = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userBookId = Value(userBookId),
       borrowerName = Value(borrowerName),
       loanedAt = Value(loanedAt);
  static Insertable<BookLoan> custom({
    Expression<String>? id,
    Expression<String>? userBookId,
    Expression<String>? borrowerName,
    Expression<String>? borrowerContact,
    Expression<DateTime>? loanedAt,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? returnedAt,
    Expression<String>? notes,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userBookId != null) 'user_book_id': userBookId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (borrowerContact != null) 'borrower_contact': borrowerContact,
      if (loanedAt != null) 'loaned_at': loanedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (notes != null) 'notes': notes,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookLoansCompanion copyWith({
    Value<String>? id,
    Value<String>? userBookId,
    Value<String>? borrowerName,
    Value<String?>? borrowerContact,
    Value<DateTime>? loanedAt,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? returnedAt,
    Value<String?>? notes,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return BookLoansCompanion(
      id: id ?? this.id,
      userBookId: userBookId ?? this.userBookId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      loanedAt: loanedAt ?? this.loanedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
      notes: notes ?? this.notes,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userBookId.present) {
      map['user_book_id'] = Variable<String>(userBookId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (borrowerContact.present) {
      map['borrower_contact'] = Variable<String>(borrowerContact.value);
    }
    if (loanedAt.present) {
      map['loaned_at'] = Variable<DateTime>(loanedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (returnedAt.present) {
      map['returned_at'] = Variable<DateTime>(returnedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookLoansCompanion(')
          ..write('id: $id, ')
          ..write('userBookId: $userBookId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerContact: $borrowerContact, ')
          ..write('loanedAt: $loanedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('notes: $notes, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CatalogBooksTable catalogBooks = $CatalogBooksTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $UserBooksTable userBooks = $UserBooksTable(this);
  late final $ScansTable scans = $ScansTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  late final $BookLoansTable bookLoans = $BookLoansTable(this);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    catalogBooks,
    shelves,
    userBooks,
    scans,
    syncQueueEntries,
    bookLoans,
  ];
}

typedef $$CatalogBooksTableCreateCompanionBuilder =
    CatalogBooksCompanion Function({
      Value<int> id,
      Value<String?> olKey,
      Value<String?> isbn13,
      required String title,
      Value<String?> subtitle,
      Value<List<String>> authors,
      Value<String?> publisher,
      Value<int?> publishYear,
      Value<String?> language,
      Value<String?> coverUrl,
    });
typedef $$CatalogBooksTableUpdateCompanionBuilder =
    CatalogBooksCompanion Function({
      Value<int> id,
      Value<String?> olKey,
      Value<String?> isbn13,
      Value<String> title,
      Value<String?> subtitle,
      Value<List<String>> authors,
      Value<String?> publisher,
      Value<int?> publishYear,
      Value<String?> language,
      Value<String?> coverUrl,
    });

final class $$CatalogBooksTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogBooksTable, CatalogBook> {
  $$CatalogBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserBooksTable, List<UserBook>>
  _userBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userBooks,
    aliasName: $_aliasNameGenerator(db.catalogBooks.id, db.userBooks.bookId),
  );

  $$UserBooksTableProcessedTableManager get userBooksRefs {
    final manager = $$UserBooksTableTableManager(
      $_db,
      $_db.userBooks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogBooksTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogBooksTable> {
  $$CatalogBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get olKey => $composableBuilder(
    column: $table.olKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userBooksRefs(
    Expression<bool> Function($$UserBooksTableFilterComposer f) f,
  ) {
    final $$UserBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableFilterComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogBooksTable> {
  $$CatalogBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get olKey => $composableBuilder(
    column: $table.olKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogBooksTable> {
  $$CatalogBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get olKey =>
      $composableBuilder(column: $table.olKey, builder: (column) => column);

  GeneratedColumn<String> get isbn13 =>
      $composableBuilder(column: $table.isbn13, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  Expression<T> userBooksRefs<T extends Object>(
    Expression<T> Function($$UserBooksTableAnnotationComposer a) f,
  ) {
    final $$UserBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogBooksTable,
          CatalogBook,
          $$CatalogBooksTableFilterComposer,
          $$CatalogBooksTableOrderingComposer,
          $$CatalogBooksTableAnnotationComposer,
          $$CatalogBooksTableCreateCompanionBuilder,
          $$CatalogBooksTableUpdateCompanionBuilder,
          (CatalogBook, $$CatalogBooksTableReferences),
          CatalogBook,
          PrefetchHooks Function({bool userBooksRefs})
        > {
  $$CatalogBooksTableTableManager(_$AppDatabase db, $CatalogBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> olKey = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<List<String>> authors = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publishYear = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
              }) => CatalogBooksCompanion(
                id: id,
                olKey: olKey,
                isbn13: isbn13,
                title: title,
                subtitle: subtitle,
                authors: authors,
                publisher: publisher,
                publishYear: publishYear,
                language: language,
                coverUrl: coverUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> olKey = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<List<String>> authors = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publishYear = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
              }) => CatalogBooksCompanion.insert(
                id: id,
                olKey: olKey,
                isbn13: isbn13,
                title: title,
                subtitle: subtitle,
                authors: authors,
                publisher: publisher,
                publishYear: publishYear,
                language: language,
                coverUrl: coverUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userBooksRefs) db.userBooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userBooksRefs)
                    await $_getPrefetchedData<
                      CatalogBook,
                      $CatalogBooksTable,
                      UserBook
                    >(
                      currentTable: table,
                      referencedTable: $$CatalogBooksTableReferences
                          ._userBooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CatalogBooksTableReferences(
                            db,
                            table,
                            p0,
                          ).userBooksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CatalogBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogBooksTable,
      CatalogBook,
      $$CatalogBooksTableFilterComposer,
      $$CatalogBooksTableOrderingComposer,
      $$CatalogBooksTableAnnotationComposer,
      $$CatalogBooksTableCreateCompanionBuilder,
      $$CatalogBooksTableUpdateCompanionBuilder,
      (CatalogBook, $$CatalogBooksTableReferences),
      CatalogBook,
      PrefetchHooks Function({bool userBooksRefs})
    >;
typedef $$ShelvesTableCreateCompanionBuilder =
    ShelvesCompanion Function({
      required String id,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$ShelvesTableUpdateCompanionBuilder =
    ShelvesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDatabase, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserBooksTable, List<UserBook>>
  _userBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userBooks,
    aliasName: $_aliasNameGenerator(db.shelves.id, db.userBooks.shelfId),
  );

  $$UserBooksTableProcessedTableManager get userBooksRefs {
    final manager = $$UserBooksTableTableManager(
      $_db,
      $_db.userBooks,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userBooksRefs(
    Expression<bool> Function($$UserBooksTableFilterComposer f) f,
  ) {
    final $$UserBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableFilterComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  Expression<T> userBooksRefs<T extends Object>(
    Expression<T> Function($$UserBooksTableAnnotationComposer a) f,
  ) {
    final $$UserBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({bool userBooksRefs})
        > {
  $$ShelvesTableTableManager(_$AppDatabase db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelvesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelvesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userBooksRefs) db.userBooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userBooksRefs)
                    await $_getPrefetchedData<Shelf, $ShelvesTable, UserBook>(
                      currentTable: table,
                      referencedTable: $$ShelvesTableReferences
                          ._userBooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShelvesTableReferences(db, table, p0).userBooksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({bool userBooksRefs})
    >;
typedef $$UserBooksTableCreateCompanionBuilder =
    UserBooksCompanion Function({
      required String id,
      Value<int?> bookId,
      Value<String?> manualTitle,
      Value<String?> manualAuthor,
      Value<String?> shelfId,
      Value<ReadingStatus> status,
      required MatchConfidence confidence,
      Value<String?> spineColor,
      Value<String?> capturePath,
      Value<int?> shelfPosition,
      required DateTime addedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$UserBooksTableUpdateCompanionBuilder =
    UserBooksCompanion Function({
      Value<String> id,
      Value<int?> bookId,
      Value<String?> manualTitle,
      Value<String?> manualAuthor,
      Value<String?> shelfId,
      Value<ReadingStatus> status,
      Value<MatchConfidence> confidence,
      Value<String?> spineColor,
      Value<String?> capturePath,
      Value<int?> shelfPosition,
      Value<DateTime> addedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

final class $$UserBooksTableReferences
    extends BaseReferences<_$AppDatabase, $UserBooksTable, UserBook> {
  $$UserBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogBooksTable _bookIdTable(_$AppDatabase db) =>
      db.catalogBooks.createAlias(
        $_aliasNameGenerator(db.userBooks.bookId, db.catalogBooks.id),
      );

  $$CatalogBooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$CatalogBooksTableTableManager(
      $_db,
      $_db.catalogBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) => db.shelves
      .createAlias($_aliasNameGenerator(db.userBooks.shelfId, db.shelves.id));

  $$ShelvesTableProcessedTableManager? get shelfId {
    final $_column = $_itemColumn<String>('shelf_id');
    if ($_column == null) return null;
    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BookLoansTable, List<BookLoan>>
  _bookLoansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookLoans,
    aliasName: $_aliasNameGenerator(db.userBooks.id, db.bookLoans.userBookId),
  );

  $$BookLoansTableProcessedTableManager get bookLoansRefs {
    final manager = $$BookLoansTableTableManager(
      $_db,
      $_db.bookLoans,
    ).filter((f) => f.userBookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookLoansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserBooksTableFilterComposer
    extends Composer<_$AppDatabase, $UserBooksTable> {
  $$UserBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualTitle => $composableBuilder(
    column: $table.manualTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualAuthor => $composableBuilder(
    column: $table.manualAuthor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReadingStatus, ReadingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchConfidence, MatchConfidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get spineColor => $composableBuilder(
    column: $table.spineColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfPosition => $composableBuilder(
    column: $table.shelfPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogBooksTableFilterComposer get bookId {
    final $$CatalogBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.catalogBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogBooksTableFilterComposer(
            $db: $db,
            $table: $db.catalogBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookLoansRefs(
    Expression<bool> Function($$BookLoansTableFilterComposer f) f,
  ) {
    final $$BookLoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookLoans,
      getReferencedColumn: (t) => t.userBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookLoansTableFilterComposer(
            $db: $db,
            $table: $db.bookLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $UserBooksTable> {
  $$UserBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualTitle => $composableBuilder(
    column: $table.manualTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualAuthor => $composableBuilder(
    column: $table.manualAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spineColor => $composableBuilder(
    column: $table.spineColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfPosition => $composableBuilder(
    column: $table.shelfPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogBooksTableOrderingComposer get bookId {
    final $$CatalogBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.catalogBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogBooksTableOrderingComposer(
            $db: $db,
            $table: $db.catalogBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserBooksTable> {
  $$UserBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get manualTitle => $composableBuilder(
    column: $table.manualTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manualAuthor => $composableBuilder(
    column: $table.manualAuthor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReadingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MatchConfidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get spineColor => $composableBuilder(
    column: $table.spineColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfPosition => $composableBuilder(
    column: $table.shelfPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  $$CatalogBooksTableAnnotationComposer get bookId {
    final $$CatalogBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.catalogBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookLoansRefs<T extends Object>(
    Expression<T> Function($$BookLoansTableAnnotationComposer a) f,
  ) {
    final $$BookLoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookLoans,
      getReferencedColumn: (t) => t.userBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookLoansTableAnnotationComposer(
            $db: $db,
            $table: $db.bookLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserBooksTable,
          UserBook,
          $$UserBooksTableFilterComposer,
          $$UserBooksTableOrderingComposer,
          $$UserBooksTableAnnotationComposer,
          $$UserBooksTableCreateCompanionBuilder,
          $$UserBooksTableUpdateCompanionBuilder,
          (UserBook, $$UserBooksTableReferences),
          UserBook,
          PrefetchHooks Function({
            bool bookId,
            bool shelfId,
            bool bookLoansRefs,
          })
        > {
  $$UserBooksTableTableManager(_$AppDatabase db, $UserBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                Value<String?> manualTitle = const Value.absent(),
                Value<String?> manualAuthor = const Value.absent(),
                Value<String?> shelfId = const Value.absent(),
                Value<ReadingStatus> status = const Value.absent(),
                Value<MatchConfidence> confidence = const Value.absent(),
                Value<String?> spineColor = const Value.absent(),
                Value<String?> capturePath = const Value.absent(),
                Value<int?> shelfPosition = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBooksCompanion(
                id: id,
                bookId: bookId,
                manualTitle: manualTitle,
                manualAuthor: manualAuthor,
                shelfId: shelfId,
                status: status,
                confidence: confidence,
                spineColor: spineColor,
                capturePath: capturePath,
                shelfPosition: shelfPosition,
                addedAt: addedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> bookId = const Value.absent(),
                Value<String?> manualTitle = const Value.absent(),
                Value<String?> manualAuthor = const Value.absent(),
                Value<String?> shelfId = const Value.absent(),
                Value<ReadingStatus> status = const Value.absent(),
                required MatchConfidence confidence,
                Value<String?> spineColor = const Value.absent(),
                Value<String?> capturePath = const Value.absent(),
                Value<int?> shelfPosition = const Value.absent(),
                required DateTime addedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBooksCompanion.insert(
                id: id,
                bookId: bookId,
                manualTitle: manualTitle,
                manualAuthor: manualAuthor,
                shelfId: shelfId,
                status: status,
                confidence: confidence,
                spineColor: spineColor,
                capturePath: capturePath,
                shelfPosition: shelfPosition,
                addedAt: addedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, shelfId = false, bookLoansRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (bookLoansRefs) db.bookLoans],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable: $$UserBooksTableReferences
                                        ._bookIdTable(db),
                                    referencedColumn: $$UserBooksTableReferences
                                        ._bookIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (shelfId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shelfId,
                                    referencedTable: $$UserBooksTableReferences
                                        ._shelfIdTable(db),
                                    referencedColumn: $$UserBooksTableReferences
                                        ._shelfIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookLoansRefs)
                        await $_getPrefetchedData<
                          UserBook,
                          $UserBooksTable,
                          BookLoan
                        >(
                          currentTable: table,
                          referencedTable: $$UserBooksTableReferences
                              ._bookLoansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookLoansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserBooksTable,
      UserBook,
      $$UserBooksTableFilterComposer,
      $$UserBooksTableOrderingComposer,
      $$UserBooksTableAnnotationComposer,
      $$UserBooksTableCreateCompanionBuilder,
      $$UserBooksTableUpdateCompanionBuilder,
      (UserBook, $$UserBooksTableReferences),
      UserBook,
      PrefetchHooks Function({bool bookId, bool shelfId, bool bookLoansRefs})
    >;
typedef $$ScansTableCreateCompanionBuilder =
    ScansCompanion Function({
      required String id,
      Value<int?> detectedCount,
      Value<int?> matchedCount,
      Value<String?> capturePath,
      required DateTime createdAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$ScansTableUpdateCompanionBuilder =
    ScansCompanion Function({
      Value<String> id,
      Value<int?> detectedCount,
      Value<int?> matchedCount,
      Value<String?> capturePath,
      Value<DateTime> createdAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$ScansTableFilterComposer extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedCount => $composableBuilder(
    column: $table.detectedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScansTableOrderingComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedCount => $composableBuilder(
    column: $table.detectedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get detectedCount => $composableBuilder(
    column: $table.detectedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capturePath => $composableBuilder(
    column: $table.capturePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$ScansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScansTable,
          Scan,
          $$ScansTableFilterComposer,
          $$ScansTableOrderingComposer,
          $$ScansTableAnnotationComposer,
          $$ScansTableCreateCompanionBuilder,
          $$ScansTableUpdateCompanionBuilder,
          (Scan, BaseReferences<_$AppDatabase, $ScansTable, Scan>),
          Scan,
          PrefetchHooks Function()
        > {
  $$ScansTableTableManager(_$AppDatabase db, $ScansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> detectedCount = const Value.absent(),
                Value<int?> matchedCount = const Value.absent(),
                Value<String?> capturePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansCompanion(
                id: id,
                detectedCount: detectedCount,
                matchedCount: matchedCount,
                capturePath: capturePath,
                createdAt: createdAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> detectedCount = const Value.absent(),
                Value<int?> matchedCount = const Value.absent(),
                Value<String?> capturePath = const Value.absent(),
                required DateTime createdAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansCompanion.insert(
                id: id,
                detectedCount: detectedCount,
                matchedCount: matchedCount,
                capturePath: capturePath,
                createdAt: createdAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScansTable,
      Scan,
      $$ScansTableFilterComposer,
      $$ScansTableOrderingComposer,
      $$ScansTableAnnotationComposer,
      $$ScansTableCreateCompanionBuilder,
      $$ScansTableUpdateCompanionBuilder,
      (Scan, BaseReferences<_$AppDatabase, $ScansTable, Scan>),
      Scan,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      required SyncEntity entity,
      required String rowId,
      required SyncOperation operation,
      required DateTime enqueuedAt,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      Value<SyncEntity> entity,
      Value<String> rowId,
      Value<SyncOperation> operation,
      Value<DateTime> enqueuedAt,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEntity, SyncEntity, String> get entity =>
      $composableBuilder(
        column: $table.entity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperation, SyncOperation, String>
  get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncEntity, String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueEntry,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueEntriesTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SyncEntity> entity = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<SyncOperation> operation = const Value.absent(),
                Value<DateTime> enqueuedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                id: id,
                entity: entity,
                rowId: rowId,
                operation: operation,
                enqueuedAt: enqueuedAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required SyncEntity entity,
                required String rowId,
                required SyncOperation operation,
                required DateTime enqueuedAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueEntriesCompanion.insert(
                id: id,
                entity: entity,
                rowId: rowId,
                operation: operation,
                enqueuedAt: enqueuedAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueEntry,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$BookLoansTableCreateCompanionBuilder =
    BookLoansCompanion Function({
      required String id,
      required String userBookId,
      required String borrowerName,
      Value<String?> borrowerContact,
      required DateTime loanedAt,
      Value<DateTime?> dueDate,
      Value<DateTime?> returnedAt,
      Value<String?> notes,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$BookLoansTableUpdateCompanionBuilder =
    BookLoansCompanion Function({
      Value<String> id,
      Value<String> userBookId,
      Value<String> borrowerName,
      Value<String?> borrowerContact,
      Value<DateTime> loanedAt,
      Value<DateTime?> dueDate,
      Value<DateTime?> returnedAt,
      Value<String?> notes,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

final class $$BookLoansTableReferences
    extends BaseReferences<_$AppDatabase, $BookLoansTable, BookLoan> {
  $$BookLoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserBooksTable _userBookIdTable(_$AppDatabase db) =>
      db.userBooks.createAlias(
        $_aliasNameGenerator(db.bookLoans.userBookId, db.userBooks.id),
      );

  $$UserBooksTableProcessedTableManager get userBookId {
    final $_column = $_itemColumn<String>('user_book_id')!;

    final manager = $$UserBooksTableTableManager(
      $_db,
      $_db.userBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookLoansTableFilterComposer
    extends Composer<_$AppDatabase, $BookLoansTable> {
  $$BookLoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borrowerContact => $composableBuilder(
    column: $table.borrowerContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loanedAt => $composableBuilder(
    column: $table.loanedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  $$UserBooksTableFilterComposer get userBookId {
    final $$UserBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userBookId,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableFilterComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookLoansTableOrderingComposer
    extends Composer<_$AppDatabase, $BookLoansTable> {
  $$BookLoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borrowerContact => $composableBuilder(
    column: $table.borrowerContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loanedAt => $composableBuilder(
    column: $table.loanedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserBooksTableOrderingComposer get userBookId {
    final $$UserBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userBookId,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableOrderingComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookLoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookLoansTable> {
  $$BookLoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get borrowerName => $composableBuilder(
    column: $table.borrowerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get borrowerContact => $composableBuilder(
    column: $table.borrowerContact,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loanedAt =>
      $composableBuilder(column: $table.loanedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  $$UserBooksTableAnnotationComposer get userBookId {
    final $$UserBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userBookId,
      referencedTable: $db.userBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.userBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookLoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookLoansTable,
          BookLoan,
          $$BookLoansTableFilterComposer,
          $$BookLoansTableOrderingComposer,
          $$BookLoansTableAnnotationComposer,
          $$BookLoansTableCreateCompanionBuilder,
          $$BookLoansTableUpdateCompanionBuilder,
          (BookLoan, $$BookLoansTableReferences),
          BookLoan,
          PrefetchHooks Function({bool userBookId})
        > {
  $$BookLoansTableTableManager(_$AppDatabase db, $BookLoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookLoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookLoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookLoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userBookId = const Value.absent(),
                Value<String> borrowerName = const Value.absent(),
                Value<String?> borrowerContact = const Value.absent(),
                Value<DateTime> loanedAt = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> returnedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookLoansCompanion(
                id: id,
                userBookId: userBookId,
                borrowerName: borrowerName,
                borrowerContact: borrowerContact,
                loanedAt: loanedAt,
                dueDate: dueDate,
                returnedAt: returnedAt,
                notes: notes,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userBookId,
                required String borrowerName,
                Value<String?> borrowerContact = const Value.absent(),
                required DateTime loanedAt,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> returnedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookLoansCompanion.insert(
                id: id,
                userBookId: userBookId,
                borrowerName: borrowerName,
                borrowerContact: borrowerContact,
                loanedAt: loanedAt,
                dueDate: dueDate,
                returnedAt: returnedAt,
                notes: notes,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookLoansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userBookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userBookId,
                                referencedTable: $$BookLoansTableReferences
                                    ._userBookIdTable(db),
                                referencedColumn: $$BookLoansTableReferences
                                    ._userBookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookLoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookLoansTable,
      BookLoan,
      $$BookLoansTableFilterComposer,
      $$BookLoansTableOrderingComposer,
      $$BookLoansTableAnnotationComposer,
      $$BookLoansTableCreateCompanionBuilder,
      $$BookLoansTableUpdateCompanionBuilder,
      (BookLoan, $$BookLoansTableReferences),
      BookLoan,
      PrefetchHooks Function({bool userBookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CatalogBooksTableTableManager get catalogBooks =>
      $$CatalogBooksTableTableManager(_db, _db.catalogBooks);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$UserBooksTableTableManager get userBooks =>
      $$UserBooksTableTableManager(_db, _db.userBooks);
  $$ScansTableTableManager get scans =>
      $$ScansTableTableManager(_db, _db.scans);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$BookLoansTableTableManager get bookLoans =>
      $$BookLoansTableTableManager(_db, _db.bookLoans);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'44154e51c3f3079ee293d8ad0ebd1e17cca871ed';

/// The app-wide database handle.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
