import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({
    super.key,
    this.prefilledName,
    this.email,
    this.phoneNumber,
    this.shouldReturnToSignIn = true,
  });

  final String? prefilledName;
  final String? email;
  final String? phoneNumber;
  final bool shouldReturnToSignIn;

  @override
  ConsumerState<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

final class _CompleteProfilePageState
    extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _driverIdController;
  late final TextEditingController _entrepreneurStatusController;
  late final TextEditingController _plateNumberController;
  late DriverVehicleType _selectedVehicleType;
  late DriverAvatarPreset _avatarPreset;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionControllerProvider);
    _driverIdController = TextEditingController(text: session.driverId);
    _entrepreneurStatusController = TextEditingController(
      text: session.entrepreneurStatus,
    );
    _plateNumberController = TextEditingController(
      text: session.vehiclePlateNumber,
    );
    _selectedVehicleType = session.vehicleType;
    _avatarPreset = session.avatarPreset;
  }

  @override
  void dispose() {
    _driverIdController.dispose();
    _entrepreneurStatusController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarPreset() async {
    final selectedPreset = await showModalBottomSheet<DriverAvatarPreset>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a profile style',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sky,
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: const Text('Use initials avatar'),
                  onTap: () {
                    Navigator.of(context).pop(DriverAvatarPreset.initials);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sky,
                    child: Icon(
                      Icons.pedal_bike_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Use bike badge'),
                  onTap: () {
                    Navigator.of(context).pop(DriverAvatarPreset.bicycle);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sky,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Use books badge'),
                  onTap: () {
                    Navigator.of(context).pop(DriverAvatarPreset.books);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3EFEA),
                    child: Icon(Icons.close_rounded, color: AppColors.subtitle),
                  ),
                  title: const Text('Clear selection'),
                  onTap: () {
                    Navigator.of(context).pop(DriverAvatarPreset.none);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedPreset != null) {
      setState(() => _avatarPreset = selectedPreset);
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final driverId = _driverIdController.text.trim();
    final entrepreneurStatus = _entrepreneurStatusController.text.trim();
    final vehiclePlateNumber = _plateNumberController.text.trim();

    final result = await ref
        .read(userApiProvider)
        .updateCurrentUser(
          FormData.fromMap({
            'driverId': driverId,
            'entrepreneurStatus': entrepreneurStatus,
            'vehicleType': _selectedVehicleType.name,
            'vehiclePlateNumber': vehiclePlateNumber,
          }),
        );

    if (!mounted) {
      return;
    }

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }

    await ref
        .read(appSessionControllerProvider.notifier)
        .completeProfile(
          vehicleType: _selectedVehicleType,
          driverId: driverId,
          entrepreneurStatus: entrepreneurStatus,
          vehiclePlateNumber: vehiclePlateNumber,
          avatarPreset: _avatarPreset,
        );

    if (!mounted) {
      return;
    }

    if (widget.shouldReturnToSignIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.signIn,
        (route) => false,
        arguments: SignInRouteArgs(
          prefilledEmail: widget.email,
          successMessage: 'Profile saved. Sign in to continue.',
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            Text(
              'Complete Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Just a few more details to get you on the road',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: AppColors.subtitle,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _pickAvatarPreset,
                    child: Container(
                      width: 176,
                      height: 176,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF3F1EE),
                        border: Border.all(
                          color: const Color(0xFFCFDCE8),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _AvatarPreview(
                          name: widget.prefilledName,
                          preset: _avatarPreset,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: _pickAvatarPreset,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x246B97C2),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const DriverFieldLabel("Driver's Use"),
            const SizedBox(height: 12),
            Row(
              children: [
                DriverVehicleCard(
                  label: 'Bike',
                  icon: Icons.pedal_bike_rounded,
                  selected: _selectedVehicleType == DriverVehicleType.bike,
                  onTap: () {
                    setState(
                      () => _selectedVehicleType = DriverVehicleType.bike,
                    );
                  },
                ),
                const SizedBox(width: 16),
                DriverVehicleCard(
                  label: 'Electric Bike',
                  icon: Icons.electric_bike_rounded,
                  selected:
                      _selectedVehicleType == DriverVehicleType.electricBike,
                  onTap: () {
                    setState(
                      () =>
                          _selectedVehicleType = DriverVehicleType.electricBike,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            DriverTextField(
              controller: _driverIdController,
              label: 'ID',
              hintText: 'xxxxxxxx',
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.required(value, label: 'ID'),
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _entrepreneurStatusController,
              label: 'Entrepreneur Status',
              hintText: 'xxxxxxxx',
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.required(value, label: 'Entrepreneur status'),
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _plateNumberController,
              label: 'Vehicle Plate Number (Optional)',
              hintText: 'ABC-123',
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 30),
            DriverPrimaryButton(
              label: 'Save & Continue',
              isLoading: _isSaving,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

final class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.name, required this.preset});

  final String? name;
  final DriverAvatarPreset preset;

  @override
  Widget build(BuildContext context) {
    switch (preset) {
      case DriverAvatarPreset.initials:
        final initial = (name?.trim().isNotEmpty ?? false)
            ? name!.trim().characters.first.toUpperCase()
            : 'D';
        return Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.sky,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        );
      case DriverAvatarPreset.bicycle:
        return const Icon(
          Icons.pedal_bike_rounded,
          size: 70,
          color: AppColors.primary,
        );
      case DriverAvatarPreset.books:
        return const Icon(
          Icons.menu_book_rounded,
          size: 70,
          color: AppColors.primary,
        );
      case DriverAvatarPreset.none:
        return const Icon(
          Icons.add_photo_alternate_outlined,
          size: 72,
          color: AppColors.primary,
        );
    }
  }
}
