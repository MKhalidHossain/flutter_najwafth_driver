import 'package:flutter_najwafth_driver/core/errors/result.dart';
import 'package:flutter_najwafth_driver/core/network/api_client.dart';
import 'package:flutter_najwafth_driver/core/network/network_providers.dart';
import 'package:flutter_najwafth_driver/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    return _apiClient.post(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      parser: (data) => AuthResponse.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  Future<Result<AuthResponse>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    return _apiClient.post(
      '/api/v1/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': 'driver',
      },
      parser: (data) => AuthResponse.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  Future<Result<String>> forgotPassword(String email) async {
    return _apiClient.post(
      '/api/v1/auth/forgot-password',
      data: {'email': email},
      parser: (data) => data['message'] as String? ?? 'OTP sent',
    );
  }

  Future<Result<String>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _apiClient.post(
      '/api/v1/auth/verify-otp',
      data: {
        'email': email,
        'otp': otp,
      },
      parser: (data) => data['data']['resetToken'] as String,
    );
  }

  Future<Result<String>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return _apiClient.post(
      '/api/v1/auth/reset-password',
      data: {
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      parser: (data) => data['message'] as String? ?? 'Password reset successfully',
    );
  }

  Future<Result<void>> logout() async {
    return _apiClient.post(
      '/api/v1/auth/logout',
      parser: (_) {},
    );
  }
}
