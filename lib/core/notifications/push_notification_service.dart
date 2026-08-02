import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/application/driver_request_event.dart';
import 'package:flutter_najwafth_driver/features/notifications/data/notification_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  PushNotificationService.new,
);

final class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  bool _started = false;
  String? _currentToken;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  Future<void> start() async {
    if (Firebase.apps.isEmpty) return;
    if (_started) {
      await _registerCurrentToken();
      return;
    }
    _started = true;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await _registerCurrentToken();

      _tokenSubscription = messaging.onTokenRefresh.listen((token) {
        _currentToken = token;
        unawaited(_registerToken(token));
      });
      _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleMessage(message, opened: true),
      );

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handleMessage(initialMessage, opened: true),
        );
      }
    } on Object catch (error) {
      debugPrint('[push] start failed: $error');
      _started = false;
    }
  }

  void _handleMessage(RemoteMessage message, {bool opened = false}) {
    final type = message.data['type'] ?? '';
    if (type != 'driver_request_new' && type != 'driver_request_assigned') {
      return;
    }

    final requestId = message.data['driverRequestId'];
    _ref
        .read(driverRequestEventProvider.notifier)
        .emit(type: type, driverRequestId: requestId);

    if (!opened) return;
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    if (type == 'driver_request_assigned' &&
        requestId != null &&
        requestId.isNotEmpty) {
      navigator.pushNamed(
        AppRoutes.driverRequestDetails,
        arguments: DriverRequestDetailsRouteArgs(driverRequestId: requestId),
      );
    } else {
      navigator.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    }
  }

  Future<void> _registerCurrentToken() async {
    if (!await _canFetchToken()) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    _currentToken = token;
    await _registerToken(token);
  }

  Future<void> _registerToken(String token) async {
    final result = await _ref
        .read(notificationApiProvider)
        .registerDeviceToken(token);
    if (result.failureOrNull != null) {
      debugPrint('[push] token registration failed');
    }
  }

  Future<void> unregister() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final token =
          _currentToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _ref.read(notificationApiProvider).removeDeviceToken(token);
      }
    } on Object catch (error) {
      debugPrint('[push] token removal failed: $error');
    } finally {
      await _tokenSubscription?.cancel();
      await _messageSubscription?.cancel();
      await _openedSubscription?.cancel();
      _tokenSubscription = null;
      _messageSubscription = null;
      _openedSubscription = null;
      _currentToken = null;
      _started = false;
    }
  }

  Future<bool> _canFetchToken() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return true;
    }
    final token = await FirebaseMessaging.instance.getAPNSToken();
    return token != null && token.isNotEmpty;
  }
}
