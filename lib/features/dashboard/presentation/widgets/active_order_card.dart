import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';

class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({
    super.key,
    required this.orderId,
    required this.fromAddress,
    required this.toAddress,
    this.itemName = 'Delivery',
    this.status = 'accepted',
    this.onViewDetails,
  });

  final String orderId;
  final String fromAddress;
  final String toAddress;
  final String itemName;
  final String status;
  final VoidCallback? onViewDetails;

  String get _displayOrderId {
    final trimmed = orderId.trim();
    return trimmed.length > 8 ? trimmed.substring(0, 8) : trimmed;
  }

  String _statusLabel(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'picked_up':
        return context.l10n.tr('Picked Up');
      case 'picked':
      case 'on_way':
        return context.l10n.tr('On The Way');
      case 'delivered':
        return context.l10n.tr('Delivered');
      default:
        return context.l10n.tr('Accepted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Light blue-grey background
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
                  '${context.l10n.tr('Order')} ORD-$_displayOrderId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4F0), // Light blue background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(context),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow(context.l10n.tr('From:'), fromAddress),
          const SizedBox(height: 12),
          _buildLocationRow(context.l10n.tr('To:'), toAddress),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.tr('Order Items'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              _buildOverlappingImages(),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: InkWell(
              onTap: onViewDetails,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.tr('View Details'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.location_on_outlined,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlappingImages() {
    return SizedBox(
      width: 80,
      height: 30,
      child: Stack(
        children: [
          Positioned(right: 0, child: _buildItemThumbnail()),
          Positioned(right: 15, child: _buildItemThumbnail()),
          Positioned(right: 30, child: _buildItemThumbnail()),
          Positioned(right: 45, child: _buildItemThumbnail()),
        ],
      ),
    );
  }

  Widget _buildItemThumbnail() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.amber, // Placeholder color for item image
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.book, size: 14, color: Colors.brown),
    );
  }
}
