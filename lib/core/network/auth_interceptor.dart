import 'package:dio/dio.dart';
import 'package:flutter_najwafth_driver/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref);

  final Ref ref;

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _signedInKey = 'driver.auth.signed_in';
  static const _retryKey = 'auth_retry';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final storage = ref.read(keyValueStorageProvider);
    final accessToken = storage.readString(_accessTokenKey);

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra[_retryKey] == true;
    final isRefreshRequest = requestOptions.path.contains(
      '/api/v1/auth/refresh-token',
    );

    if (response?.statusCode != 401 || alreadyRetried || isRefreshRequest) {
      handler.next(err);
      return;
    }

    final storage = ref.read(keyValueStorageProvider);
    final refreshToken = storage.readString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearAuthStorage();
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: requestOptions.connectTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          headers: const {Headers.acceptHeader: Headers.jsonContentType},
        ),
      );

      final refreshResponse = await refreshDio.post<dynamic>(
        '/api/v1/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final tokenData = _extractTokenData(refreshResponse.data);
      final accessToken = tokenData['accessToken'];
      final newRefreshToken = tokenData['refreshToken'];

      if (accessToken == null || accessToken.isEmpty) {
        await _clearAuthStorage();
        handler.next(err);
        return;
      }

      await storage.writeString(_accessTokenKey, accessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await storage.writeString(_refreshTokenKey, newRefreshToken);
      }

      final retryOptions = requestOptions.copyWith(
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $accessToken',
        },
        extra: {...requestOptions.extra, _retryKey: true},
      );

      final retryResponse = await Dio().fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on Object {
      await _clearAuthStorage();
      handler.next(err);
    }
  }

  Map<String, String?> _extractTokenData(dynamic data) {
    final payload = data is Map<String, dynamic> ? data['data'] : null;
    final tokenMap = payload is Map<String, dynamic>
        ? payload
        : data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return {
      'accessToken': tokenMap['accessToken'] as String?,
      'refreshToken': tokenMap['refreshToken'] as String?,
    };
  }

  Future<void> _clearAuthStorage() async {
    final storage = ref.read(keyValueStorageProvider);
    await storage.remove(_accessTokenKey);
    await storage.remove(_refreshTokenKey);
    await storage.writeBool(_signedInKey, false);
  }
}
