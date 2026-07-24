import 'package:flutter/material.dart';

enum AppLanguage { french, english }

extension AppLanguageX on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.french => const Locale('fr'),
    AppLanguage.english => const Locale('en'),
  };

  String get flag => switch (this) {
    AppLanguage.french => '🇫🇷',
    AppLanguage.english => '🇬🇧',
  };
}
