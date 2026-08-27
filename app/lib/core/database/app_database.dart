import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart';
import 'sync_queue_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Rafça's local store.
///
/// Local-first is a product requirement, not an optimisation: the library must
/// open and be fully usable with no network (SPINE_BLUEPRINT.md 3.1, 6.2).
/// Cloud sync is a queue drained on top of this, never a prerequisite for it.
///
/// The schema mirrors `supabase/migrations/`, with two device-only additions
/// the server has no column for: `capture_path`, because photos never leave the
/// phone (SPINE_BLUEPRINT.md 5), and `pending_sync`, because a row exists here
/// before any server has heard of it.
@DriftDatabase(
  tables: [CatalogBooks, Shelves, UserBooks, Scans, SyncQueueEntries],
  daos: [SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openSpineDatabase());

  /// Visible for testing: an in-memory database with no file behind it.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        // Version 1 was Faz 1's empty schema, which shipped to nobody but does
        // exist on the machines the foundation was verified on. Creating the
        // missing entities is the whole of the upgrade; there is no v1 data to
        // carry forward.
        onUpgrade: (migrator, from, to) async {
          if (from == 1) {
            await migrator.createAll();
          }
        },
        beforeOpen: (details) async {
          // Drift leaves foreign keys off because SQLite does. The schema
          // relies on them: a user_book points at a shelf and at a catalogue
          // row, and a dangling pointer there is a card that cannot render.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// The app-wide database handle.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
