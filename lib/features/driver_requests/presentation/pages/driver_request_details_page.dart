import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/errors/app_failure.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/core/utils/currency_formatter.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/data/driver_api.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DriverRequestDetailsPage extends ConsumerStatefulWidget {
  const DriverRequestDetailsPage({super.key, required this.driverRequestId});

  final String driverRequestId;

  @override
  ConsumerState<DriverRequestDetailsPage> createState() =>
      _DriverRequestDetailsPageState();
}

final class _DriverRequestDetailsPageState
    extends ConsumerState<DriverRequestDetailsPage> {
  bool _isLoading = true;
  AppFailure? _failure;
  DriverRequest? _request;

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
    setState(() {
      _failure = failure;
      _request = result.dataOrNull;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.title,
        title: const Text('Request Details'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequest,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_failure != null)
              _DetailsErrorView(failure: _failure!, onRetry: _loadRequest)
            else if (_request == null)
              const _DetailsEmptyView()
            else
              _DriverRequestDetailsContent(request: _request!),
          ],
        ),
      ),
    );
  }
}

final class _DriverRequestDetailsContent extends StatelessWidget {
  const _DriverRequestDetailsContent({required this.request});

  final DriverRequest request;

  @override
  Widget build(BuildContext context) {
    final orderId = request.orderId.isNotEmpty ? request.orderId : request.id;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.shopName.isNotEmpty
                      ? request.shopName
                      : 'Unknown Shop',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
              ),
              Text(
                formatCurrency(request.price ?? 0),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Order ID', value: orderId),
          _DetailRow(label: 'Status', value: request.status),
          _DetailRow(label: 'Customer', value: request.customerName),
          _DetailRow(label: 'Phone', value: request.phone),
          _DetailRow(label: 'Item', value: request.item),
          _DetailRow(label: 'Location', value: request.location),
          _DetailRow(
            label: 'Total Amount',
            value: request.totalAmount == null
                ? ''
                : formatCurrency(request.totalAmount!),
          ),
          _DetailRow(label: 'Message', value: request.message),
        ],
      ),
    );
  }
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: AppColors.title),
          ),
        ],
      ),
    );
  }
}

final class _DetailsErrorView extends StatelessWidget {
  const _DetailsErrorView({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 52, color: AppColors.subtitle),
          const SizedBox(height: 16),
          Text(
            failure.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.title),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

final class _DetailsEmptyView extends StatelessWidget {
  const _DetailsEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: Text(
          'Driver request not found',
          style: TextStyle(fontSize: 15, color: AppColors.title),
        ),
      ),
    );
  }
}
