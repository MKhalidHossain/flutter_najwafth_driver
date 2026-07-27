import 'package:flutter_najwafth_driver/core/localization/app_localizations.dart';

final class Validators {
  const Validators._();

  static String? required(
    String? value, {
    String label = 'This field',
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.requiredMessage(label) ?? '$label is required.';
    }
    return null;
  }

  static String? email(String? value, {AppLocalizations? l10n}) {
    final requiredMessage = required(value, label: 'Email', l10n: l10n);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return l10n?.tr('Enter a valid email address.') ??
          'Enter a valid email address.';
    }

    return null;
  }

  static String? minLength(
    String? value,
    int length, {
    String label = 'Value',
    AppLocalizations? l10n,
  }) {
    final requiredMessage = required(value, label: label, l10n: l10n);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (value!.trim().length < length) {
      return l10n?.minLengthMessage(label, length) ??
          '$label must be at least $length characters.';
    }

    return null;
  }
}
