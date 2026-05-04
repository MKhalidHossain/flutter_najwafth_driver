enum AppEnvironment { development, staging, production }

final class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  const AppConfig.development()
    : this(
        appName: 'Najwafth Driver',
        environment: AppEnvironment.development,
        // Use 10.0.2.2:5000 for Android emulator, 127.0.0.1:5000 for iOS simulator
        baseUrl: 'http://127.0.0.1:5000',
      );

  final String appName;
  final AppEnvironment environment;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;
}
