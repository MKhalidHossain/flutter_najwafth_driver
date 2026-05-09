import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const Color backgroundColor = AppColors.background;
  static const String logoAsset = 'assets/images/app_logo.png';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

final class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();
    _routeTimer = Timer(const Duration(milliseconds: 1400), _routeFromSplash);
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    super.dispose();
  }

  void _routeFromSplash() {
    if (!mounted || _navigated) {
      return;
    }

    _navigated = true;
    final session = ref.read(appSessionControllerProvider);

    if (!session.onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }

    if (!session.isSignedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
      return;
    }

    if (!session.profileCompleted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.completeProfile,
        arguments: CompleteProfileRouteArgs(
          prefilledName: session.userName,
          email: session.email,
          phoneNumber: session.phoneNumber,
          shouldReturnToSignIn: false,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: SplashPage.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: SplashPage.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: SplashPage.backgroundColor,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.72,
            child: Image(
              image: AssetImage(SplashPage.logoAsset),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
