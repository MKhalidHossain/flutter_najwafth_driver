import 'package:flutter/foundation.dart';

const bool kUseLiveServer = bool.fromEnvironment(
  'USE_LIVE_SERVER',
  defaultValue: true,
);

const String _liveBaseUrl = 'https://api.booksonwheeels.com';
const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

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
      appName: 'Books on Wheels Driver',
      environment: kUseLiveServer
          ? AppEnvironment.production
          : AppEnvironment.development,
      baseUrl: _resolveBaseUrl(),
    );
  }

  final String appName;
  final AppEnvironment environment;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;
}

String _resolveBaseUrl() {
  if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
  if (kUseLiveServer) return _liveBaseUrl;

  return defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:5002'
      : 'http://localhost:5002';
}
