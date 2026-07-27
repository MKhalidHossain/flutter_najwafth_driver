class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isEmailVerified,
    this.driverId,
    this.entrepreneurStatus,
    this.vehicleType,
    this.vehiclePlateNumber,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final bool isEmailVerified;
  final String? driverId;
  final String? entrepreneurStatus;
  final String? vehicleType;
  final String? vehiclePlateNumber;

  factory User.fromJson(Map<String, dynamic> json) {
    final verificationInfo = json['verificationInfo'];

    return User(
      id: json['_id'] as String? ?? '',
      fullName: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isEmailVerified:
          json['isEmailVerified'] as bool? ??
          (verificationInfo is Map
              ? verificationInfo['verified'] as bool? ?? false
              : false),
      driverId: json['driverId'] as String?,
      entrepreneurStatus: json['entrepreneurStatus'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlateNumber: json['vehiclePlateNumber'] as String?,
    );
  }
}

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final User user;
  final String accessToken;
  final String refreshToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthResponse(
      user: User.fromJson(userJson),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class TokenResponse {
  const TokenResponse({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}
