import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';

class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key, this.itemName = 'Delivery'});

  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.tr('Order Items'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              itemName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                _buildItemImage('assets/images/book1.png'),
                const SizedBox(width: 8),
                _buildItemImage('assets/images/book2.png'),
                const SizedBox(width: 8),
                _buildItemImage('assets/images/book3.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String assetPath) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
      ),
      // Use Icon as placeholder since we don't have the actual assets yet
      child: const Center(
        child: Icon(Icons.menu_book, size: 20, color: AppColors.primary),
      ),
    );
  }
}
