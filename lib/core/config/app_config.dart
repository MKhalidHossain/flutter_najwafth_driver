import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

final class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  factory AppConfig.development() {
    return AppConfig(
      appName: 'Najwafth Driver',
      environment: AppEnvironment.development,
      baseUrl: _developmentBaseUrl,
    );
  }

  final String appName;
  final AppEnvironment environment;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;

  static String get _developmentBaseUrl {
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.isNotEmpty) return dartDefineUrl;

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5002'
        : 'http://localhost:5002';
  }
}
