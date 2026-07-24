import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_najwafth_driver/core/theme/app_theme.dart';
import 'package:flutter_najwafth_driver/core/utils/validators.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  static const _genderOptions = ['Male', 'Female', 'Other'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPickingAvatar = false;
  String? _errorMessage;
  String? _avatarUrl;
  XFile? _selectedAvatar;
  String? _selectedGender;
  late DriverVehicleType _vehicleType;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionControllerProvider);
    _vehicleType = session.vehicleType;
    _vehiclePlateController.text = session.vehiclePlateNumber ?? '';
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(userApiProvider).getCurrentUser();

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      });
      return;
    }

    _fillForm(result.dataOrNull!);
    setState(() => _isLoading = false);
  }

  void _fillForm(UserProfile profile) {
    final session = ref.read(appSessionControllerProvider);
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _bioController.text = profile.bio;
    _selectedGender = _readGender(profile.gender);
    _genderController.text = _selectedGender ?? '';
    _dobController.text = profile.dob?.toIso8601String().split('T').first ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _addressController.text = profile.address;
    _avatarUrl = profile.avatarUrl;
    _selectedAvatar = null;

    final backendVehicleType = _readVehicleType(profile.vehicleType);
    _vehicleType = backendVehicleType ?? session.vehicleType;
    _vehiclePlateController.text =
        profile.vehiclePlateNumber ?? session.vehiclePlateNumber ?? '';
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSaving) return;

    setState(() => _isSaving = true);

    final fields = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'gender': _genderController.text.trim(),
      'dob': _dobController.text.trim(),
      'address': _addressController.text.trim(),
    };

    final age = int.tryParse(_ageController.text.trim());
    if (age != null) fields['age'] = age;

    if (_selectedAvatar != null) {
      fields['avatar'] = await MultipartFile.fromFile(
        _selectedAvatar!.path,
        filename: _selectedAvatar!.name,
      );
    }

    final formData = FormData.fromMap(fields);

    final result = await ref.read(userApiProvider).updateCurrentUser(formData);

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }

    final updatedProfile = result.dataOrNull!;
    await ref
        .read(appSessionControllerProvider.notifier)
        .updateCachedProfile(
          name: updatedProfile.name,
          email: updatedProfile.email,
          phone: updatedProfile.phone,
        );

    // TODO: PATCH /api/v1/driver/profile is needed for vehicle details.
    await ref
        .read(appSessionControllerProvider.notifier)
        .updateVehicleDetailsLocally(
          vehicleType:
              _readVehicleType(updatedProfile.vehicleType) ?? _vehicleType,
          vehiclePlateNumber:
              updatedProfile.vehiclePlateNumber ??
              _vehiclePlateController.text.trim(),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
    Navigator.pop(context);
  }

  Future<void> _pickAvatar() async {
    if (_isPickingAvatar) return;

    setState(() => _isPickingAvatar = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null || !mounted) return;

      setState(() => _selectedAvatar = image);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = _avatarPickerErrorMessage(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picker is not ready. Please rebuild the app.'),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
    } finally {
      if (mounted) setState(() => _isPickingAvatar = false);
    }
  }

  String _avatarPickerErrorMessage(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = error.message?.toLowerCase() ?? '';
    if (code.contains('denied') || message.contains('denied')) {
      return 'Photo access is denied. Enable Photos permission in Settings.';
    }
    if (code == 'already_active') return 'Image picker is already open.';
    if (code.contains('plugin') ||
        message.contains('missingplugin') ||
        message.contains('unable to establish connection on channel') ||
        message.contains('image_picker_ios')) {
      return 'Image picker is not ready. Please rebuild the app.';
    }
    return error.message?.isNotEmpty == true
        ? error.message!
        : 'Could not pick image.';
  }

  DriverVehicleType? _readVehicleType(String? value) {
    return switch (value) {
      'electricBike' ||
      'electric_bike' ||
      'E-Bike' ||
      'Electric Bike' => DriverVehicleType.electricBike,
      'bike' || 'Bike' => DriverVehicleType.bike,
      _ => null,
    };
  }

  String? _readGender(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;

    for (final option in _genderOptions) {
      if (option.toLowerCase() == normalized) return option;
    }

    return 'Other';
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
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadProfile)
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarImageProvider,
                      backgroundColor: AppColors.border,
                      child: _avatarImageProvider == null
                          ? const Icon(
                              Icons.person,
                              size: 44,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.required(value, label: 'Name'),
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.required(value, label: 'Phone'),
              decoration: const InputDecoration(hintText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Bio'),
            ),
            const SizedBox(height: 16),
            ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                decoration: const InputDecoration(hintText: 'Gender'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: _genderOptions
                    .map(
                      (gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _genderController.text = value ?? '';
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Date of Birth'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty || int.tryParse(text) != null) return null;
                return 'Age must be a number.';
              },
              decoration: const InputDecoration(hintText: 'Age'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Address'),
            ),
            const SizedBox(height: 16),
            ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<DriverVehicleType>(
                initialValue: _vehicleType,
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                decoration: const InputDecoration(hintText: 'Vehicle Type'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: const [
                  DropdownMenuItem(
                    value: DriverVehicleType.bike,
                    child: Text('Bike'),
                  ),
                  DropdownMenuItem(
                    value: DriverVehicleType.electricBike,
                    child: Text('Electric Bike'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _vehicleType = value);
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehiclePlateController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Vehicle Plate'),
              onFieldSubmitted: (_) => _saveProfile(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? get _avatarImageProvider {
    final selectedAvatar = _selectedAvatar;
    if (selectedAvatar != null) return FileImage(File(selectedAvatar.path));

    final avatarUrl = _avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    return NetworkImage(avatarUrl);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtitle),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
