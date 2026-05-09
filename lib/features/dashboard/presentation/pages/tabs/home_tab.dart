import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/errors/app_failure.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/core/utils/currency_formatter.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/custom_toggle_switch.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/request_card.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
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
  bool _isLoading = false;
  AppFailure? _error;
  UserProfile? _profile;
  int _unreadCount = 0;
  List<DriverRequest> _allDriverRequests = const [];
  List<DriverRequest> _driverRequests = const [];
  final Set<String> _acceptingRequestIds = <String>{};
  final Set<String> _rejectingRequestIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userResult = await ref.read(userApiProvider).getCurrentUser();
    final notificationResult = await ref
        .read(notificationApiProvider)
        .getUnreadNotificationCount();
    final requestsResult = await ref
        .read(driverApiProvider)
        .getDriverRequests(page: 1, limit: 10);

    if (!mounted) return;

    final userFailure = userResult.failureOrNull;
    final requestsFailure = requestsResult.failureOrNull;
    if (userFailure != null || requestsFailure != null) {
      setState(() {
        _error = userFailure ?? requestsFailure;
        _isLoading = false;
      });
      return;
    }

    final requests = requestsResult.dataOrNull?.requests ?? const [];

    setState(() {
      _profile = userResult.dataOrNull;
      _unreadCount = notificationResult.dataOrNull ?? 0;
      _allDriverRequests = requests;
      _driverRequests = requests
          .where((request) => request.status.toLowerCase() == 'pending')
          .toList(growable: false);
      _isLoading = false;
    });
  }

  Future<void> _refresh() => _loadHomeData();

  // TODO: Replace local online state with PATCH /api/v1/driver/availability
  // when backend support is available.
  void _setOnline(bool value) {
    setState(() => _isOnline = value);
    if (value && _driverRequests.isEmpty && !_isLoading) {
      _loadHomeData();
    }
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
    final driverId = _profile?.id;
    if (driverId == null || driverId.isEmpty) {
      _showLifecycleMessage('Driver profile is not loaded yet.');
      return;
    }
    if (_acceptingRequestIds.contains(driverRequestId)) return;

    setState(() => _acceptingRequestIds.add(driverRequestId));

    final api = ref.read(driverApiProvider);
    final assignResult = await api.assignDriverToRequest(
      driverRequestId: driverRequestId,
      driverId: driverId,
    );

    if (!mounted) return;

    final assignFailure = assignResult.failureOrNull;
    if (assignFailure != null) {
      setState(() => _acceptingRequestIds.remove(driverRequestId));
      _showLifecycleMessage(assignFailure.message);
      return;
    }

    final statusResult = await api.updateDriverRequestStatus(
      driverRequestId: driverRequestId,
      status: 'accepted',
    );

    if (!mounted) return;

    setState(() => _acceptingRequestIds.remove(driverRequestId));

    final statusFailure = statusResult.failureOrNull;
    if (statusFailure != null) {
      _showLifecycleMessage(statusFailure.message);
      await _loadHomeData();
      return;
    }

    _removeRequestFromNewList(driverRequestId);
    _showLifecycleMessage('Request accepted.');
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
    _showLifecycleMessage('Request rejected.');
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
                            : 'Driver',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.title,
                        ),
                      ),
                      Text(
                        'Hi, Good Morning',
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
            CustomToggleSwitch(isOnline: _isOnline, onChanged: _setOnline),
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
        const Text(
          'Go online to start',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'You need to be online to receive new delivery requests.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.title),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 200,
          child: FilledButton(
            onPressed: () => _setOnline(true),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Go Online',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

    // TODO: GET /api/v1/driver/earnings/today is needed from backend.
    // TODO: Replace temporary stats with GET /api/v1/driver/dashboard when
    // backend endpoints are available.
    // TODO: Replace the all-requests feed with GET /api/v1/driver/requests/new
    // when backend support is available.
    final deliveredRequests = _allDriverRequests
        .where((request) => request.status.toLowerCase() == 'delivered')
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
                "Today's Earnings",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('$deliveries', 'Deliveries')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
            Text(
              '${_driverRequests.length} pending',
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
    final orderId = request.orderId.isNotEmpty ? request.orderId : request.id;
    final pickup = request.shopName.isNotEmpty
        ? request.shopName
        : request.location;

    return RequestCard(
      orderId: orderId,
      storeName: request.shopName.isNotEmpty
          ? request.shopName
          : 'Unknown Shop',
      itemName: request.item.isNotEmpty ? request.item : 'Delivery request',
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
            FilledButton(onPressed: _loadHomeData, child: const Text('Retry')),
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
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: AppColors.subtitle),
          SizedBox(height: 12),
          Text(
            'No new delivery requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pull down to refresh when you are online.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.subtitle),
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
