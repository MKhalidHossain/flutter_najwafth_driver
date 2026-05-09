import 'package:flutter_najwafth_driver/core/errors/result.dart';
import 'package:flutter_najwafth_driver/core/network/api_client.dart';
import 'package:flutter_najwafth_driver/core/network/network_providers.dart';
import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';
import 'package:flutter_najwafth_driver/features/notifications/domain/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(apiClientProvider));
});

final class NotificationApi {
  const NotificationApi(this._apiClient);

  static const _basePath = '/api/v1/notification';

  final ApiClient _apiClient;

  Future<Result<NotificationsPage>> getNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get(
      _basePath,
      queryParameters: {'page': page, 'limit': limit},
      parser: (data) => NotificationsPage.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<int>> getUnreadNotificationCount() {
    return _apiClient.get(
      '$_basePath/unread-count',
      parser: (data) {
        final payload = data['data'] as JsonMap? ?? const <String, dynamic>{};
        final unreadCount = payload['unreadCount'];
        if (unreadCount is int) return unreadCount;
        if (unreadCount is num) return unreadCount.toInt();
        return 0;
      },
    );
  }

  Future<Result<AppNotification>> markNotificationAsRead(
    String notificationId,
  ) {
    return _apiClient.patch(
      '$_basePath/$notificationId/read',
      parser: (data) => AppNotification.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<int>> markAllNotificationsAsRead() {
    return _apiClient.patch(
      '$_basePath/read-all',
      parser: (data) {
        final payload = data['data'] as JsonMap? ?? const <String, dynamic>{};
        final modifiedCount = payload['modifiedCount'];
        if (modifiedCount is int) return modifiedCount;
        if (modifiedCount is num) return modifiedCount.toInt();
        return 0;
      },
    );
  }
}
