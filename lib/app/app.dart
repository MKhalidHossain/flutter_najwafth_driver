import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_najwafth_driver/core/notifications/push_notification_service.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';

final class NajwafthDriverApp extends ConsumerWidget {
  const NajwafthDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final language = ref.watch(localeControllerProvider);
    final isSignedIn = ref.watch(
      appSessionControllerProvider.select((state) => state.isSignedIn),
    );
    if (isSignedIn) {
      unawaited(ref.read(pushNotificationServiceProvider).start());
    }

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) => config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
