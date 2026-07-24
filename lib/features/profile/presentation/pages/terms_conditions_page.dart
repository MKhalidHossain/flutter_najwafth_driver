import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/widgets/document_page.dart';

// TODO: Replace static content with GET /api/v1/settings/terms when backend
// settings content is available.
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentPage(
      title: context.l10n.tr('Terms & Conditions'),
      content: context.l10n.termsContent,
      icon: Icons.gavel_outlined,
      accentColor: const Color(0xFF93661A),
    );
  }
}
