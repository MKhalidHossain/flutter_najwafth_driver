import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/splash/presentation/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class NajwafthDriverApp extends ConsumerWidget {
  const NajwafthDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.isDevelopment,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider),
      home: const SplashPage(),
    );
  }
}
