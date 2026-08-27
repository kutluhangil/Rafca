import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Where the database file lives.
///
/// Kept beside the capture directory described in SPINE_BLUEPRINT.md 5, both
/// under the app's documents directory, so that "everything Rafça knows about
/// you is on this device" stays a single, checkable statement.
Future<File> databaseFile() async {
  final documents = await getApplicationDocumentsDirectory();
  return File(p.join(documents.path, 'spine', 'rafca.sqlite'));
}

/// Opens the on-device SQLite file on Android and iOS.
QueryExecutor openSpineDatabase() {
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
