import 'package:flutter_najwafth_driver/core/localization/app_language.dart';
import 'package:flutter_najwafth_driver/core/storage/key_value_storage.dart';
import 'package:flutter_najwafth_driver/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeControllerProvider =
    NotifierProvider<LocaleController, AppLanguage>(LocaleController.new);

final class LocaleController extends Notifier<AppLanguage> {
  static const _languageKey = 'driver.selected_language';
  static const _legacyLanguageKey = 'driver.settings.language';

  KeyValueStorage? _storage;

  @override
  AppLanguage build() {
    _storage ??= ref.watch(keyValueStorageProvider);
    final savedLanguage =
        _storage!.readString(_languageKey) ??
        _storage!.readString(_legacyLanguageKey);

    if (savedLanguage == 'English') return AppLanguage.english;
    if (savedLanguage == 'France' || savedLanguage == 'French') {
      return AppLanguage.french;
    }

    return AppLanguage.values.firstWhere(
      (language) => language.name == savedLanguage,
      orElse: () => AppLanguage.french,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _storage!.writeString(_languageKey, language.name);
  }
}
