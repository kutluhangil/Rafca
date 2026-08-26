import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

/// Rafça's local store.
///
/// Local-first is a product requirement, not an optimisation: the library must
/// open and be fully usable with no network (SPINE_BLUEPRINT.md 3.1, 6.2).
/// Cloud sync is a queue drained on top of this, never a prerequisite for it.
///
/// The schema is empty at Faz 1 on purpose — this class exists so that the
/// connection, the background isolate and the provider are proven; Faz 3 (A3)
/// adds the tables that mirror the Supabase schema plus the `pending_sync`
/// flag and `capture_path`.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Visible for testing: an in-memory database with no file behind it.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

/// Where the database file lives.
///
/// Kept beside the capture directory described in SPINE_BLUEPRINT.md 5, both
/// under the app's documents directory, so that "everything Rafça knows about
/// you is on this device" stays a single, checkable statement.
Future<File> databaseFile() async {
  final documents = await getApplicationDocumentsDirectory();
  return File(p.join(documents.path, 'spine', 'rafca.sqlite'));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await databaseFile();
    await file.parent.create(recursive: true);

    // sqlite3 on Android needs a writable temp directory, and old Android
    // versions ship a broken system sqlite; both are handled here.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
    }

    return NativeDatabase.createInBackground(file);
  });
}

/// The app-wide database handle.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
