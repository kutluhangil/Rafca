import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/share/models/share_models.dart';
import 'package:rafca/features/share/widgets/share_card.dart';
import 'package:rafca/l10n/app_localizations.dart';

void main() {
  group('ShareCard', () {
    Widget wrap(Widget child, {Locale locale = const Locale('tr')}) {
      return MaterialApp(
        theme: SpineTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('renders book count, subtitle and watermark in Turkish', (tester) async {
      const data = ShareCollectionData(
        title: 'Sonbahar Rafı',
        subtitle: 'Felsefe Kitaplığı',
        bookCount: 42,
        spineColors: ['#304E2E', '#C9963F', '#8B2323'],
        categories: ['Felsefe', 'Tarih'],
      );

      await tester.pumpWidget(wrap(const ShareCard(data: data)));
      await tester.pumpAndSettle();

      expect(find.text('42 Kitap'), findsOneWidget);
      expect(find.text('FELSEFE KİTAPLIĞI'), findsOneWidget);
      expect(find.text('FELSEFE / TARİH'), findsOneWidget);
      expect(find.text('RAFÇA'), findsOneWidget);
    });

    testWidgets('renders in English when locale is en', (tester) async {
      const data = ShareCollectionData(
        title: 'Autumn Shelf',
        subtitle: 'Philosophy Shelf',
        bookCount: 15,
        spineColors: ['#1E262B', '#C9963F'],
        categories: ['Poetry', 'Noir'],
      );

      await tester.pumpWidget(wrap(const ShareCard(data: data), locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('15 Books'), findsOneWidget);
      expect(find.text('PHILOSOPHY SHELF'), findsOneWidget);
      expect(find.text('POETRY / NOIR'), findsOneWidget);
      expect(find.text('RAFÇA'), findsOneWidget);
    });

    testWidgets('handles empty spine colors gracefully with defaults', (tester) async {
      const data = ShareCollectionData(
        title: 'Boş Koleksiyon',
        subtitle: 'Genel',
        bookCount: 0,
        spineColors: [],
      );

      await tester.pumpWidget(wrap(const ShareCard(data: data)));
      await tester.pumpAndSettle();

      expect(find.text('0 Kitap'), findsOneWidget);
      expect(find.text('GENEL'), findsOneWidget);
      expect(find.text('RAFÇA'), findsOneWidget);
    });
  });
}
