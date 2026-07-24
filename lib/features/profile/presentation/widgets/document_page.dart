import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.title,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _DocumentHeader(
              title: title,
              icon: icon,
              accentColor: accentColor,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverToBoxAdapter(
              child: DocumentContent(
                content: content,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: accentColor.withValues(alpha: .09),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Books on Wheels',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentContent extends StatelessWidget {
  const DocumentContent({
    super.key,
    required this.content,
    required this.accentColor,
  });

  final String content;
  final Color accentColor;

  static final RegExp _sectionPattern = RegExp(r'^\d+(?:\.\d+)?\.?\s+');
  static final RegExp _detailPattern = RegExp(r'^[^:]{1,32}\s?:\s?.+');

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          if (index > 0) SizedBox(height: _spacingBefore(blocks[index])),
          _buildBlock(blocks[index], isFirst: index == 0),
        ],
      ],
    );
  }

  List<_DocumentBlock> _parseBlocks(String source) {
    final blocks = <_DocumentBlock>[];
    final paragraphLines = <String>[];

    void flushParagraph() {
      if (paragraphLines.isEmpty) return;
      blocks.add(
        _DocumentBlock(_DocumentBlockType.paragraph, paragraphLines.join(' ')),
      );
      paragraphLines.clear();
    }

    for (final rawLine in source.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flushParagraph();
        continue;
      }

      if (line.startsWith('•')) {
        flushParagraph();
        blocks.add(
          _DocumentBlock(_DocumentBlockType.bullet, line.substring(1).trim()),
        );
        continue;
      }

      if (_sectionPattern.hasMatch(line)) {
        flushParagraph();
        blocks.add(_DocumentBlock(_DocumentBlockType.section, line));
        continue;
      }

      if (_isMajorHeading(line)) {
        flushParagraph();
        blocks.add(_DocumentBlock(_DocumentBlockType.majorHeading, line));
        continue;
      }

      if (_detailPattern.hasMatch(line)) {
        flushParagraph();
        blocks.add(_DocumentBlock(_DocumentBlockType.detail, line));
        continue;
      }

      paragraphLines.add(line);
    }

    flushParagraph();
    return blocks;
  }

  bool _isMajorHeading(String line) {
    final letters = line.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ]'), '');
    return letters.isNotEmpty && line == line.toUpperCase();
  }

  double _spacingBefore(_DocumentBlock block) {
    return switch (block.type) {
      _DocumentBlockType.majorHeading => 30,
      _DocumentBlockType.section => 24,
      _DocumentBlockType.paragraph => 14,
      _DocumentBlockType.bullet => 9,
      _DocumentBlockType.detail => 8,
    };
  }

  Widget _buildBlock(_DocumentBlock block, {required bool isFirst}) {
    return switch (block.type) {
      _DocumentBlockType.majorHeading => _MajorHeading(
        text: block.text,
        accentColor: accentColor,
        isFirst: isFirst,
      ),
      _DocumentBlockType.section => _SectionHeading(
        text: block.text,
        accentColor: accentColor,
      ),
      _DocumentBlockType.bullet => _BulletLine(
        text: block.text,
        accentColor: accentColor,
      ),
      _DocumentBlockType.detail => _DetailLine(
        text: block.text,
        accentColor: accentColor,
      ),
      _DocumentBlockType.paragraph => SelectableText(
        block.text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 15,
          height: 1.65,
          color: Color(0xFF3F4754),
        ),
      ),
    };
  }
}

class _MajorHeading extends StatelessWidget {
  const _MajorHeading({
    required this.text,
    required this.accentColor,
    required this.isFirst,
  });

  final String text;
  final Color accentColor;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 52, height: 4, color: accentColor),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: .09),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          height: 1.35,
          fontWeight: FontWeight.w800,
          color: accentColor,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: accentColor,
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: Color(0xFF3F4754),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final details = _splitDetails(text);
    final action = _resolveAction(details.$1, details.$2);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _performAction(context, action),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withValues(alpha: .22)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _leadingIcon(details.$1),
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.$1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      details.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F4754),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _performAction(context, action),
                tooltip: _actionTooltip(context, action.type),
                visualDensity: VisualDensity.compact,
                icon: Icon(action.icon, color: accentColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String) _splitDetails(String source) {
    final separatorIndex = source.indexOf(':');
    if (separatorIndex < 0) return ('Info', source.trim());

    final label = source.substring(0, separatorIndex).trim();
    final value = source.substring(separatorIndex + 1).trim();
    return (label, value);
  }

  _DocumentAction _resolveAction(String label, String value) {
    final email = RegExp(
      r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}',
    ).firstMatch(value)?.group(0);
    if (email != null) {
      return _DocumentAction(
        type: _DocumentActionType.email,
        value: email,
        icon: Icons.email_outlined,
      );
    }

    final normalizedLabel = label.toLowerCase();
    if (normalizedLabel.contains('address') ||
        normalizedLabel.contains('adresse')) {
      return _DocumentAction(
        type: _DocumentActionType.map,
        value: value,
        icon: Icons.map_outlined,
      );
    }

    return _DocumentAction(
      type: _DocumentActionType.copy,
      value: value,
      icon: Icons.copy_outlined,
    );
  }

  IconData _leadingIcon(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('publisher') || normalized.contains('éditeur')) {
      return Icons.business_outlined;
    }
    if (normalized.contains('legal status') ||
        normalized.contains('statut juridique')) {
      return Icons.account_balance_outlined;
    }
    if (normalized.contains('manager') || normalized.contains('responsable')) {
      return Icons.person_outline;
    }
    if (normalized.contains('address') || normalized.contains('adresse')) {
      return Icons.location_on_outlined;
    }
    if (normalized.contains('mail')) return Icons.alternate_email;
    if (normalized.contains('siret')) return Icons.badge_outlined;
    if (normalized.contains('contact')) return Icons.support_agent_outlined;
    return Icons.info_outline;
  }

  String _actionTooltip(BuildContext context, _DocumentActionType type) {
    return switch (type) {
      _DocumentActionType.email => context.l10n.tr('Send email'),
      _DocumentActionType.map => context.l10n.tr('Open in Maps'),
      _DocumentActionType.copy => context.l10n.tr('Copy'),
    };
  }

  Future<void> _performAction(
    BuildContext context,
    _DocumentAction action,
  ) async {
    switch (action.type) {
      case _DocumentActionType.email:
        final opened = await launchUrl(
          Uri(scheme: 'mailto', path: action.value),
          mode: LaunchMode.externalApplication,
        );
        if (!opened && context.mounted) {
          _showMessage(context, context.l10n.tr('Could not open this action.'));
        }
      case _DocumentActionType.map:
        final opened = await launchUrl(
          Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': action.value,
          }),
          mode: LaunchMode.externalApplication,
        );
        if (!opened && context.mounted) {
          _showMessage(context, context.l10n.tr('Could not open this action.'));
        }
      case _DocumentActionType.copy:
        await Clipboard.setData(ClipboardData(text: action.value));
        if (context.mounted) {
          _showMessage(context, context.l10n.tr('Copied to clipboard'));
        }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _DocumentActionType { email, map, copy }

class _DocumentAction {
  const _DocumentAction({
    required this.type,
    required this.value,
    required this.icon,
  });

  final _DocumentActionType type;
  final String value;
  final IconData icon;
}

enum _DocumentBlockType { majorHeading, section, paragraph, bullet, detail }

class _DocumentBlock {
  const _DocumentBlock(this.type, this.text);

  final _DocumentBlockType type;
  final String text;
}
