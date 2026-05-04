import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'New',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title,
                ),
              ),
            ),
            _buildNotificationItem(
              icon: Icons.block,
              iconColor: Colors.red,
              text: 'Lorem ipsum is a dummy or',
              time: '01 min',
            ),
            _buildNotificationItem(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              text: 'Lorem ipsum is a dummy',
              time: '01 min',
            ),
            _buildNotificationItem(
              icon: Icons.chat,
              iconColor: Colors.green,
              text: 'Lorem ipsum is a dummy or',
              time: '01 min',
            ),
            _buildNotificationItem(
              icon: Icons.send,
              iconColor: Colors.blue,
              text: 'Lorem ipsum is a dummy or',
              time: '01 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '15 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '15 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '15 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '20 min',
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                'Earlier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.title,
                ),
              ),
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '31 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '31 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '31 min',
            ),
            _buildNotificationItem(
              text: 'Lorem ipsum is a dummy or placeholder text commonly used in graphic',
              time: '58 min',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    IconData? icon,
    Color? iconColor,
    required String text,
    required String time,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Color(0xFFEFEFEF), height: 1),
        ),
      ],
    );
  }
}
