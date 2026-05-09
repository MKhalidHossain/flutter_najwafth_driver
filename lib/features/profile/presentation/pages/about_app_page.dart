import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';

// TODO: Replace static content with GET /api/v1/settings/about when backend
// settings content is available.
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String content =
        'Najwafth Driver helps delivery partners view available requests, manage active deliveries, follow route information, and track completed work from one focused app.\n\n'
        'The current driver flow is connected to authentication, profile, notifications, and driver request APIs. Delivery lifecycle features such as accept, reject, live status updates, route metadata, and earnings will become fully live when the backend exposes the dedicated driver endpoints.\n\n'
        'This screen uses static app information until backend-managed settings content is available.';

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
        title: const Text(
          'About App',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          content,
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.title),
        ),
      ),
    );
  }
}
