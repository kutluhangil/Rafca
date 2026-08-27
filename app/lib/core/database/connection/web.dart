import 'package:drift/drift.dart';

/// Web has no Rafça database.
///
/// Web exists only so that the design system can be reviewed in Chrome during
/// a phase (CLAUDE.md, "Faz içi doğrulama yüzeyi"). It is not a delivery
/// target: the product is local-first around an on-device SQLite file, the
/// camera and ML Kit, none of which this build has.
///
/// This throws rather than falling back to an in-memory database on purpose.
/// A silent fallback would let a screen look like it persisted something in
/// Chrome and then behave differently on a phone, which is exactly the class
/// of bug the local-first requirement cannot afford.
QueryExecutor openSpineDatabase() {
  throw UnsupportedError(
    'Rafça has no database on web. The web build is a design review surface '
    'only (CLAUDE.md, "Faz içi doğrulama yüzeyi"); run on Android or iOS to '
    'use anything that reads or writes the library.',
  );
}
