import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/core/utils/currency_formatter.dart';
import 'package:flutter_najwafth_driver/core/utils/map_launcher.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/location_info_card.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/order_items_card.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/order_status_timeline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  const OrderDetailsPage({super.key, required this.driverRequestId});

  final String driverRequestId;

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  bool _isLoading = true;
  AppFailure? _failure;
  DriverRequest? _request;
  OrderStatus _currentStatus = OrderStatus.accepted;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _failure = null;
    });

    final result = await ref
        .read(driverApiProvider)
        .getDriverRequestById(widget.driverRequestId);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _failure = failure;
        _isLoading = false;
      });
      return;
    }

    final request = result.dataOrNull;
    setState(() {
      _request = request;
      _currentStatus = _parseStatus(request?.status ?? '');
      _isLoading = false;
    });
  }

  OrderStatus _parseStatus(String raw) {
    return switch (raw.toLowerCase()) {
      'processing' || 'picked_up' || 'in_progress' => OrderStatus.pickedUp,
      'picked' || 'on_way' || 'shipped' => OrderStatus.onWay,
      'delivered' => OrderStatus.delivered,
      _ => OrderStatus.accepted,
    };
  }

  Future<void> _nextStatus() async {
    if (_currentStatus == OrderStatus.delivered) {
      Navigator.pop(context);
      return;
    }

    final request = _request;
    if (request == null) return;

    final orderId = request.orderId.isNotEmpty ? request.orderId : request.id;

    final String nextStatusRaw = switch (_currentStatus) {
      OrderStatus.accepted => 'processing',
      OrderStatus.pickedUp => 'picked',
      OrderStatus.onWay => 'delivered',
      OrderStatus.delivered => 'delivered',
    };

    setState(() {
      _isLoading = true;
    });

    final result = await ref
        .read(driverApiProvider)
        .updateOrderStatus(orderId: orderId, status: nextStatusRaw);

    if (!mounted) return;

    if (result.failureOrNull == null) {
      setState(() {
        _currentStatus = _parseStatus(nextStatusRaw);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tr('Status updated successfully'))),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failureOrNull?.message ??
                context.l10n.tr('Failed to update status'),
          ),
        ),
      );
    }
  }

  Future<void> _openRoute(DriverRequest request) async {
    final opened = await openMapRoute(
      pickupPoint: _mapPoint(request.pickupLat, request.pickupLng),
      deliveryPoint: _mapPoint(request.deliveryLat, request.deliveryLng),
      pickupAddress: request.pickupAddress ?? request.shopName,
      deliveryAddress: request.deliveryAddress,
      fallbackLocation: request.location,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tr('Location not available'))),
      );
    }
  }

  MapPoint? _mapPoint(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return null;
    return MapPoint(latitude: latitude, longitude: longitude);
  }

  Color _getButtonColor() {
    return switch (_currentStatus) {
      OrderStatus.accepted => const Color(0xFFE5B400),
      OrderStatus.pickedUp => const Color(0xFF008A2E),
      OrderStatus.onWay || OrderStatus.delivered => AppColors.primary,
    };
  }

  String _getButtonText() {
    return switch (_currentStatus) {
      OrderStatus.accepted => context.l10n.tr('Mark as Picked'),
      OrderStatus.pickedUp => context.l10n.tr('Go to On Way'),
      OrderStatus.onWay => context.l10n.tr('Confirm Delivery'),
      OrderStatus.delivered => context.l10n.tr('Done'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    final orderId = request == null
        ? '...'
        : (request.orderId.isNotEmpty ? request.orderId : request.id);
    final earnings = request?.price == null
        ? '—'
        : formatCurrency(request!.price!);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.l10n.tr('Order')}  $orderId',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
            Text(
              '${context.l10n.tr('Estimated Earnings:')} $earnings',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.title,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(request, orderId),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: _isLoading || request == null ? null : _nextStatus,
            style: FilledButton.styleFrom(
              backgroundColor: _isLoading || request == null
                  ? null
                  : _getButtonColor(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isLoading || request == null ? '...' : _getButtonText(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DriverRequest? request, String orderId) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: AppColors.subtitle,
              ),
              const SizedBox(height: 16),
              Text(
                _failure!.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.title),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadRequest,
                child: Text(context.l10n.tr('Retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (request == null) {
      return Center(
        child: Text(
          context.l10n.tr('Order not found.'),
          style: const TextStyle(fontSize: 15, color: AppColors.title),
        ),
      );
    }

    final dateStr = request.orderDate?.dayMonthYear ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          OrderStatusTimeline(currentStatus: _currentStatus),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openRoute(request),
              icon: const Icon(Icons.location_on, size: 20),
              label: Text(context.l10n.tr('View Route on Map')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LocationInfoCard(
            title: context.l10n.tr('Pickup From'),
            titleIcon: Icons.storefront_outlined,
            locationName: request.shopName.isNotEmpty
                ? request.shopName
                : context.l10n.tr('Shop'),
            address:
                request.pickupAddress ??
                (request.location.isNotEmpty ? request.location : '—'),
            orderDate: dateStr,
            phone: request.phone.isNotEmpty ? request.phone : '—',
            orderId: orderId,
          ),
          LocationInfoCard(
            title: context.l10n.tr('Deliver To'),
            titleIcon: Icons.person_outline,
            locationName: request.customerName.isNotEmpty
                ? request.customerName
                : context.l10n.tr('Customer'),
            address:
                request.deliveryAddress ??
                (request.location.isNotEmpty ? request.location : '—'),
            orderDate: dateStr,
            phone: request.phone.isNotEmpty ? request.phone : '—',
            orderId: orderId,
          ),
          OrderItemsCard(
            itemName: request.item.isNotEmpty
                ? request.item
                : context.l10n.tr('Delivery'),
          ),
        ],
      ),
    );
  }
}
