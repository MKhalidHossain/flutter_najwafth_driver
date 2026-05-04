import 'package:flutter/material.dart';

import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/active_order_card.dart';

class ActiveTab extends StatefulWidget {
  const ActiveTab({super.key});

  @override
  State<ActiveTab> createState() => _ActiveTabState();
}

class _ActiveTabState extends State<ActiveTab> {
  // Toggle this flag to test empty vs populated state
  final bool _hasActiveOrders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Active Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: _hasActiveOrders ? _buildPopulatedState() : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8), // Light blue circle background
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No active orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accept a delivery request to see\nit here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ActiveOrderCard(
          orderId: 'ORD-1001',
          fromAddress: 'City Lights Booksellers',
          toAddress: '123 Library St, Book City',
          itemCount: 4,
          onViewDetails: () => Navigator.pushNamed(context, '/order-details'),
        ),
        ActiveOrderCard(
          orderId: 'ORD-1001',
          fromAddress: 'City Lights Booksellers',
          toAddress: '123 Library St, Book City',
          itemCount: 4,
          onViewDetails: () => Navigator.pushNamed(context, '/order-details'),
        ),
      ],
    );
  }
}
