import 'package:flutter/widgets.dart';
import 'package:flutter_najwafth_driver/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppBootstrap {
  const AppBootstrap._();

  static Future<ProviderScope> createProviderScope({
    required Widget child,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final preferences = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: child,
    );
  }
}
