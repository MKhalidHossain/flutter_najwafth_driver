import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/core/utils/currency_formatter.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.itemName,
    required this.price,
    required this.address,
    required this.onAccept,
    required this.onReject,
    this.onViewDetails,
    this.isAcceptLoading = false,
    this.isRejectLoading = false,
    this.phone,
    this.customerName,
    this.location,
    this.totalAmount,
    this.message,
  });

  final String orderId;
  final String storeName;
  final String itemName;
  final double price;
  final String address;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onViewDetails;
  final bool isAcceptLoading;
  final bool isRejectLoading;
  final String? phone;
  final String? customerName;
  final String? location;
  final double? totalAmount;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final isBusy = isAcceptLoading || isRejectLoading;

    return InkWell(
      onTap: isBusy ? null : onViewDetails,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    storeName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatCurrency(price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Order #$orderId',
              style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
            ),
            const SizedBox(height: 4),
            Text(
              itemName,
              style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.subtitle,
                    ),
                  ),
                ),
              ],
            ),
            if (_hasExtraDetails) ...[
              const SizedBox(height: 12),
              if (customerName != null && customerName!.isNotEmpty)
                _RequestDetailLine(label: 'Customer', value: customerName!),
              if (phone != null && phone!.isNotEmpty)
                _RequestDetailLine(label: 'Phone', value: phone!),
              if (location != null && location!.isNotEmpty)
                _RequestDetailLine(label: 'Location', value: location!),
              if (totalAmount != null)
                _RequestDetailLine(
                  label: 'Total',
                  value: formatCurrency(totalAmount!),
                ),
              if (message != null && message!.isNotEmpty)
                _RequestDetailLine(label: 'Message', value: message!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: isRejectLoading
                        ? const _ButtonSpinner(color: AppColors.primary)
                        : const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.title,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isBusy ? null : onAccept,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                    child: isAcceptLoading
                        ? const _ButtonSpinner(color: Colors.white)
                        : const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasExtraDetails {
    return (phone != null && phone!.isNotEmpty) ||
        (customerName != null && customerName!.isNotEmpty) ||
        (location != null && location!.isNotEmpty) ||
        totalAmount != null ||
        (message != null && message!.isNotEmpty);
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _RequestDetailLine extends StatelessWidget {
  const _RequestDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
      ),
    );
  }
}
