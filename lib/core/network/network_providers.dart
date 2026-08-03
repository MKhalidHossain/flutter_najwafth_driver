import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_najwafth_driver/core/config/app_config.dart';
import 'package:flutter_najwafth_driver/core/network/api_client.dart';
import 'package:flutter_najwafth_driver/core/network/auth_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.development();
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: const {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref));

  if (kDebugMode) {
    debugPrint('[API] Base URL: ${config.baseUrl}');
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _printApiBox(
            'API REQUEST',
            '${options.method} ${options.baseUrl}${options.path}',
            [
              'HEADERS',
              _readable(_redactedHeaders(options.headers)),
              'QUERY',
              _readable(options.queryParameters),
              'BODY',
              _readable(options.data),
            ],
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          _printApiBox(
            'API RESPONSE',
            '${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
            ['BODY', _readable(response.data)],
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _printApiBox(
            'API ERROR',
            '${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.path}',
            [
              'MESSAGE',
              error.message ?? '',
              'BODY',
              _readable(error.response?.data),
            ],
          );
          handler.next(error);
        },
      ),
    );
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
  return headers.map((key, value) {
    if (key.toLowerCase() == 'authorization') {
      return MapEntry(key, _redactAuthorization(value));
    }
    return MapEntry(key, value);
  });
}

String _redactAuthorization(Object? value) {
  final header = value?.toString() ?? '';
  if (!header.toLowerCase().startsWith('bearer ')) {
    return '***';
  }

  final token = header.substring(7);
  if (token.length <= 12) {
    return 'Bearer ***';
  }

  return 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 6)}';
}

void _printLine(String message) {
  const maxLogLineLength = 800;
  for (final line in message.split('\n')) {
    if (line.isEmpty) {
      debugPrint('');
      continue;
    }

    var start = 0;
    while (start < line.length) {
      final end = (start + maxLogLineLength < line.length)
          ? start + maxLogLineLength
          : line.length;
      debugPrint(line.substring(start, end));
      start = end;
    }
  }
  debugPrint('');
}

void _printApiBox(String title, String route, List<String> lines) {
  const border = '============================================================';
  _printLine(border);
  _printLine('$title | $route');
  _printLine(border);
  for (var i = 0; i < lines.length; i += 2) {
    _printLine(lines[i]);
    _printLine(lines[i + 1]);
    if (i + 2 < lines.length) {
      _printLine(
        '------------------------------------------------------------',
      );
    }
  }
  _printLine(border);
}

String _readable(dynamic value) {
  if (value == null) {
    return 'null';
  }

  if (value is FormData) {
    final fields = value.fields.map((e) => '${e.key}: ${e.value}').toList();
    final files = value.files
        .map((e) => '${e.key}: ${e.value.filename ?? 'file'}')
        .toList();
    return 'FormData{\n  fields: $fields,\n  files: $files\n}';
  }

  if (value is Map || value is List) {
    return _prettyJson(value);
  }

  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return _prettyJson(jsonDecode(trimmed));
      } on FormatException {
        return value;
      }
    }
  }

  return value.toString();
}

String _prettyJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}
