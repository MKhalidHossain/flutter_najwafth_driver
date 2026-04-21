import 'package:flutter_najwafth_driver/core/errors/app_failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueFailureX<T> on AsyncValue<T> {
  AppFailure? get failureOrNull {
    return whenOrNull(
      error: (error, stackTrace) => AppFailure.fromObject(error, stackTrace),
    );
  }
}
