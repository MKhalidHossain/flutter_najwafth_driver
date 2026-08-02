import 'package:dio/dio.dart';
import 'package:flutter_najwafth_driver/core/errors/result.dart';
import 'package:flutter_najwafth_driver/core/network/api_client.dart';
import 'package:flutter_najwafth_driver/core/network/network_providers.dart';
import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.watch(apiClientProvider));
});

final class UserApi {
  const UserApi(this._apiClient);

  static const _basePath = '/api/v1/user';

  final ApiClient _apiClient;

  Future<Result<UserProfile>> getCurrentUser() {
    return _apiClient.get(
      '$_basePath/me',
      parser: (data) => UserProfile.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<UserProfile>> updateCurrentUser(FormData formData) {
    return _apiClient.patch(
      '$_basePath/me',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      parser: (data) => UserProfile.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<UserProfile>> updateAvailability(bool isOnline) {
    return _apiClient.patch(
      '$_basePath/me/availability',
      data: {'isOnline': isOnline},
      parser: (data) => UserProfile.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<UserProfile>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _apiClient.patch(
      '$_basePath/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      parser: (data) => UserProfile.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<void>> deleteCurrentUser() {
    return _apiClient.delete('$_basePath/me', parser: (_) {});
  }
}
