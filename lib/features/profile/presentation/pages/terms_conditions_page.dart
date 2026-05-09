import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';

// TODO: Replace static content with GET /api/v1/settings/terms when backend
// settings content is available.
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String content =
        'Drivers are responsible for using accurate account information, keeping login credentials secure, and handling delivery request information with care.\n\n'
        'Delivery actions in the app should reflect real-world progress. Some lifecycle actions are currently disabled until backend APIs are available, so the app does not show fake success states for accept, reject, pickup, on-way, or delivered updates.\n\n'
        'Route and location information is provided to support delivery work and may depend on the information returned by the backend.\n\n'
        'These terms are static until backend-managed terms content is available.';

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
          'Terms & Conditions',
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
