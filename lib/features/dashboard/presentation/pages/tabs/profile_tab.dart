import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/notifications/data/notification_api.dart';
import 'package:flutter_najwafth_driver/features/user/data/user_api.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _isLoading = false;
  AppFailure? _failure;
  UserProfile? _profile;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _failure = null;
    });

    final profileRequest = ref.read(userApiProvider).getCurrentUser();
    final unreadCountRequest = ref
        .read(notificationApiProvider)
        .getUnreadNotificationCount();

    final profileResult = await profileRequest;
    final unreadCountResult = await unreadCountRequest;

    if (!mounted) return;

    setState(() {
      _profile = profileResult.dataOrNull;
      _failure = profileResult.failureOrNull;
      _unreadNotificationCount =
          unreadCountResult.dataOrNull ?? _unreadNotificationCount;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionControllerProvider);
    final displayName = _profile?.name.isNotEmpty == true
        ? _profile!.name
        : session.userName ?? context.l10n.tr('Driver');
    final email = _profile?.email.isNotEmpty == true
        ? _profile!.email
        : session.email;
    final phone = _profile?.phone.isNotEmpty == true
        ? _profile!.phone
        : session.phoneNumber;
    final role = _profile?.role.isNotEmpty == true ? _profile!.role : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(
              session,
              displayName,
              email,
              phone,
              role,
              _profile?.avatarUrl,
            ),
            if (_failure != null && _profile == null) _buildErrorBanner(),
            const SizedBox(height: 16),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(
    AppSessionState session,
    String displayName,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
  ) {
    final backendVehicleType = _readVehicleType(_profile?.vehicleType);
    final vehicleType = backendVehicleType ?? session.vehicleType;
    final vehicleLabel = vehicleType == DriverVehicleType.electricBike
        ? context.l10n.tr('Electric Bike')
        : context.l10n.tr('Bike');
    final vehicleIcon = vehicleType == DriverVehicleType.electricBike
        ? Icons.electric_bike
        : Icons.directions_bike;
    final driverId = _profile?.driverId?.isNotEmpty == true
        ? _profile!.driverId!
        : session.driverId?.isNotEmpty == true
        ? session.driverId!
        : 'N/A';
    final entrepreneurStatus = _profile?.entrepreneurStatus?.isNotEmpty == true
        ? _profile!.entrepreneurStatus!
        : session.entrepreneurStatus?.isNotEmpty == true
        ? session.entrepreneurStatus!
        : 'N/A';
    final plateNumber = _profile?.vehiclePlateNumber?.isNotEmpty == true
        ? _profile!.vehiclePlateNumber!
        : session.vehiclePlateNumber?.isNotEmpty == true
        ? session.vehiclePlateNumber!
        : 'N/A';

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F7FC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.border,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 26,
                          )
                        : null,
                  ),
                  if (_isLoading)
                    const Positioned.fill(
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.black12,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.title,
                      ),
                    ),
                    if (email?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ],
                    if (phone?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (role?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          context.l10n.tr('Driver Details'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    // IconButton(
                    //   tooltip: context.l10n.tr('Edit driver details'),
                    //   onPressed: () async {
                    //     await Navigator.pushNamed(
                    //       context,
                    //       AppRoutes.editProfile,
                    //     );
                    //     if (mounted) _loadProfile();
                    //   },
                    //   icon: const Icon(
                    //     Icons.edit_outlined,
                    //     color: AppColors.primary,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DriverDetailLine(
                            label: context.l10n.tr('Vehicle'),
                            value: vehicleLabel,
                          ),
                          const SizedBox(height: 12),
                          _DriverDetailLine(
                            label: context.l10n.tr('ID'),
                            value: driverId,
                          ),
                          const SizedBox(height: 12),
                          _DriverDetailLine(
                            label: context.l10n.tr('Status'),
                            value: entrepreneurStatus,
                          ),
                          const SizedBox(height: 12),
                          _DriverDetailLine(
                            label: context.l10n.tr('Plate'),
                            value: plateNumber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        children: [
                          Icon(vehicleIcon, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text(
                            vehicleLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.subtitle),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _failure!.message,
              style: const TextStyle(fontSize: 13, color: AppColors.subtitle),
            ),
          ),
          TextButton(
            onPressed: _loadProfile,
            child: Text(
              context.l10n.tr('Retry'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.edit_outlined,
          title: context.l10n.tr('Edit Profile'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
        ),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: context.l10n.tr('Change Password'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: context.l10n.tr('About App'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp),
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          title: context.l10n.tr('Privacy Policy'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
        ),
        _buildMenuItem(
          icon: Icons.block,
          title: context.l10n.tr('Terms & Conditions'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.termsConditions),
        ),
        _buildMenuItem(
          icon: Icons.language,
          title: context.l10n.tr('Choose Language'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.chooseLanguage),
        ),
        _buildMenuItem(
          icon: Icons.notifications_none,
          title: context.l10n.tr('Notifications'),
          trailing: _NotificationTrailing(count: _unreadNotificationCount),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        _buildMenuItem(
          icon: Icons.person_remove_outlined,
          title: context.l10n.tr('Delete Account'),
          titleColor: const Color(0xFFB42318),
          iconColor: const Color(0xFFB42318),
          onTap: () => _showDeleteAccountDialog(context),
        ),
        _buildMenuItem(
          icon: Icons.logout,
          title: context.l10n.tr('Log Out'),
          titleColor: AppColors.primary,
          iconColor: AppColors.primary,
          onTap: () => _showLogoutDialog(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.tr('Are you sure you want to log out?'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.l10n.tr('Cancel'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _LogoutButton(
                        onConfirm: () async {
                          Navigator.pop(dialogContext);
                          // signOut: calls POST /api/v1/auth/logout, clears
                          // access/refresh tokens and signed-in flag from storage.
                          await ref
                              .read(appSessionControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.signIn,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(context.l10n.tr('Delete Account')),
        content: Text(
          context.l10n.tr(
            'Your account and personal profile data will be permanently deleted. This action cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.tr('Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.tr('Delete Account')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ref.read(userApiProvider).deleteCurrentUser();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }

    await ref.read(appSessionControllerProvider.notifier).clearLocalSession();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (route) => false,
      arguments: SignInRouteArgs(
        successMessage: context.l10n.tr('Your account has been deleted.'),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color titleColor = AppColors.title,
    Color iconColor = AppColors.title,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          trailing:
              trailing ?? Icon(Icons.chevron_right, color: AppColors.border),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Color(0xFFF0F0F0), height: 1),
        ),
      ],
    );
  }
}

class _DriverDetailLine extends StatelessWidget {
  const _DriverDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTrailing extends StatelessWidget {
  const _NotificationTrailing({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return Icon(Icons.chevron_right, color: AppColors.border);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 24),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count > 99 ? '99+' : '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: AppColors.border),
      ],
    );
  }
}

// Separate stateful widget to manage loading state for the logout button
// without rebuilding the whole dialog.
class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              await widget.onConfirm();
            },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              context.l10n.tr('Log Out'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
    );
  }
}
