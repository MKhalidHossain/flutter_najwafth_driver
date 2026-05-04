import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';

enum OrderStatus {
  accepted,
  pickedUp,
  onWay,
  delivered,
}

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  final OrderStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTimelineStep(
          title: 'Accepted',
          subtitle: 'Order received by Driver',
          isCompleted: currentStatus.index >= OrderStatus.accepted.index,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Picked Up',
          subtitle: 'Driver partner picked up order',
          isCompleted: currentStatus.index >= OrderStatus.pickedUp.index,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'On Way',
          subtitle: 'Order On Way',
          isCompleted: currentStatus.index >= OrderStatus.onWay.index,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Delivered',
          subtitle: 'Order delivered successfully',
          isCompleted: currentStatus.index >= OrderStatus.delivered.index,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.subtitle,
                      width: 1.5,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primary : AppColors.subtitle.withValues(alpha: .3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.primary : AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted ? AppColors.primary.withValues(alpha: .7) : AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
