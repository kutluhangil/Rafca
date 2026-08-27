import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart';

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
  AppDatabase() : super(openSpineDatabase());

  /// Visible for testing: an in-memory database with no file behind it.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

/// The app-wide database handle.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
