import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/notifications/data/notification_api.dart';
import 'package:flutter_najwafth_driver/features/notifications/domain/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  static const _pageSize = 20;

  final _scrollController = ScrollController();
  final List<AppNotification> _notifications = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || _isRefreshing) return;
    if (_scrollController.position.extentAfter < 240) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    setState(() {
      _errorMessage = null;
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    final result = await ref
        .read(notificationApiProvider)
        .getNotifications(page: 1, limit: _pageSize);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    final page = result.dataOrNull!;
    setState(() {
      _notifications
        ..clear()
        ..addAll(page.notifications);
      _page = page.page;
      _hasMore = page.hasMore;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    final result = await ref
        .read(notificationApiProvider)
        .getNotifications(page: _page + 1, limit: _pageSize);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    final page = result.dataOrNull!;
    setState(() {
      _notifications.addAll(page.notifications);
      _page = page.page;
      _hasMore = page.hasMore;
      _isLoadingMore = false;
    });
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.id.isEmpty || notification.isRead) return;

    final index = _notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (index == -1) return;

    setState(() {
      _notifications[index] = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    });

    final result = await ref
        .read(notificationApiProvider)
        .markNotificationAsRead(notification.id);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _notifications[index] = notification);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    final updated = result.dataOrNull;
    if (updated != null) {
      setState(() => _notifications[index] = updated);
    }
  }

  Future<void> _markAllAsRead() async {
    final hasUnread = _notifications.any(
      (notification) => !notification.isRead,
    );
    if (!hasUnread) return;

    final previous = List<AppNotification>.of(_notifications);
    setState(() {
      for (var index = 0; index < _notifications.length; index += 1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    });

    final result = await ref
        .read(notificationApiProvider)
        .markAllNotificationsAsRead();

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _notifications
          ..clear()
          ..addAll(previous);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.title,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.tr('Notifications'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
        actions: [
          if (_notifications.any((notification) => !notification.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(context.l10n.tr('Mark All')),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: () => _loadNotifications(),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(
              child: Text(
                context.l10n.tr('No notifications yet.'),
                style: const TextStyle(color: AppColors.subtitle),
              ),
            ),
          ],
        ),
      );
    }

    final newNotifications = _notifications
        .where((notification) => !notification.isRead)
        .toList(growable: false);
    final earlierNotifications = _notifications
        .where((notification) => notification.isRead)
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (newNotifications.isNotEmpty) ...[
            _SectionHeader(title: context.l10n.tr('New')),
            for (final notification in newNotifications)
              _buildNotificationItem(
                notification: notification,
                onTap: () => _markAsRead(notification),
              ),
          ],
          if (earlierNotifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                context.l10n.tr('Earlier'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title,
                ),
              ),
            ),
            for (final notification in earlierNotifications)
              _buildNotificationItem(
                notification: notification,
                onTap: () => _markAsRead(notification),
              ),
          ],
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required AppNotification notification,
    required VoidCallback onTap,
  }) {
    final icon = _iconForType(notification.type);
    final text = _notificationText(notification);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon.$1, color: icon.$2, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: notification.isRead
                          ? AppColors.subtitle
                          : AppColors.title,
                      height: 1.4,
                      fontWeight: notification.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _relativeTime(notification.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFFEFEFEF), height: 1),
          ),
        ],
      ),
    );
  }

  (IconData, Color)? _iconForType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('cancel') || normalized.contains('reject')) {
      return (Icons.block, Colors.red);
    }
    if (normalized.contains('success') ||
        normalized.contains('complete') ||
        normalized.contains('delivered')) {
      return (Icons.check_circle, Colors.green);
    }
    if (normalized.contains('chat') || normalized.contains('message')) {
      return (Icons.chat, Colors.green);
    }
    if (normalized.contains('send') ||
        normalized.contains('order') ||
        normalized.contains('delivery')) {
      return (Icons.send, Colors.blue);
    }
    return null;
  }

  String _notificationText(AppNotification notification) {
    final title = context.l10n.tr(notification.title.trim());
    final message = context.l10n.tr(notification.message.trim());

    if (title.isEmpty) return message;
    if (message.isEmpty) return title;
    return '$title\n$message';
  }

  String _relativeTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    final difference = DateTime.now().difference(createdAt.toLocal());
    if (difference.inMinutes < 1) return context.l10n.tr('now');
    if (difference.inMinutes < 60) {
      return context.l10n.minutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) {
      return context.l10n.hoursAgo(difference.inHours);
    }
    if (difference.inDays < 7) {
      return context.l10n.daysAgo(difference.inDays);
    }
    return MaterialLocalizations.of(
      context,
    ).formatShortDate(createdAt.toLocal());
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.title,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtitle),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.tr('Retry')),
            ),
          ],
        ),
      ),
    );
  }
}
