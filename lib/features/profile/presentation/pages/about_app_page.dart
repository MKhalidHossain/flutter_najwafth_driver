import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/profile/presentation/widgets/document_page.dart';

// TODO: Replace static content with GET /api/v1/settings/about when backend
// settings content is available.
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentPage(
      title: context.l10n.tr('About App'),
      content: context.l10n.aboutContent,
      icon: Icons.auto_stories_outlined,
      accentColor: const Color(0xFF237A73),
    );
  }
}
