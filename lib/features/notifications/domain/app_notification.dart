import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';

final class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final JsonMap metadata;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    JsonMap? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AppNotification.fromJson(JsonMap json) {
    return AppNotification(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? json['body'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      readAt: _readDate(json['readAt']),
      createdAt: _readDate(json['createdAt']),
      metadata: json['metadata'] is JsonMap
          ? json['metadata'] as JsonMap
          : const <String, dynamic>{},
    );
  }
}

final class NotificationsPage {
  const NotificationsPage({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory NotificationsPage.fromJson(JsonMap json) {
    final rawNotifications = json['notifications'];
    final notifications = rawNotifications is List
        ? rawNotifications
              .whereType<JsonMap>()
              .map(AppNotification.fromJson)
              .toList(growable: false)
        : const <AppNotification>[];
    final pagination = json['pagination'] is JsonMap
        ? json['pagination'] as JsonMap
        : const <String, dynamic>{};

    return NotificationsPage(
      notifications: notifications,
      unreadCount: _readInt(json['unreadCount']),
      page: _readInt(pagination['page'], fallback: 1),
      limit: _readInt(pagination['limit'], fallback: notifications.length),
      total: _readInt(pagination['total'], fallback: notifications.length),
      totalPages: _readInt(pagination['totalPages'], fallback: 1),
    );
  }
}

DateTime? _readDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
