import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/active_order_card.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Replace with GET /api/v1/driver/orders/active once backend provides a
// dedicated active-orders endpoint.

const _activeStatuses = {'accepted', 'processing', 'picked'};

class ActiveTab extends ConsumerStatefulWidget {
  const ActiveTab({super.key});

  @override
  ConsumerState<ActiveTab> createState() => _ActiveTabState();
}

class _ActiveTabState extends ConsumerState<ActiveTab> {
  bool _isLoading = false;
  AppFailure? _error;
  List<DriverRequest> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadActiveOrders();
  }

  Future<void> _loadActiveOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final profileResult = await ref.read(userApiProvider).getCurrentUser();

    if (!mounted) return;

    final profileFailure = profileResult.failureOrNull;
    if (profileFailure != null) {
      setState(() {
        _error = profileFailure;
        _isLoading = false;
      });
      return;
    }

    final driverId = profileResult.dataOrNull?.id ?? '';
    if (driverId.isEmpty) {
      setState(() {
        _orders = const [];
        _isLoading = false;
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
      });
      return;
    }

    final all = result.dataOrNull?.requests ?? const [];
    final active = all
        .where((r) => _activeStatuses.contains(r.status.toLowerCase()))
        .toList(growable: false);

    setState(() {
      _orders = active;
      _isLoading = false;
    });
  }

  void _openRequestDetails(String driverRequestId) {
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
        title: Text(
          context.l10n.tr('Active Orders'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: RefreshIndicator(onRefresh: _loadActiveOrders, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPopulatedState();
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.tr('No active orders'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.tr('Accept a delivery request to see\nit here.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppFailure failure) {
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
                failure.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.title),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadActiveOrders,
                child: Text(context.l10n.tr('Retry')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopulatedState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final request = _orders[index];
        final orderId = request.orderId.isNotEmpty
            ? request.orderId
            : request.id;
        final fromAddress = request.shopName.isNotEmpty
            ? request.shopName
            : context.l10n.tr('Unknown Shop');
        final toAddress = request.location.isNotEmpty
            ? request.location
            : context.l10n.tr('Unknown Location');

        return ActiveOrderCard(
          orderId: orderId,
          fromAddress: fromAddress,
          toAddress: toAddress,
          itemName: request.item.isNotEmpty
              ? request.item
              : context.l10n.tr('Delivery'),
          status: request.status,
          onViewDetails: () => _openRequestDetails(request.id),
        );
      },
    );
  }
}
