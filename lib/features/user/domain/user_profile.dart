import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';

final class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.bio,
    required this.address,
    this.gender,
    this.dob,
    this.age,
    this.avatarUrl,
    this.vehicleType,
    this.vehiclePlateNumber,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String bio;
  final String address;
  final String? gender;
  final DateTime? dob;
  final int? age;
  final String? avatarUrl;
  final String? vehicleType;
  final String? vehiclePlateNumber;

  factory UserProfile.fromJson(JsonMap json) {
    final avatar = json['avatar'];

    return UserProfile(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String?,
      dob: _readDate(json['dob']),
      age: _readIntOrNull(json['age']),
      avatarUrl: avatar is JsonMap
          ? avatar['url'] as String?
          : avatar is String
          ? avatar
          : json['avatarUrl'] as String? ?? json['profileImage'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlateNumber: json['vehiclePlateNumber'] as String?,
    );
  }
}

DateTime? _readDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

int? _readIntOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
