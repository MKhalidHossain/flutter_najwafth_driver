import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/data/auth_repository.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({required this.email, required this.otp, super.key});

  final String email;
  final String otp;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

final class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = context.l10n;
    final error = Validators.minLength(
      value,
      6,
      label: l10n.tr('Confirm Password'),
      l10n: l10n,
    );
    if (error != null) return error;

    if (value!.trim() != _newPasswordController.text.trim()) {
      return l10n.tr('Passwords do not match.');
    }
    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          email: widget.email,
          otp: widget.otp,
          password: _newPasswordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tr(failure.message))));
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (route) => false,
      arguments: SignInRouteArgs(
        prefilledEmail: widget.email,
        successMessage: context.l10n.tr(
          'Password updated. Sign in with your new password.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          children: [
            const SizedBox(height: 72),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            DriverIntro(
              title: l10n.tr('Reset New password'),
              subtitle: l10n.tr('Enter your new password and confirm password'),
              centered: true,
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _newPasswordController,
              label: l10n.tr('New Password'),
              hintText: l10n.tr('Enter your Password'),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureNewPassword,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.minLength(
                value,
                6,
                label: l10n.tr('New Password'),
                l10n: l10n,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DriverTextField(
              controller: _confirmPasswordController,
              label: l10n.tr('Confirm Password'),
              hintText: l10n.tr('Enter Confirm Password'),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 24),
            DriverPrimaryButton(
              label: l10n.tr('Continue'),
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
