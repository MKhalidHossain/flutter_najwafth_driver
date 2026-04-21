import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/splash/presentation/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Splash screen shows logo with brand background', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = await AppBootstrap.createProviderScope(
      child: const NajwafthDriverApp(),
    );

    await tester.pumpWidget(app);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(scaffold.backgroundColor, SplashPage.backgroundColor);
    expect(find.byType(Image), findsOneWidget);
  });
}
