import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/reset_password_page.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/pages/sign_up_page.dart';
import 'package:flutter_najwafth_driver/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter_najwafth_driver/features/splash/presentation/splash_page.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/pages/order_details_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/change_password_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/about_app_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/privacy_policy_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/terms_conditions_page.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/pages/choose_language_page.dart';
import 'package:flutter_najwafth_driver/features/notifications/presentation/pages/notifications_page.dart';

final class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String completeProfile = '/complete-profile';
  static const String home =
      '/home'; // Keeping original for backward compat if needed
  static const String dashboard = '/dashboard';
  static const String orderDetails = '/order-details';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String aboutApp = '/about-app';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String chooseLanguage = '/choose-language';
  static const String notifications = '/notifications';
}

final class SignInRouteArgs {
  const SignInRouteArgs({this.prefilledEmail, this.successMessage});

  final String? prefilledEmail;
  final String? successMessage;
}

final class OtpRouteArgs {
  const OtpRouteArgs({required this.email});

  final String email;
}

final class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({required this.email, required this.otp});

  final String email;
  final String otp;
}

final class CompleteProfileRouteArgs {
  const CompleteProfileRouteArgs({
    this.prefilledName,
    this.email,
    this.phoneNumber,
    this.shouldReturnToSignIn = true,
  });

  final String? prefilledName;
  final String? email;
  final String? phoneNumber;
  final bool shouldReturnToSignIn;
}

final class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _pageRoute(const SplashPage(), settings);
      case AppRoutes.onboarding:
        return _pageRoute(const OnboardingPage(), settings);
      case AppRoutes.signIn:
        final args = settings.arguments as SignInRouteArgs?;
        return _pageRoute(
          SignInPage(
            prefilledEmail: args?.prefilledEmail,
            successMessage: args?.successMessage,
          ),
          settings,
        );
      case AppRoutes.signUp:
        return _pageRoute(const SignUpPage(), settings);
      case AppRoutes.forgotPassword:
        return _pageRoute(const ForgotPasswordPage(), settings);
      case AppRoutes.otp:
        final args = settings.arguments as OtpRouteArgs;
        return _pageRoute(OtpVerificationPage(email: args.email), settings);
      case AppRoutes.resetPassword:
        final args = settings.arguments as ResetPasswordRouteArgs;
        return _pageRoute(
          ResetPasswordPage(email: args.email, otp: args.otp),
          settings,
        );
      case AppRoutes.completeProfile:
        final args = settings.arguments as CompleteProfileRouteArgs?;
        return _pageRoute(
          CompleteProfilePage(
            prefilledName: args?.prefilledName,
            email: args?.email,
            phoneNumber: args?.phoneNumber,
            shouldReturnToSignIn: args?.shouldReturnToSignIn ?? true,
          ),
          settings,
        );
      case AppRoutes.home:
        return _pageRoute(const DashboardPage(), settings);
      case AppRoutes.dashboard:
        return _pageRoute(const DashboardPage(), settings);
      case AppRoutes.orderDetails:
        return _pageRoute(const OrderDetailsPage(), settings);
      case AppRoutes.editProfile:
        return _pageRoute(const EditProfilePage(), settings);
      case AppRoutes.changePassword:
        return _pageRoute(const ChangePasswordPage(), settings);
      case AppRoutes.aboutApp:
        return _pageRoute(const AboutAppPage(), settings);
      case AppRoutes.privacyPolicy:
        return _pageRoute(const PrivacyPolicyPage(), settings);
      case AppRoutes.termsConditions:
        return _pageRoute(const TermsConditionsPage(), settings);
      case AppRoutes.chooseLanguage:
        return _pageRoute(const ChooseLanguagePage(), settings);
      case AppRoutes.notifications:
        return _pageRoute(const NotificationsPage(), settings);
      default:
        return _pageRoute(const SplashPage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _pageRoute(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
