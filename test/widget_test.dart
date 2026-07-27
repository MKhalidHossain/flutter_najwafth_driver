import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/widgets/document_page.dart';
import 'package:flutter_najwafth_driver/features/splash/presentation/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Defaults to French and can switch to English', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = await AppBootstrap.createProviderScope(
      child: const NajwafthDriverApp(),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(scaffold.backgroundColor, SplashPage.backgroundColor);
    expect(find.byType(Image), findsOneWidget);
    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, const Locale('fr'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container
        .read(localeControllerProvider.notifier)
        .setLanguage(AppLanguage.english);
    await tester.pump();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, const Locale('en'));
  });

  testWidgets('Saved English preference changes the app locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'driver.selected_language': 'english',
    });
    final app = await AppBootstrap.createProviderScope(
      child: const NajwafthDriverApp(),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, const Locale('en'));
  });

  testWidgets('Legacy English preference is preserved', (tester) async {
    SharedPreferences.setMockInitialValues({
      'driver.settings.language': 'English',
    });
    final app = await AppBootstrap.createProviderScope(
      child: const NajwafthDriverApp(),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, const Locale('en'));
  });

  testWidgets('Legal email addresses stay on one line on narrow screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [AppLocalizations.delegate],
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: DocumentContent(
              content: '''
LEGAL NOTICES

E-mail: booksonwheels21000@gmail.com
Contact: for any questions regarding this document: booksonwheels21000@gmail.com
''',
              accentColor: AppColors.primary,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final emailFinder = find.text('booksonwheels21000@gmail.com');
    expect(emailFinder, findsNWidgets(2));
    for (final element in emailFinder.evaluate()) {
      final text = element.widget as Text;
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
      expect(
        find.ancestor(
          of: find.byWidget(element.widget),
          matching: find.byType(FittedBox),
        ),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
