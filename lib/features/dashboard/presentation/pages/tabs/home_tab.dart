import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/core/utils/currency_formatter.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/custom_toggle_switch.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/request_card.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/application/driver_request_event.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/notifications/data/notification_api.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  bool _isOnline = false;
  bool _isTogglingOnline = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  int _availabilityRevision = 0;
  AppFailure? _error;
  UserProfile? _profile;
  int _unreadCount = 0;
  List<DriverRequest> _allDriverRequests = const [];
  List<DriverRequest> _driverRequests = const [];
  final Set<String> _acceptingRequestIds = <String>{};
  final Set<String> _rejectingRequestIds = <String>{};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    ref.listenManual(driverRequestEventProvider, (previous, next) {
      if (next != null && _isOnline) {
        _loadHomeData(showLoading: false);
      }
    });
    ref.listenManual(appLifecycleProvider, (previous, next) {
      if (next == AppLifecycleState.resumed) {
        _loadHomeData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHomeData({bool showLoading = true}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    final availabilityRevision = _availabilityRevision;
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final userResult = await ref.read(userApiProvider).getCurrentUser();
    final notificationResult = await ref
        .read(notificationApiProvider)
        .getUnreadNotificationCount();

    if (!mounted) return;

    final userFailure = userResult.failureOrNull;
    if (userFailure != null) {
      setState(() {
        _error = userFailure;
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    final api = ref.read(driverApiProvider);
    final requestsResult = await api.getDriverRequests(page: 1, limit: 10);
    final driverId = userResult.dataOrNull?.id ?? '';
    final assignedRequestsResult = driverId.isEmpty
        ? null
        : await api.getDriverRequestsByDriver(driverId);

    if (!mounted) return;

    final requestsFailure = requestsResult.failureOrNull;
    final assignedRequestsFailure = assignedRequestsResult?.failureOrNull;
    if (requestsFailure != null || assignedRequestsFailure != null) {
      setState(() {
        _error = requestsFailure ?? assignedRequestsFailure;
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    final requests = _deduplicateRequests(
      requestsResult.dataOrNull?.requests ?? const [],
    );
    final assignedRequests =
        assignedRequestsResult?.dataOrNull?.requests ?? const [];
    final hasActiveRequest = assignedRequests.any(
      (request) => request.status.toLowerCase() == 'accepted',
    );
    final profile = userResult.dataOrNull;

    setState(() {
      _profile = profile;
      if (availabilityRevision == _availabilityRevision) {
        _isOnline = profile?.isOnline ?? false;
      }
      _unreadCount = notificationResult.dataOrNull ?? 0;
      _allDriverRequests = assignedRequests;
      _driverRequests = hasActiveRequest
          ? const []
          : requests
                .where((request) => request.status.toLowerCase() == 'pending')
                .toList(growable: false);
      _isLoading = false;
      _isRefreshing = false;
    });
    _syncRefreshTimer();
  }

  Future<void> _refresh() => _loadHomeData();

  Future<void> _setOnline(bool value) async {
    if (_isTogglingOnline || value == _isOnline) return;
    _availabilityRevision += 1;
    setState(() => _isTogglingOnline = true);

    final result = await ref.read(userApiProvider).updateAvailability(value);
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _isTogglingOnline = false);
      _showLifecycleMessage(failure.message);
      return;
    }

    setState(() {
      _isOnline = result.dataOrNull?.isOnline ?? value;
      _profile = result.dataOrNull ?? _profile;
      _isTogglingOnline = false;
    });
    _syncRefreshTimer();
    if (_isOnline) await _loadHomeData(showLoading: false);
  }

  void _syncRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (!_isOnline) return;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadHomeData(showLoading: false),
    );
  }

  List<DriverRequest> _deduplicateRequests(List<DriverRequest> requests) {
    final byId = <String, DriverRequest>{};
    for (final request in requests) {
      byId[request.id] = request;
    }
    final result = byId.values.toList();
    result.sort(
      (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
    return result;
  }

  void _openRequestDetails(String driverRequestId) {
    Navigator.of(context).pushNamed(
      AppRoutes.driverRequestDetails,
      arguments: DriverRequestDetailsRouteArgs(
        driverRequestId: driverRequestId,
      ),
    );
  }

  Future<void> _acceptRequest(String driverRequestId) async {
    if (_acceptingRequestIds.contains(driverRequestId)) return;

    setState(() => _acceptingRequestIds.add(driverRequestId));

    final statusResult = await ref
        .read(driverApiProvider)
        .acceptDriverRequest(driverRequestId);

    if (!mounted) return;

    setState(() => _acceptingRequestIds.remove(driverRequestId));

    final statusFailure = statusResult.failureOrNull;
    if (statusFailure != null) {
      if (statusFailure.statusCode == 409) {
        _removeRequestFromNewList(driverRequestId);
      }
      _showLifecycleMessage(statusFailure.message);
      await _loadHomeData(showLoading: false);
      return;
    }

    _removeRequestFromNewList(driverRequestId);
    ref
        .read(driverRequestEventProvider.notifier)
        .emit(
          type: 'driver_request_accepted',
          driverRequestId: driverRequestId,
        );
    _showLifecycleMessage(context.l10n.tr('Request accepted.'));
    await _loadHomeData(showLoading: false);
  }

  Future<void> _rejectRequest(String driverRequestId) async {
    if (_rejectingRequestIds.contains(driverRequestId)) return;

    setState(() => _rejectingRequestIds.add(driverRequestId));

    final result = await ref
        .read(driverApiProvider)
        .updateDriverRequestStatus(
          driverRequestId: driverRequestId,
          status: 'rejected',
        );

    if (!mounted) return;

    setState(() => _rejectingRequestIds.remove(driverRequestId));

    final failure = result.failureOrNull;
    if (failure != null) {
      _showLifecycleMessage(failure.message);
      return;
    }

    _removeRequestFromNewList(driverRequestId);
    _showLifecycleMessage(context.l10n.tr('Request rejected.'));
  }

  void _removeRequestFromNewList(String driverRequestId) {
    setState(() {
      _driverRequests = _driverRequests
          .where((request) => request.id != driverRequestId)
          .toList(growable: false);
    });
  }

  void _showLifecycleMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _HomeProfileAvatar(avatarUrl: _profile?.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _profile?.name.isNotEmpty == true
                            ? _profile!.name
                            : context.l10n.tr('Driver'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.title,
                        ),
                      ),
                      Text(
                        context.l10n.tr('Hi, Good Morning'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.notifications),
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 28,
                        color: AppColors.title,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Visibility(
                          visible: _unreadCount > 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              _unreadCount > 99 ? '99+' : '$_unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomToggleSwitch(
              isOnline: _isOnline,
              isLoading: _isTogglingOnline,
              onChanged: _setOnline,
            ),
            const SizedBox(height: 30),
            if (!_isOnline) _buildOfflineView() else _buildOnlineView(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sky,
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          context.l10n.tr('Go online to start'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.l10n.tr(
              'You need to be online to receive new delivery requests.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.title,
            ),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 200,
          child: FilledButton(
            onPressed: _isTogglingOnline ? null : () => _setOnline(true),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.l10n.tr('Go Online'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineView() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildErrorView(_error!);
    }

    final now = DateTime.now();
    final deliveredRequests = _allDriverRequests
        .where(
          (request) =>
              request.status.toLowerCase() == 'delivered' &&
              _isSameDay(request.updatedAt ?? request.orderDate, now),
        )
        .toList(growable: false);
    final todayEarnings = deliveredRequests.fold<double>(
      0,
      (total, request) => total + (request.price ?? 0),
    );
    final deliveries = deliveredRequests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                formatWholeCurrency(todayEarnings),
                context.l10n.tr("Today's Earnings"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '$deliveries',
                context.l10n.tr('Deliveries'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.tr('New Requests'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
            Text(
              context.l10n.pendingRequests(_driverRequests.length),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_driverRequests.isEmpty)
          _buildEmptyRequestsView()
        else
          ..._driverRequests.map(_buildRequestCard),
      ],
    );
  }

  Widget _buildRequestCard(DriverRequest request) {
    final orderId = request.orderId.isNotEmpty
        ? request.orderId
        : context.l10n.tr('Unavailable');
    final pickup = request.shopName.isNotEmpty
        ? request.shopName
        : request.location;

    return RequestCard(
      orderId: orderId,
      storeName: request.shopName.isNotEmpty
          ? request.shopName
          : context.l10n.tr('Unknown Shop'),
      itemName: request.item.isNotEmpty
          ? request.item
          : context.l10n.tr('Delivery request'),
      price: request.price ?? 0,
      address: pickup.isNotEmpty ? pickup : request.location,
      phone: request.phone,
      customerName: request.customerName,
      location: request.location,
      totalAmount: request.totalAmount,
      message: request.message,
      isAcceptLoading: _acceptingRequestIds.contains(request.id),
      isRejectLoading: _rejectingRequestIds.contains(request.id),
      onViewDetails: () => _openRequestDetails(request.id),
      onAccept: () => _acceptRequest(request.id),
      onReject: () => _rejectRequest(request.id),
    );
  }

  bool _isSameDay(DateTime? date, DateTime day) {
    if (date == null) return false;
    final localDate = date.toLocal();
    return localDate.year == day.year &&
        localDate.month == day.month &&
        localDate.day == day.day;
  }

  Widget _buildErrorView(AppFailure failure) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.subtitle,
            ),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.title),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loadHomeData,
              child: Text(context.l10n.tr('Retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRequestsView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 42, color: AppColors.subtitle),
          const SizedBox(height: 12),
          Text(
            context.l10n.tr('No new delivery requests'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.tr('Pull down to refresh when you are online.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: .5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.title),
          ),
        ],
      ),
    );
  }
}

class _HomeProfileAvatar extends StatelessWidget {
  const _HomeProfileAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = avatarUrl?.trim();
    final hasAvatar = normalizedUrl != null && normalizedUrl.isNotEmpty;

    return ClipOval(
      child: SizedBox.square(
        dimension: 48,
        child: hasAvatar
            ? Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _HomeAvatarFallback(),
              )
            : const _HomeAvatarFallback(),
      ),
    );
  }
}

class _HomeAvatarFallback extends StatelessWidget {
  const _HomeAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.border,
      child: Icon(Icons.person, color: Colors.white),
    );
  }
}
