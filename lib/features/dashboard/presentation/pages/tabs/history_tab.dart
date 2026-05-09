import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/errors/app_failure.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/history_order_card.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: GET /api/v1/driver/orders/history?page=1&limit=10 is needed from
// backend for a server-side filtered, driver-scoped delivery history endpoint.
// Current backend only has GET /api/v1/driver-request/driver-requests/driver/:driverId,
// without pagination or delivered lifecycle statuses.

class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppFailure? _error;
  List<DriverRequest> _orders = const [];
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadHistory(reset: true);
  }

  Future<void> _loadHistory({bool reset = false}) async {
    if (_isLoading || _isLoadingMore) return;

    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _orders = const [];
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final nextPage = reset ? 1 : _page + 1;

    final profileResult = await ref.read(userApiProvider).getCurrentUser();

    if (!mounted) return;

    final profileFailure = profileResult.failureOrNull;
    if (profileFailure != null) {
      setState(() {
        _error = profileFailure;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final driverId = profileResult.dataOrNull?.id ?? '';
    if (driverId.isEmpty) {
      setState(() {
        _orders = const [];
        _hasMore = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final result = await ref
        .read(driverApiProvider)
        .getDriverRequestsByDriver(driverId);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _error = failure;
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    final page = result.dataOrNull;
    final incoming = (page?.requests ?? const [])
        .where((r) => r.status.toLowerCase() == 'delivered')
        .toList(growable: false);

    setState(() {
      _orders = incoming;
      _page = nextPage;
      _hasMore = false;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _refresh() => _loadHistory(reset: true);

  void _openDetails(String driverRequestId) {
    Navigator.of(context).pushNamed(
      AppRoutes.orderDetails,
      arguments: OrderDetailsRouteArgs(driverRequestId: driverRequestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _orders.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                  color: AppColors.subtitle,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.title),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _loadHistory(reset: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No delivery history',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completed deliveries will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _orders.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _orders.length) {
          return _buildLoadMoreButton();
        }

        final request = _orders[index];
        final orderId = request.orderId.isNotEmpty
            ? request.orderId
            : request.id;
        final fromAddress = request.shopName.isNotEmpty
            ? request.shopName
            : 'Unknown Shop';
        final toAddress = request.location.isNotEmpty
            ? request.location
            : 'Unknown Location';
        final total = request.price ?? request.totalAmount ?? 0.0;

        return HistoryOrderCard(
          orderId: orderId,
          fromAddress: fromAddress,
          toAddress: toAddress,
          total: total,
          onTap: () => _openDetails(request.id),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton(
          onPressed: () => _loadHistory(),
          child: const Text('Load More'),
        ),
      ),
    );
  }
}
