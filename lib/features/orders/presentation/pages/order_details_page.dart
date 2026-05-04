import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/location_info_card.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/order_items_card.dart';
import 'package:flutter_najwafth_driver/features/orders/presentation/widgets/order_status_timeline.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  OrderStatus _currentStatus = OrderStatus.accepted;

  void _nextStatus() {
    setState(() {
      if (_currentStatus == OrderStatus.accepted) {
        _currentStatus = OrderStatus.pickedUp;
      } else if (_currentStatus == OrderStatus.pickedUp) {
        _currentStatus = OrderStatus.delivered;
      } else if (_currentStatus == OrderStatus.delivered) {
        // Final action
        Navigator.pop(context);
      }
    });
  }

  Color _getButtonColor() {
    switch (_currentStatus) {
      case OrderStatus.accepted:
        return const Color(0xFFE5B400); // Yellow
      case OrderStatus.pickedUp:
        return const Color(0xFF008A2E); // Green
      case OrderStatus.delivered:
      case OrderStatus.onWay:
        return AppColors.primary; // Blue
    }
  }

  String _getButtonText() {
    switch (_currentStatus) {
      case OrderStatus.accepted:
        return 'Go to Picked';
      case OrderStatus.pickedUp:
        return 'Go to Delivered';
      case OrderStatus.delivered:
      case OrderStatus.onWay:
        return 'Confirm Delivery';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.title),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order  ORD-1001',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
            Text(
              'Estimated Earnings: \$12.00',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.title,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            OrderStatusTimeline(currentStatus: _currentStatus),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on, size: 20),
                label: const Text('View Route on Map'),
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
            const LocationInfoCard(
              title: 'Pickup From',
              titleIcon: Icons.storefront_outlined,
              locationName: 'City Lights Booksellers',
              address: '261 Columbus Ave, San\nFrancisco',
              orderDate: '4/8/2026',
              phone: '01810641003',
              orderId: 'ORD-9102',
            ),
            const LocationInfoCard(
              title: 'Deliver To',
              titleIcon: Icons.person_outline,
              locationName: 'Delivery Address',
              address: '123 Main Street, Apt 4B\nSan Francisco, CA\n94105',
              orderDate: '4/8/2026',
              phone: '01810641003',
              orderId: 'ORD-9102',
            ),
            const OrderItemsCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: _nextStatus,
            style: FilledButton.styleFrom(
              backgroundColor: _getButtonColor(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _getButtonText(),
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
}
