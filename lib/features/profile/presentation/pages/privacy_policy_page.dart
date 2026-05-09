import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';

// TODO: Replace static content with GET /api/v1/settings/privacy-policy when
// backend settings content is available.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String content =
        'Najwafth Driver uses account and profile information to identify the signed-in driver and keep protected app features secure.\n\n'
        'The app may display delivery request details such as shop name, customer name, phone number, item information, delivery location, route hints, notifications, and order status. These details are used only to support delivery workflows inside the app.\n\n'
        'Authentication tokens are stored locally so protected API requests can be authorized. Logging out clears the stored tokens and local user session data.\n\n'
        'This privacy content is static until backend-managed policy content is available.';

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
          'Privacy Policy',
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
