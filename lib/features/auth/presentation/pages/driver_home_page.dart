import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/application/app_session_controller.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  String _vehicleLabel(DriverVehicleType type) {
    return switch (type) {
      DriverVehicleType.bike => 'Bike courier',
      DriverVehicleType.electricBike => 'Electric bike courier',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionControllerProvider);

    return DriverScaffold(
      child: DriverScrollableBody(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
        children: [
          const SizedBox(height: 18),
          Row(
            children: [
              const DriverBrandHeader(width: 185),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(appSessionControllerProvider.notifier)
                      .signOut();
                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.signIn,
                    (route) => false,
                    arguments: SignInRouteArgs(
                      prefilledEmail: session.rememberedEmail ?? session.email,
                    ),
                  );
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.link,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'Welcome back, ${session.userName ?? 'Driver'}',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your onboarding and driver profile are ready. This page gives you a simple working destination after sign-in while you connect the real backend later.',
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppColors.subtitle,
            ),
          ),
          const SizedBox(height: 28),
          _InfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: session.email ?? 'Not available',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.two_wheeler_rounded,
            title: 'Vehicle',
            value: _vehicleLabel(session.vehicleType),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.badge_outlined,
            title: 'Driver ID',
            value: session.driverId ?? 'Pending',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.verified_user_outlined,
            title: 'Status',
            value: session.entrepreneurStatus ?? 'Pending',
          ),
          const SizedBox(height: 30),
          DriverPrimaryButton(
            label: 'Edit Profile Again',
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.completeProfile,
                arguments: CompleteProfileRouteArgs(
                  prefilledName: session.userName,
                  email: session.email,
                  phoneNumber: session.phoneNumber,
                  shouldReturnToSignIn: false,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

final class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.sky,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
