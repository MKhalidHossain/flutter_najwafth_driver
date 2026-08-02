import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_najwafth_driver/core/notifications/push_notification_service.dart';
import 'package:flutter_najwafth_driver/core/storage/storage_providers.dart';
import 'package:flutter_najwafth_driver/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppBootstrap {
  const AppBootstrap._();

  static Future<ProviderScope> createProviderScope({
    required Widget child,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } on Object {
      // The app remains usable when Firebase client configuration is absent.
    }

    final preferences = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: child,
    );
  }
}
