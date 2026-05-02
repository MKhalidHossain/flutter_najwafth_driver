import 'package:flutter/material.dart';
import 'package:flutter_najwafth_driver/app/app_router.dart';
import 'package:flutter_najwafth_driver/core/core.dart';
import 'package:flutter_najwafth_driver/features/auth/presentation/widgets/auth_ui.dart';

final class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({required this.email, super.key});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

final class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
    final error = Validators.minLength(value, 6, label: 'Confirm password');
    if (error != null) {
      return error;
    }

    if (value!.trim() != _newPasswordController.text.trim()) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (route) => false,
      arguments: SignInRouteArgs(
        prefilledEmail: widget.email,
        successMessage: 'Password updated. Sign in with your new password.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverScaffold(
      child: Form(
        key: _formKey,
        child: DriverScrollableBody(
          children: [
            const SizedBox(height: 72),
            const DriverBrandHeader(width: 240),
            const SizedBox(height: 24),
            const DriverIntro(
              title: 'Reset New password',
              subtitle: 'Enter your new password and confirm password',
              centered: true,
            ),
            const SizedBox(height: 24),
            DriverTextField(
              controller: _newPasswordController,
              label: 'New Password',
              hintText: 'Enter your Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureNewPassword,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.minLength(value, 6, label: 'New password'),
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
              label: 'Confirm Password',
              hintText: 'Enter Confirm Password',
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
            DriverPrimaryButton(label: 'Continue', onPressed: _submit),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
