import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/core/storage/storage_providers.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Connect to app i18n once localization delegates/locales are added.
// TODO: Sync language with PATCH /api/v1/user/language when backend support is
// available.
class ChooseLanguagePage extends ConsumerStatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  ConsumerState<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends ConsumerState<ChooseLanguagePage> {
  static const _languageKey = 'driver.settings.language';

  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        ref.read(keyValueStorageProvider).readString(_languageKey) ??
        _selectedLanguage;
  }

  Future<void> _saveLanguage() async {
    await ref
        .read(keyValueStorageProvider)
        .writeString(_languageKey, _selectedLanguage);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language saved: $_selectedLanguage')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          'Choose Language',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLanguageOption(
              flag: '🇬🇧',
              name: 'English',
              subtitle: 'United Kingdom',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              flag: '🇫🇷',
              name: 'France',
              subtitle: 'France',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveLanguage,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String name,
    required String subtitle,
  }) {
    final isSelected = _selectedLanguage == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = name;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.title : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.black : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
