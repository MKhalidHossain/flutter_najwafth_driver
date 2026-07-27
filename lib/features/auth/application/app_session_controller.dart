import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/data/auth_repository.dart';
import 'package:flutter_najwafth_driver/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appSessionControllerProvider =
    NotifierProvider<AppSessionController, AppSessionState>(
      AppSessionController.new,
    );

enum DriverVehicleType { bike, electricBike }

enum DriverAvatarPreset { none, initials, bicycle, books }

final class AppSessionState {
  const AppSessionState({
    required this.onboardingCompleted,
    required this.isSignedIn,
    required this.profileCompleted,
    required this.rememberMe,
    required this.vehicleType,
    required this.avatarPreset,
    this.rememberedEmail,
    this.email,
    this.userName,
    this.phoneNumber,
    this.driverId,
    this.entrepreneurStatus,
    this.vehiclePlateNumber,
    this.isLoading = false,
  });

  static const _sentinel = Object();

  final bool onboardingCompleted;
  final bool isSignedIn;
  final bool profileCompleted;
  final bool rememberMe;
  final String? rememberedEmail;
  final String? email;
  final String? userName;
  final String? phoneNumber;
  final String? driverId;
  final String? entrepreneurStatus;
  final String? vehiclePlateNumber;
  final DriverVehicleType vehicleType;
  final DriverAvatarPreset avatarPreset;
  final bool isLoading;

  bool get hasRequiredDriverDetails =>
      driverId?.trim().isNotEmpty == true &&
      entrepreneurStatus?.trim().isNotEmpty == true;

  bool get shouldShowCompleteProfile =>
      !profileCompleted && !hasRequiredDriverDetails;

  AppSessionState copyWith({
    bool? onboardingCompleted,
    bool? isSignedIn,
    bool? profileCompleted,
    bool? rememberMe,
    Object? rememberedEmail = _sentinel,
    Object? email = _sentinel,
    Object? userName = _sentinel,
    Object? phoneNumber = _sentinel,
    Object? driverId = _sentinel,
    Object? entrepreneurStatus = _sentinel,
    Object? vehiclePlateNumber = _sentinel,
    DriverVehicleType? vehicleType,
    DriverAvatarPreset? avatarPreset,
    bool? isLoading,
  }) {
    return AppSessionState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      rememberMe: rememberMe ?? this.rememberMe,
      rememberedEmail: rememberedEmail == _sentinel
          ? this.rememberedEmail
          : rememberedEmail as String?,
      email: email == _sentinel ? this.email : email as String?,
      userName: userName == _sentinel ? this.userName : userName as String?,
      phoneNumber: phoneNumber == _sentinel
          ? this.phoneNumber
          : phoneNumber as String?,
      driverId: driverId == _sentinel ? this.driverId : driverId as String?,
      entrepreneurStatus: entrepreneurStatus == _sentinel
          ? this.entrepreneurStatus
          : entrepreneurStatus as String?,
      vehiclePlateNumber: vehiclePlateNumber == _sentinel
          ? this.vehiclePlateNumber
          : vehiclePlateNumber as String?,
      vehicleType: vehicleType ?? this.vehicleType,
      avatarPreset: avatarPreset ?? this.avatarPreset,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final class AppSessionController extends Notifier<AppSessionState> {
  static const _onboardingKey = 'driver.onboarding.completed';
  static const _signedInKey = 'driver.auth.signed_in';
  static const _rememberMeKey = 'driver.auth.remember_me';
  static const _rememberedEmailKey = 'driver.auth.remembered_email';
  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _emailKey = 'driver.profile.email';
  static const _nameKey = 'driver.profile.name';
  static const _phoneKey = 'driver.profile.phone';
  static const _profileCompletedKey = 'driver.profile.completed';
  static const _driverIdKey = 'driver.profile.driver_id';
  static const _entrepreneurStatusKey = 'driver.profile.entrepreneur_status';
  static const _vehiclePlateNumberKey = 'driver.profile.vehicle_plate_number';
  static const _vehicleTypeKey = 'driver.profile.vehicle_type';
  static const _avatarPresetKey = 'driver.profile.avatar_preset';

  @override
  AppSessionState build() {
    final storage = ref.watch(keyValueStorageProvider);

    return AppSessionState(
      onboardingCompleted: storage.readBool(_onboardingKey) ?? false,
      isSignedIn: storage.readBool(_signedInKey) ?? false,
      profileCompleted: storage.readBool(_profileCompletedKey) ?? false,
      rememberMe: storage.readBool(_rememberMeKey) ?? false,
      rememberedEmail: storage.readString(_rememberedEmailKey),
      email: storage.readString(_emailKey),
      userName: storage.readString(_nameKey),
      phoneNumber: storage.readString(_phoneKey),
      driverId: storage.readString(_driverIdKey),
      entrepreneurStatus: storage.readString(_entrepreneurStatusKey),
      vehiclePlateNumber: storage.readString(_vehiclePlateNumberKey),
      vehicleType: _readVehicleType(storage.readString(_vehicleTypeKey)),
      avatarPreset: _readAvatarPreset(storage.readString(_avatarPresetKey)),
    );
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await ref.read(keyValueStorageProvider).writeBool(_onboardingKey, true);
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    final failure = result.failureOrNull;
    if (failure != null) {
      state = state.copyWith(isLoading: false);
      return failure.message;
    }

    final auth = result.dataOrNull!;
    if (auth.user.role != 'driver') {
      state = state.copyWith(isLoading: false);
      return 'This account is not registered as a driver.';
    }

    final storage = ref.read(keyValueStorageProvider);
    final profileCompleted = _hasRequiredDriverDetails(auth.user);
    await storage.writeString(_accessTokenKey, auth.accessToken);
    await storage.writeString(_refreshTokenKey, auth.refreshToken);
    await storage.writeBool(_signedInKey, true);
    await storage.writeBool(_profileCompletedKey, profileCompleted);
    await storage.writeBool(_rememberMeKey, rememberMe);
    await storage.writeString(_emailKey, auth.user.email);
    await storage.writeString(_nameKey, auth.user.fullName);
    await storage.writeString(_phoneKey, auth.user.phone);
    await _writeOptionalString(storage, _driverIdKey, auth.user.driverId);
    await _writeOptionalString(
      storage,
      _entrepreneurStatusKey,
      auth.user.entrepreneurStatus,
    );
    await _writeOptionalString(
      storage,
      _vehiclePlateNumberKey,
      auth.user.vehiclePlateNumber,
    );
    await _writeOptionalString(storage, _vehicleTypeKey, auth.user.vehicleType);
    if (rememberMe) {
      await storage.writeString(_rememberedEmailKey, auth.user.email);
    } else {
      await storage.remove(_rememberedEmailKey);
    }

    state = state.copyWith(
      isSignedIn: true,
      profileCompleted: profileCompleted,
      rememberMe: rememberMe,
      rememberedEmail: rememberMe ? auth.user.email : null,
      email: auth.user.email,
      userName: auth.user.fullName,
      phoneNumber: auth.user.phone,
      driverId: _emptyToNull(auth.user.driverId),
      entrepreneurStatus: _emptyToNull(auth.user.entrepreneurStatus),
      vehiclePlateNumber: _emptyToNull(auth.user.vehiclePlateNumber),
      vehicleType: _readVehicleType(auth.user.vehicleType),
      isLoading: false,
    );
    return null;
  }

  Future<String?> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ref
        .read(authRepositoryProvider)
        .register(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          confirmPassword: confirmPassword,
        );

    final failure = result.failureOrNull;
    if (failure != null) {
      state = state.copyWith(isLoading: false);
      return failure.message;
    }

    final auth = result.dataOrNull!;
    if (auth.user.role != 'driver') {
      state = state.copyWith(isLoading: false);
      return 'This account is not registered as a driver.';
    }

    final storage = ref.read(keyValueStorageProvider);
    final profileCompleted = _hasRequiredDriverDetails(auth.user);
    await storage.writeString(_accessTokenKey, auth.accessToken);
    await storage.writeString(_refreshTokenKey, auth.refreshToken);
    await storage.writeBool(_signedInKey, true);
    await storage.writeBool(_profileCompletedKey, profileCompleted);
    await storage.writeString(_emailKey, auth.user.email);
    await storage.writeString(_nameKey, auth.user.fullName);
    await storage.writeString(_phoneKey, auth.user.phone);
    await _writeOptionalString(storage, _driverIdKey, auth.user.driverId);
    await _writeOptionalString(
      storage,
      _entrepreneurStatusKey,
      auth.user.entrepreneurStatus,
    );
    await _writeOptionalString(
      storage,
      _vehiclePlateNumberKey,
      auth.user.vehiclePlateNumber,
    );
    await _writeOptionalString(storage, _vehicleTypeKey, auth.user.vehicleType);

    state = state.copyWith(
      isSignedIn: true,
      profileCompleted: profileCompleted,
      email: auth.user.email,
      userName: auth.user.fullName,
      phoneNumber: auth.user.phone,
      driverId: _emptyToNull(auth.user.driverId),
      entrepreneurStatus: _emptyToNull(auth.user.entrepreneurStatus),
      vehiclePlateNumber: _emptyToNull(auth.user.vehiclePlateNumber),
      vehicleType: _readVehicleType(auth.user.vehicleType),
      isLoading: false,
    );
    return null;
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on Object {
      // Local sign-out should still complete if the backend logout request
      // fails because the token is already invalid or the network is down.
    } finally {
      await clearLocalSession();
    }
  }

  Future<void> clearLocalSession() async {
    final storage = ref.read(keyValueStorageProvider);
    await storage.remove(_accessTokenKey);
    await storage.remove(_refreshTokenKey);
    await storage.remove(_emailKey);
    await storage.remove(_nameKey);
    await storage.remove(_phoneKey);
    await storage.remove(_driverIdKey);
    await storage.remove(_entrepreneurStatusKey);
    await storage.remove(_vehiclePlateNumberKey);
    await storage.remove(_vehicleTypeKey);
    await storage.remove(_avatarPresetKey);
    await storage.writeBool(_signedInKey, false);
    await storage.writeBool(_profileCompletedKey, false);
    state = state.copyWith(
      isSignedIn: false,
      profileCompleted: false,
      email: null,
      userName: null,
      phoneNumber: null,
      driverId: null,
      entrepreneurStatus: null,
      vehiclePlateNumber: null,
      vehicleType: DriverVehicleType.bike,
      avatarPreset: DriverAvatarPreset.none,
    );
  }

  Future<void> updateCachedProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final storage = ref.read(keyValueStorageProvider);
    await storage.writeString(_nameKey, name);
    await storage.writeString(_emailKey, email);
    await storage.writeString(_phoneKey, phone);

    state = state.copyWith(userName: name, email: email, phoneNumber: phone);
  }

  Future<void> updateVehicleDetailsLocally({
    required DriverVehicleType vehicleType,
    String? vehiclePlateNumber,
  }) async {
    final trimmedPlate = vehiclePlateNumber?.trim();
    final storage = ref.read(keyValueStorageProvider);
    await storage.writeString(_vehicleTypeKey, vehicleType.name);

    if (trimmedPlate == null || trimmedPlate.isEmpty) {
      await storage.remove(_vehiclePlateNumberKey);
    } else {
      await storage.writeString(_vehiclePlateNumberKey, trimmedPlate);
    }

    state = state.copyWith(
      vehicleType: vehicleType,
      vehiclePlateNumber: trimmedPlate == null || trimmedPlate.isEmpty
          ? null
          : trimmedPlate,
    );
  }

  Future<void> completeProfile({
    required DriverVehicleType vehicleType,
    required String driverId,
    required String entrepreneurStatus,
    required DriverAvatarPreset avatarPreset,
    String? vehiclePlateNumber,
  }) async {
    final trimmedDriverId = driverId.trim();
    final trimmedEntrepreneurStatus = entrepreneurStatus.trim();
    final trimmedPlate = vehiclePlateNumber?.trim();

    state = state.copyWith(
      profileCompleted: true,
      vehicleType: vehicleType,
      driverId: trimmedDriverId,
      entrepreneurStatus: trimmedEntrepreneurStatus,
      vehiclePlateNumber: trimmedPlate == null || trimmedPlate.isEmpty
          ? null
          : trimmedPlate,
      avatarPreset: avatarPreset,
    );

    final storage = ref.read(keyValueStorageProvider);
    await storage.writeBool(_profileCompletedKey, true);
    await storage.writeString(_driverIdKey, trimmedDriverId);
    await storage.writeString(
      _entrepreneurStatusKey,
      trimmedEntrepreneurStatus,
    );
    await storage.writeString(_vehicleTypeKey, vehicleType.name);
    await storage.writeString(_avatarPresetKey, avatarPreset.name);

    if (trimmedPlate == null || trimmedPlate.isEmpty) {
      await storage.remove(_vehiclePlateNumberKey);
    } else {
      await storage.writeString(_vehiclePlateNumberKey, trimmedPlate);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  DriverVehicleType _readVehicleType(String? rawValue) {
    return DriverVehicleType.values.firstWhere(
      (type) => type.name == rawValue,
      orElse: () => DriverVehicleType.bike,
    );
  }

  DriverAvatarPreset _readAvatarPreset(String? rawValue) {
    return DriverAvatarPreset.values.firstWhere(
      (preset) => preset.name == rawValue,
      orElse: () => DriverAvatarPreset.none,
    );
  }

  Future<void> _writeOptionalString(
    KeyValueStorage storage,
    String key,
    String? value,
  ) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await storage.remove(key);
      return;
    }

    await storage.writeString(key, trimmed);
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  bool _hasRequiredDriverDetails(User user) {
    return user.driverId?.trim().isNotEmpty == true &&
        user.entrepreneurStatus?.trim().isNotEmpty == true;
  }
}
