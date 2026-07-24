import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/widgets/document_page.dart';

// TODO: Replace static content with GET /api/v1/settings/privacy-policy when
// backend settings content is available.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentPage(
      title: context.l10n.tr('Privacy Policy'),
      content: context.l10n.privacyPolicyContent,
      icon: Icons.shield_outlined,
      accentColor: AppColors.primaryDark,
    );
  }
}
