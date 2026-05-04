import 'package:flutter/material.dart';

import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/features/dashboard/presentation/widgets/history_order_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          HistoryOrderCard(
            orderId: 'ORD-1001',
            fromAddress: 'City Lights Booksellers',
            toAddress: '123 Library St, Book City',
            total: 12.99,
          ),
          HistoryOrderCard(
            orderId: 'ORD-1001',
            fromAddress: 'City Lights Booksellers',
            toAddress: '123 Library St, Book City',
            total: 12.99,
          ),
        ],
      ),
    );
  }
}
